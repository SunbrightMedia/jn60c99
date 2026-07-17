#!/usr/bin/env python3
"""arp_sched_ab.py — #96 arp SCHEDULE execution-diff: the PLUGIN's own arp note
schedule (driven under Unicorn) vs the PORT's carp.c schedule, in 24-PPQN ticks.

This closes the residual in docs/PHASE4_ARP_AUDIO_CERT.md: previously the arp
step-engine was proven vs a Python re-implementation (verify_grid 330/330) and the
render was proven vs the plugin (arp_audio_ab 63/63), but carp.c's own schedule was
never diffed DIRECTLY against the plugin's own arp in one comparison.

REFERENCE (process 1, --ref): the plugin under Unicorn.
  build -> recall leaves (as recall_render_ab) -> enable+configure the arp via the
  plugin's OWN controller methods (the exact calls the host param router
  sub_7FF91E027AE0 makes for ARPEGGIO SW/TYPE/STEP: 0x3C49F0 / 0x3C4E50 / 0x3C49B0,
  values = raw preset bytes) -> note_on -> tick the transport sub_7FF91E026750 N
  times, hooking the assigner noteOn(vtbl+24)/noteOff(vtbl+16) to record
  (tick, kind, note, vel) for unit 0. This is the plugin's real CKbdArp schedule,
  post velocity-scale, at the assigner — the same layer the port trace observes.

PORT (process 2, --port): juno_gui_arp_trace on libjuno.so, sample offsets ->
  ticks (tick = round((smp+1)/tick_period), tick_period = round(SR*60/(bpm*24))).

Comparison is OFFSET-CONVENTION-FREE where it matters: we compare the ordered
(kind, note, vel) event sequence AND the inter-event tick gaps, plus the absolute
first-onset tick. A mismatch in any is a real schedule divergence.

STATUS (2026-07-17): GREEN 7/7. This gate EXPOSED and drove the fix for a real
carp.c omission: the plugin's per-beat re-latch sub_7FF91E023C50 (0x3C3C50) arms a
one-shot at arp ENABLE (router+6) and consumes it at the first 24-PPQN beat boundary
(rtrTick % 12 == 0). If a note is held, it re-quantizes the step grid to the beat --
a normal advancing step fired ON the beat (next_step=tick, pat_step=-1) with the
octave cycle reset (oct_shift=0), so the UP selector re-fires the current note while
the UP&DOWN/DOWN selectors (which recompute oct_shift = sel/count) advance. Result:
plugin steps 1,7,12,18,24... not the free-run 1,7,13,19. Implemented in
src/carp.c (carp_arm_beat_requant + the beat-requant block in carp_tick) and
gui/juno_bridge.c (arm on the arp-enable toggle). Proven bit-exact for all 7 factory
arp patches; the exact restart contract was read out of the plugin's own selector
state trajectory (scratchpad/b2_selstate.py).

TWO-PROCESS (mandatory): never build E2E + load libjuno in one process.
  python3 arp_sched_ab.py --ref  [patches...]
  python3 arp_sched_ab.py --port [patches...]
"""
import sys, os, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')

SR = 48000.0
BPM = 120.0                      # carp power-on tempo == the plugin arp step clock
NOTE, VEL = 60, 105
NTICKS = 96
ARPS = [1, 9, 17, 25, 33, 41, 49]
PKL = os.environ.get('JUNO_ARP_SCHED_PKL', '/home/user/jn60c99/scratchpad/arp_sched_ref.pkl')

TICK_PERIOD = round(SR * 60.0 / (BPM * 24.0))   # 1000 @ 48k/120


def parse_patches(argv):
    ps = [int(a) for a in argv if a.lstrip('-').isdigit()]
    return ps or ARPS


