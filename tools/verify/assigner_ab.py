#!/usr/bin/env python3
"""assigner_ab.py -- VOICE-ASSIGN (KEY ASSIGN / LEGATO / PORTAMENTO) A/B gate.

WHY THIS GATE EXISTS
--------------------
Every render gate before this one drove BOTH sides through a recall that only
DISPATCHes parameter values (0x3B9A30). The plugin's voice allocator CAssignJu60
does not read its mode from there: it caches ASSIGN MODE (param 800) at
assigner+16 and LEGATO (799) at assigner+20, and the ONLY writer is
sub_7FF91DFB49B0(assigner, 4) -- which the engine's HOST parameter entry
sub_7FF91E027AE0 (engine vtable +112) calls after EVERY parameter write, right
after the dispatch:

    (*(vtbl(proc[u])   + 88))(proc[u], idx, 0, value)     <- what recall did
    (*(vtbl(assign[u]) +  8))(assign[u], 4)               <- what recall did NOT

Result: the oracle's own allocator sat in POLY for every patch, the port was
"corrected" to match it, and both were wrong together. The note dispatcher
sub_7FF91DFB5820 switches on that cached field (1 = MONO -> sub_7FF91DFB38F0,
2 = UNISON -> sub_7FF91DFB3B60, else POLY), so 16 of the 64 factory patches were
being played in the wrong voice-assign mode by the port AND by every gate.

Executed impact, plugin vs itself, same recall + same note, refresh the ONLY
difference (probes/assigner/laneX_audio_impact.py): +16.65 dB on Chillwave 3
"BS Solid", +17.43 dB on Chillwave 4 "BS Glide", every sample differing; an
ASSIGN=0 patch stays bit-identical, which makes the result non-vacuous.

This gate drives NOTE SEQUENCES (not the single note the render A/Bs use -- a
single note cannot tell POLY from MONO) through the plugin's own allocator and
through the port's, and requires bit-exact audio.

REFERENCE = the plugin's own recall + its own assigner refresh + its own DSP
under Unicorn. PORT = libjuno via ctypes. TWO-PROCESS, as mandated.

  python3 tools/verify/assigner_ab.py --ref     # plugin  -> pickle
  python3 tools/verify/assigner_ab.py --port    # port, compare, verdict

Env: JUNO_ASGAB_PKL. Covenant: no capture data anywhere.
"""
import sys, os, struct, pickle

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import truth

SCRATCH = os.environ.get(
    'JUNO_SCRATCH',
    '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad')
PKL = os.environ.get('JUNO_ASGAB_PKL', os.path.join(SCRATCH, 'assigner_ab_ref.pkl'))

RATES = [44100.0, 48000.0]

# Factory patches spanning every ASSIGN MODE the bank uses, plus the LEGATO and
# PORTAMENTO combinations. (blob 54 = PORTAMENTO, 55 = LEGATO, 56 = ASSIGN MODE.)
#   p0  ASSIGN 0, PORTA 10          plain poly, portamento engaged
#   p5  ASSIGN 1, LEGATO 1, PORTA 4 mono + legato + glide
#   p6  ASSIGN 1                    mono, no glide
#   p13 ASSIGN 1, PORTA 12          mono + glide
#   p55 ASSIGN 0, LEGATO 1, PORTA 33  poly legato-glide (the one LEGATO read site)
#   p61 ASSIGN 2, LEGATO 1          unison + legato
#   p63 ASSIGN 2                    unison
# Arp patches {1,9,17,25,33,41,49} are excluded (no transport clock in this
# oracle, exactly as recall_render_ab documents).
PATCHES = [0, 5, 6, 13, 55, 61, 63]

