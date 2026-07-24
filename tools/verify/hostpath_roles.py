#!/usr/bin/env python3
"""hostpath_roles.py -- #112 HOST-PATH REACHABILITY GATE.

Every other gate in this repo drives the plugin through its RECALL role. A real
VST3 host drives a second, different role, and until #112 nothing in `make verify`
covered it.

  RECALL role   the plugin's own enumerator sub_7FF91E0148A0 (rva 0x3B48A0, a2!=0)
                calls  0x3B9A30(proc[u], idx, /*flag*/ 1, value)
  HOST role     a host's IParameterChanges reach engine vtable +112 (rva 0x3C7AE0),
                which calls  0x3B9A30(proc[u], idx, /*flag*/ 0, value)

0x3B9A30 forwards (flag, value) to each leaf setter as that setter's own (a2, a3),
so the flag is not a ramp/immediate switch: it selects a ROLE inside the setter.

WHAT THIS GATE ASSERTS, precisely: the set of the plugin's own recall indices for
which the RECALL role writes NO engine state at any in-range value while the HOST
role does -- i.e. exactly what a host can reach that loading a preset never
touches. It must equal EXPECTED_ROLE_SPLIT (the six-index live MODULATION family;
its value law is separately proven exhaustively by hostmod_gate.py). If a future
change to the binary, the leaf table or this harness makes that set grow or shrink,
this gate goes RED.

Deliberately NOT asserted: bit-level equality of the two roles' settled values on
the indices they share. That comparison was built and run during #112 and is not
yet trustworthy enough to freeze -- it is extremely sensitive to engine warm-up
(each parameter short-circuits at its own power-on default; some setters lag a
dispatch), and four successive protocol errors each produced a large, tidy-looking
set of divergences that did not survive a stricter protocol. See
docs/P112_FINDINGS.md section 8 before attempting it again. Reachability, by
contrast, is a property of the code path rather than of the state it started from,
which is why it is stable and is what gets frozen here.

Protocol per probe, identical for both roles:
  * PRIME the index in the recall role with a different in-range value (what a
    preset load does to that parameter) so nothing is measured against a pristine
    power-on default;
  * write the descriptor DB[idx].value (rva 0x98c048 + 16*idx) -- the leaf setters
    read their input from there, not from the dispatch argument;
  * dispatch on all 9 units, twice;
  * count only writes landing inside a compared unit's state block, and only those
    made by the dispatch itself (the prime and the harness ramp-settle are excluded
    but still rolled back);
  * roll every write back so the next probe starts byte-identical.
Probe values are mapped into the index's OWN paramDB range {min,max}
(rva 0x98c040 + 16*idx): the host entry range-checks before dispatching, so nothing
outside it is deliverable by any host.

Usage:
  hostpath_roles.py --dump [values]   classify and print (also writes the json)
  hostpath_roles.py                   gate: classification must equal EXPECTED
"""
import sys, os, struct, json, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import e2e_emu as E
import real_recall as R
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RDX

IB = E.IB
DISPATCH = IB + 0x3B9A30
ENUM = IB + 0x3B48A0
DB_LO = 0x98C040                 # param descriptor table {min,max,value,...} x 16
DB_N = 4966
UNITS = (0, 8)
SR = 48000.0
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   '..', '..', 'scratchpad', 'hostpath_roles.json')

# --- FROZEN EXPECTATION -----------------------------------------------------
# Indices whose HOST role differs from their RECALL role. Every one of these is a
# member of the live MODULATION family: no-op under recall, and under the host role
# it applies  out = base + off*(off>0 ? 255-base : base)/100  to a front-panel
# parameter's recalled base (paramDB range {-100,100}). See P112_FINDINGS.md §4 and
# the exhaustive law proof in hostmod_gate.py.
EXPECTED_ROLE_SPLIT = {
    312: 'MODULATION -> VCF CUTOFF FREQ (779)',
    313: 'MODULATION -> HPF CUTOFF FREQ (782)',
    314: 'MODULATION -> VCF RESONANCE (781)',
    315: 'MODULATION -> DCO PWM DEPTH (758)',
    316: 'MODULATION -> PORTAMENTO (798)',
    317: 'MODULATION -> EFFECT DEPTH (794)',
}


def build():
    e = E.E2E(); uc = e.uc
    hits = []
    def hk(uc_, a, s, u):
        if a == DISPATCH: hits.append(uc_.reg_read(UC_X86_REG_RDX))
    hid = uc.hook_add(UC_HOOK_CODE, hk, begin=DISPATCH, end=DISPATCH)
    e.build(SR); e.snap_all()
    hits.clear()
    e.call(ENUM, rcx=e.proc[0], rdx=1, count=200_000_000)
    recall_idx = sorted(set(hits))
    uc.hook_del(hid)
    return e, recall_idx


