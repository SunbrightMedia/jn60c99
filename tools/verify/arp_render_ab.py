#!/usr/bin/env python3
"""arp_render_ab.py — arp RENDER A/B for the 7 factory arp patches, factory
scenario (single held note 60, per-patch preset arp config, BPM 120, N=16000).

The render-A/B oracle (recall_render_ab) cannot drive the arp (its recall path
does not enable the arp and it has no transport clock), so the 7 arp patches are
proven here instead, composing two independently-proven links:
  - SCHEDULE: the port's carp.c schedule is bit-exact vs the plugin's OWN arp
    (tools/verify/arp_sched_ab.py, 7/7 under Unicorn).
  - RENDER of that schedule: proven here by REPLAYING the port's (proven) arp
    event schedule into the plugin's real per-sample voice+master render at the
    same sample offsets, and comparing bit-for-bit to the port's own render.
    The plugin's arp and a manual note-on converge on the SAME CVoiceAssigner
    (docs/PHASE4_ARP_AUDIO_CERT.md link 2), so replaying via note_on/note_off
    reproduces the plugin's arp render.

TWO-PROCESS (mandatory):
  python3 arp_render_ab.py --port   # port render + arp schedule -> pickle
  python3 arp_render_ab.py --ref    # replay schedule into plugin, compare

STATUS (2026-07-17): 4/7 BIT-EXACT. This gate EXPOSED a real render divergence
that arp_audio_ab (chords @ BPM128) missed: patches [1, 33, 41] diverge starting
at the FIRST arp note-change (sample 7000 = tick 7), even though their SCHEDULE is
proven bit-exact (arp_sched_ab 7/7).
ROOT CAUSE: PROVEN (executed, scratchpad/b2_statediff.py + b2_pregate.py). The port
does NOT replicate the plugin's CROSS-VOICE note-on broadcast. The plugin's note-on
reaches ALL voice units; when a note is played, it seeds even the NON-allocated
voices. The port's voice_trigger touches ONLY the allocated voice (juno_note_on on
the picked voice; no cross-voice update). Decisive isolation, port vs plugin voice
state (correct layout: plugin voice v renders at state[v]+v*10512, NOT state[v]+0):
  - sample 998, BEFORE the tick-1 note-60 broadcast: voice6 = 0 diff, voice7 = 0 diff.
  - sample 6998, AFTER the broadcast, BEFORE voice6 gates: voice6 = 68 cells DIFFER,
    voice7 (the ALLOCATED note-60 voice) = 0 diff (perfect).
So playing note 60 (allocated to voice 7) diverges the NON-allocated voice 6's
free-run state; when the arp gates voice 6 at tick 7, it inherits that divergent
seed -> the render diverges from the first note-change (small growing delta,
1.6e-5 -> 5.5e-4). Invisible for non-arp (an ungated voice is enveloped to silence,
so its divergent free-run never reaches the mix) -> only the arp, which gates a
previously-idle voice, exposes it. Patch-specific [1,33,41] because the seeded
state only reaches the output for certain patches' modulation routing (that
selectivity is the one piece still to pin). FIX = replicate the plugin's per-unit
note-on effect on non-allocated voices (find what noteOn writes to a non-picked
voice; the +1856 any-note flag is one such cell). Verify no regression to the
57/57 non-arp render + voice-alloc tests.
Both harnesses (interleave scratchpad/b2_render_ref.py + this replay) give the
identical 3 failures at the identical sample -> real, not a harness artifact.
The SCHEDULE (#96 deliverable) is proven; this render-state divergence is the
remaining arp sub-task.
"""
import sys, os, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

SR = 48000.0; NOTE, VEL, N = 60, 105, 16000
ARPS = [1, 9, 17, 25, 33, 41, 49]
PKL = os.environ.get('JUNO_ARP_RENDER_PKL', '/home/user/jn60c99/scratchpad/arp_render_ab.pkl')

if sys.argv[1:2] == ['--port']:
    import ctypes
    bankb = open(E.BANK, 'rb').read()
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_arp_trace.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_int), ctypes.c_int]
    lib.juno_gui_arp_trace_count.restype = ctypes.c_int
    lib.juno_gui_arp_trace_count.argtypes = [ctypes.c_void_p]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    out = {}
    for p in ARPS:
        c = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(c, bankb, len(bankb), p)
        cap = 4096; tb = (ctypes.c_int * (4 * cap))()
        lib.juno_gui_arp_trace(c, tb, cap)
        lib.juno_gui_note_on(c, NOTE, VEL)
        buf = (ctypes.c_float * (2 * N))(); lib.juno_gui_render(c, buf, N)
        ne = lib.juno_gui_arp_trace_count(c)
        sched = [(tb[4*i], tb[4*i+1], tb[4*i+2], tb[4*i+3]) for i in range(ne)]
        inter = struct.unpack("<%dI" % (2*N), bytes(buf))
        out[p] = {'L': list(inter[0::2]), 'R': list(inter[1::2]), 'sched': sched}
        lib.juno_gui_destroy(c)
    pickle.dump(out, open(PKL, 'wb'))
    print("PORT: saved render + schedule for %d arp patches" % len(out))

elif sys.argv[1:2] == ['--ref']:
    import real_recall as R
    data = pickle.load(open(PKL, 'rb'))
    bank = E.bank_bytes(); leaves = R.leaf_table(); FX = [(1179, 3057), (1181, 3060)]

    def plugin_replay(patch, sched):
        e = E.E2E(); e.build(SR); e.snap_all()
        blob = E.patch_blob(bank, patch)
        for (disp, bb) in leaves: R.wr_desc(e, disp, R.dec(blob, bb))
        for (disp, ro) in FX:     R.wr_desc(e, disp, R.dec(blob, ro - 16))
        for u in range(9):
            for (disp, bb) in leaves:
                try: e.dispatch(u, disp, R.rd_desc(e, disp))
                except RuntimeError: pass
            for (disp, ro) in FX:
                try: e.dispatch(u, disp, R.rd_desc(e, disp))
                except RuntimeError: pass
        e.snap_all(); e.clear_latch(); e.set_ftz()
        L = []; Rr = []; cur = 0
        for (smp, kind, note, vel) in sched:
            if smp > cur:
                l, r = e.render(smp - cur); L += l; Rr += r; cur = smp
            if kind == 0: e.note_off(note)
            else:         e.note_on(note, vel)
        if N > cur:
            l, r = e.render(N - cur); L += l; Rr += r
        return L, Rr

    npass = nfail = 0; fails = []
    print("=== arp RENDER A/B (factory scenario, note %d, SR %g, N %d) ===" % (NOTE, SR, N))
    for p in sorted(data):
        gL, gR = plugin_replay(p, data[p]['sched'])
        pL, pR = data[p]['L'], data[p]['R']
        nd = 0; first = None
        for i in range(min(len(gL), len(pL))):
            if gL[i] != pL[i] or gR[i] != pR[i]:
                if first is None: first = i
                nd += 1
        tag = 'BIT-EXACT' if nd == 0 else 'FIRST@%d diffs=%d' % (first, nd)
        print("  patch %2d %-18s %s" % (p, E.patch_name(bank, p), tag))
        if nd == 0: npass += 1
        else: nfail += 1; fails.append(p)
    print("\n%d/%d arp renders BIT-EXACT%s" % (npass, npass + nfail, "" if not fails else "  FAIL: " + str(fails)))
    sys.exit(1 if nfail else 0)
else:
    print("usage: arp_render_ab.py --port | --ref", file=sys.stderr); sys.exit(2)
