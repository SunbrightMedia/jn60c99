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
  ticks. The port's render driver (the plugin's, rva 0x320B20; CLAIMS B14) ticks
  at sample 0 and then every tick_period = SR*60/(bpm*24) samples (1000 at
  48000 / 120, no host tempo), and an arp event carries the sample of its tick:
  tick = smp // tick_period + 1, the reference's 1-based transport call.

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

THE SCATTER GRID (--ref-grid / --port-grid, task #62): every SCATTER TYPE (0..9) x every SCATTER
DEPTH the plugin's setter takes (-7..7: patterns 0..14 of the type's slab), one held note and a held
C major chord: 300 schedules of the plugin's own arp against carp.c. The plugin side: the controller
setters of the host parameter entry (rva 0x3C7AE0, cases 831..835, READ: SW 0x3C49F0, TYPE 0x3C4E50,
STEP 0x3C49B0, SCATTER TYPE 0x3C4F10, SCATTER DEPTH 0x3C4EE0), in that order, on all 9 units; the
port side: the record of arp patch 1 with both fields written as whole int8x4 values (the high
nibbles the sign) through juno_gui_apply_bank (the recall model: juno_bank_scatter, then the port's
setters). It replaces the one-time 330/330 sweep of a Python model (lost with an old container) that
tests/test_arp_pattern.c's goldens came from. Its first run drove only SW / TYPE / STEP on the plugin
side -- the plugin stayed at the built pattern (0, 7) and 189 of 220 differed: the harness, not the
port (playbook 184). --port-grid --tooth: the port is given the negated depth -- it must FAIL.
  python3 arp_sched_ab.py --ref-grid
  python3 arp_sched_ab.py --port-grid [--tooth | --reach-tooth]   (--reach-tooth: a blind plugin side; exit 0 = it bites)

THE UNIT TEST'S GOLDENS (task #62): tests/test_arp_pattern.c's five cases (ARPEGGIO TYPE / STEP,
SCATTER TYPE / DEPTH, held keys with their velocities) played by the plugin's own arp. Its goldens
came from a lost model that the plugin does NOT play (4 of 5 differ: velocities, one note); they are
now tests/arp_pattern_golden.h, written from the plugin by --emit-goldens, and the test plays the
port's product path (juno_gui_apply_bank + note-ons) against them.
  python3 arp_sched_ab.py --ref-goldens                    the plugin's events -> scratchpad
  python3 arp_sched_ab.py --emit-goldens [PATH]            tests/arp_pattern_golden.h from them
  python3 arp_sched_ab.py --check-goldens [--tooth]        the committed header IS them
  python3 arp_sched_ab.py --port-goldens                   the port's product path == the plugin
"""
import os as _os_jrepo; _JREPO = _os_jrepo.path.dirname(_os_jrepo.path.dirname(_os_jrepo.path.dirname(_os_jrepo.path.abspath(__file__))))  # repo root from this file; never hardcode it (tools/verify/pathcheck.py)
import sys, os, struct, pickle
import refio
sys.path.insert(0, _JREPO + '/tools/verify')

SR = 48000.0
BPM = 120.0                      # carp power-on tempo == the plugin arp step clock
NOTE, VEL = 60, 105
NTICKS = 96
ARPS = [1, 9, 17, 25, 33, 41, 49]
PKL = os.environ.get('JUNO_ARP_SCHED_PKL', _JREPO + '/scratchpad/arp_sched_ref.pkl')

TICK_PERIOD = round(SR * 60.0 / (BPM * 24.0))   # 1000 @ 48k/120
GRID_PKL = os.environ.get('JUNO_ARP_GRID_PKL', _JREPO + '/scratchpad/arp_grid_ref.pkl')
GRID_BASE = 1                                   # an arp patch: SW on
SCATTER_TYPE_LO, SCATTER_DEPTH_LO = 322, 330    # the fields' low bytes, record offsets (src/juno_apply.c: leaves 92, 93)
GRID_HELD = ((60,), (60, 64, 67))


def grid_configs():
    only = os.environ.get('JUNO_ARP_GRID_ONLY')       # "t:d,t:d": a subset (a smoke run; with its own PKL)
    pick = set(tuple(int(x) for x in td.split(':')) for td in only.split(',')) if only else None
    return [(t, d, h) for t in range(10) for d in range(-7, 8) for h in GRID_HELD if pick is None or (t, d) in pick]


def grid_bank(bank, t, d):
    """the bank with patch GRID_BASE's SCATTER TYPE = t and DEPTH = d, each a whole int8x4 (8 nibbles,
    two's complement: the high nibbles carry the sign), at the record offsets of their low bytes - 6"""
    b = bytearray(bank)
    rec = 23 + GRID_BASE * 20223                 # the bank header, the record stride (e2e_emu)
    for lo, v in ((SCATTER_TYPE_LO, t), (SCATTER_DEPTH_LO, d)):
        u = v & 0xFFFFFFFF
        for k in range(8):
            b[rec + lo - 6 + k] = (u >> (4 * (7 - k))) & 0xF
    return bytes(b)


