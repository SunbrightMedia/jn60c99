#!/usr/bin/env python3
"""ramp_ab_emu.py -- ORACLE side of the JUNO RAMP A/B (process A).

docs/GATE_PARITY.tsv row `ramp_smoothing`. The JX-3P got a ramp gate on
2026-08-26; the JUNO had `src/juno_ramp.c` transcribed for months with NO
differential gate at all. That was not a guess: `ramp_const` is a MUTATION
SURVIVOR -- the mutation harness changes a ramp constant, rebuilds, and every
gate in `make verify` stays green. A survivor is a gate that must be written.

This drives the plugin's OWN ramp engine under Unicorn:
    start  sub_1803C2E80(r, target, time_ms, subdiv)
    step   sub_1803C2E00(r)
    reset  sub_1803C2E60(r)
over RANDOM SEEDED ramp configurations, and pickles every intermediate state
for the ctypes side. Random, not patch-derived: a ramp's behaviour is a
function of (start, target, time_ms, subdiv, rate), and the factory bank pins
four of those five.

The value spread deliberately includes the classes that break naive ports:
  * time_ms so large the per-step increment UNDERFLOWS to exactly 0 -- the
    reason the plugin carries the 0x1F800000 / 0x9F800000 nudge constants;
  * target == start (the early-out that returns 0);
  * denormal, NaN and infinite starts and targets;
  * subdiv 1..8, so the tick divider is exercised, not just subdiv 1.

usage: ramp_ab_emu.py <out.pkl> [n_cases=300] [seed=1] [steps=64]
"""
import sys, os, struct, pickle, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import e2e_emu as E

R_START = 0x3C2E80
R_STEP = 0x3C2E00
R_RESET = 0x3C2E60
RECSZ = 40


def rnd_f32(rng):
    pick = rng.random()
    if pick < 0.06:
        return rng.choice([0x7FC00000, 0x7F800000, 0xFF800000,
                           0x80000000, 0x00000000])
    if pick < 0.12:
        return rng.choice([0x00000001, 0x007FFFFF, 0x80000001])
    if pick < 0.55:
        # ordinary audio-range values, where most real ramps live
        return struct.unpack('<I', struct.pack('<f', rng.uniform(-4.0, 4.0)))[0]
    return rng.getrandbits(32)


def rnd_time(rng):
    """Include times that make the increment underflow to exactly 0."""
    pick = rng.random()
    if pick < 0.25:
        # Large enough that (target-start)*(1000/time_ms)/(rate/subdiv)
        # UNDERFLOWS to exactly 0. 1e30 was NOT enough -- the gate's own
        # refusal caught that, which is why the tooth exists. At 44100 Hz and
        # a unit delta the increment reaches zero only past ~1e35.
        return struct.unpack('<I', struct.pack(
            '<f', rng.uniform(1e35, 3.0e38)))[0]
    if pick < 0.28:
        return struct.unpack('<I', struct.pack('<f', rng.uniform(1e-6, 1e-1)))[0]
    return struct.unpack('<I', struct.pack('<f', rng.uniform(0.1, 5000.0)))[0]


