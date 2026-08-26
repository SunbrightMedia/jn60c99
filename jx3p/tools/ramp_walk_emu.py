#!/usr/bin/env python3
"""ramp_walk_emu.py -- ORACLE side of the RAMP WALKER A/B (process A).

Builds RANDOM ramp lists in emulator memory, runs the PLUGIN's own walker
(sub_1803F40E0) over them, and pickles the before/after bytes for the C side.

Why random and not "a real state": the walker is a container algorithm. Its
defects (skipping the compacted-in element, advancing the wrong cursor, reading
a stale end) show up as a function of LIST SHAPE -- how many ramps retire, in
what order -- not as a function of musical values. A factory patch exercises
one shape. Seeds exercise the space (playbook 80 / charter rule 1: the value
spread must not come from the shipped bank).

usage: ramp_walk_emu.py <out.pkl> [n_cases=200] [seed=1]
"""
import sys, os, struct, pickle, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J

WALK = 0x3F40E0
REC = 40                    # PROVEN by the walker's own index arithmetic
MAXN = 24                   # ramps per case


def rnd_f32(rng):
    """A value spread that includes the awkward classes on purpose."""
    pick = rng.random()
    if pick < 0.08:
        return rng.choice([0x7FC00000, 0xFF800000, 0x7F800000,   # NaN, +-inf
                           0x80000000, 0x00000000])
    if pick < 0.16:
        return rng.choice([0x00000001, 0x007FFFFF])              # denormals
    return rng.getrandbits(32)


def build_case(rng):
    """One random (pool, index-list) pair as raw bytes plus its length."""
    n = rng.randint(1, MAXN)
    pool = bytearray()
    for _ in range(n):
        # target pointer is patched in by the caller; the rest is random
        step = rnd_f32(rng); acc = rnd_f32(rng); off = rnd_f32(rng)
        lim = rnd_f32(rng); pad = rng.getrandbits(32)
        # enabled: mostly on, sometimes off (the early-out path)
        en = 0 if rng.random() < 0.15 else rng.randint(1, 255)
        # period/counter: small so retirement actually happens within a pass
        per = rng.randint(0, 4); cnt = rng.randint(0, 4)
        pool += struct.pack('<Q', 0)                     # +0x00 target (patched)
        pool += struct.pack('<IIII', step, acc, off, lim)
        pool += struct.pack('<I', pad)                   # +0x18
        pool += struct.pack('<BBBB', en, 0, 0, 0)        # +0x1C
        pool += struct.pack('<ii', per, cnt)             # +0x20/+0x24
    assert len(pool) == n * REC
    # the live list: every index once, in a random order (the plugin's own
    # list is a permutation; order changes which memmove ranges overlap)
    idx = list(range(n)); rng.shuffle(idx)
    return n, bytes(pool), idx


def main():
    out = sys.argv[1]
    ncase = int(sys.argv[2]) if len(sys.argv) > 2 else 200
    seed = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    rng = random.Random(seed)

    jx = J.JX().build(); jx.set_ftz(); uc = jx.uc
    BASE = J.BUF_BASE
    OBJ = BASE                       # the walker's object
    POOL = BASE + 0x1000             # record array
    LIST = BASE + 0x4000             # int32 index list
    TGT = BASE + 0x6000              # the floats the ramps write

    cases = []
    for c in range(ncase):
        n, pool, idx = build_case(rng)
        # patch each record's target pointer to its own float slot
        pool = bytearray(pool)
        tgt_init = []
        for i in range(n):
            struct.pack_into('<Q', pool, i * REC, TGT + 4 * i)
            tgt_init.append(rnd_f32(rng))
        uc.mem_write(POOL, bytes(pool))
        uc.mem_write(LIST, b"".join(struct.pack('<i', i) for i in idx))
        uc.mem_write(TGT, b"".join(struct.pack('<I', v) for v in tgt_init))
        obj = bytearray(0x80)
        struct.pack_into('<Q', obj, 0x58, POOL)
        struct.pack_into('<Q', obj, 0x70, LIST)
        struct.pack_into('<Q', obj, 0x78, LIST + 4 * n)
        uc.mem_write(OBJ, bytes(obj))

        before = dict(n=n, pool=bytes(pool), idx=list(idx),
                      tgt=list(tgt_init))

        jx.call(J.IB + WALK, rcx=OBJ)

        end = struct.unpack('<Q', uc.mem_read(OBJ + 0x78, 8))[0]
        live = (end - LIST) // 4
        after = dict(
            pool=bytes(uc.mem_read(POOL, n * REC)),
            idx=list(struct.unpack('<%di' % n, uc.mem_read(LIST, 4 * n))),
            live=live,
            tgt=list(struct.unpack('<%dI' % n, uc.mem_read(TGT, 4 * n))),
        )
        cases.append((before, after))

    with open(out, "wb") as f:
        pickle.dump(cases, f)
    retired = sum(b['n'] - a['live'] for b, a in cases)
    print("WALKER ORACLE: %d cases, %d ramps, %d retired, faults=%d"
          % (ncase, sum(b['n'] for b, _ in cases), retired, jx.faults))
    if retired == 0:
        raise SystemExit("REFUSE: no ramp retired -- the compaction path, which "
                         "is the whole reason this gate exists, was never run")


if __name__ == "__main__":
    main()