GOLD_PKL = os.environ.get('JUNO_ARP_GOLD_PKL', _JREPO + '/scratchpad/arp_golden_ref.pkl')
ARP_SW_LO, ARP_TYPE_LO, ARP_STEP_LO = 298, 306, 314   # the arp fields' low bytes (src/juno_apply.c juno_bank_arp_raw)


# tests/test_arp_pattern.c's five cases (their names from the lost model's goldens they replace):
# (name, ARPEGGIO TYPE, SCATTER TYPE, SCATTER DEPTH, ARPEGGIO STEP, held keys [(note, velocity)])
GOLD_CASES = [
    ('default_1note',      0, 0,  0, 0, [(60, 100)]),
    ('chord4_slab7sub10',  0, 7,  3, 0, [(60, 100), (64, 110), (67, 120), (72, 90)]),
    ('vel71_slab1sub3',    0, 1, -4, 0, [(60, 100), (67, 120)]),
    ('dense_slab6sub2_r1', 0, 6, -5, 1, [(48, 90), (52, 100), (55, 110), (60, 120)]),
    ('down_slab7sub10_r1', 2, 7,  3, 1, [(60, 100), (64, 110), (67, 120), (72, 90)]),
]
GOLD_H = _JREPO + '/tests/arp_pattern_golden.h'


def golden_header(gref):
    """tests/arp_pattern_golden.h from the plugin's events (deterministic text)"""
    L = ['/* arp_pattern_golden.h -- GENERATED by tools/verify/arp_sched_ab.py --emit-goldens from the PLUGIN\'s',
         ' * own arp (JUNO60.vst3 under Unicorn): patch 1 of the factory bank with ARPEGGIO SW / TYPE / STEP and',
         ' * SCATTER TYPE / DEPTH set, the controller setters of the host parameter entry (rva 0x3C49F0, 0x3C4E50,',
         ' * 0x3C49B0, 0x3C4F10, 0x3C4EE0), the keys pressed, %d engine ticks (rva 0x3C6750) at %g Hz / %g BPM.' % (NTICKS, SR, BPM),
         ' * Every event the arp sends the assigner: {tick, kind (1 on, 0 off), note, velocity}. Do not edit by',
         ' * hand: tools/repro/regen_check.py (entry arp_golden) regenerates it and compares. */',
         '#ifndef ARP_PATTERN_GOLDEN_H', '#define ARP_PATTERN_GOLDEN_H',
         '#define ARP_GOLD_SR %d' % int(SR), '#define ARP_GOLD_TICK %d' % TICK_PERIOD, '#define ARP_GOLD_NTICKS %d' % NTICKS,
         'typedef struct { int tick, kind, note, vel; } arp_gold_ev;',
         'typedef struct { const char *name; int type, slab, depth, step, nheld; int held[4][2]; int nev; const arp_gold_ev *ev; } arp_gold_case;']
    for (name, typ, slab, depth, step, held) in GOLD_CASES:
        ev = [e for e in gref[name]['ev'] if e[0] <= NTICKS]
        L.append('static const arp_gold_ev ARP_GOLD_%s[%d] = {' % (name, len(ev)))
        for i in range(0, len(ev), 6):
            L.append('    ' + ' '.join('{%d,%d,%d,%d},' % tuple(e) for e in ev[i:i + 6]))
        L.append('};')
    L.append('static const arp_gold_case ARP_GOLD[%d] = {' % len(GOLD_CASES))
    for (name, typ, slab, depth, step, held) in GOLD_CASES:
        n = len([e for e in gref[name]['ev'] if e[0] <= NTICKS])
        L.append('    { "%s", %d, %d, %d, %d, %d, { %s }, %d, ARP_GOLD_%s },' % (
            name, typ, slab, depth, step, len(held), ', '.join('{%d,%d}' % h for h in held), n, name))
    L += ['};', '#define ARP_GOLD_N %d' % len(GOLD_CASES), '#endif', '']
    return '\n'.join(L)


