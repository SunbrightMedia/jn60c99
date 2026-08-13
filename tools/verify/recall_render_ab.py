#!/usr/bin/env python3
"""recall_render_ab.py -- Phase-1 AUDIBLE gate: port recall+render vs the PLUGIN's
own recall+render, BIT-EXACT on the output audio.

This is the authoritative Phase-1 judge (NOT the recall-state diff): a cell only
needs fixing if fixing it makes THIS A/B more bit-exact; a cell that diverges in
the recall-state diff but is render-overwritten shows up here as already-matching.

REFERENCE (process 1, --ref) = the plugin's OWN recall + render, executed under
Unicorn, with ZERO port code in the path:
  build (0x3C68D0, applies defaults to all 9 units) -> snap_all
  -> write each COMPLETE value-tree leaf's decoded patch byte into the plugin's
     descriptor table, then dispatch that leaf through the plugin's REAL setter
     (sub_7FF91E019A30) to all 9 units  [ = real_recall's dispatch-loop recall ]
  -> snap_all -> clear_latch -> set_ftz -> note_on(60,105) -> render(N)
  This is the plugin's changed-leaf recall (its true replaceState behaviour): each
  leaf setter is a direct idempotent store, so dispatching every leaf == dispatching
  only the changed ones. It is NOT the full 0..4965 loop: re-dispatching the ~4850
  NON-leaf indices (recall_fullstate_diff.py --ref) clobbers real leaf cells the
  plugin never re-touches on recall -- e.g. VCF cutoff 6736 -> 1.0 (the golden/oracle-
  proven per-patch value is 0.6) and LFO-rate 1088/2064 -> a constant. The full loop
  is thus contaminated for those cells; the complete-leaf recall matches the plugin's
  captured post-recall engine state (juno_apply.c: 6736 == coarse value, 0/64 mism).

PORT (process 2, --port) = juno_gui_create(SR) + juno_gui_apply_bank(patch)
  + juno_gui_note_on(60,105) + juno_gui_render(N), via ctypes on libjuno.so.

TWO-PROCESS (mandatory): never build E2E + load libjuno in one process.
  python3 recall_render_ab.py --ref  [patches...]   # plugin -> pickle
  python3 recall_render_ab.py --port [patches...]   # port, compare, verdict
"""
import sys, struct, pickle

HERE = '/home/user/jn60c99/tools/verify'
sys.path.insert(0, HERE)
import os
PKL  = os.environ.get('JUNO_RENDER_REF_PKL',
                     '/home/user/jn60c99/scratchpad/recall_render_ref.pkl')
import os as _o, sys as _s; _s.path.insert(0, _o.path.dirname(_o.path.abspath(__file__)))
import truth; BANK = truth.BANK  # single source of ground truth (truth/ folder)
# Host rate (default 48 kHz). JUNO_RENDER_SR overrides it so the SAME render A/B can
# prove the whole recall->render chain at NON-standard rates (88200/192000) — the
# "other host sample rates" gate. Both processes read the same env, so the port and
# the plugin oracle build at the same rate.
SR   = float(os.environ.get('JUNO_RENDER_SR', '48000'))
NOTE, VEL, N = 60, 105, 16000

# diff set (RANGE/PWM/LFO variation) + delay-active + no-divergence controls.
# Every factory patch EXCEPT the 7 arp-enabled ones. This oracle's recall does not
# enable the arp and its render has no transport clock, so it CANNOT arpeggiate --
# comparing its (sustained) reference against the port's (arpeggiated) render for the
# arp patches is meaningless. The 7 arp patches [1,9,17,25,33,41,49] are covered by
# dedicated gates instead: arp_sched_ab.py (schedule, 7/7 vs the plugin's own arp)
# and arp_render_ab.py (render of that schedule). See docs + ROADMAP_TO_DONE.md.
def _arp_patches(bank_bytes):
    """WHICH patches have the arpeggiator on, ASKED OF THE BANK rather than
    remembered.

    ⚠ THIS WAS A HARDCODED SET {1,9,17,25,33,41,49} AND IT WAS WRONG THE MOMENT
    A SECOND BANK EXISTED. Those are the FACTORY bank's arp patches. Run against
    any other bank it did two damaging things at once:

      1. It SKIPPED patches 1,9,17,25,33,41,49 whatever they contained -- seven
         untested patches per bank, silently, reported as "57/57".
      2. It RENDERED that bank's real arp patches. The reference has no
         transport clock and CANNOT arpeggiate, so those comparisons were
         guaranteed to differ for a reason that is not a port defect -- and they
         were counted as failures.

    Found 2026-08-13 when the port was run against 12 user banks (768 patches):
    111 render mismatches, cause unattributable until this was fixed. A constant
    that encodes a property of the DATA is a defect the moment the data changes.

    The port's own accessor answers it: juno_bank_arp() is the same function the
    engine uses to decide whether to arpeggiate, so the skip set cannot disagree
    with what is actually rendered."""
    import ctypes
    lib = ctypes.CDLL(os.path.join(os.path.dirname(os.path.dirname(
        os.path.dirname(os.path.abspath(__file__)))), 'libjuno.so'))
    lib.juno_bank_arp.restype = ctypes.c_int
    lib.juno_bank_arp.argtypes = [ctypes.c_char_p, ctypes.c_int,
                                  ctypes.POINTER(ctypes.c_int),
                                  ctypes.POINTER(ctypes.c_int)]
    m = ctypes.c_int(0); o = ctypes.c_int(0)
    out = set()
    for p in range(64):
        if lib.juno_bank_arp(bank_bytes, p, ctypes.byref(m), ctypes.byref(o)):
            out.add(p)
    return out


