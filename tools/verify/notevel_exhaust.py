#!/usr/bin/env python3
"""notevel_exhaust.py — Phase-2 exhaustion: all 128 notes x 128 velocities through
the plugin's own note-on, state-level. For each (note, vel): plugin note_on ->
find the allocated voice (the unit whose pitch cell 304 changed) -> compare its
M.CV(304) / VCF-vel(6864) / VCA-vel(9680) bits against the port's
juno_note_pitch(note) / juno_curve(56,vel) / juno_curve(57,vel). Also asserts no
note x velocity cross-term exists (the exhaustion IS the proof of separability).
vel 1..127 (vel 0 is note-off semantics on both sides), notes 0..127: 16256 events."""
import sys, struct, ctypes
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E

lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
lib.juno_note_pitch.restype = ctypes.c_float
lib.juno_note_pitch.argtypes = [ctypes.c_int]
lib.juno_curve.restype = ctypes.c_float
lib.juno_curve.argtypes = [ctypes.c_int, ctypes.c_int]

def bits(x):
    return struct.unpack('<I', struct.pack('<f', x))[0]

e = E.E2E(); e.build(48000.0); e.snap_all(); e.clear_latch(); e.set_ftz()

def cells():
    """Per-voice control cells live at off + v*10512 and note-on broadcasts them to
    every unit — read all 8 voice slots from unit 0's state."""
    st = e.state[0]
    return [(e.rd_u32(st + 304 + v*10512), e.rd_u32(st + 6864 + v*10512),
             e.rd_u32(st + 9680 + v*10512)) for v in range(8)]

bad = 0; checked = 0
prev = cells()
for note in range(128):
    exp_mcv = bits(lib.juno_note_pitch(note))
    for vel in range(1, 128):
        e.note_on(note, vel)
        cur = cells()
        vch = [u for u in range(8) if cur[u] != prev[u]]
        if len(vch) != 1:
            print(f"note {note} vel {vel}: {len(vch)} voices changed (expect 1): {vch}", flush=True)
            bad += 1
        else:
            u = vch[0]
            mcv, vcf, vca = cur[u]
            e_vcf = bits(lib.juno_curve(56, vel)); e_vca = bits(lib.juno_curve(57, vel))
            if mcv != exp_mcv or vcf != e_vcf or vca != e_vca:
                print(f"note {note} vel {vel} voice {u}: MCV {mcv:08x}!={exp_mcv:08x} "
                      f"VCF {vcf:08x}!={e_vcf:08x} VCA {vca:08x}!={e_vca:08x}", flush=True)
                bad += 1
        checked += 1
        e.note_off(note)
        prev = cells()
    if note % 16 == 15:
        print(f"  ... notes 0..{note} done ({checked} events, {bad} bad)", flush=True)
print(f"\nNOTE x VELOCITY EXHAUSTION: {checked - bad} identical / {bad} mismatched of {checked}", flush=True)
