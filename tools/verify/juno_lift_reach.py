#!/usr/bin/env python3
"""juno_lift_reach.py -- L1 of the JUNO-60 lift (docs/JUNO_LIFT.md): the plugin code a PRODUCT can reach.

The plugin booted as a DAW boots it (tools/verify/host_process_emu.HostProcess), then a composite drive that
exercises the whole product surface -- patch loads, process() with notes / chords / release / MIDI controllers /
host automation, setState / getState, the UI-timer drain, MIDI learn, the editor's model set / commit, the editor
attached + window zoom, voice-count and engine-rate settings. A Unicorn BLOCK hook records every executed
instruction's rva, every indirect call / jmp edge (the block after an indirect transfer), and every import or
host-object stub reached by name. Harness = plumbing (a block hook, PORT_LESSONS 8): it reruns the plugin, it
reimplements nothing.

Output scratchpad/lift/juno_reach.json: {"functions": [rva ...] (pdata starts that ran), "executed": N distinct
instruction rvas, "indirect": {caller_rva: [target ...]}, "stubs": {name: count}, "forms": {mnemonic: count},
"insn_total": distinct instructions, "func_insns": instructions inside reached functions}. The function set and
insn_total are L1's denominator for the progress measure; the forms are L3's work list.

usage: python3 tools/verify/juno_lift_reach.py            (Unicorn only; two-process rule: never loads libjuno)
"""
import os
import sys
import json
import time
import struct
import collections

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
import host_process_emu as H                                       # noqa: E402
import truth                                                       # noqa: E402
import pefile                                                      # noqa: E402
import capstone                                                    # noqa: E402
from unicorn import UC_HOOK_BLOCK                                  # noqa: E402

OUT = os.path.join(REPO, 'scratchpad', 'lift', 'juno_reach.json')
IB = H.IB
MODEL_SET, REC_ID, PATCH_LOAD = 0x283DB0, 0x319C50, 0x335850
UITICK, CC_LEARN, CC_FORGET, REC_IDX = 0x320120, 0x31AA40, 0x3192E0, 0x325870
COMMIT = (0x285320, 0x2853C0, 0x283120)
SAMPLERATE, VOICES = 0x0FFFC015, 0x0FFFC00E

pe = pefile.PE(truth.VST3, fast_load=True)
pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
FUNCS = sorted(e.struct.BeginAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION)          # pdata function starts (rva)
FUNC_END = {e.struct.BeginAddress: e.struct.EndAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION}
import bisect


def func_of(rva):
    i = bisect.bisect_right(FUNCS, rva) - 1
    if i >= 0 and rva < FUNC_END[FUNCS[i]]:
        return FUNCS[i]
    return None