# Event scripts. A single note cannot distinguish the modes, so both scripts
# overlap notes and release them out of order -- the exact surface where POLY,
# MONO (last-note priority, fall back to lowest held) and UNISON (whole stack)
# differ from each other.
#   ('on', note, vel) | ('off', note) | ('r', nsamples)
SCRIPTS = {
    'overlap': [('on', 60, 100), ('r', 3000),
                ('on', 67, 100), ('r', 3000),
                ('off', 60),     ('r', 3000),
                ('off', 67),     ('r', 5000)],
    'chord':   [('on', 48, 100), ('on', 52, 100), ('on', 55, 100), ('r', 4000),
                ('on', 60,  90), ('r', 3000),
                ('off', 52),     ('r', 2000),
                ('off', 48), ('off', 55), ('off', 60), ('r', 5000)],
}
BLOCK = 512


def _ref():
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RA
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    out = {'rates': RATES, 'runs': {}}
    for sr in RATES:
        for p in PATCHES:
            e = RA.prepare_recall(p, bank, leaves, E, R, sr)
            # Record what the plugin's OWN allocator believes, so a --port run
            # can report the mode alongside a divergence.
            mode = e.rd_i32(e.assign[0] + 16)
            leg = e.rd_i32(e.assign[0] + 20)
            del e
            for name, script in sorted(SCRIPTS.items()):
                e = RA.prepare_recall(p, bank, leaves, E, R, sr)
                L, Rr = [], []
                for ev in script:
                    if ev[0] == 'on':    e.note_on(ev[1], ev[2])
                    elif ev[0] == 'off': e.note_off(ev[1])
                    else:
                        a, b = e.render(ev[1], block=BLOCK)
                        L += a; Rr += b
                del e
                out['runs'][(sr, p, name)] = (mode, leg, L, Rr)
                print("  ref: sr %g patch %2d %-8s mode=%d legato=%d  %d samples"
                      % (sr, p, name, mode, leg, len(L)), flush=True)
    pickle.dump(out, open(PKL, 'wb'))
    print("assigner_ab ref -> %s" % PKL)
    return 0


def _port():
    import ctypes
    d = pickle.load(open(PKL, 'rb'))
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float),
                                    ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(truth.BANK, 'rb').read()
    bits = lambda f: struct.unpack('<I', struct.pack('<f', f))[0]

    fails = checks = 0
    for (sr, p, name), (mode, leg, rl, rr) in sorted(
            d['runs'].items(), key=lambda kv: (kv[0][0], kv[0][1], kv[0][2])):
        c = lib.juno_gui_create(ctypes.c_float(sr), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), p)
        L, Rr = [], []
        for ev in SCRIPTS[name]:
            if ev[0] == 'on':    lib.juno_gui_note_on(c, ev[1], ev[2])
            elif ev[0] == 'off': lib.juno_gui_note_off(c, ev[1])
            else:
                done = 0
                while done < ev[1]:
                    b = min(BLOCK, ev[1] - done)
                    buf = (ctypes.c_float * (2 * b))()
                    lib.juno_gui_render(c, buf, b)
                    for i in range(b):
                        L.append(bits(buf[2*i])); Rr.append(bits(buf[2*i+1]))
                    done += b
        lib.juno_gui_destroy(c)
        dl = sum(1 for x, y in zip(rl, L) if x != y)
        dr = sum(1 for x, y in zip(rr, Rr) if x != y)
        first = next((i for i, (x, y) in enumerate(zip(rl, L)) if x != y), None)
        checks += 1
        ok = (dl == 0 and dr == 0 and len(L) == len(rl))
        if not ok: fails += 1
        print("  sr %6g patch %2d %-8s ASSIGN=%d LEGATO=%d : %s (L %d, R %d of %d%s)"
              % (sr, p, name, mode, leg,
                 "BIT-EXACT" if ok else "*** DIVERGES ***", dl, dr, len(rl),
                 "" if first is None else ", first @ %d" % first))
    print("ASSIGNER A/B: %d/%d bit-exact -> %s"
          % (checks - fails, checks, "PASS" if fails == 0 else "FAIL"))
    return 1 if fails else 0


if __name__ == '__main__':
    truth.require()
    sys.exit(_ref() if '--ref' in sys.argv else _port())