if len(sys.argv) > 1 and sys.argv[1] == '--ref':
    import e2e_emu as E
    import real_recall as R
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8)
    IB = E.IB
    CTRL_SW, CTRL_TYPE, CTRL_STEP = IB + 0x3C49F0, IB + 0x3C4E50, IB + 0x3C49B0
    TRANSPORT = IB + 0x3C6750
    leaves = R.leaf_table(); bank = E.bank_bytes()
    FX = [(1179, 3057), (1181, 3060)]

    def cap_ref(patch):
        e = E.E2E(); e.build(SR); e.snap_all()
        uc = e.uc
        def u64(a): return int.from_bytes(uc.mem_read(a, 8), 'little')
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
        sw, typ, step = R.dec(blob, 282), R.dec(blob, 290), R.dec(blob, 298)
        for u in range(9):
            c = u64(e.HOST + 136 + 64 * u)
            e.call(CTRL_SW, rcx=c, rdx=(1 if sw else 0), r8=0)
            e.call(CTRL_TYPE, rcx=c, rdx=typ, r8=0)
            e.call(CTRL_STEP, rcx=c, rdx=step, r8=0)
        asg0 = e.assign[0]
        vt = u64(asg0)
        ON_FN, OFF_FN = u64(vt + 24), u64(vt + 16)
        e.snap_all(); e.clear_latch(); e.set_ftz()
        e.note_on(NOTE, VEL)
        ev = []; cur = [0]
        def hook(uc, addr, size, user):
            this = uc.reg_read(UC_X86_REG_RCX)
            if this != asg0: return
            note = uc.reg_read(UC_X86_REG_RDX) & 0xff
            vel = uc.reg_read(UC_X86_REG_R8) & 0xff
            ev.append((cur[0], 1 if addr == ON_FN else 0, note, vel))
        h1 = uc.hook_add(UC_HOOK_CODE, hook, begin=ON_FN, end=ON_FN)
        h2 = uc.hook_add(UC_HOOK_CODE, hook, begin=OFF_FN, end=OFF_FN)
        faults = 0
        for t in range(NTICKS):
            cur[0] = t + 1
            try: e.call(TRANSPORT, rcx=e.HOST)
            except RuntimeError: faults += 1
        uc.hook_del(h1); uc.hook_del(h2)
        return {'sw': sw, 'typ': typ, 'step': step, 'faults': faults, 'ev': ev}

    patches = parse_patches(sys.argv[2:])
    out = {}
    for p in patches:
        r = cap_ref(p)
        out[p] = r
        sys.stderr.write("ref patch %2d (%s): SW=%d TYPE=%d STEP=%d  %d events  faults=%d\n" %
                         (p, E.patch_name(bank, p), r['sw'], r['typ'], r['step'], len(r['ev']), r['faults']))
        sys.stderr.flush()
    pickle.dump(out, open(PKL, 'wb'))
    print("REF: saved %d arp schedules (N=%d ticks, note %d vel %d, SR %g, BPM %g)" %
          (len(out), NTICKS, NOTE, VEL, SR, BPM))

elif len(sys.argv) > 1 and sys.argv[1] == '--port':
    import ctypes
    import e2e_emu as E
    ref = pickle.load(open(PKL, 'rb'))
    bankbytes = open(E.BANK, 'rb').read()
    bank = E.bank_bytes()
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

    def port_sched(patch):
        c = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(c, bankbytes, len(bankbytes), patch)
        cap = 4096
        buf = (ctypes.c_int * (4 * cap))()
        lib.juno_gui_arp_trace(c, buf, cap)
        lib.juno_gui_note_on(c, NOTE, VEL)
        nrender = NTICKS * TICK_PERIOD + TICK_PERIOD
        out = (ctypes.c_float * (2 * nrender))()
        lib.juno_gui_render(c, out, nrender)
        ne = lib.juno_gui_arp_trace_count(c)
        sched = [(buf[4 * i], buf[4 * i + 1], buf[4 * i + 2], buf[4 * i + 3]) for i in range(ne)]
        lib.juno_gui_destroy(c)
        # sample -> tick
        return [(round((smp + 1) / TICK_PERIOD), kind, note, vel) for (smp, kind, note, vel) in sched]

    def gaps(ev):
        ts = [e[0] for e in ev]
        return [ts[i + 1] - ts[i] for i in range(len(ts) - 1)]

    print("=== arp SCHEDULE A/B: plugin's own arp vs port carp.c (24-PPQN ticks) ===")
    print("N=%d ticks, note %d vel %d, SR %g, BPM %g, tick_period %d\n" % (NTICKS, NOTE, VEL, SR, BPM, TICK_PERIOD))
    npass = nfail = 0; fails = []
    for p in sorted(ref):
        rev = ref[p]['ev']
        pev = port_sched(p)
        # trim both to the render window (port rendered NTICKS+1 tick_periods)
        rev = [e for e in rev if e[0] <= NTICKS]
        pev = [e for e in pev if e[0] <= NTICKS]
        seq_r = [(k, n, v) for (t, k, n, v) in rev]
        seq_p = [(k, n, v) for (t, k, n, v) in pev]
        seq_ok = seq_r == seq_p
        gap_ok = gaps(rev) == gaps(pev)
        first_ok = (rev[0][0] == pev[0][0]) if (rev and pev) else (rev == pev)
        ok = seq_ok and gap_ok and first_ok
        tag = 'MATCH' if ok else ('SEQ' if not seq_ok else '') + ('/GAP' if not gap_ok else '') + ('/FIRST' if not first_ok else '')
        print("  patch %2d %-18s ref %2d ev  port %2d ev  %s" %
              (p, E.patch_name(bank, p), len(rev), len(pev), tag if ok else 'DIVERGE ' + tag))
        if not ok:
            for i in range(max(len(rev), len(pev))):
                a = rev[i] if i < len(rev) else None
                b = pev[i] if i < len(pev) else None
                if a != b:
                    print("      first diff @#%d: plugin %s  port %s" % (i, a, b))
                    break
            nfail += 1; fails.append(p)
        else:
            npass += 1
    print("\n%d/%d schedules MATCH%s" % (npass, npass + nfail, "" if not fails else "  DIVERGE: " + str(fails)))
    sys.exit(1 if nfail else 0)

else:
    print("usage: arp_sched_ab.py --ref | --port  [patches...]", file=sys.stderr)
    sys.exit(2)
