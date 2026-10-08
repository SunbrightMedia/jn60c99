#!/usr/bin/env python3
"""host_edit_gate.py -- HOST-ROLE parameter edits (DAW automation) on a RUNNING
engine, plugin vs port, audio + state, no snap (CLAIMS B7).

A DAW that automates a panel parameter calls the plugin's host parameter entry
(rva 0x3C7AE0): the setter runs with flag 0 on all 9 units, and in that role
most setters RAMP their cells (4..96 ms, the record's stored target decides
whether a ramp starts at all) instead of writing them. Every other gate edits
through a recall. This gate drives the entry itself, renders between edits and
never snaps, so the ramps run in the renders as they do in a DAW.

Per chain (one engine per side, one host rate):
    settled recall of a base record -> script of
      ('host', i, v)   plugin: APPLY(pid of host param i, v); port: juno_gui_host_set
      ('lrecall', ...) a live patch change (as warm_render_gate.py live)
      ('on'/'off', n), ('render', n), ('check',)
Compares every rendered sample (L and R bits) and, at every check, the state
each plugin unit renders (voice v from unit v, the master from unit 8) and
the ramp records of the 798 ramped cells (stored target and active always;
start, increment, accumulator and step while active): the hidden state that
decides whether the NEXT edit glides.

FAMILIES (--ref builds the scripts and stores them; --port replays them)
  each    every host parameter: three edits 40 / 250 / 900 samples apart
          (edits land inside and after the ramps) with two notes held
  fx      FX parameters under every EFFECT TYPE / DELAY TYPE in force, the type
          parameters themselves included, with a note sounding
  level   DELAY LEVEL 0/1/2 and REVERB LEVEL 0/1/2/3 sequences (the on-flag
          hysteresis, the reverb on/off threshold and its tank clear)
  seed    seeded legal records, 16 random edits of random parameters at random
          gaps (10..700 samples), notes on and off
  mix     host edits interleaved with live patch changes (a recall lands while
          host ramps are in flight, and the next edit meets the targets the
          recall left)
  law     one chain per rule the census alone could not key: VCF CUTOFF's
          step-dependent ramp time, PORTAMENTO under POLY + LEGATO and the porta
          gate, the arp refresh gated on the processor's arp state, the DELAY
          TYPE 1 instance's kept tap time, DELAY TYPE switches under the DELAY
          LEVEL on-flag off / on / held by hysteresis
  tune    MASTER TUNE (a SYSTEM parameter, no patch slot): edits inside and
          after its 4 ms ramps, across live patch changes, out of range
ARPEGGIO SW is edited only with no note held, and switched off before the next
note: the oracle has no transport clock and cannot arpeggiate (as
seed_recall_gate.py HOLD).

LIMITS, stated: all 79 panel parameters; out-of-range host values included
(the law family); host rates 44100 / 48000 / 96001.

TOOTH (--tooth): seventeen named defects must each turn --port red: the
settled re-recall (the old port), the scratch recall meeting live ramps, the
cutoff time law, the porta gate's restore value, the recall's re-send of the
kept tap, the reverb fade in double, the arp gate, the POLY+LEGATO skip, an
out-of-range value clamped instead of dropped, the H leaves from the recall,
the cutoff step from the record, OCTAVE SHIFT re-running the recall, the 86
build-stale ramp targets, MASTER TUNE reaching no engine cell (the old A20
claim), MASTER TUNE from the recall, MASTER TUNE's ramp time, DELAY TYPE
assuming the DELAY LEVEL on-flag set. One reach probe
is printed, not graded (the kept vs current tap on a switch to type 1): no
path observes it.

TWO-PROCESS RULE: --ref (Unicorn only) -> scratchpad/host_edit_ref.pkl;
--port (libjuno only) reads it.

FP MODE: the port runs in the oracle's FP mode (DAZ, no FTZ; playbook 120).

USAGE
    python3 tools/verify/host_edit_gate.py --ref
    python3 tools/verify/host_edit_gate.py --port [-v] [--chain N]
    python3 tools/verify/host_edit_gate.py --tooth
    python3 tools/verify/host_edit_gate.py --ref-trace N; --port-trace N -v
                          (chain N with a check after every event: where it parts)
"""
import gc
import os
import re
import sys
import pickle
import refio
import random
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
# HOST_EDIT_REF: another reference file, so a run cannot meet the one a full
# `make verify` in a snapshot tree is using (the snapshot shares scratchpad/)
REF_PKL = os.environ.get('HOST_EDIT_REF') or os.path.join(SCRATCH, 'host_edit_ref.pkl')
TRACE_PKL = os.path.join(SCRATCH, 'host_edit_trace_%d.pkl')

HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
RATES = [44100.0, 48000.0, 96001.0]
REC_DTYPE, REC_ETYPE = 650, 634
APPLY_RVA, POPULATE_RVA, MAP_RVA = 0x3C7AE0, 0xAD5A0, 0xCB0E18
DB_RANGE_RVA = 0x98c040
NOTES = [48, 55, 60, 64, 67, 72, 52, 59]
SHARED_LO, SHARED_HI = 84272, 84436
RR_BASE = int(re.search(r'#define\s+JUNO_RR_BASE\s+(\d+)u',
                        open(os.path.join(REPO, 'src', 'juno_engine.h')).read()).group(1))   # 32-byte header