def field_bank(bank, fields):
    """the bank with patch GRID_BASE's int8x4 fields set: {low byte record offset: value}"""
    b = bytearray(bank)
    rec = 23 + GRID_BASE * 20223
    for lo, v in fields.items():
        u = v & 0xFFFFFFFF
        for k in range(8):
            b[rec + lo - 6 + k] = (u >> (4 * (7 - k))) & 0xF
    return bytes(b)


def parse_patches(argv):
    ps = [int(a) for a in argv if a.lstrip('-').isdigit()]
    return ps or ARPS


if len(sys.argv) > 1 and sys.argv[1] in ('--ref', '--ref-grid', '--ref-goldens'):
    import e2e_emu as E
    import real_recall as R
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8)
    IB = E.IB
    CTRL_SW, CTRL_TYPE, CTRL_STEP = IB + 0x3C49F0, IB + 0x3C4E50, IB + 0x3C49B0
    TRANSPORT = IB + 0x3C6750
    leaves = R.leaf_table(); bank = E.bank_bytes()
    FX = [(1179, 3057), (1181, 3060)]

    SCAT_TYPE, SCAT_DEPTH = IB + 0x3C4F10, IB + 0x3C4EE0     # the controller's SCATTER setters (READ)

    def cap_ref(patch, bk=None, notes=(NOTE,), scatter=None):
        e = E.E2E(); e.build(SR); e.snap_all()
        uc = e.uc
        def u64(a): return int.from_bytes(uc.mem_read(a, 8), 'little')
        blob = E.patch_blob(bank if bk is None else bk, patch)
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
            if scatter is not None:                            # dispatch cases 834 / 835: r8 = 0
                e.call(SCAT_TYPE, rcx=c, rdx=scatter[0] & 0xFFFFFFFFFFFFFFFF, r8=0)
                e.call(SCAT_DEPTH, rcx=c, rdx=scatter[1] & 0xFFFFFFFFFFFFFFFF, r8=0)
        asg0 = e.assign[0]
        vt = u64(asg0)
        ON_FN, OFF_FN = u64(vt + 24), u64(vt + 16)
        e.snap_all(); e.clear_latch(); e.set_ftz()
        for n in notes:
            nv = n if isinstance(n, tuple) else (n, VEL)
            e.note_on(nv[0], nv[1])
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

    if sys.argv[1:2] == ['--ref'] and '--grid' in sys.argv:
        raise SystemExit('use --ref-grid')
    if sys.argv[1] == '--ref-goldens':
        out = {}
        for (name, typ, slab, depth, step, held) in GOLD_CASES:
            bk = field_bank(bank, {ARP_SW_LO: 1, ARP_TYPE_LO: typ, ARP_STEP_LO: step,
                                   SCATTER_TYPE_LO: slab, SCATTER_DEPTH_LO: depth})
            out[name] = cap_ref(GRID_BASE, bk, held, scatter=(slab, depth))
        refio.dump(out, GOLD_PKL)
        print("REF: saved the plugin's arp for %d test_arp_pattern cases (N=%d ticks)" % (len(out), NTICKS))
        sys.exit(0)
    if sys.argv[1] == '--ref-grid':
        out = {}
        for (t, d, h) in grid_configs():
            out[(t, d, h)] = cap_ref(GRID_BASE, grid_bank(bank, t, d), h, scatter=(t, d))
            if d == 7 and h == GRID_HELD[-1]:
                sys.stderr.write("ref grid: scatter type %d done\n" % t)
                sys.stderr.flush()
        refio.dump(out, GRID_PKL)
        print("REF: saved %d grid schedules (scatter type x depth x held, N=%d ticks)" % (len(out), NTICKS))
        sys.exit(0)
    patches = parse_patches(sys.argv[2:])
    out = {}
    for p in patches:
        r = cap_ref(p)
        out[p] = r
        sys.stderr.write("ref patch %2d (%s): SW=%d TYPE=%d STEP=%d  %d events  faults=%d\n" %
                         (p, E.patch_name(bank, p), r['sw'], r['typ'], r['step'], len(r['ev']), r['faults']))
        sys.stderr.flush()
    refio.dump(out, PKL)
    print("REF: saved %d arp schedules (N=%d ticks, note %d vel %d, SR %g, BPM %g)" %
          (len(out), NTICKS, NOTE, VEL, SR, BPM))