def main():
    out = sys.argv[1]
    ncase = int(sys.argv[2]) if len(sys.argv) > 2 else 300
    seed = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    nstep = int(sys.argv[4]) if len(sys.argv) > 4 else 64
    rng = random.Random(seed)

    e = E.E2E()
    # MXCSR = FTZ|DAZ, the mode the plugin runs in under any audio host, and
    # the mode the port compiles into via juno_ftz.c. Omitting this made the
    # ORACLE produce denormal increments the port had already flushed, and the
    # difference looked like a port defect. The other JUNO gates all call it.
    e.set_ftz()
    REC = E.BUF_BASE
    SLOT = E.BUF_BASE + 0x1000

    cases = []
    n_underflow = 0
    n_active_end = 0
    for _ in range(ncase):
        slot0 = rnd_f32(rng)
        rate = struct.unpack('<I', struct.pack(
            '<f', rng.choice([44100.0, 48000.0, 88200.0, 96000.0, 192000.0])))[0]
        target = rnd_f32(rng)
        time_ms = rnd_time(rng)
        subdiv = rng.randint(1, 8)
        # a fraction of cases start from an ALREADY-ACTIVE ramp, because
        # juno_ramp_start's return value depends on the prior active flag
        pre_active = 1 if rng.random() < 0.3 else 0
        # The plugin's FIRST instruction pair is `ucomiss xmm3,[rcx+0x14]; jne`
        # -- if the new target equals the record's CURRENT target it returns 0
        # immediately and arms nothing. An earlier version of this harness set
        # pre_target = target in 70% of cases, so most cases armed no ramp at
        # all and the underflow tooth stayed at zero. Keep the equal-target
        # early-out as a deliberate ~10% case, not as the default.
        pre_target = target if rng.random() < 0.10 else rnd_f32(rng)

        rec = bytearray(RECSZ)
        struct.pack_into('<Q', rec, 0, SLOT)
        struct.pack_into('<I', rec, 8, rnd_f32(rng))       # incr
        struct.pack_into('<I', rec, 12, rnd_f32(rng))      # accum
        struct.pack_into('<I', rec, 16, rnd_f32(rng))      # start
        struct.pack_into('<I', rec, 20, pre_target)        # target
        struct.pack_into('<I', rec, 24, rate)              # rate
        struct.pack_into('<i', rec, 28, pre_active)        # active
        struct.pack_into('<i', rec, 32, rng.randint(1, 8))  # subdiv
        struct.pack_into('<i', rec, 36, rng.randint(0, 8))  # step_cnt

        e.uc.mem_write(REC, bytes(rec))
        e.uc.mem_write(SLOT, struct.pack('<I', slot0))

        before = dict(rec=bytes(rec), slot=slot0, target=target,
                      time_ms=time_ms, subdiv=subdiv, nstep=nstep)

        # start(r, target, time_ms, subdiv): rcx=rec, xmm1=target,
        # xmm2=time_ms, r9=subdiv  (Win64: float args go in xmm by POSITION)
        e.uc.reg_write(E.UC_X86_REG_XMM1, target)
        e.uc.reg_write(E.UC_X86_REG_XMM2, time_ms)
        rc_start = e.call(E.IB + R_START, rcx=REC, r9=subdiv)

        after_start = bytes(e.uc.mem_read(REC, RECSZ))
        if struct.unpack('<I', after_start[8:12])[0] in (0x1F800000, 0x9F800000):
            n_underflow += 1

        steps = []
        for _ in range(nstep):
            rc = e.call(E.IB + R_STEP, rcx=REC)
            steps.append((rc & 0xFFFFFFFF,
                          bytes(e.uc.mem_read(REC, RECSZ)),
                          struct.unpack('<I', e.uc.mem_read(SLOT, 4))[0]))
        if struct.unpack('<i', steps[-1][1][28:32])[0]:
            n_active_end += 1

        e.call(E.IB + R_RESET, rcx=REC)
        after_reset = bytes(e.uc.mem_read(REC, RECSZ))

        cases.append((before,
                      dict(rc_start=rc_start & 0xFFFFFFFF,
                           after_start=after_start,
                           steps=steps,
                           after_reset=after_reset,
                           slot_end=struct.unpack('<I', e.uc.mem_read(SLOT, 4))[0])))

    with open(out, "wb") as f:
        pickle.dump(cases, f)
    print("RAMP ORACLE: %d cases x %d steps, %d hit the increment-underflow "
          "nudge, %d still active at the end, faults=%d"
          % (ncase, nstep, n_underflow, n_active_end, e.faults))
    if n_underflow == 0:
        raise SystemExit("REFUSE: no case hit the 0x1F800000/0x9F800000 nudge "
                         "path -- that path is the whole reason the plugin's "
                         "ramp is not a plain lerp, and it went untested")


if __name__ == "__main__":
    main()
