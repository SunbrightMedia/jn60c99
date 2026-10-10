#!/usr/bin/env python3
"""fw_map.py -- where the JUNO-60's wrapper functions sit in another Roland Cloud plugin (READ, static).

The Roland Cloud plugins share their VST3 wrapper: process(), the render driver, the rate converter, the
patch browser, the state calls. The JUNO-60 port has all of it ported and gated; another plugin reuses it
when its machine code is the same. This tool proves that per function and gives the address: each function
of the JUNO image named below and each function of the target image (both from their .pdata unwind
tables) is reduced to a normalized instruction stream -- rip-relative operands, branch and call targets,
and immediates inside the image masked; registers, displacements and every other constant kept -- and a
JUNO function maps to the target functions whose stream is EQUAL. A function with no unwind entry (a leaf)
is matched by its first instructions up to a branch, and so labelled.

  python3 jx3p/tools/fw_map.py [target.vst3]             the default table, against jx3p/truth/JX3P.vst3
  python3 jx3p/tools/fw_map.py target.vst3 name=RVA ...   any JUNO functions
  python3 jx3p/tools/fw_map.py --tooth                     a JUNO engine function (CWaveGen build) must
                                                           NOT map, and one changed byte must break a match
Exit 1 when a function of the default table has no match or more than one.
"""
import collections
import hashlib
import os
import sys

import pefile
from capstone import CS_ARCH_X86, CS_MODE_64, Cs
from capstone.x86 import X86_OP_IMM, X86_OP_MEM, X86_REG_RIP

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
JUNO = os.path.join(REPO, 'truth', 'JUNO60.vst3')
TARGET = os.path.join(REPO, 'jx3p', 'truth', 'JX3P.vst3')

# the JUNO wrapper functions the JUNO port's host layer rests on (docs/HOST_RENDER_LAYER.md, CLAIMS A24-A40)
TABLE = [
    ('GetPluginFactory', 0x348B40), ('createInstance (processor)', 0x349CA0),
    ('IComponent::getState', 0x349EA0), ('IComponent::setState', 0x34AAA0),
    ('IComponent::setActive', 0x34AA50), ('IAudioProcessor::process', 0x34A380),
    ('IAudioProcessor::setupProcessing', 0x3CB150), ('core initialize', 0x320420),
    ('core setup', 0x321AC0), ('render driver', 0x320B20), ('all sound off record', 0x3208E0),
    ('UI-timer drain', 0x320120), ('non-note MIDI path', 0x31F4E0), ('ManagePatch handler', 0x322E60),
    ('patch load', 0x335850), ('patch manager', 0x338090), ('render object lookup', 0x343A80),
    ('rate converter', 0x343E30), ('silence object', 0x344280), ('automatic engine rate', 0x34B260),
    ('engine setSampleRate', 0x3C7A20), ('arp init', 0x3BE2F0), ('window zoom getter', 0x2AA590),
    ('window fit', 0x312750),
]


def load(path):
    pe = pefile.PE(path, fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
    img = pe.get_memory_mapped_image()
    funcs = sorted({(e.struct.BeginAddress, e.struct.EndAddress)
                    for e in getattr(pe, 'DIRECTORY_ENTRY_EXCEPTION', [])})
    return img, pe.OPTIONAL_HEADER.ImageBase, funcs


MD = Cs(CS_ARCH_X86, CS_MODE_64)
MD.detail = True


def norm(img, ib, start, end, stop_at_branch=False):
    """the normalized instruction stream of [start, end). A displacement that points INTO the function
    (rva-based, `[r15 + rax + table]` with r15 = the image base) is a switch table MSVC places after
    the code: it is written as its offset from the function start, and the stream stops where the
    first table begins (the tables hold case addresses, which move with the code)."""
    tables = []
    for ins in MD.disasm(img[start:end], ib + start):
        for op in ins.operands:
            if op.type == X86_OP_MEM and op.mem.base != X86_REG_RIP and start < op.mem.disp < end:
                tables.append(op.mem.disp)
    stop = min(tables) if tables else end
    out = []
    for ins in MD.disasm(img[start:stop], ib + start):
        ops = []
        branch = ins.mnemonic.startswith('j') or ins.mnemonic in ('call', 'ret')
        for op in ins.operands:
            if op.type == X86_OP_MEM:
                d = op.mem.disp
                ops.append('[rip]' if op.mem.base == X86_REG_RIP else
                           '[%d,%d,%d,F+%x]' % (op.mem.base, op.mem.index, op.mem.scale, d - start)
                           if start < d < end else
                           '[%d,%d,%d,%d]' % (op.mem.base, op.mem.index, op.mem.scale, d))
            elif op.type == X86_OP_IMM:
                v = op.imm
                ops.append('A' if branch or ib <= v < ib + len(img) else str(v))
            else:
                ops.append(ins.reg_name(op.reg))
        out.append(ins.mnemonic + ' ' + ','.join(ops))
        if stop_at_branch and branch:
            break
    return out


def key(seq):
    return hashlib.sha1('\n'.join(seq).encode()).hexdigest()


class Map:
    def __init__(self, juno=JUNO, target=TARGET):
        self.j = load(juno)
        self.t = load(target)
        img, ib, funcs = self.t
        self.index = collections.defaultdict(list)
        for b, e in funcs:
            self.index[key(norm(img, ib, b, e))].append(b)
        self.jend = {b: e for b, e in self.j[2]}

    def find(self, rva):
        """(target rvas, how): equal normalized function, or for a leaf its prefix up to a branch"""
        img, ib, _ = self.j
        if rva in self.jend:
            return self.index.get(key(norm(img, ib, rva, self.jend[rva])), []), 'function'
        pre = norm(img, ib, rva, rva + 0x400, stop_at_branch=True)
        timg, tib, _ = self.t
        hits = []
        n = len(pre)
        for off in range(0, len(timg) - 16):           # leaf: scan every offset of the executable range
            if timg[off] != img[rva]:
                continue
            if norm(timg, tib, off, off + 0x400, stop_at_branch=True)[:n] == pre:
                hits.append(off)
                if len(hits) > 3:
                    break
        return hits, 'leaf prefix (%d instructions)' % n


def main():
    args = sys.argv[1:]
    if '--tooth' in args:
        m = Map()
        eng, _ = m.find(0x3C68D0)                      # the JUNO's CWaveGen BUILD: engine code, must not map
        jimg = bytearray(m.j[0])
        rva = 0x343A80
        jimg[rva + 4] ^= 0x01                          # one byte of the render-object lookup changed
        m.j = (bytes(jimg), m.j[1], m.j[2])
        broke, _ = m.find(rva)
        ok = not eng and not broke
        print('fw_map --tooth: engine BUILD maps to %s, a changed byte maps to %s: %s'
              % (eng or 'nothing', broke or 'nothing', 'BITES' if ok else 'DID NOT BITE'))
        return 0 if ok else 1
    target = args[0] if args and not '=' in args[0] else TARGET
    names = [(a.split('=')[0], int(a.split('=')[1], 16)) for a in args if '=' in a] or TABLE
    m = Map(target=target)
    bad = 0
    print('JUNO %d functions, target %s %d functions' % (len(m.j[2]), os.path.basename(target), len(m.t[2])))
    for name, rva in names:
        hits, how = m.find(rva)
        bad += len(hits) != 1
        print('  %-34s JUNO 0x%06X -> %s  (%s)' % (name, rva, ', '.join('0x%06X' % h for h in hits) or 'NO MATCH', how))
    print('fw_map: %d of %d functions map to exactly one target function' % (len(names) - bad, len(names)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
