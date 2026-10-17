#!/usr/bin/env python3
"""boss_reach.py -- L1 of the BOSS lift (the JUNO's docs/JUNO_LIFT.md plan, pointed at this plugin): the plugin code a
PRODUCT reaches. The twin of tools/verify/juno_lift_reach.py: the booted plugin (boss_host.BossProc, from the boot
snapshot), a Unicorn BLOCK hook recording every executed instruction rva, every indirect call / jmp edge, every
import or host-object stub by name, under a drive over the product surface (boss_drive.py: setup, every model, every
parameter, state, presets). Harness = plumbing: it reruns the plugin, it reimplements nothing.

Output scratchpad/boss/boss_reach.json, the same keys as the JUNO census (functions, executed, indirect, stubs,
forms, func_insns, func_total), so tools/lift/* and jp8/tools/jp8_lift.py read it unchanged; and
scratchpad/boss/boss_executed.json (the executed rvas).

usage: python3 boss/tools/boss_reach.py [--models 0,4,6] [--quick]      (Unicorn only; never loads a ctypes port)
"""
import bisect
import collections
import json
import os
import sys
import time

import capstone
import pefile
from unicorn import UC_HOOK_BLOCK

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import boss_emu as B                                                    # noqa: E402
import boss_host as BH                                                  # noqa: E402

OUT = os.path.join(B.SNAP_DIR, 'boss_reach.json')
IB = B.IB
pe = pefile.PE(B.BIN, fast_load=True)
pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
FUNCS = sorted(e.struct.BeginAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION)
FUNC_END = {e.struct.BeginAddress: e.struct.EndAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION}
IMG = B.IMG
_text = [s for s in pe.sections if s.Name.startswith(b'.text')][0]
CLO, CHI = _text.VirtualAddress, _text.VirtualAddress + _text.Misc_VirtualSize
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)


def func_of(rva):
    i = bisect.bisect_right(FUNCS, rva) - 1
    if i >= 0 and rva < FUNC_END[FUNCS[i]]:
        return FUNCS[i]
    return None


class Census:
    """the block hook; attach() to any oracle instance (a deterministic boot: the same stubs at the same addresses)"""

    def __init__(self):
        self.executed = set()
        self.edges = collections.defaultdict(set)
        self.stubs = collections.Counter()
        self.prev_ind = None
        self.bcache = {}

    def _decode(self, rva):
        out = self.bcache.get(rva)
        if out is None:
            out = []
            a = rva
            while a < CHI:
                ins = next(md.disasm(bytes(IMG[a:a + 16]), IB + a), None)
                if ins is None:
                    break
                out.append((a, ins.mnemonic))
                m = ins.mnemonic
                if m[0] == 'j' or m in ('ret', 'retn', 'call') or m.startswith('loop'):
                    break
                a += ins.size
            self.bcache[rva] = out
        return out

    def attach(self, h):
        self.h = h

        def block(uc_, address, size, user):
            rva = address - IB
            if self.prev_ind is not None:
                self.edges[self.prev_ind].add(rva)
                self.prev_ind = None
            if B.STUB_BASE <= address < B.STUB_BASE + 0x10000:
                nm = h.stub2name.get(address)
                self.stubs[nm[1] if nm else '%#x' % address] += 1
                return
            if not (CLO <= rva < CHI):
                return
            last, last_rva = None, rva
            for a, mn in self._decode(rva):
                self.executed.add(a)
                last, last_rva = mn, a
            if last in ('call', 'jmp'):          # key the edge by the transfer instruction (playbook: interior targets)
                self.prev_ind = last_rva
        h.uc.hook_add(UC_HOOK_BLOCK, block)

    def nfuncs(self):
        return len({func_of(a) for a in self.executed} - {None})

    def write(self, out=OUT):
        funcs = sorted({f for f in (func_of(a) for a in self.executed) if f is not None})
        forms = collections.Counter()
        total = 0
        for f in funcs:
            for ins in md.disasm(bytes(IMG[f:FUNC_END[f]]), IB + f):
                forms[ins.mnemonic] += 1
                total += 1
        d = dict(functions=funcs, executed=len(self.executed),
                 func_insns=sum(1 for a in self.executed if func_of(a) is not None),
                 indirect={('%#x' % k): sorted('%#x' % t for t in v) for k, v in self.edges.items()},
                 stubs=dict(self.stubs), forms=dict(forms.most_common()), func_total=total)
        os.makedirs(os.path.dirname(out), exist_ok=True)
        json.dump(d, open(out + '.partial', 'w'))
        os.replace(out + '.partial', out)
        exe = os.path.join(os.path.dirname(out), 'boss_executed.json')
        json.dump(sorted(self.executed), open(exe + '.partial', 'w'))
        os.replace(exe + '.partial', exe)
        return d


def main():
    import boss_drive as D
    t0 = time.time()

    def log(m):
        sys.stderr.write('[%6.1fs] %s\n' % (time.time() - t0, m))
        sys.stderr.flush()
    args = sys.argv[1:]
    models = None
    if '--models' in args:
        models = [int(x) for x in args[args.index('--models') + 1].split(',')]
    c = Census()
    h = BH.BossProc.booted()
    c.attach(h)                    # setup runs UNDER the hook: the lifted init re-runs it
    D.run(h, models=models, quick='--quick' in args, log=lambda m: log('%s; functions %d' % (m, c.nfuncs())))
    d = c.write()
    print('BOSS L1 reach: %d functions, %d distinct instructions executed, %d instructions in those functions (%d forms), '
          '%d stubs; %s (%.0f s)' % (len(d['functions']), d['executed'], d['func_total'], len(d['forms']), len(d['stubs']),
                                     OUT, time.time() - t0))


if __name__ == '__main__':
    main()
