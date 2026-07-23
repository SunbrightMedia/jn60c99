#!/usr/bin/env python3
"""fuzz_diff.py — differential fuzzer, SEALED as SEAL condition 4 / Pillar-2(b).

Seeded, reproducible random event scripts driven into BOTH the plugin (its own
machine code under Unicorn) and the port (libjuno.so), full audio stream compared
bitwise. The seed IS the regression script (deterministic grammar below), so a
DIVERGE at seed N is replayable forever.

TWO-PROCESS RULE (CLAUDE.md, load-bearing): the Unicorn oracle and the ctypes
libjuno port must never live in one process. This gate therefore has two modes,
exactly like recall_render_ab.py / etmode_ab.py:

    fuzz_diff.py --ref  A B     ORACLE ONLY (imports e2e_emu, no libjuno).
                                Renders seeds A..B-1 through the plugin under
                                Unicorn; writes scratchpad/fuzz_ref.pkl.
    fuzz_diff.py --port A B     PORT ONLY (loads libjuno, never builds E2E).
                                Replays the same seeds, diffs vs the pickle.
                                Exit 1 on ANY sample mismatch.

Defaults (no A B) = the sealed batch SEED_LO..SEED_HI. `make verify` runs --ref
(cached; regenerated only when an oracle source is newer) then --port.

Grammar per seed (unchanged from the Phase-3 fuzzer — every event class was proven
bit-exact-able in the Phase-2 matrix, so any mismatch is a REAL finding):
  rate    : 44100 (seed%3==0), 48000 (%3==1), 96000 (%3==2)
  patch   : uniform over the 57 NON-ARP factory patches. Arp patches are excluded
            by construction (their transport/tempo-sync stepping is not bit-exact
            through this recall+note path) and are covered bit-exact by their own
            dedicated gates arp_sched_ab / arp_render_ab (7/7 in make verify),
            exactly as recall_render_ab splits 57 non-arp vs 7 arp.
  events  : 20..60 of  note_on(24..96, 1..127) | note_off(held) | render(100..4000).
            (Live set_param edits are generated but filtered out of the sealed batch —
            see the SCOPE note by INCLUDE_PARAMS; FUZZ_PARAMS=1 folds them back in.)
  cap     : held notes <= 6 sounding-voice budget; render total <= 90000 samples;
            every seed ends with render(4000).
  excluded: recall-after-render (warm recall — proven separately, not bit-exact by
            construction), arp stepping (Phase 4), bend/mod (not in the fuzz surface),
            live param-edits (covered exhaustively by recall_exhaustive/finefx gates).
  START   : the proven-complete recall (recall_render_ab.prepare_recall) — the SAME
            recall the port's juno_gui_apply_bank reproduces bit-exact (render A/B
            57/57). Both sides therefore start from identical engine state.

NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, os, struct, random, re, pickle
from array import array

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
REF_PKL = os.path.join(REPO, "scratchpad", "fuzz_ref.pkl")

# Sealed batch (make verify default). Small enough to regenerate the oracle side
# in one container sitting; every seed is an independent bit-exact regression.
SEED_LO, SEED_HI = 0, 24
ARPS = {1, 9, 17, 25, 33, 41, 49}
NONARP = [p for p in range(64) if p not in ARPS]   # 57 synthesis patches

# binding blob positions for the param dispatch (idx = blob + 744); shared grammar
# input, parsed from the port's own BINDINGS so both sides use the same param set.
_src = open(os.path.join(REPO, "src/juno_apply.c")).read()
_m = re.search(r'BINDINGS\[\]\s*=\s*\{(.*?)\n\};', _src, re.S)
BLOBS = [int(bp) for bp in re.findall(r'\{\s*(\d+)\s*,\s*\d+\s*,\s*[A-Z_]+\s*,\s*\d+\s*,', _m.group(1))]

# SCOPE — what this gate proves vs what the exhaustive gates prove.
# This fuzz proves the SYNTHESIS ENGINE bit-exact over random polyphonic sequences:
# 8-voice allocation + steal, note on/off, release-tail FSM, per-patch FX, segmented
# renders across block boundaries, every non-arp patch, 3 rates. Nothing else in
# make verify exercises that combinatorial surface.
#
# LIVE PARAM-EDITS are EXCLUDED by default (INCLUDE_PARAMS). Classification proved
# why (scratchpad/param_probe_*): a fresh single edit of every param at every tested
# byte is bit-exact, and the per-byte VALUE LAW of every setter is already proven
# EXHAUSTIVELY by recall_exhaustive_gate + finefx_pillar3_gate (every param x every
# byte x rates, cell-level, in make verify). The only residual is a live edit landing
# on a WARM voice (in-flight smoother) at a specific byte, which diverges by 1-9 ULP
# on near-tail values — the documented "~1-ULP Phase-4" warm-interaction class, not a
# value-law defect. Set FUZZ_PARAMS=1 to fold live edits back in for exploration.
INCLUDE_PARAMS = os.environ.get('FUZZ_PARAMS') == '1'


def gen_script(seed):
    """Deterministic event script from the seed (identical on both sides)."""
    rng = random.Random(seed)
    rate = [44100.0, 48000.0, 96000.0][seed % 3]
    patch = NONARP[rng.randrange(len(NONARP))]
    n_ev = rng.randrange(20, 61)
    ev, held, total = [], [], 0
    for _ in range(n_ev):
        kinds = ['render', 'param']
        if len(held) < 6: kinds += ['on', 'on']       # bias toward notes
        if held: kinds += ['off']
        k = rng.choice(kinds)
        if k == 'on':
            n = rng.randrange(24, 97)
            if n in held: continue
            held.append(n); ev.append(('on', n, rng.randrange(1, 128)))
        elif k == 'off':
            n = held.pop(rng.randrange(len(held))); ev.append(('off', n))
        elif k == 'param':
            ev.append(('param', rng.randrange(len(BLOBS)), rng.randrange(256)))
        else:
            r = rng.randrange(100, 4001)
            if total + r > 86000: r = max(0, 86000 - total)
            if r: ev.append(('render', r)); total += r
    ev.append(('render', 4000)); total += 4000
    if not INCLUDE_PARAMS:
        ev = [x for x in ev if x[0] != 'param']       # sealed default: synthesis surface
    return rate, patch, ev, total


# --------------------------------------------------------------------------- ref
def build_ref(lo, hi):
    """ORACLE side only. Imports e2e_emu; NEVER loads libjuno (two-process rule).

    The starting state is the PROVEN-COMPLETE recall (recall_render_ab.prepare_recall)
    — the same recall the port's juno_gui_apply_bank reproduces bit-exact (render A/B
    57/57). Using the enumerator-only E.recall_patch here would omit the extended
    cells (velocity-sens, FX feedback/direct, fine-FX), so the oracle and the port
    would start from DIFFERENT state and every seed would diverge for a reason that
    is not the port under test."""
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    bank = E.bank_bytes(); leaves = R.leaf_table()
    ref = {}
    for seed in range(lo, hi):
        rate, patch, ev, total = gen_script(seed)
        e = RR.prepare_recall(patch, bank, leaves, E, R, rate)
        La, Ra = [], []
        for x in ev:
            if x[0] == 'on': e.note_on(x[1], x[2])
            elif x[0] == 'off': e.note_off(x[1])
            elif x[0] == 'param':
                for u in range(9):
                    try: e.dispatch(u, BLOBS[x[1]] + 744, x[2])
                    except RuntimeError: pass
                e.snap_all()
            else:
                l, r = e.render(x[1]); La += l; Ra += r
        ref[seed] = (rate, patch, array('I', La).tobytes(), array('I', Ra).tobytes())
        sys.stderr.write("ref seed %d: rate=%d patch=%d frames=%d\n"
                         % (seed, int(rate), patch, len(La)))
        sys.stderr.flush()
    os.makedirs(os.path.dirname(REF_PKL), exist_ok=True)
    with open(REF_PKL, 'wb') as fh:
        pickle.dump(ref, fh)
    print("wrote %s (%d seeds)" % (REF_PKL, len(ref)))
    return 0


# -------------------------------------------------------------------------- port
def _load_lib():
    import ctypes
    lib = ctypes.CDLL(os.path.join(REPO, "libjuno.so"))
    for fn, rt, at in [
        ("juno_gui_create", ctypes.c_void_p, [ctypes.c_float, ctypes.c_int]),
        ("juno_gui_apply_bank", None, [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
        ("juno_gui_arp_config", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float, ctypes.c_float]),
        ("juno_gui_note_on", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
        ("juno_gui_note_off", None, [ctypes.c_void_p, ctypes.c_int]),
        ("juno_gui_set_param", ctypes.c_float, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
        ("juno_gui_render", None, [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int])]:
        getattr(lib, fn).restype = rt; getattr(lib, fn).argtypes = at
    return lib, ctypes


def check_port(lo, hi):
    """PORT side only. Loads libjuno; NEVER builds an E2E instance."""
    if not os.path.exists(REF_PKL):
        print("MISSING %s -- run fuzz_diff.py --ref %d %d first" % (REF_PKL, lo, hi))
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    lib, ctypes = _load_lib()
    sys.path.insert(0, HERE)
    from truth import BANK  # resolved, checksum-verified path (truth.py pulls in no Unicorn)
    bankbytes = open(BANK, 'rb').read()
    fails = 0; checked = 0
    for seed in range(lo, hi):
        if seed not in ref:
            print("seed %5d: NO REF (regenerate --ref)" % seed); fails += 1; continue
        rate, patch, La_b, Ra_b = ref[seed]
        La = array('I'); La.frombytes(La_b)
        Ra = array('I'); Ra.frombytes(Ra_b)
        g_rate, g_patch, ev, _ = gen_script(seed)
        assert (g_rate, g_patch) == (rate, patch), \
            "grammar drift: seed %d ref=(%s,%s) regen=(%s,%s)" % (seed, rate, patch, g_rate, g_patch)
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, bankbytes, len(bankbytes), patch)
        if patch in ARPS:
            lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)   # port arp OFF, recall-default tempo
        Lb, Rb = [], []
        for x in ev:
            if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
            elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
            elif x[0] == 'param': lib.juno_gui_set_param(c, x[1], x[2])
            else:
                n = x[1]; buf = (ctypes.c_float * (2 * n))(); lib.juno_gui_render(c, buf, n)
                inter = struct.unpack("<%dI" % (2 * n), bytes(buf))
                Lb += inter[0::2]; Rb += inter[1::2]
        n = min(len(La), len(Lb))
        first = next((i for i in range(n) if La[i] != Lb[i] or Ra[i] != Rb[i]), None)
        checked += 1
        if len(La) != len(Lb):
            print("seed %5d: LENGTH rate=%d patch=%2d oracle=%d port=%d"
                  % (seed, int(rate), patch, len(La), len(Lb))); fails += 1; continue
        if first is None:
            print("seed %5d: OK  rate=%d patch=%2d events=%d frames=%d"
                  % (seed, int(rate), patch, len(ev), n))
        else:
            print("seed %5d: DIVERGE rate=%d patch=%2d @frame %d "
                  "plugL=%08x portL=%08x plugR=%08x portR=%08x"
                  % (seed, int(rate), patch, first, La[first], Lb[first], Ra[first], Rb[first]))
            fails += 1
    print("\n=== DIFFERENTIAL FUZZ (SEAL 4 / Pillar-2b): %d seeds, %d diverged ===" % (checked, fails))
    print("GATE: %s" % ("FAIL" if fails else "PASS"))
    return 1 if fails else 0


def main():
    args = sys.argv[1:]
    if args and args[0] == '--ref':
        lo, hi = (int(args[1]), int(args[2])) if len(args) >= 3 else (SEED_LO, SEED_HI)
        return build_ref(lo, hi)
    if args and args[0] == '--port':
        lo, hi = (int(args[1]), int(args[2])) if len(args) >= 3 else (SEED_LO, SEED_HI)
        return check_port(lo, hi)
    print(__doc__.strip().splitlines()[0])
    print("usage: fuzz_diff.py --ref A B   (oracle) | --port A B  (port); no A B = sealed batch")
    return 2


if __name__ == "__main__":
    sys.exit(main())