def default_patches(bank_bytes):
    arp = _arp_patches(bank_bytes)
    return [p for p in range(64) if p not in arp], arp


def parse_patches(argv, bank_bytes=None):
    ps = [int(a) for a in argv if a.lstrip('-').isdigit()]
    if ps:
        return ps
    if bank_bytes is None:
        bank_bytes = open(BANK, 'rb').read()
    keep, arp = default_patches(bank_bytes)
    print("  arp patches in THIS bank (skipped, the reference cannot "
          "arpeggiate): %s" % sorted(arp))
    return keep


# Master/FX value-tree leaves whose dispatch index is beyond real_recall.leaf_table's
# voice range (disp <= 877) but which the plugin's replaceState still fires on recall.
# (dispatch idx, RECORD byte): DELAY FEEDBACK -> 102560, DELAY DIRECT LEVEL -> 102512.
# Executed law (tools/verify/delay_fb_sweep.py, bit-exact 768/768 over all 256 bytes
# x 3 rates): 102560 = f32(byte/255)*f32(0.9), 102512 = byte/255.
FX_LEAVES = [(1179, 3057), (1181, 3060)]

# Extended value-tree leaves the plugin's OWN recall (0x3B48A0) fires but which are
# absent from real_recall.leaf_table (the 112-leaf voice set), yet write render-read
# voice cells. Dropping them left the port velocity-flat (see src/juno_apply.c). Blob
# byte positions from the validated Script.xml cumulative offset map (0 mismatches vs
# all 112 proven leaves); setter maps (executed): 1028->7424, 1058->9600 = value/255.
# (disp, blob byte)
EXTRA_LEAVES = [(1028, 1852),   # VCF VELOCITY SENS -> cell 7424
                (1058, 2086)]   # VCA VELOCITY SENS -> cell 9600

# DELAY fine-FX FILTER leaves (#116) — dispatchable setter leaves that the plugin's
# recall ENUMERATOR (0x3B48A0) does NOT fire, but a real host's preset-load applies
# via the controller path. They write the delay slot-1 high-cut/damp coefficient
# cells (102368..102672). Absent here, BOTH the oracle and the port left those cells
# frozen at the plugin default byte (the render-A/B blind spot that hid the darkness:
# factory p2/p6 use DELAY HIGH CUT=3). Dispatching them here == what the host does;
# the port applies the identical law (src/finefx_recall.c). (disp, record byte, raw)
# where raw=True marks an int1x7 leaf (single record byte, DELAY HIGH CUT) vs the
# int8x4 nibble-pair damp leaves. SCOPED to DELAY TYPE 0 (rec 650): for TYPE 1/4 the
# delay uses a different cell signature and TYPE 2/3/5 slot-1 hosts chorus/reverb
# (which own 102656) — exactly as src/delay_recall.c gates the applier.
DELAY_FILT_LEAVES = [(1180, 3059, True),   # DELAY HIGH CUT    -> 102368..102496 (7 cells)
                     (1182, 3068, False),  # DELAY LF DAMP     -> 102640
                     (1183, 3076, False),  # DELAY LF DAMP FREQ-> 102608 (rate-armed)
                     (1184, 3084, False),  # DELAY HF DAMP     -> 102672
                     (1185, 3092, False)]  # DELAY HF DAMP FREQ-> 102656 (rate-armed)