def host_table():
    """[(host index, name, record offset)] from src/juno_hostparams.c"""
    src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
    return [(k, m.group(1).strip(), int(m.group(2))) for k, m in
            enumerate(re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),', src))]


def record_bank(bank, base, sets):
    rec = bytearray(bank[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for off, v in sets.items():
        rec[off] = (v >> 4) & 0xF
        rec[off + 1] = v & 0xF
    return bytes(bank[:HEADER]) + bytes(rec)


# --------------------------------------------------------------------- oracle
def oracle_params(e, E, S):
    """{host index: (name, dispatch index, pid, lo, hi)} for every host param
    the plugin's parameter map holds, read from the plugin (POPULATE must have
    run on e)."""
    uc = e.uc
    q = lambda x: int.from_bytes(uc.mem_read(x, 8), 'little')
    pid_of = {}
    seen = set()

    def walk(n):
        if not n or n in seen or uc.mem_read(n + 25, 1)[0]:
            return
        seen.add(n)
        walk(q(n))
        pid, idx = struct.unpack('<II', uc.mem_read(n + 28, 8))
        pid_of[idx] = pid
        walk(q(n + 16))

    walk(q(q(E.IB + MAP_RVA) + 8))
    roff_to = {off: d for d, off, kind in S.leaf_slots()}
    # leaves the harness recall does not carry, by their dispatch index
    # (coverage_leaves.tsv): the host-only fine leaves, the signed OCTAVE SHIFT
    # and the SYSTEM parameter MASTER TUNE (dispatch 20: host_census_mt.py)
    by_name = {'LFO RATE H': 878, 'VCF CUTOFF FREQ H': 1029, 'OCTAVE SHIFT': 836, 'MASTER TUNE': 20}
    # the host entry subtracts these before the database range check (rva
    # 0x3C7AE0, READ: dispatch 20/665/707 -> value - 100, 22 -> - 12, 769 -> - 11):
    # the HOST value range is the database range shifted back
    host_offset = {20: 100, 665: 100, 707: 100, 22: 12, 769: 11}
    out = {}
    for k, name, roff in host_table():
        d = by_name.get(name, roff_to.get(roff))
        if d is None or d not in pid_of:
            continue
        lo, hi = struct.unpack('<ii', uc.mem_read(E.IB + DB_RANGE_RVA + 16 * d, 8))
        o = host_offset.get(d, 0)
        out[k] = (name, d, pid_of[d], lo + o, hi + o)
    return out


def scripts(bank, params):
    """[(family, rate, script)]. --ref only."""
    sys.path.insert(0, HERE)
    import real_recall as R
    import seed_recall_gate as S
    import warm_chain_gate as W
    leaf = dict(R.leaf_table())
    arp = leaf[831] + BLOB_OFF
    name_to = {v[0]: k for k, v in params.items()}
    ARP_SW = name_to['ARPEGGIO SW']

    def noarp(rb):
        rec = bytearray(rb)
        rec[HEADER + arp] = 0
        rec[HEADER + arp + 1] = 0
        return bytes(rec)

    def rval(rnd, k):
        _, _, _, lo, hi = params[k]
        return rnd.randint(lo, hi)

    out = []
    keys = sorted(params)
    # each: every host param, three edits inside / after the ramps
    rnd = random.Random(11)
    groups = [keys[g::10] for g in range(10)]
    for g, ks in enumerate(groups):
        base = (5 * g + 3) % 64
        sc = [('recall', 'f%d' % base, noarp(record_bank(bank, base, {}))), ('render', 64)]
        held = []
        for k in ks:
            _, _, _, lo, hi = params[k]
            if k == ARP_SW:
                for n in held:
                    sc += [('off', n)]
                held = []
                sc += [('render', 300), ('host', k, 1), ('render', 400), ('check',), ('host', k, 0), ('render', 200)]
                continue
            if not held:
                held = [NOTES[g % 8], NOTES[(g + 3) % 8]]
                sc += [('on', held[0]), ('on', held[1]), ('render', 128)]
            vals = [hi, lo, rnd.randint(lo, hi)] if hi > lo else [lo, lo, lo]
            for v, gap in zip(vals, (40, 250, 900)):
                sc += [('host', k, v), ('render', gap)]
            sc += [('check',)]
        for n in held:
            sc += [('off', n)]
        sc += [('render', 1500), ('check',)]
        out.append(('each', RATES[g % 3], sc))
    # fx: FX parameters under every type in force
    fxk = [k for k in keys if k >= 51]        # EFFECT TYPE .. REVERB DIRECT LEVEL
    ET, DT = name_to['EFFECT TYPE'], name_to['DELAY TYPE']
    for c in range(6):
        rnd = random.Random(500 + c)
        base = (9 * c + 1) % 64
        sc = [('recall', 'fx%d' % c, noarp(record_bank(bank, base, {REC_ETYPE: c, REC_DTYPE: (c + 2) % 6}))),
              ('render', 64), ('on', 60), ('render', 200)]
        for step in range(14):
            if step % 4 == 0:
                sc += [('host', ET, rnd.randint(0, 5)), ('render', rnd.choice((30, 200, 600)))]
                sc += [('host', DT, rnd.randint(0, 5)), ('render', rnd.choice((30, 200, 600)))]
            k = rnd.choice(fxk)
            sc += [('host', k, rval(rnd, k)), ('render', rnd.choice((20, 150, 500))), ('check',)]
            if step == 6:
                sc += [('off', 60), ('render', 300), ('on', 64)]
        sc += [('off', 64), ('render', 2048), ('check',)]
        out.append(('fx', RATES[c % 3], sc))
    # level: the on-flag hysteresis and the reverb threshold
    DL, RL = name_to['DELAY LEVEL'], name_to['REVERB LEVEL']
    seqs = [(DL, (2, 1, 0, 1, 2, 0, 2, 1)), (RL, (200, 0, 3, 2, 1, 3, 0, 255))]
    for c in range(6):
        k, seq = seqs[c % 2]
        sc = [('recall', 'lv%d' % c, noarp(record_bank(bank, (13 * c + 2) % 64, {REC_DTYPE: c, REC_ETYPE: (c + 1) % 6}))),
              ('render', 64), ('on', 57), ('render', 300)]
        for t, v in enumerate(seq):
            sc += [('host', k, v), ('render', (60, 400, 1200)[t % 3]), ('check',)]
        sc += [('off', 57), ('render', 1500), ('check',)]
        out.append(('level', RATES[c % 3], sc))
    # seed: random edits on seeded records
    slots, ranges = S.leaf_slots(), S.declared_ranges()
    edit_keys = [k for k in keys if k != ARP_SW]
    for c in range(8):
        rnd = random.Random(900 + c)
        rb, _, _ = S.seed_bank(bank, 8800 + c, slots, ranges, wild=False)
        sc = [('recall', 's%d' % c, noarp(rb)), ('render', 64)]
        held = []
        for step in range(16):
            r = rnd.random()
            if r < 0.25 and len(held) < 3:
                n = NOTES[rnd.randrange(8)]
                if n not in held:
                    held.append(n)
                    sc += [('on', n)]
            elif r < 0.4 and held:
                sc += [('off', held.pop(0))]
            k = rnd.choice(edit_keys)
            sc += [('host', k, rval(rnd, k)), ('render', rnd.randint(10, 700))]
            if step % 4 == 3:
                sc += [('check',)]
        for n in held:
            sc += [('off', n)]
        sc += [('render', 1024), ('check',)]
        out.append(('seed', RATES[c % 3], sc))
    # law: the rules the census alone could not key, one chain each rule
    #   VCF CUTOFF's ramp time follows the step (1..5 -> 12, 9, 6, 5, 5; 0 -> 15)
    #   PORTAMENTO under POLY + LEGATO skips the porta on/off set; the porta gate
    #   restores the recalled on/off, not the cell a note zeroed
    #   the arp refresh runs only with the processor's arp on (host SW only)
    #   DELAY TIME / TEMPO SYNC re-send the DELAY TYPE 1 instance's kept tap
    CUT, POR, ASG, LEG = name_to['VCF CUTOFF FREQ'], name_to['PORTAMENTO'], name_to['ASSIGN MODE'], name_to['LEGATO']
    ATY, AST, TAP, DTI = name_to['ARPEGGIO TYPE'], name_to['ARPEGGIO STEP'], name_to['DELAY TAP TIME'], name_to['DELAY TIME']
    law = []
    sc = [('recall', 'lw_cut', noarp(record_bank(bank, 12, {}))), ('render', 64), ('on', 60), ('render', 100),
          ('host', CUT, 100), ('render', 300)]
    for v in (101, 104, 104, 99, 104, 103, 101, 102, 100, 110, 109):
        sc += [('host', CUT, v), ('render', 150), ('check',)]
    law.append(sc + [('off', 60), ('render', 800), ('check',)])
    sc = [('recall', 'lw_porta', noarp(record_bank(bank, 20, {}))), ('render', 64),
          ('host', ASG, 0), ('host', LEG, 1), ('host', POR, 140), ('render', 200), ('on', 60), ('render', 300),
          ('on', 64), ('render', 300), ('host', POR, 0), ('render', 100), ('on', 67), ('render', 300), ('check',),
          ('host', POR, 200), ('render', 100), ('off', 60), ('on', 72), ('render', 400), ('check',),
          ('host', LEG, 0), ('host', POR, 90), ('render', 100), ('on', 55), ('render', 400), ('check',)]
    law.append(sc + [('off', 64), ('off', 67), ('off', 72), ('off', 55), ('render', 800), ('check',)])
    sc = [('recall', 'lw_arp', noarp(record_bank(bank, 31, {}))), ('render', 64),
          ('host', ATY, 3), ('render', 50), ('check',), ('host', AST, 2), ('render', 50), ('check',),
          ('host', ARP_SW, 1), ('render', 50), ('check',), ('host', ATY, 1), ('render', 50), ('check',),
          ('host', ARP_SW, 1), ('render', 50), ('host', AST, 4), ('render', 50), ('check',),
          ('recall', 'lw_arp2', noarp(record_bank(bank, 33, {}))), ('render', 50),
          ('host', ATY, 5), ('render', 50), ('check',), ('host', ARP_SW, 0), ('render', 50),
          ('host', AST, 1), ('render', 50), ('check',)]
    law.append(sc + [('render', 400), ('check',)])
    sc = [('recall', 'lw_tap', noarp(record_bank(bank, 40, {REC_DTYPE: 1}))), ('render', 64), ('on', 62), ('render', 200),
          ('host', TAP, 5), ('render', 40), ('host', TAP, 80), ('render', 600), ('check',),
          ('host', DT, 0), ('render', 300), ('host', TAP, 20), ('render', 300), ('check',),
          ('host', DT, 1), ('render', 300), ('check',), ('host', TAP, 33), ('render', 15),
          ('lrecall', 'lw_tap2', noarp(record_bank(bank, 41, {REC_DTYPE: 1}))), ('render', 600),
          ('lrecall', 'lw_tap3', noarp(record_bank(bank, 42, {REC_DTYPE: 0}))), ('render', 300), ('check',),
          ('host', DTI, 77), ('render', 300), ('check',)]
    law.append(sc + [('off', 62), ('render', 800), ('check',)])
    #   a value outside the parameter's database range reaches no setter (dropped;
    #   HPF TYPE maps to v != 0); the host-only H floats; OCTAVE SHIFT's empty set
    OOR = [(name_to['EFFECT TYPE'], 9), (name_to['VCF CUTOFF FREQ'], 300), (name_to['HPF TYPE'], 5),
           (TAP, 101), (name_to['REVERB TYPE'], 6), (name_to['OCTAVE SHIFT'], 5), (name_to['OCTAVE SHIFT'], -4),
           (name_to['LFO RATE H'], 0x3f800001), (name_to['DELAY TYPE'], 200), (name_to['ENV1 ATTACK'], -1)]
    sc = [('recall', 'lw_oor', noarp(record_bank(bank, 44, {}))), ('render', 64), ('on', 64), ('render', 200)]
    for k, v in OOR:
        sc += [('host', k, v), ('render', 120), ('check',)]
    for k, v in ((name_to['VCF CUTOFF FREQ H'], 0x3e800000), (name_to['LFO RATE H'], 0x3f000000),
                 (name_to['OCTAVE SHIFT'], 2), (name_to['VCF CUTOFF FREQ H'], 0x3f400000), (name_to['OCTAVE SHIFT'], -3),
                 (name_to['VCF CUTOFF FREQ'], 90), (name_to['LFO RATE H'], 0)):
        sc += [('host', k, v), ('render', 150), ('check',)]
    law.append(sc + [('off', 64), ('render', 800), ('check',)])
    #   DELAY TYPE re-sends DELAY LEVEL, whose on-flag (hysteresis) decides the
    #   feedback cell's first set (0 when off): switches with the flag off, on,
    #   and held by hysteresis at DELAY LEVEL 1, under three EFFECT TYPEs
    DL = name_to['DELAY LEVEL']
    for c, et in enumerate((0, 2, 5)):
        rnd = random.Random(1900 + c)
        sc = [('recall', 'lw_dt%d' % c, noarp(record_bank(bank, (17 * c + 38) % 64, {REC_ETYPE: et, REC_DTYPE: 5, 120: 0}))),
              ('render', 64), ('on', 57), ('render', 200)]
        for dl in (0, 1, 2, 1, 0):
            sc += [('host', DL, dl), ('render', 60)]
            for to in rnd.sample(range(6), 6):
                sc += [('host', DT, to), ('render', rnd.choice((20, 150, 500))), ('check',)]
        law.append(sc + [('off', 57), ('render', 800), ('check',)])
    for c, sc in enumerate(law):
        out.append(('law', RATES[c % 3], sc))
    # tune: MASTER TUNE ramps every voice's tune cell over 4 ms (curve 55 of the
    # host value); a patch change leaves it (a SYSTEM parameter); 201 is dropped
    MT = name_to['MASTER TUNE']
    P = W.pool()
    for c in range(3):
        rnd = random.Random(1700 + c)
        n0, b0, s0 = P[rnd.randrange(len(P))]
        sc = [('recall', n0, noarp(record_bank(bank, b0, s0))), ('render', 64), ('on', 60), ('render', 200),
              ('host', MT, 37), ('render', 100), ('check',), ('host', MT, 163), ('render', 40),
              ('host', MT, 100), ('render', 300), ('check',), ('host', MT, (0, 200, 1)[c]), ('render', 250)]
        for step in range(4):
            n, b, s = P[rnd.randrange(len(P))]
            sc += [('lrecall', n, noarp(record_bank(bank, b, s))), ('render', rnd.choice((30, 200))), ('check',),
                   ('host', MT, rnd.randint(0, 200)), ('render', rnd.choice((15, 90, 600))), ('check',)]
            if step == 1:
                sc += [('off', 60), ('on', 67), ('render', 300), ('check',)]
        sc += [('host', MT, 201), ('render', 100), ('check',), ('host', MT, -1), ('render', 100), ('check',),
               ('host', MT, 55), ('render', 500), ('off', 67), ('render', 800), ('check',)]
        out.append(('tune', RATES[c % 3], sc))
    # mix: host edits and live patch changes
    P = W.pool()
    for c in range(4):
        rnd = random.Random(1300 + c)
        n0, b0, s0 = P[rnd.randrange(len(P))]
        sc = [('recall', n0, noarp(record_bank(bank, b0, s0))), ('render', 64), ('on', 60), ('render', 100)]
        for step in range(12):
            if step % 3 == 2:
                n, b, s = P[rnd.randrange(len(P))]
                sc += [('lrecall', n, noarp(record_bank(bank, b, s))), ('render', rnd.choice((30, 120, 400)))]
            k = rnd.choice(edit_keys)
            sc += [('host', k, rval(rnd, k)), ('render', rnd.choice((15, 80, 300, 900))), ('check',)]
        sc += [('off', 60), ('render', 1500), ('check',)]
        out.append(('mix', RATES[c % 3], sc))
    return out


def voice_regions(v):
    import warm_render_gate as WR
    return WR.voice_regions(v)


def master_ranges():
    import warm_render_gate as WR
    return WR.master_ranges()


def oracle_live_recall(e, rb, lt, E, R, RR):
    """the plugin's recall into the running engine, no snap (warm_render_gate.py live)"""
    blob = E.patch_blob(rb, 0)
    late = RR.late_leaves(blob, R)
    for (d, bb) in lt:
        R.wr_desc(e, d, R.dec(blob, bb))
    for (d, v) in late:
        R.wr_desc(e, d, v)
    for u in range(9):
        for (d, _) in lt:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
        for (d, _) in late:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
    e.assigner_notify()


def dense(sc):
    """the same script with a check after every event (--trace)"""
    out = []
    for ev in sc:
        out.append(ev)
        if ev[0] != 'check':
            out.append(('check',))
    return out


def ramp_map(e, E):
    """{composite cell: record address} for every ramped cell: voice v's cells
    from unit v's records, the master's from unit 8's (the port's one state)"""
    import warm_render_gate as WR
    uc = e.uc
    q = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
    out = {}
    for u in range(9):
        st = e.state[u]
        desc, desc_end, base = q(st + 0x38), q(st + 0x40), q(st + 0x58)
        for i in range((desc_end - desc) // 40):
            if int.from_bytes(uc.mem_read(desc + 40 * i + 0xC, 4), 'little') != 1:
                continue
            ix = int.from_bytes(uc.mem_read(desc + 40 * i + 0x14, 4), 'little')
            rec = base + 40 * ix
            c = q(rec) - st
            owner = 8
            for v in range(8):
                if any(a <= c < b for a, b in WR.voice_regions(v)[:2]):
                    owner = v
            if SHARED_LO <= c < SHARED_HI:
                owner = 0
            if owner == u:
                out[c] = rec
    return out


def oracle_records(e, rmap):
    """(target, active, start, incr, accum, step) bits per ramped cell, sorted"""
    out = []
    for c in sorted(rmap):
        raw = bytes(e.uc.mem_read(rmap[c] + 8, 32))
        incr, accum, start, target = struct.unpack('<4I', raw[0:16])
        active = raw[20]
        step = struct.unpack('<i', raw[28:32])[0]
        out.append((target, active, start, incr, accum, step))
    return out


def build_ref(trace=None):
    import zlib
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    import seed_recall_gate as S
    from array import array
    bank = E.bank_bytes()
    lt = R.leaf_table()
    e0 = RR.build_engine(E, 44100.0)
    e0.call(E.IB + POPULATE_RVA, count=200_000_000)
    params = oracle_params(e0, E, S)
    del e0
    gc.collect()
    ch = scripts(bank, params)
    if trace is not None:
        fam, rate, sc = ch[trace]
        ch = [(fam, rate, dense(sc))]
    ref = {'_params': params, '_chains': []}
    for ci, (fam, rate, sc) in enumerate(ch):
        e = RR.build_engine(E, rate)
        e.call(E.IB + POPULATE_RVA, count=200_000_000)
        rmap = ramp_map(e, E)
        recs = []
        outs = []
        for ev in sc:
            if ev[0] == 'recall':
                RR.apply_recall(e, 0, ev[2], lt, E, R)
            elif ev[0] == 'lrecall':
                oracle_live_recall(e, ev[2], lt, E, R, RR)
            elif ev[0] == 'host':
                _, d, pid, lo, hi = params[ev[1]]
                e.call(E.IB + APPLY_RVA, rcx=e.HOST, rdx=pid, r8=ev[2] & 0xFFFFFFFF, count=60_000_000)
            elif ev[0] == 'on':
                e.note_on(ev[1], 100)
            elif ev[0] == 'off':
                e.note_off(ev[1])
            elif ev[0] == 'render':
                L, Rr = e.render(ev[1])
                outs.append(zlib.compress(array('I', L).tobytes() + array('I', Rr).tobytes(), 6))
            elif ev[0] == 'check':
                parts = []
                for v in range(8):
                    for a, b in voice_regions(v):
                        parts.append(bytes(e.uc.mem_read(e.state[v] + a, b - a)))
                for a, b in master_ranges():
                    parts.append(bytes(e.uc.mem_read(e.state[8] + a, b - a)))
                outs.append(zlib.compress(b''.join(parts), 6))
                if rmap is not None:
                    recs.append(oracle_records(e, rmap))
        ref.setdefault('_recs', {})[ci] = zlib.compress(pickle.dumps(recs), 6)
        ref['_rcells'] = sorted(rmap)
        ref['_chains'].append((fam, rate, [(ev[0], ev[1], zlib.compress(ev[2], 6)) if ev[0] in ('recall', 'lrecall')
                                           else ev for ev in sc]))
        ref[ci] = outs
        del e
        gc.collect()
        sys.stderr.write('ref chain %d %s (%g Hz): %d events\n' % (ci, fam, rate, len(sc)))
        sys.stderr.flush()
    out = REF_PKL if trace is None else TRACE_PKL % trace
    refio.dump(ref, out)
    print('wrote %s (%d chains, %d host params)' % (out, len(ch), len(params)))
    return 0


# ----------------------------------------------------------------------- port
def check_port(trace=None):
    import ctypes
    import zlib
    import numpy as np
    sys.path.insert(0, HERE)
    import freshlib
    pk = TRACE_PKL % trace if trace is not None else REF_PKL
    if not os.path.exists(pk):
        print('MISSING %s -- run --ref first' % pk)
        return 2
    ref = pickle.load(open(pk, 'rb'))
    lib = freshlib.load()
    V, I, F, C = ctypes.c_void_p, ctypes.c_int, ctypes.c_float, ctypes.c_char_p
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [F, I]
    lib.juno_gui_apply_bank.argtypes = [V, C, I, I]
    lib.juno_gui_apply_bank_live.argtypes = [V, C, I, I]
    lib.juno_gui_host_set.argtypes = [V, I, I]
    lib.juno_gui_host_min.argtypes = [I]
    lib.juno_gui_host_max.argtypes = [I]
    lib.juno_gui_state.restype = V
    lib.juno_gui_state.argtypes = [V]
    lib.juno_gui_note_on.argtypes = [V, I, I]
    lib.juno_gui_note_off.argtypes = [V, I]
    lib.juno_gui_render.argtypes = [V, ctypes.POINTER(F), I]
    lib.juno_gui_destroy.argtypes = [V]
    lib.juno_set_fp_oracle_mode.argtypes = [I]
    params = ref['_params']
    mism = 0
    for k, (name, d, pid, lo, hi) in sorted(params.items()):
        if (lib.juno_gui_host_min(k), lib.juno_gui_host_max(k)) != (lo, hi):
            print('RANGE MISMATCH host param %d %s: plugin [%d,%d] port [%d,%d]'
                  % (k, name, lo, hi, lib.juno_gui_host_min(k), lib.juno_gui_host_max(k)))
            mism += 1
    if mism:
        print('GATE: FAIL (%d host ranges differ from the plugin\'s parameter database)' % mism)
        return 1
    red, total = {}, {}
    for ci, (fam, rate, sc) in enumerate(ref['_chains']):
        if ONLY is not None and ci != ONLY:
            continue
        c = lib.juno_gui_create(F(rate), 0)
        lib.juno_set_fp_oracle_mode(1)
        outs = ref[ci]
        oi = 0
        bad = None
        last = None
        ci_check = [0]
        rec_seen = [False]
        recs_want = pickle.loads(zlib.decompress(ref['_recs'][ci])) if '_recs' in ref else None
        for evi, ev in enumerate(sc):
            if trace is not None and ev[0] in ('render', 'on', 'off'):
                last = '#%d %s %s' % (evi, ev[0], ev[1])
            if ev[0] in ('recall', 'lrecall'):
                rb = zlib.decompress(ev[2])
                (lib.juno_gui_apply_bank if ev[0] == 'recall' else lib.juno_gui_apply_bank_live)(c, rb, len(rb), 0)
                last = '#%d %s %s' % (evi, ev[0], ev[1])
            elif ev[0] == 'host':
                lib.juno_gui_host_set(c, ev[1], ev[2])
                last = '#%d host %s=%d' % (evi, params[ev[1]][0], ev[2])
            elif ev[0] == 'on':
                lib.juno_gui_note_on(c, ev[1], 100)
            elif ev[0] == 'off':
                lib.juno_gui_note_off(c, ev[1])
            elif ev[0] == 'render':
                n = ev[1]
                buf = (F * (2 * n))()
                lib.juno_gui_render(c, buf, n)
                got = np.frombuffer(bytes(buf), dtype='<u4')
                want = np.frombuffer(zlib.decompress(outs[oi]), dtype='<u4')
                oi += 1
                gl, gr = got[0::2], got[1::2]
                wl, wr = want[:n], want[n:]
                dd = np.nonzero((gl != wl) | (gr != wr))[0]
                if len(dd) and bad is None:
                    bad = 'after %s: render of %d differs from sample %d (%d samples)' % (last, n, int(dd[0]), len(dd))
                if len(dd) and VERBOSE:
                    print('    [%s] render %d: first diff %d, %d samples; plug %08x port %08x'
                          % (last, n, int(dd[0]), len(dd), int(wl[dd[0]]), int(gl[dd[0]])))
            elif ev[0] == 'check':
                st = lib.juno_gui_state(c)
                parts = []
                for v in range(8):
                    for a, b in voice_regions(v):
                        parts.append(ctypes.string_at(st + a, b - a))
                for a, b in master_ranges():
                    parts.append(ctypes.string_at(st + a, b - a))
                got = np.frombuffer(b''.join(parts), dtype='<u4')
                want = np.frombuffer(zlib.decompress(outs[oi]), dtype='<u4')
                oi += 1
                dd = np.nonzero(got != want)[0]
                if recs_want is not None:
                    want_r = recs_want[ci_check[0]]
                    ci_check[0] += 1
                    rdiff = []
                    for k, cell in enumerate(ref['_rcells']):
                        b = ctypes.string_at(st + RR_BASE + 32 + 32 * k, 24)
                        incr, accum, start, target, active, step = struct.unpack('<4Iii', b)
                        pw = want_r[k]
                        pg = (target, 1 if active else 0, start, incr, accum, step)
                        pw = (pw[0], 1 if pw[1] else 0) + tuple(pw[2:])
                        if pw[:2] != pg[:2] or (pw[1] and pw[2:] != pg[2:]):
                            rdiff.append((cell, ['%x' % x for x in pw], ['%x' % x for x in pg]))
                    if rdiff and not rec_seen[0]:
                        rec_seen[0] = True
                        if VERBOSE or trace is not None:
                            print('    [%s] RECORDS differ at %d cells (plug / port: target active start incr accum step): %s'
                                  % (last, len(rdiff), rdiff[:4]))
                        if bad is None:
                            bad = 'after %s: %d ramp records differ (first cell %d)' % (last, len(rdiff), rdiff[0][0])
                if len(dd) and (bad is None or VERBOSE):
                    offs = []
                    for w in dd[:6]:
                        k = int(w) * 4
                        for v in range(8):
                            for a, b in voice_regions(v):
                                if k < b - a:
                                    offs.append('v%d:%d' % (v, a + k)); k = None; break
                                k -= b - a
                            if k is None:
                                break
                        if k is not None:
                            for a, b in master_ranges():
                                if k < b - a:
                                    offs.append('m:%d' % (a + k)); k = None; break
                                k -= b - a
                    if bad is None:
                        bad = 'after %s: %d state cells differ %s' % (last, len(dd), offs)
                    if VERBOSE:
                        print('    [%s] check: %d cells differ %s  plug %s port %s'
                              % (last, len(dd), offs, ['%08x' % int(want[w]) for w in dd[:6]],
                                 ['%08x' % int(got[w]) for w in dd[:6]]))
        lib.juno_gui_destroy(c)
        total[fam] = total.get(fam, 0) + 1
        if bad:
            red[fam] = red.get(fam, 0) + 1
            print('%s chain %d (%g Hz): %s' % (fam, ci, rate, bad))
    n_red = sum(red.values())
    print('\n=== HOST EDITS (CLAIMS B7): audio + rendered state, red chains per family: %s ==='
          % ', '.join('%s %d/%d' % (f, red.get(f, 0), total[f]) for f in total))
    print('GATE: %s' % ('FAIL' if n_red else 'PASS'))
    return 1 if n_red else 0


VERBOSE = '-v' in sys.argv
ONLY = None


def tooth():
    """Named defects, each found by this gate or a rule it must hold; every one
    must turn --port red. A tooth that does not bite names a rule no chain here
    reaches (printed, and the run fails)."""
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    gate = ['tools/verify/host_edit_gate.py', '--port']
    T = [
        ('he_settled_recall', 'a host edit re-runs the settled recall (the old port)',
         [('gui/juno_bridge.c', 'if (juno_host_edit_known(i) && host_edit_live(c, rec, i, v)) return;',
           'if (0 && host_edit_live(c, rec, i, v)) return;')]),
        ('he_copy_unsettled', 'the scratch recall meets the live ramps in flight',
         [('gui/juno_bridge.c', '        juno_rr_settle(tmp);\n', '')]),
        ('he_cutoff_time_fixed', 'VCF CUTOFF ramps over 24 ms whatever the step',
         [('src/host_edit.c', 'if (t & 0x80) t = cutoff_time(f);', 'if (t & 0x80) t = 5;')]),
        ('he_porta_live_cell', 'the porta gate restores the live cell, not the recalled on/off',
         [('gui/juno_bridge.c', 'c->porta_base = JF(settled, 592);', 'c->porta_base = JF(c->st, 592);')]),
        ('he_tap_not_resent', 'the recall leaving DELAY TYPE 1 does not re-send the kept tap',
         [('src/delay_recall.c', '            memcpy(&JF(state, 4297792), &tb, 4);\n', '            (void)tb;\n')]),
        ('he_fade_in_double', 'the reverb fade steps in double precision (the decompiled literal)',
         [('src/master_render.c', '      v474 = v474 - 0.00039999999f;', '      v474 = v474 - 0.00039999999;')]),
        ('he_arp_ungated', 'the arp refresh runs whatever the processor arp state',
         [('src/host_edit.c', '    if (gated_off(hp, f)) return 0;\n', '')]),
        ('he_poly_legato_ignored', 'PORTAMENTO sets the porta on/off under POLY + LEGATO too',
         [('gui/juno_bridge.c', 'f.pl = host_val(rec, "ASSIGN MODE") == 0 && host_val(rec, "LEGATO") == 1;', 'f.pl = 0;')]),
        ('he_out_of_range_clamped', 'an out-of-range host value is clamped and applied, not dropped',
         [('gui/juno_bridge.c', '    if (v < juno_host_param_min(i) || v > juno_host_param_max(i)) return;\n',
           '    if (v < juno_host_param_min(i)) v = juno_host_param_min(i);\n'
           '    if (v > juno_host_param_max(i)) v = juno_host_param_max(i);\n')]),
        ('he_h_from_recall', 'the H leaves set the recall\'s cell value, not the host value',
         [('src/host_edit.c', 'case JH_HOSTV: bits = (uint32_t)f->to; break;', 'case JH_HOSTV: memcpy(&bits, settled + o->cell, 4); break;')]),
        ('he_cutoff_last_from_record', 'the cutoff step is taken from the record, not the object\'s last value',
         [('gui/juno_bridge.c', '    if (i == host_index("VCF CUTOFF FREQ")) f.from = juno_rr_cut_last(c->st);   /* the object\'s last value */\n', '')]),
        ('he_octave_rerecall', 'OCTAVE SHIFT re-runs the settled recall instead of touching nothing',
         [('gui/juno_bridge.c', '    if (!strcmp(juno_host_param_name(i), "OCTAVE SHIFT")) {',
           '    if (0) {')]),
        ('he_dtype_flag_on', 'DELAY TYPE assumes the DELAY LEVEL on-flag set (the v2 census\'s only context)',
         [('gui/juno_bridge.c', '            f.don1 = JI(tmp, JUNO_DLY_ON) != 0;',
           '            f.don1 = (i == host_index("DELAY TYPE")) ? 1 : (JI(tmp, JUNO_DLY_ON) != 0);')]),
        ('he_tune_unported', 'MASTER TUNE reaches no engine cell (the old A20 claim, the old table)',
         [('src/host_ramp_table.h', '    { 0x00u, 1u, 40u, 0, 200, 0u },   /* 40 MASTER TUNE: key none */',
           '    { 0xFFFFu, 0u, 0u, 0, 0, 0u },   /* 40 MASTER TUNE: no host program */')]),
        ('he_tune_from_recall', 'MASTER TUNE sets the recall\'s cell value, not curve 55 of the host value',
         [('src/host_edit.c', 'case JH_CURVE: v = juno_curve(o->pad, f->to); memcpy(&bits, &v, 4); break;',
           'case JH_CURVE: memcpy(&bits, settled + o->cell, 4); break;')]),
        ('he_tune_time', 'MASTER TUNE glides over 96 ms, not the setter\'s 4 ms',
         [('src/host_edit.c', 'case JH_CURVE: v = juno_curve(o->pad, f->to); memcpy(&bits, &v, 4); break;',
           'case JH_CURVE: v = juno_curve(o->pad, f->to); memcpy(&bits, &v, 4); t = 15; break;')]),
        ('he_build_targets', 'every record seeded with its cell value (the build leaves 86 at 0)',
         [('src/recall_ramp.c', 'r->target = JUNO_RAMP_BUILD0[i] ? 0.0f : JF(st, JUNO_RAMP_CELL[i]);',
           'r->target = JF(st, JUNO_RAMP_CELL[i]);')]),
    ]
    # REACH PROBE, not a tooth: a rule the port keeps as the plugin measures it,
    # whose violation no path observes (printed, never graded): kept tap vs
    # current tap on a switch to DELAY TYPE 1 -- the switch's last arm is the
    # current tap, and the kept tap equals every target a tap arm sets, so the
    # two lists end in the same record state (CLAIMS A20). (The 86 build-stale
    # targets were a probe until the gate compared the records; now a tooth.)
    R = [
        ('he_tap_as_recall', 'a switch to DELAY TYPE 1 arms the current tap, not the kept one',
         [('src/host_edit.c', 'case JH_TAP2: bits = juno_rr_tap2_bits(st); break;',
           'case JH_TAP2: memcpy(&bits, settled + o->cell, 4); break;')]),
    ]
    res = {}
    for name, what, edits in T + R:
        res[name] = run_tooth(name, edits, gate, tail=400)
    print()
    for name, what, edits in T:
        print('%-24s %-12s %s' % (name, {0: 'BITES', 1: 'DID NOT BITE', 2: 'NO VERDICT'}[res[name]], what))
    for name, what, edits in R:
        print('%-24s %-12s %s (reach probe: %s)' % (name, {0: 'BITES', 1: 'NOT SEEN', 2: 'NO VERDICT'}[res[name]], what,
              'a path now reaches it -- make it a tooth' if res[name] == 0 else 'no path observes it'))
    return 0 if all(res[n] == 0 for n, w, e in T) else 1


def main():
    global ONLY
    a = [x for x in sys.argv[1:] if x != '-v']
    if '--chain' in a:
        i = a.index('--chain')
        ONLY = int(a[i + 1])
        del a[i:i + 2]
    if a[:1] == ['--ref']:
        return build_ref()
    if a[:1] == ['--port']:
        return check_port()
    if a[:1] == ['--ref-trace']:
        return build_ref(int(a[1]))
    if a[:1] == ['--port-trace']:
        return check_port(trace=int(a[1]))
    if a[:1] == ['--tooth']:
        return tooth()
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