elif len(sys.argv) > 1 and sys.argv[1] in ('--check-goldens', '--emit-goldens'):
    # tests/arp_pattern_golden.h is the plugin's own arp on the five cases (`make test` grades the port's
    # product path against it with no emulator). --emit-goldens [PATH] writes it from the reference;
    # --check-goldens: the committed file IS that text (--tooth: one velocity moved, must FAIL).
    gref = pickle.load(open(GOLD_PKL, 'rb'))
    text = golden_header(gref)
    if sys.argv[1] == '--emit-goldens':
        out = sys.argv[2] if len(sys.argv) > 2 else GOLD_H
        open(out, 'w').write(text)
        print("wrote %s (%d cases)" % (out, len(GOLD_CASES)))
        sys.exit(0)
    have = open(GOLD_H).read()
    if '--tooth' in sys.argv:
        k = have.index('{1,', have.index('ARP_GOLD_chord4_slab7sub10['))
        e = have.index('}', k)
        f = have[k + 1:e].split(',')
        have = have[:k + 1] + ','.join(f[:3] + [str(int(f[3]) + 1)]) + have[e:]
        print("arp goldens --tooth (one velocity moved): %s" % ('BITES' if have != text else 'DID NOT BITE'))
        sys.exit(0 if have != text else 1)
    nev = sum(len([e for e in gref[c[0]]['ev'] if e[0] <= NTICKS]) for c in GOLD_CASES)
    print("arp goldens: tests/arp_pattern_golden.h %s the plugin's own arp (%d cases, %d events)" % (
        'IS' if have == text else 'IS NOT', len(GOLD_CASES), nev))
    sys.exit(0 if have == text else 1)