# REVERB fine-FX leaves (#116) — same blind spot as DELAY: dispatchable via 0x3B9A30,
# absent from the recall enumerator, the port applies them (finefx_recall.c
# juno_apply_reverb_finefx). Unconditional (the master always runs the reverb tank).
# (disp, record byte, raw=int1x7). REVERB PRE DELAY (1323, W1) shifts the reverb tap
# array (34 ints at 11022208) + master predelay cell 10759360 -- port applies it in
# juno_apply_reverb (juno_write_reverb_taps_pd). Factory bank is all PRE DELAY 20
# (default), so dispatching it here is identity (no render change); it closes the
# blind spot so the oracle can't leave PRE DELAY unapplied.
REVERB_FINEFX_LEAVES = [(1323, 3947, True),   # REVERB PRE DELAY -> taps + 10759360
                        (1324, 3948, True),   # REVERB LOW CUT   -> 10759520/536/552
                        (1325, 3949, True),   # REVERB HIGH CUT  -> 10759568..632
                        (1326, 3950, True),   # REVERB DENSITY   -> 10759392
                        (1327, 3951, False)]  # REVERB DIRECT LV -> 10759424


# SLOT-1 CHORUS fine-FX leaves (#116) — the CHORUS HIGH/LOW CUT / PRE DELAY params
# apply ONLY to the DELAY-TYPE-2/3 slot-1 chorus (the slot-2 EFFECT-TYPE chorus has
# no fine filters). Port: finefx_recall.c juno_apply_chorus_finefx via apply_slot1_
# chorus. (disp, record byte, raw=int1x7). Cells 6396xxx.
CHORUS_FINEFX_LEAVES = [(1210, 3286, True),   # CHORUS PRE DELAY -> 6396128
                        (1211, 3287, True),   # CHORUS LOW CUT   -> 6396336/352
                        (1212, 3288, True)]   # CHORUS HIGH CUT  -> 6396192..320


def _finefx_leaves(blob, R):
    """The extra FX fine-FX leaves to fire for this patch (beyond the recall
    enumerator): DELAY filter leaves when DELAY TYPE in {0,1} (TYPE 0 -> first
    instance 102xxx, TYPE 1 -> second instance 4297xxx -- context-dependent, both
    applied by the port; finefx_multictx_probe.py); SLOT-1 CHORUS filter leaves when
    DELAY TYPE in {2,3}; REVERB filter/gain leaves unconditionally (reverb tank
    always runs). DELAY TYPE = rec 650 (blob index 650-16=634)."""
    dtype = R.dec(blob, 634)
    # DELAY TYPE 5 (slot-1 reverb) hosts BOTH a delay-filter block (6497xxx, delay
    # leaves) and a chorus-filter block (10693xxx, chorus leaves) -- dispatch both.
    dly = DELAY_FILT_LEAVES if dtype in (0, 1, 5) else []
    cho = CHORUS_FINEFX_LEAVES if dtype in (2, 3, 5) else []
    return dly + cho + REVERB_FINEFX_LEAVES


def prepare_recall(idx, bank, leaves, E, R, sr):
    """Build a plugin engine and drive its OWN complete recall for patch idx at rate
    sr, leaving it noteless/settled (snap+clear_latch+set_ftz done). This is the
    proven-bit-exact recall (the port's juno_gui_apply_bank reproduces it, 57/57
    render A/B): the value-tree leaves PLUS the extended cells the enumerator omits
    (FX feedback/direct, VCF/VCA velocity-sens, DELAY/CHORUS/REVERB fine-FX). Reused
    by the differential fuzz (fuzz_diff.py) so its oracle starts from the SAME state
    the port does — otherwise an omitted leaf (e.g. velocity-sens at vel<127) makes
    every event-sequence diverge for a reason that is NOT the port."""
    e = E.E2E(); e.build(sr); e.snap_all()
    blob = E.patch_blob(bank, idx)
    for (disp, bb) in leaves:
        R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, recoff) in FX_LEAVES:                  # record byte -> blob-relative
        R.wr_desc(e, disp, R.dec(blob, recoff - 16))
    for (disp, bb) in EXTRA_LEAVES:
        R.wr_desc(e, disp, R.dec(blob, bb))
    finefx = _finefx_leaves(blob, R)
    for (disp, recoff, raw) in finefx:                # int1x7 raw byte vs nibble pair
        v = (blob[recoff - 16] & 0x7F) if raw else R.dec(blob, recoff - 16)
        R.wr_desc(e, disp, v)
    for u in range(9):
        for (disp, bb) in leaves:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff) in FX_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, bb) in EXTRA_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff, raw) in finefx:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    # What the HOST does that a bare dispatch does not: the engine's parameter
    # entry 0x3C7AE0 follows every 0x3B9A30 write with assigner->slot+8(4), which
    # re-caches ASSIGN MODE (800) and LEGATO (799). Skipping it pins the plugin's
    # own allocator to POLY, so a MONO/UNISON patch renders polyphonically on BOTH
    # sides of every render A/B -- the shared blind spot this closes. Idempotent:
    # it re-reads the current values, so once after the writes == after each write
    # (proven by probes/assigner/laneX_notify_placement.py).
    e.assigner_notify()
    e.snap_all(); e.clear_latch(); e.set_ftz()
    return e


