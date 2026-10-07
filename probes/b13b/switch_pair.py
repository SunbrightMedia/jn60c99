"""Oracle-only probe (CLAIMS B13b): the records and compared state right after the plugin's
SECOND setSampleRate of a pair (setting A, then setting B, keys held), for a record-by-record
comparison with the port (scratchpad/switch_pair_port.py reads the same pickle). Writes
scratchpad/switch_pair.pkl.

    python3 probes/b13b/switch_pair.py [patch] [settingA] [settingB] [host_rate]   (Unicorn only)"""
import os
import pickle
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b13b'))
import host_process_emu as H          # noqa: E402
import e2e_emu as E                   # noqa: E402
from unicorn import UC_HOOK_CODE      # noqa: E402
from host_process_gate import HEADER, STRIDE, NAME   # noqa: E402
from setsr_writes import snap, recs   # noqa: E402


def main():
    patch = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    sa = int(sys.argv[2]) if len(sys.argv) > 2 else 6
    sb = int(sys.argv[3]) if len(sys.argv) > 3 else 2
    rate = float(sys.argv[4]) if len(sys.argv) > 4 else 48000.0
    bank = E.bank_bytes()
    h = H.HostProcess()
    h.start(rate, 4096)
    cap = []

    def on_ret(uc, addr, size, ud):
        cap.append({'state': snap(h), 'recs': recs(h)})
    h.uc.hook_add(UC_HOOK_CODE, on_ret, begin=E.IB + 0x3C7AD3, end=E.IB + 0x3C7AD3)
    rec = bank[HEADER + patch * STRIDE: HEADER + (patch + 1) * STRIDE]
    h.load_patch(rec[NAME:])
    T = dict(tempo=120.0, playing=True)
    h.process(256, events=[('on', 0, 0, 60, 0.8)], ctx=T)
    for _ in range(6):
        h.process(256, ctx=T)
    for s in (sa, sb):
        pl = struct.pack('>Ii', H.SAMPLERATE_ID, s)
        h.set_state(struct.pack('>I', len(pl)) + pl)
        h.process(256, ctx=T)
        for _ in range(3 if s == sa else 0):
            h.process(256, ctx=T)
    print('setSampleRate returns captured:', len(cap))
    p = os.path.join(REPO, 'scratchpad', 'switch_pair.pkl')
    pickle.dump({'patch': patch, 'sa': sa, 'sb': sb, 'host': rate, 'cap': cap}, open(p + '.partial', 'wb'))
    os.replace(p + '.partial', p)
    print('wrote', p)


if __name__ == '__main__':
    main()