elif len(sys.argv) > 1 and sys.argv[1] in ('--port', '--port-grid', '--port-goldens'):
    import ctypes
    import e2e_emu as E
    ref = pickle.load(open(PKL, 'rb')) if sys.argv[1] == '--port' else None
    bankbytes = open(E.BANK, 'rb').read()
    bank = E.bank_bytes()
    import freshlib  # stale-artifact guard (ROADMAP P0.3): refuse a libjuno.so older than src
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_arp_trace.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_int), ctypes.c_int]
    lib.juno_gui_arp_trace_count.restype = ctypes.c_int
    lib.juno_gui_arp_trace_count.argtypes = [ctypes.c_void_p]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]

    def port_sched(patch, bk=None, notes=(NOTE,)):
        bb = bankbytes if bk is None else bk
        c = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(c, bb, len(bb), patch)
        cap = 4096
        buf = (ctypes.c_int * (4 * cap))()
        lib.juno_gui_arp_trace(c, buf, cap)
        for n in notes:
            nv = n if isinstance(n, tuple) else (n, VEL)
            lib.juno_gui_note_on(c, nv[0], nv[1])
        nrender = NTICKS * TICK_PERIOD + TICK_PERIOD
        out = (ctypes.c_float * (2 * nrender))()
        lib.juno_gui_render(c, out, nrender)
        ne = lib.juno_gui_arp_trace_count(c)
        sched = [(buf[4 * i], buf[4 * i + 1], buf[4 * i + 2], buf[4 * i + 3]) for i in range(ne)]
        lib.juno_gui_destroy(c)
        # sample -> tick
        return [(smp // TICK_PERIOD + 1, kind, note, vel) for (smp, kind, note, vel) in sched]

    def gaps(ev):
        ts = [e[0] for e in ev]
        return [ts[i + 1] - ts[i] for i in range(len(ts) - 1)]

    if sys.argv[1] == '--port-goldens':
        # the same five cases through the port's recall model (juno_gui_apply_bank + note-ons) against
        # the plugin's own arp: every event, its tick included
        gref = pickle.load(open(GOLD_PKL, 'rb'))
        bad = 0
        for (name, typ, slab, depth, step, held) in GOLD_CASES:
            bk = field_bank(bankbytes, {ARP_SW_LO: 1, ARP_TYPE_LO: typ, ARP_STEP_LO: step,
                                        SCATTER_TYPE_LO: slab, SCATTER_DEPTH_LO: depth})
            rev = [e for e in gref[name]['ev'] if e[0] <= NTICKS]
            pev = [e for e in port_sched(GRID_BASE, bk, held) if e[0] <= NTICKS]
            ok = [tuple(e) for e in rev] == [tuple(e) for e in pev]
            bad += not ok
            i = next((i for i in range(max(len(rev), len(pev))) if (rev[i] if i < len(rev) else None) !=
                      (pev[i] if i < len(pev) else None)), None)
            print("  %-20s %3d plugin events: %s" % (name, len(rev), 'the port plays them' if ok else
                  'DIFFER at #%d: plugin %s port %s' % (i, rev[i] if i < len(rev) else None, pev[i] if i < len(pev) else None)))
        print("arp golden cases: %d/5 through the port's recall model == the plugin's own arp" % (5 - bad))
        sys.exit(1 if bad else 0)

    if sys.argv[1] == '--port-grid':
        gref = pickle.load(open(GRID_PKL, 'rb'))
        tooth = '--tooth' in sys.argv
        if '--reach-tooth' in sys.argv:              # a blind reference (one schedule per held set): must FAIL
            first = {}
            for k in grid_configs():
                first.setdefault(k[2], gref[k])
            gref = {k: first[k[2]] for k in grid_configs()}
        bad = []
        # REACH: the plugin side must SEE the grid. Its first run drove no SCATTER setter and gave ONE
        # schedule per held set for all 220 inputs -- 189 "divergences" that were the harness's
        # (playbook 184). Every type x depth that the plugin plays differently is a distinct schedule.
        for h in GRID_HELD:
            keys = [k for k in grid_configs() if k[2] == h]
            nd = len(set(tuple(tuple(e) for e in gref[k]['ev'] if e[0] <= NTICKS) for k in keys))
            print("  reach: held %s: %d distinct plugin schedules over %d type x depth inputs" % (h, nd, len(keys)))
            if len(keys) > 1 and nd < 2:
                print("arp scatter grid: REACH FAILED -- the plugin side gives one schedule for every input "
                      "(the reference does not see the scatter)")
                if '--reach-tooth' in sys.argv:
                    print("arp scatter grid --reach-tooth: BITES")
                    sys.exit(0)
                sys.exit(1)
        if '--reach-tooth' in sys.argv:
            print("arp scatter grid --reach-tooth: DID NOT BITE")
            sys.exit(1)
        for (t, d, h) in grid_configs():
            rev = [e for e in gref[(t, d, h)]['ev'] if e[0] <= NTICKS]
            pev = [e for e in port_sched(GRID_BASE, grid_bank(bankbytes, t, -d if tooth else d), h) if e[0] <= NTICKS]
            same = ([e[1:] for e in rev] == [e[1:] for e in pev] and gaps(rev) == gaps(pev) and
                    ((rev[0][0] == pev[0][0]) if (rev and pev) else rev == pev))
            if not same:
                bad.append((t, d, h))
                if len(bad) <= 5 and not tooth:
                    i = next((i for i in range(max(len(rev), len(pev)))
                              if (rev[i] if i < len(rev) else None) != (pev[i] if i < len(pev) else None)), 0)
                    print("  DIVERGE type %d depth %+d held %s: first diff @#%d plugin %s port %s" % (
                        t, d, h, i, rev[i] if i < len(rev) else None, pev[i] if i < len(pev) else None))
        n = len(grid_configs())
        if tooth:
            print("arp scatter grid --tooth (the port given the negated depth): %s (%d of %d differ)" % (
                'BITES' if bad else 'DID NOT BITE', len(bad), n))
            sys.exit(0 if bad else 1)
        print("arp scatter grid: %d/%d schedules MATCH the plugin's own arp%s" % (n - len(bad), n, '' if not bad else ' -- %d DIVERGE' % len(bad)))
        sys.exit(1 if bad else 0)

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
