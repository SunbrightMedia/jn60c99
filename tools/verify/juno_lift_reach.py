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
import gc
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
    h.boot_host(log=lambda s: None)       # the template cut is post-boot_host; setup() runs UNDER the hook below, so
    uc = h.uc                             # setupProcessing / setActive are censused and lifted (junoh_init calls them)
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
        last_rva = rva
        for a, mn in decode_block(rva):
            executed.add(a)
            last = mn
            last_rva = a
        if last in ('call', 'jmp'):                     # the next block is the target of a CALL or an unconditional
            prev_ind[0] = last_rva                       # JMP (a tail call); key the edge by the transfer instruction.
            #                                              Both are rooted (tools/lift/jn_extra_roots.py): interior
            #                                              indirect targets (e.g. 0x3c7c6f, 0x3b929f) are functions
            #                                              with no pdata of their own, reached only this way.

    uc.hook_add(UC_HOOK_BLOCK, block)
    h.setup(48000.0, 512)                 # setupProcessing + setActive(1) + the blocks' host objects: the lifted
    #                                       junoh_init re-runs exactly this, so its code must be in the census

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
    # 0. the gate's OWN scenario first: the shared process drive (tools/lift/jn_proc_seq) on the INITIAL (template)
    #    patch -- no-context AND context blocks, a chord, release, flush, sizes -- so the host lift covers exactly
    #    what the L5 process gate drives (the paths the factory-patch loop does not reach)
    sys.path.insert(0, os.path.join(REPO, 'tools', 'lift'))
    import jn_proc_seq                                                # noqa: E402
    for st in jn_proc_seq.steps():
        h.process(st['n'], events=list(st['events']), params=list(st['params']), ctx=jn_proc_seq.oracle_ctx(st['ctx']))
    log('initial-patch process drive done; functions %d' % len({func_of(a) for a in executed} - {None}))
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
    log('patches done; functions %d' % len({func_of(a) for a in executed} - {None}))

    # every surface after the patches is INDEPENDENT: a throw on one must not lose the census
    # (the plugin's own C++ exceptions stop by name in the oracle; the reach up to the throw is kept).
    def step(name, fn):
        try:
            fn()
        except Exception as e:
            log('step %s stopped (reach kept): %s' % (name, e))
        log('after %s: functions %d' % (name, len({func_of(a) for a in executed} - {None})))

    def s_midi():                              # MIDI-ish params (voice count, engine-rate setting) through process()
        for pid, val in [(VOICES, 6), (VOICES, 1), (SAMPLERATE, 2), (SAMPLERATE, 3), (SAMPLERATE, 0), (SAMPLERATE, 5)]:
            h.process(256, params=[(pid, 0, val)], ctx=T)
            h.process(256, ctx=T)

    def s_rates():                             # the HOST-rate paths: setupProcessing at each host rate reaches the
        #                                        core's render object both ways -- the rate converter (rva 0x343E30,
        #                                        host rate != engine 96 kHz) AND the identity object (rva 0x344270,
        #                                        host rate == engine rate). The 48 kHz census reaches only the
        #                                        converter; 96000 reaches the identity path (playbook: it trapped).
        for r in (44100.0, 96000.0, 48000.0):
            h.set_active(0); h.setup_processing(r); h.set_active(1)
            h.process(256, events=[ev_on(60)], ctx=T)
            h.process(256, events=[ev_off(60)], ctx=T)

    def s_editor_attach():                     # attach the editor FIRST: it builds the GUI tree the panel paths need
        h.attach_editor(1920, 1080)
        for size in list(getattr(h, 'windows', {})):
            h.window_conv(size)

    def s_model_set():                         # the editor's set of every record at a few values + a block each
        for pid, obj in recs:
            for v in (0, 1, 127, 255):
                h.call(IB + MODEL_SET, rcx=model, rdx=obj, r8=v & 0xFFFFFFFF, r9=1, count=500_000_000)
        h.process(256, ctx=T)

    def s_commit():
        for rva in COMMIT:
            h.call(IB + rva, rcx=model, count=500_000_000)

    def s_uitick():
        h.call(IB + UITICK, rcx=h.core, count=2_000_000_000)

    def s_learn():
        for pid in list(kidx)[:4]:
            h.call(IB + CC_LEARN, rcx=h.core + 24, rdx=kidx[pid])
            h.call(IB + CC_FORGET, rcx=h.core + 24, rdx=kidx[pid])

    def s_state():
        st = h.get_state()
        h.set_state(st)
        h.process(256, ctx=T)

    for name, fn in [('midi', s_midi), ('rates', s_rates), ('editor_attach', s_editor_attach), ('model_set', s_model_set),
                     ('commit', s_commit), ('uitick', s_uitick), ('learn', s_learn), ('state', s_state)]:
        step(name, fn)

    # the L6 search's OWN vocabulary (tools/lift/jn_search_seq.py): its census seeds, each on a FRESH oracle booted and
    # set up as the search's are, under this same block hook -- so the lift covers what the machine search drives (host
    # automation of the panel records and MIDI controllers through process(), odd block sizes, transport states, the
    # editor's set, patch loads, ...) and the census and the search can never drift apart.
    import jn_search_seq as SS                                       # noqa: E402
    import jn_ops                                                    # noqa: E402
    nseed = int(os.environ.get('JUNO_REACH_SEARCH_SEEDS', str(SS.CENSUS_SEEDS)))
    nops = int(os.environ.get('JUNO_REACH_SEARCH_NOPS', '120'))
    for seed in range(nseed):
        def s_seed(seed=seed):
            prev_ind[0] = None
            h2 = H.HostProcess()
            h2.boot_host(log=lambda s: None)
            h2.uc.hook_add(UC_HOOK_BLOCK, block)        # the same stubs at the same addresses (a deterministic boot)
            h2.setup(48000.0, 512)
            ops = jn_ops.OracleOps(h2, bank)
            for op in SS.plan(seed, nops):
                if ops.run(op)[0] == 'throw':
                    break
            del ops, h2
            gc.collect()                                 # one engine at a time: free the seed's emulator now
        step('search seed %d' % seed, s_seed)
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
    # the executed instruction rvas themselves (L2's check: no lifted trap may sit on a reached rva; L6 reuse)
    EXE = os.path.join(os.path.dirname(OUT), 'juno_executed.json')
    json.dump(sorted(executed), open(EXE + '.partial', 'w'))
    os.replace(EXE + '.partial', EXE)
    print('L1 reach: %d functions reached, %d distinct instructions executed, %d instructions in those functions '
          '(%d forms); %d stubs; wrote %s (%.0fs)'
          % (len(funcs), len(executed), out['func_total'], len(forms), len(stubs), OUT, time.time() - t0))


if __name__ == '__main__':
    main()