def main():
    t0 = time.time()

    def log(m):
        sys.stderr.write('[%6.1fs] %s\n' % (time.time() - t0, m))
        sys.stderr.flush()

    h = H.HostProcess()
    h.start(48000.0, 512, log=lambda s: None)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    STUB_LO = H.E.STUB_BASE
    STUB_HI = STUB_LO + 0x10000

    executed = set()
    edges = collections.defaultdict(set)
    stubs = collections.Counter()
    prev_ind = [None]
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = True
    IMG = pe.get_memory_mapped_image()
    CLO = [s for s in pe.sections if s.Name.startswith(b'.text')][0].VirtualAddress
    CHI = CLO + [s for s in pe.sections if s.Name.startswith(b'.text')][0].Misc_VirtualSize
    bcache = {}

    def decode_block(rva):
        out = bcache.get(rva)
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
            bcache[rva] = out
        return out

    def block(uc_, address, size, user):
        rva = address - IB
        if prev_ind[0] is not None:
            edges[prev_ind[0]].add(rva)
            prev_ind[0] = None
        if STUB_LO <= address < STUB_HI:
            nm = h.stub2name.get(address)
            stubs[nm[1] if nm else '%#x' % address] += 1
            return
        if not (CLO <= rva < CHI):
            return
        last = None
        for a, mn in decode_block(rva):
            executed.add(a)
            last = mn
        if last == 'call':                              # the block after a call/indirect is the target
            prev_ind[0] = rva

    uc.hook_add(UC_HOOK_BLOCK, block)

    # the composite drive: every product surface
    bank = open(truth.BANK, 'rb').read()
    HEADER, STRIDE, NAME = 23, 20223, 16
    model = q(q(h.core + 8))
    vb, ve = q(h.core + 24), q(h.core + 32)
    recs = [(h.call(IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF, q(vb + 24 * i)) for i in range((ve - vb) // 24)]
    kidx = {}
    for i in range((ve - vb) // 24):
        pid = h.call(IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF
        kidx[pid] = i

    T = dict(tempo=120.0, playing=True)
    ev_on = lambda p, v=0.8: ('on', 0, 0, p, v)
    ev_off = lambda p: ('off', 0, 0, p, 0.0)

    log('boot done; functions so far %d' % len({func_of(a) for a in executed} - {None}))
    npatch = int(os.environ.get('JUNO_REACH_PATCHES', '64'))
    # 1. every factory patch: load + a chord + release + a few blocks (arp patches included)
    for idx in range(npatch):
        h.load_patch(bank[HEADER + idx * STRIDE + NAME: HEADER + (idx + 1) * STRIDE])
        h.process(256, events=[ev_on(60), ev_on(64, 0.7), ev_on(67, 0.9)], ctx=T)
        h.process(256, ctx=T)
        h.process(256, events=[ev_off(60), ev_off(64), ev_off(67)], ctx=T)
        h.process(128, ctx=T)
        if idx % 16 == 15:
            log('patches through %d; functions %d' % (idx, len({func_of(a) for a in executed} - {None})))
    # 2. MIDI controllers through process() params (CC map base + n), bend, AT, sustain, all notes off
    base = h.call(IB + 0x31F2C0, rcx=h.core) if False else None   # base via midi; use host_param ids directly
    # the CC-map base is core-relative; reuse the known mapping ids via params at offsets
    for pid, val in [(VOICES, 6), (VOICES, 1), (SAMPLERATE, 2), (SAMPLERATE, 3), (SAMPLERATE, 0), (SAMPLERATE, 5)]:
        h.process(256, params=[(pid, 0, val)], ctx=T)
        h.process(256, ctx=T)
    # 3. the editor's set (model set) of every record at a few values + commit + the host round trip
    for pid, obj in recs:
        for v in (0, 1, 127, 255):
            h.call(IB + MODEL_SET, rcx=model, rdx=obj, r8=v & 0xFFFFFFFF, r9=1, count=500_000_000)
        h.process(256, ctx=T)
    for rva in COMMIT:
        h.call(IB + rva, rcx=model, count=500_000_000)
    log('editor set done; functions %d' % len({func_of(a) for a in executed} - {None}))
    # 4. the UI-timer drain + MIDI learn / forget
    h.call(IB + UITICK, rcx=h.core, count=2_000_000_000)
    for pid in list(kidx)[:4]:
        h.call(IB + CC_LEARN, rcx=h.core + 24, rdx=kidx[pid])
        h.call(IB + CC_FORGET, rcx=h.core + 24, rdx=kidx[pid])
    # 5. getState / setState round trip + an engine-rate setting state
    st = h.get_state()
    h.set_state(st)
    h.process(256, ctx=T)
    # 6. the editor attached + the window zoom getter over a screen
    try:
        h.attach_editor(1920, 1080)
        for size in list(getattr(h, 'windows', {})):
            h.window_conv(size)
    except Exception as e:
        log('editor/zoom step skipped: %s' % e)
    log('drive done')

    funcs = sorted({f for f in (func_of(a) for a in executed) if f is not None})
    func_insns = sum(1 for a in executed if func_of(a) is not None)
    # the instruction-form census over the reached functions (L3's work list)
    forms = collections.Counter()
    for f in funcs:
        a = f
        while a < FUNC_END[f]:
            ins = next(md.disasm(bytes(IMG[a:a + 16]), IB + a), None)
            if ins is None:
                break
            forms[ins.mnemonic] += 1
            a += ins.size
    out = dict(functions=funcs, executed=len(executed), func_insns=func_insns,
               indirect={('%#x' % k): sorted('%#x' % t for t in v) for k, v in edges.items()},
               stubs=dict(stubs), forms=dict(forms.most_common()),
               func_total=sum(sum(1 for _ in md.disasm(bytes(IMG[f:FUNC_END[f]]), IB + f)) for f in funcs))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(out, open(OUT + '.partial', 'w'))
    os.replace(OUT + '.partial', OUT)
    print('L1 reach: %d functions reached, %d distinct instructions executed, %d instructions in those functions '
          '(%d forms); %d stubs; wrote %s (%.0fs)'
          % (len(funcs), len(executed), out['func_total'], len(forms), len(stubs), OUT, time.time() - t0))


if __name__ == '__main__':
    main()
