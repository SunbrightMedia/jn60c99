"""Oracle-only probe (task #36): WHO RUNS the core's second queue (+0x200: the MIDI push's raw
records and setParam's) -- its drain is the conductor's slot 1 (rva 0x320120, vtables AConductor
0x94AB48 / CVstConductor 0x9679C8), which writes the parameter store getState reads and completes
a MIDI learn (rva 0x319C90). Counts the drain, the learn completion and the learn arm (rva
0x31AA40) across the host calls the gates drive: start, process with CC records, getState,
setState.
    python3 probes/host_api/conductor_probe.py      (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H          # noqa: E402
from unicorn import UC_HOOK_CODE      # noqa: E402

FNS = {'drain 0x320120': 0x320120, 'learn done 0x319C90': 0x319C90, 'learn arm 0x31AA40': 0x31AA40,
       'deserialize 0x321F20': 0x321F20, 'ccmap clear 0x31A4F0': 0x31A4F0}


def main():
    h = H.HostProcess()
    hits = {k: 0 for k in FNS}
    for k, r in FNS.items():
        h.uc.hook_add(UC_HOOK_CODE, lambda uc, a, s, ud, k=k: hits.__setitem__(k, hits[k] + 1),
                      begin=H.IB + r, end=H.IB + r)

    def step(name, f):
        before = dict(hits)
        f()
        print('%-34s %s' % (name, ', '.join('%s +%d' % (k, hits[k] - before[k]) for k in FNS if hits[k] != before[k]) or '-'))
    step('start(48000)', lambda: h.start(48000.0, 4096))
    base = 0x0FFFC100
    step('process 256, no events', lambda: h.process(256))
    step('process 256, CC 3 = 0.5', lambda: h.process(256, params=[(base + 3, 0, 0.5)]))
    step('process 256, note on', lambda: h.process(256, events=[('on', 0, 0, 60, 0.8)]))
    s = [None]
    step('getState', lambda: s.__setitem__(0, h.get_state()))
    step('setState (own)', lambda: h.set_state(s[0]))
    step('process 256', lambda: h.process(256))
    import e2e_emu as E
    import midi_ctl_gate as G
    bank = E.bank_bytes()
    rec = bank[G.HEADER + 9 * G.STRIDE: G.HEADER + 10 * G.STRIDE]
    step('load_patch 9 (the patch browser)', lambda: h.load_patch(rec[G.NAME:]))
    step('process 256', lambda: h.process(256))


if __name__ == '__main__':
    main()