def ref_render(idx, bank, leaves, E, R):
    e = prepare_recall(idx, bank, leaves, E, R, SR)
    e.note_on(NOTE, VEL)
    return e.render(N)


def cmp_stream(la, ra, lb, rb):
    n = min(len(la), len(lb)); first = None; nd = 0
    for i in range(n):
        if la[i] != lb[i] or ra[i] != rb[i]:
            nd += 1
            if first is None: first = i
    return n, nd, first


# CLI dispatch is gated on __main__ so this module is safely importable (fuzz_diff.py
# reuses prepare_recall); otherwise importing it would run a render here.
_MODE = sys.argv[1] if (__name__ == '__main__' and len(sys.argv) > 1) else None
if _MODE == '--ref':
    import e2e_emu as E
    import real_recall as R
    patches = parse_patches(sys.argv[2:], open(BANK, 'rb').read())
    bank = E.bank_bytes(); leaves = R.leaf_table()
    out = {}
    for idx in patches:
        L, Rr = ref_render(idx, bank, leaves, E, R)
        out[idx] = (L, Rr)
        sys.stderr.write("ref patch %2d (%s): %d frames\n" % (idx, E.patch_name(bank, idx), len(L)))
        sys.stderr.flush()
    pickle.dump(out, open(PKL, 'wb'))
    print("REF: saved %d patch render streams (N=%d, note %d vel %d, SR %g)" %
          (len(out), N, NOTE, VEL, SR))

elif _MODE == '--port':
    import ctypes
    ref = pickle.load(open(PKL, 'rb'))
    bankbytes = open(BANK, 'rb').read()
    import freshlib  # stale-artifact guard (ROADMAP P0.3): refuse a libjuno.so older than src
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    import e2e_emu as E
    bank = E.bank_bytes()
    print("=== recall RENDER A/B: port vs plugin's own recall+render ===")
    print("N=%d note %d vel %d SR %g\n" % (N, NOTE, VEL, SR))
    npass = nfail = 0
    fails = []
    # Compare only the non-arp patches; robust against a stale pickle that may
    # still contain arp entries. Arp patches are covered by arp_sched_ab +
    # arp_render_ab (this oracle cannot arpeggiate).
    # ⚠ DERIVED FROM THIS BANK, never a constant -- see _arp_patches().
    _arp_here = _arp_patches(bankbytes)
    for idx in [p for p in sorted(ref) if p not in _arp_here]:
        c = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(c, bankbytes, len(bankbytes), idx)
        lib.juno_gui_note_on(c, NOTE, VEL)
        buf = (ctypes.c_float * (2 * N))(); lib.juno_gui_render(c, buf, N)
        inter = struct.unpack("<%dI" % (2 * N), bytes(buf))
        L = list(inter[0::2]); R = list(inter[1::2])
        lib.juno_gui_destroy(c)
        la, ra = ref[idx]
        n, nd, first = cmp_stream(la, ra, L, R)
        tag = 'BIT-EXACT' if nd == 0 else ('FIRST@%d diffs=%d' % (first, nd))
        print("  patch %2d %-18s %s" % (idx, E.patch_name(bank, idx), tag))
        if nd == 0: npass += 1
        else: nfail += 1; fails.append(idx)
    print("\n%d/%d BIT-EXACT%s" % (npass, npass + nfail,
          "" if not fails else "  FAIL: " + str(fails)))
    sys.exit(1 if nfail else 0)   # gate semantics: RED until every patch is bit-exact
elif __name__ == '__main__':
    print("usage: recall_render_ab.py --ref | --port  [patches...]", file=sys.stderr)
    sys.exit(2)