def classify(values):
    e, recall_idx = build(); uc = e.uc
    from unicorn import UC_HOOK_MEM_WRITE

    # Isolation by WRITE CAPTURE + UNDO rather than by bulk snapshot/restore: every
    # guest write during a probe is recorded with its previous bytes and rolled back
    # afterwards, so each probe starts from a byte-identical engine at a cost
    # proportional to what actually changed (bulk-restoring the ~115 MB of mutable
    # heap+image per probe makes the full 165-index sweep take hours). The rollback
    # covers EVERYTHING the guest touches -- heap, image .data/.bss, descriptor
    # table -- not just the state blocks.
    #
    # Only writes landing inside a compared unit's 12 MB state block COUNT as engine
    # behaviour; stack frames and heap scratch are execution detail and differ
    # between the roles for reasons that have nothing to do with the engine.
    SPANS = [(e.state[u], e.state[u] + E.STATE_SZ) for u in UNITS]
    def in_state(a):
        for lo, hi in SPANS:
            if lo <= a < hi: return True
        return False

    cap = {'on': False, 'w': []}
    def onwrite(uc_, access, address, size, value, user):
        if not cap['on']: return
        try: cap['w'].append((address, size, bytes(uc_.mem_read(address, size))))
        except Exception: pass
    uc.hook_add(UC_HOOK_MEM_WRITE, onwrite)

    def pywrite(addr, data):
        """our own writes (descriptor, ramp settle) must be recorded too"""
        if cap['on']:
            try: cap['w'].append((addr, len(data), bytes(uc.mem_read(addr, len(data)))))
            except Exception: pass
        uc.mem_write(addr, data)

    def snap_all_recorded():
        """e2e_emu.snap_all(), but every write goes through pywrite so it rolls back."""
        for u in range(9):
            st = e.state[u]
            base = int.from_bytes(uc.mem_read(st + 88, 8), 'little')
            a = int.from_bytes(uc.mem_read(st + 112, 8), 'little')
            b = int.from_bytes(uc.mem_read(st + 120, 8), 'little')
            n = (b - a) // 4
            if n <= 0:
                continue
            idxs = struct.unpack("<%di" % n, uc.mem_read(a, 4 * n))
            for ix in idxs:
                rec = base + 40 * ix
                outp = int.from_bytes(uc.mem_read(rec, 8), 'little')
                tgt = bytes(uc.mem_read(rec + 20, 4))
                if outp: pywrite(outp, tgt)
                pywrite(rec + 12, b"\x00\x00\x00\x00")
                pywrite(rec + 28, b"\x00\x00\x00\x00")
                pywrite(rec + 36, b"\x00\x00\x00\x00")
            pywrite(st + 120, struct.pack("<Q", a))

    def undo():
        for (a, s, old) in reversed(cap['w']):
            try: uc.mem_write(a, old)
            except Exception: pass
        cap['w'] = []

    def probe(idx, val, flag, prime):
        """returns {addr: new_bytes} for every location the probe changed, and
        leaves the engine exactly as it found it.

        PRIME first, in the RECALL role, with a value different from the one under
        test -- exactly what loading a preset does to that parameter before a host
        ever automates it. Without it the probe runs against a pristine engine where
        the parameter still sits at its POWER-ON DEFAULT, and at exactly that value
        one role short-circuits ('value unchanged') while the other writes: a cold
        sweep then reports a phantom difference at each parameter's own default byte
        (VCF CUTOFF at 255, VCA TONE at 128, DELAY HIGH CUT at 7, ...) that no host
        can ever observe. Seventeen such rows disappear once primed. Both roles get
        the identical prime, so the comparison stays symmetric."""
        cap['w'] = []; cap['on'] = True
        ok = True
        if prime is not None and prime != val:
            pywrite(R.descval_addr(idx), struct.pack('<I', prime & 0xFFFFFFFF))
            for u in range(9):
                try:
                    e.call(DISPATCH, rcx=e.proc[u], rdx=idx, r8=1,
                           r9=prime & 0xFFFFFFFF, count=200_000_000)
                except RuntimeError:
                    ok = False; break
        mark = len(cap['w'])          # everything before this is the PRIME; it is
                                      # rolled back like the rest but must NOT count
                                      # as a write made by the role under test
        pywrite(R.descval_addr(idx), struct.pack('<I', val & 0xFFFFFFFF))
        # TWO identical dispatch rounds, in BOTH roles: some leaf setters apply the
        # previous value and cache the new one, so a single round can read one
        # dispatch behind. Symmetric, so it cannot bias the comparison either way.
        for _round in range(2 if ok else 0):
            for u in range(9):
                try:
                    e.call(DISPATCH, rcx=e.proc[u], rdx=idx, r8=flag,
                           r9=val & 0xFFFFFFFF, count=200_000_000)
                except RuntimeError:
                    ok = False; break
            if not ok: break
        mark2 = len(cap['w'])         # dispatch writes are cap['w'][mark:mark2];
        if ok: snap_all_recorded()    # the ramp settle after it is harness bookkeeping
                                      # and always writes, so it must not be counted
        cap['on'] = False
        out = {}
        if ok:
            for (a, s, old) in cap['w'][mark:mark2]:
                if not in_state(a):        # engine state only -- stack/scratch
                    continue               # temporaries are not engine behaviour
                try: out[a] = bytes(uc.mem_read(a, s))
                except Exception: pass
        undo()
        return out if ok else None

    def cur(addr, n):
        try: return bytes(uc.mem_read(addr, n))
        except Exception: return None

    def dbrange(idx):
        lo, hi = struct.unpack('<ii', uc.mem_read(IB + DB_LO + 16 * idx, 8))
        return lo, hi

    def probe_values(idx):
        """`values` mapped into the index's OWN paramDB range -- the host entry
        0x3C7AE0 range-checks before dispatching, so nothing outside it is
        deliverable by any host and comparing there is meaningless."""
        lo, hi = dbrange(idx)
        if hi < lo or hi - lo > 100000:      # implausible/unset descriptor
            return [v for v in values], (lo, hi)
        out = []
        for v in values:
            w = lo + (v * (hi - lo)) // 255 if hi > lo else lo
            if w not in out: out.append(w)
        for w in (lo, hi):
            if w not in out: out.append(w)
        return sorted(out), (lo, hi)

    only = None
    for a in sys.argv:
        if a.startswith('--only='):
            only = set(int(x) for x in a.split('=', 1)[1].split(','))
    scan = [i for i in recall_idx if only is None or i in only]

    report, errors, ranges = {}, {}, {}
    t0 = time.time()
    for n, idx in enumerate(scan):
        vals_i, rng = probe_values(idx)
        ranges[idx] = rng
        rec_writes = host_writes = 0
        sample = None
        for val in vals_i:
            lo, hi = rng
            prime = lo if val != lo else hi
            s1 = probe(idx, val, 1, prime)
            s0 = probe(idx, val, 0, prime)
            if s1 is None or s0 is None:
                errors.setdefault(idx, []).append(val); continue
            if s1: rec_writes += 1
            if s0:
                host_writes += 1
                if sample is None:
                    a = sorted(s0)[0]
                    ub, off = -1, a
                    for ui, (blo, bhi) in enumerate(SPANS):
                        if blo <= a < bhi: ub, off = UNITS[ui], a - blo; break
                    sample = [ub, off, val]
        # HOST-ONLY: the patch-recall role writes NO engine state at ANY probe value
        # while the host role does. This is the completeness question #112 exists to
        # answer -- "what can a host reach that a preset load never touches" -- and,
        # unlike a value-level comparison, it is insensitive to engine warm-up /
        # smoother ordering, because "wrote nothing at all, at every value in range"
        # is a property of the code path, not of the state it started from.
        if host_writes and not rec_writes:
            report[idx] = {'host_values_writing': host_writes,
                           'probe_values': len(vals_i), 'sample': sample}
        if n % 25 == 0:
            print("  ... %d/%d  host-only so far %d  (%.0fs)"
                  % (n, len(scan), len(report), time.time() - t0))
    return recall_idx, report, errors, ranges


