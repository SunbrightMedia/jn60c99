#!/usr/bin/env python3
"""jn_import_census.py -- which imports / host-object methods each PRODUCT SURFACE of the JUNO reaches, on the host
oracle (host_process_emu), plus the oracle's Python-side state at the template cut (state the template does not carry
because it is not guest memory: the TLS / FLS dicts, the SList heads, the run-once set, the handle counter, the last
error). The lifted glue (lift/jn_host.c) must answer every import a surface reaches exactly as the oracle does
(e2e_emu._imp under wrapper_emu._imp) and start from the same Python-side state -- this tool is the work list and the
check. A UC_HOOK_CODE over the import + dynamic stub range names each call (the oracle's own driver trampolines at
CODE_BASE = STUB_BASE + 0x8000 are not imports and are excluded). Unicorn only (two-process rule).
usage: python3 tools/lift/jn_import_census.py [out.json]"""
import os
import sys
import json
import struct
import collections

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
import truth                                                       # noqa: E402
import jn_proc_seq                                                 # noqa: E402
import jn_bank_seq                                                 # noqa: E402
from unicorn import UC_HOOK_CODE                                   # noqa: E402

IB = H.IB
MODEL_SET, REC_ID, UITICK, CC_LEARN, CC_FORGET = 0x283DB0, 0x319C50, 0x320120, 0x31AA40, 0x3192E0
COMMIT = (0x285320, 0x2853C0, 0x283120)
SAMPLERATE, VOICES = 0x0FFFC015, 0x0FFFC00E


def py_state(h):
    """the oracle's Python-side state that is NOT guest memory (so not in the template)"""
    g = lambda k, d=None: getattr(h, k, d)
    return dict(tls={str(k): v for k, v in (g('tls') or {}).items()}, tls_ctr=g('tls_ctr'),
                fls={str(k): v for k, v in (g('fls') or {}).items()}, fls_ctr=g('fls_ctr'),
                slists={str(k): list(v) for k, v in (h.__dict__.get('slists') or {}).items()},
                once=sorted(g('once') or []), hc=g('_hc'), lasterr=g('lasterr'))


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, 'scratchpad', 'lift', 'juno_imports.json')
    h = H.HostProcess()
    h.boot_host(log=lambda s: None)
    cut_state = py_state(h)                      # the template cut (post boot_host): what jn_host_ref.py exports
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    lo, hi = H.E.STUB_BASE, H.E.STUB_BASE + 0x8000
    cur = ['setup']
    calls = collections.defaultdict(collections.Counter)

    def hook(uc_, addr, size, ud):
        nm = h.stub2name.get(addr)
        if nm:
            calls[cur[0]][nm[1]] += 1
    uc.hook_add(UC_HOOK_CODE, hook, begin=lo, end=hi - 1)
    h.setup(48000.0, 512)
    bank = open(truth.BANK, 'rb').read()
    T = dict(tempo=120.0, playing=True)
    model = q(q(h.core + 8))
    vb, ve = q(h.core + 24), q(h.core + 32)
    nrec = (ve - vb) // 24
    recs = [(h.call(IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF, q(vb + 24 * i)) for i in range(nrec)]

    def surface(name, fn):
        cur[0] = name
        try:
            fn()
        except Exception as e:                   # a throw on one surface must not lose the others
            calls[name]['!stopped: %s' % str(e)[:80]] += 1

    surface('process', lambda: [h.process(st['n'], events=list(st['events']), params=list(st['params']),
                                          ctx=jn_proc_seq.oracle_ctx(st['ctx'])) for st in jn_proc_seq.steps()])

    def s_patches():
        for idx in (0, 7, 31, 63):
            h.load_patch(jn_bank_seq.rec_tail(bank, idx))
            for st in jn_bank_seq.patch_steps():
                h.process(st['n'], events=list(st['events']), ctx=jn_bank_seq.oracle_ctx(st['ctx']))
    surface('patches', s_patches)
    surface('voices', lambda: [(h.process(256, params=[(VOICES, 0, v)], ctx=T), h.process(256, ctx=T)) for v in (6, 1, 6)])
    surface('engine_rate', lambda: [(h.process(256, params=[(SAMPLERATE, 0, v)], ctx=T), h.process(256, ctx=T))
                                    for v in (2, 3, 0, 5)])

    def s_rates():
        for r in (44100.0, 96000.0, 48000.0):
            h.set_active(0); h.setup_processing(r); h.set_active(1)
            h.process(256, events=[('on', 0, 0, 60, 0.8)], ctx=T)
    surface('host_rate', s_rates)
    surface('state', lambda: (h.set_state(h.get_state()), h.process(256, ctx=T)))
    surface('model_set', lambda: [h.call(IB + MODEL_SET, rcx=model, rdx=obj, r8=v, r9=1, count=500_000_000)
                                  for _, obj in recs for v in (0, 127)])
    surface('commit', lambda: [h.call(IB + r, rcx=model, count=500_000_000) for r in COMMIT])
    surface('uitick', lambda: h.call(IB + UITICK, rcx=h.core, count=2_000_000_000))
    surface('learn', lambda: [(h.call(IB + CC_LEARN, rcx=h.core + 24, rdx=i), h.call(IB + CC_FORGET, rcx=h.core + 24, rdx=i))
                              for i in range(4)])
    surface('editor_attach', lambda: h.attach_editor(1920, 1080))

    res = dict(cut_state=cut_state, end_state=py_state(h), unhandled=dict(getattr(h, 'unhandled', {})),
               surfaces={k: dict(v) for k, v in calls.items()})
    os.makedirs(os.path.dirname(out), exist_ok=True)
    json.dump(res, open(out, 'w'), indent=1)
    for k, v in calls.items():
        print('%-14s %s' % (k, ', '.join('%s(%d)' % kv for kv in sorted(v.items(), key=lambda kv: -kv[1]))))
    print('cut-state (Python side, not in the template):', json.dumps(cut_state))
    print('oracle unhandled imports:', dict(getattr(h, 'unhandled', {})))


if __name__ == '__main__':
    main()
