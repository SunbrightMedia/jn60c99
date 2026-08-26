#!/usr/bin/env python3
"""ramp_ab_c.py -- PORT side of the JUNO RAMP A/B (process B).

Two-process rule: this loads the C ramp via ctypes and NEVER builds a Unicorn
instance. It replays the pickled oracle cases and compares every intermediate
state, not just the endpoint -- a ramp that reaches the right target by the
wrong path is still wrong, and only the per-step record shows it.

MASKED, with the reason recorded:
  bytes 29..31 of the record. The plugin writes `active` as a BYTE
  (`mov byte ptr [rcx+0x1c], 1`); juno_ramp.h declares `int active`, so the C
  writes four bytes and clears three the plugin leaves untouched. Those three
  are padding in this struct -- no plugin code reads them -- so masking is
  correct here, but the difference is REAL and is recorded in
  docs/RAMP_AB_FINDINGS.md rather than silently normalised away.

usage: ramp_ab_c.py <cases.pkl> <libjunoramp.so>
"""
import sys, pickle, ctypes, struct

RECSZ = 40


def mask(b):
    """Zero the two fields that cannot legitimately match across processes.

    +0x00..0x07  the `out` POINTER: an emulator address on the oracle side, a
                 host address here. Comparing it fails on every case for a
                 reason that is not a defect.
    +0x1D..0x1F  the three bytes after the single-byte `active` flag (see the
                 module docstring).
    Every other byte of the 40-byte record IS compared, on every step.
    """
    m = bytearray(b)
    m[0:8] = b"\0" * 8
    m[29:32] = b"\0\0\0"
    return bytes(m)


def main():
    cases = pickle.load(open(sys.argv[1], "rb"))
    lib = ctypes.CDLL(sys.argv[2])
    lib.jr_case.restype = ctypes.c_int
    lib.jr_case.argtypes = [ctypes.c_char_p, ctypes.c_char_p,
                            ctypes.c_uint32, ctypes.c_uint32, ctypes.c_int,
                            ctypes.c_int, ctypes.POINTER(ctypes.c_int32),
                            ctypes.c_char_p, ctypes.c_char_p,
                            ctypes.c_char_p, ctypes.c_char_p]

    bad = 0
    nan_bad = 0
    for ci, (before, after) in enumerate(cases):
        ns = before['nstep']
        rec = ctypes.create_string_buffer(before['rec'], RECSZ)
        slot = ctypes.create_string_buffer(
            struct.pack('<I', before['slot']), 4)
        steps_rc = (ctypes.c_int32 * ns)()
        steps_rec = ctypes.create_string_buffer(RECSZ * ns)
        steps_slot = ctypes.create_string_buffer(4 * ns)
        a_start = ctypes.create_string_buffer(RECSZ)
        a_reset = ctypes.create_string_buffer(RECSZ)

        rc = lib.jr_case(rec, slot, before['target'], before['time_ms'],
                         before['subdiv'], ns, steps_rc, steps_rec,
                         steps_slot, a_start, a_reset)

        why = []
        if (rc & 0xFF) != (after['rc_start'] & 0xFF):
            why.append("start returned %d, plugin %d"
                       % (rc & 0xFF, after['rc_start'] & 0xFF))
        if mask(a_start.raw[:RECSZ]) != mask(after['after_start']):
            why.append("record after start differs")
        for i, (orc, orec, oslot) in enumerate(after['steps']):
            if (steps_rc[i] & 0xFF) != (orc & 0xFF):
                why.append("step %d returned %d, plugin %d"
                           % (i, steps_rc[i] & 0xFF, orc & 0xFF))
                break
            if mask(steps_rec.raw[RECSZ * i:RECSZ * (i + 1)]) != mask(orec):
                why.append("step %d record differs" % i)
                break
            got = struct.unpack('<I', steps_slot.raw[4 * i:4 * i + 4])[0]
            if got != oslot:
                why.append("step %d slot %08x, plugin %08x" % (i, got, oslot))
                break
        if mask(a_reset.raw[:RECSZ]) != mask(after['after_reset']):
            why.append("record after reset differs")

        if why:
            bad += 1
            # was a NaN involved? that separates the unordered-compare class
            # from every other cause, which decides what the fix is
            vals = [before['target'], before['slot'],
                    struct.unpack('<I', before['rec'][16:20])[0]]
            isnan = any((v & 0x7F800000) == 0x7F800000 and (v & 0x7FFFFF)
                        for v in vals)
            if isnan:
                nan_bad += 1
            if bad <= 6:
                print("  case %d%s: %s" % (ci, " [NaN]" if isnan else "",
                                           "; ".join(why[:2])))

    print("RAMP A/B: %d/%d cases EXACTLY 0 (%d of %d failures involve NaN)"
          % (len(cases) - bad, len(cases), nan_bad, bad))
    if bad:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