def main():
    dump = '--dump' in sys.argv
    rest = [a for a in sys.argv[1:] if not a.startswith('--')]
    values = tuple(int(x) for x in rest[0].split(',')) if rest else (0, 64, 128, 200, 255)
    print("hostpath_roles: RECALL(flag=1) vs HOST(flag=0), values=%s" % (values,))
    recall_idx, report, errors, ranges = classify(values)
    got = sorted(report)
    print("\nrecall index set: %d  |  role-split indices: %d  |  dispatch errors: %s"
          % (len(recall_idx), len(got), sorted(errors) or 'none'))
    for idx in got:
        r = report[idx]
        print("  idx %-5d range %-14s recall role writes NOTHING; host role writes at "
              "%d/%d in-range values (e.g. val=%s -> u%d+%d)"
              % (idx, ranges.get(idx), r['host_values_writing'], r['probe_values'],
                 (r['sample'] or [0, 0, '?'])[2], (r['sample'] or [-1, -1, 0])[0],
                 (r['sample'] or [-1, -1, 0])[1]))
    try:
        json.dump({'recall_idx': recall_idx, 'values': list(values),
                   'ranges': {str(k): list(v) for k, v in ranges.items()},
                   'host_only': {str(k): v for k, v in report.items()},
                   'errors': {str(k): v for k, v in errors.items()}},
                  open(OUT, 'w'), indent=0)
        print("wrote %s" % os.path.normpath(OUT))
    except OSError as ex:
        print("(could not write json: %s)" % ex)

    if dump:
        return 0
    exp = sorted(EXPECTED_ROLE_SPLIT)
    if got != exp:
        print("\nFAIL: the host-reachable-but-recall-untouched set changed.")
        print("  expected: %s" % exp)
        print("  got     : %s" % got)
        for i in sorted(set(got) - set(exp)): print("   + NEW role-split index %d" % i)
        for i in sorted(set(exp) - set(got)): print("   - MISSING role-split index %d" % i)
        return 1
    print("\nPASS: host-reachable-but-recall-untouched set == expected (%d, all MODULATION):" % len(exp))
    for i in exp: print("   %d  %s" % (i, EXPECTED_ROLE_SPLIT[i]))
    print("No OTHER index is reachable by a host parameter change but untouched by a")
    print("preset load, so the port's recall-role coverage is also its host-role coverage.")
    return 0


if __name__ == '__main__':
    sys.exit(main())
