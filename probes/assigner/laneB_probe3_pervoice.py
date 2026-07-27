#!/usr/bin/env python3
"""LANE B probe 3 — close the VOICE_MODES.md [UNVERIFIED] gap: which ENGINE CELLS
do the assigner's per-voice params 433+v (NOTE CV), 450+v (GATE) and 467+v
(the LEGATO/PORTA arming reset) actually write?

Executed: full 12 MB unit-0 state diff around each individual dispatch, driven
exactly as the assigner drives it -- proc setter 0x3B9A30(proc, paramId, 0, value)
(assigner vtbl+72 = 0x355AC0 forwards value in r9, flag=0).
Baseline = a RECALLED patch with a note already on (methodology trap 4).
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
import truth

SR = 48000.0
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 55
STRIDE = 10512
bank = open(truth.BANK, 'rb').read()
leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)
uc = e.uc
NOTIFY = E.IB + 0x3549B0
for u in range(9):
    e.call(NOTIFY, rcx=e.assign[u], rdx=4)
e.note_on(60, 105)
e.render(480, block=480)          # let the voice settle a little

ST = e.state[0]
N = 0xA83010
def snap(): return bytes(uc.mem_read(ST, N))

def diff(a, b, label):
    outs = []
    for i in range(0, N, 4):
        if a[i:i+4] != b[i:i+4]:
            va = struct.unpack('<f', a[i:i+4])[0]; vb = struct.unpack('<f', b[i:i+4])[0]
            ia = struct.unpack('<i', a[i:i+4])[0]; ib = struct.unpack('<i', b[i:i+4])[0]
            voice = i // STRIDE if i < 8 * STRIDE else None
            rel = i - voice * STRIDE if voice is not None else None
            outs.append((i, voice, rel, va, vb, ia, ib))
    print("  %-28s %d changed cells" % (label, len(outs)))
    for (i, voice, rel, va, vb, ia, ib) in outs[:24]:
        loc = ("voice %d rel %d" % (voice, rel)) if voice is not None else "abs"
        print("     cell %-9d %-16s f32 %g -> %g   i32 %d -> %d" % (i, loc, va, vb, ia, ib))
    return outs

base = snap()
for (pid, val, label) in ((433 + 3, 67, 'NOTE CV 433+3 = 67'),
                          (450 + 3, 105, 'GATE 450+3 = 105'),
                          (450 + 3, 0, 'GATE 450+3 = 0'),
                          (467 + 3, 1, 'RESET 467+3 = 1'),
                          (467 + 3, 0, 'RESET 467+3 = 0')):
    e.call(E.IB + 0x3B9A30, rcx=e.proc[0], rdx=pid, r8=0, r9=val)
    cur = snap()
    diff(base, cur, label)
    base = cur
print("faults:", e.faults)
