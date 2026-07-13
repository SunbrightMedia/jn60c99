#!/usr/bin/env python3
"""fuzz_diff.py — Phase-3 differential fuzzer: seeded, reproducible random event
scripts driven into BOTH the plugin (its own machine code under Unicorn) and the
port (libjuno.so), full audio stream compared bitwise.

Usage:  fuzz_diff.py <seed> [<seed> ...]        one line verdict per seed
        fuzz_diff.py --range A B                 seeds A..B-1

Grammar per seed (deterministic from the seed — the seed IS the regression script):
  rate    : 44100 (seed%3==0), 48000 (%3==1), 96000 (%3==2)
  patch   : uniform 0..63 (arp patches get port arp forced OFF: synthesis-to-synthesis)
  events  : 20..60 of  note_on(24..96, 1..127) | note_off(held) | render(100..4000)
            | set_param(idx 0..24, byte 0..255)
  cap     : held notes <= 6 SOUNDING-voice budget (the 9th-voice steal is a known
            ~1-ULP Phase-4 ledger item and is excluded from the bit-exact corpus;
            release tails count against the budget conservatively)
  total   : render total capped at 90000 samples; every seed ends with render(4000)
  excluded: recall-after-render (warm recall: not bit-exact-able by construction,
            proven free-running-phase — scenA + transplant), arp stepping (Phase 4),
            bend/mod (not in the fuzz surface yet — noted in the certificate).
  HARNESS CONVENTIONS (fuzz-triage seeds 0/1/2 — all three were harness artifacts):
            arp-off must pass bpm=128.0 (the plugin's recall-default tempo; any other
            value desyncs the tempo-synced delay/LFO cells on all TEMPO SYNC patches
            and detonates at the synced delay's first echo). Param events rely on
            juno_gui_set_param's LEAF expansion (one event writes every binding row
            sharing the blob byte, matching the plugin's value-tree dispatch).

Sequences are BIT-EXACT-able end to end (all event classes proven in the Phase-2
matrix); any mismatch is a real finding. Verdict per seed: OK <n> frames, or
DIVERGE @frame (first diff, bits both sides).
"""
import sys, struct, ctypes, random, re, os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import e2e_emu as E

REPO = os.path.dirname(os.path.dirname(HERE))
BANK = E.BANK
ARPS = {1, 9, 17, 25, 33, 41, 49}

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

# binding blob positions for the plugin-side param dispatch (idx = blob + 744)
_src = open(os.path.join(REPO, "src/juno_apply.c")).read()
_m = re.search(r'BINDINGS\[\]\s*=\s*\{(.*?)\n\};', _src, re.S)
BLOBS = [int(bp) for bp in re.findall(r'\{\s*(\d+)\s*,\s*\d+\s*,\s*[A-Z_]+\s*,\s*\d+\s*,', _m.group(1))]

def gen_script(seed):
    rng = random.Random(seed)
    rate = [44100.0, 48000.0, 96000.0][seed % 3]
    patch = rng.randrange(64)
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
    return rate, patch, ev, total

def run_seed(seed):
    rate, patch, ev, total = gen_script(seed)
    # plugin
    e = E.E2E(); e.build(rate); e.snap_all(); E.recall_patch(e, patch)
    e.snap_all(); e.clear_latch(); e.set_ftz()
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
    # port
    bank = open(BANK, 'rb').read()
    c = lib.juno_gui_create(ctypes.c_float(rate), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), patch)
    if patch in ARPS: lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)  # 128 = plugin recall-default tempo
    Lb, Rb = [], []
    for x in ev:
        if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
        elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
        elif x[0] == 'param': lib.juno_gui_set_param(c, x[1], x[2])
        else:
            n = x[1]; buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)
            inter = struct.unpack("<%dI" % (2*n), bytes(buf))
            Lb += inter[0::2]; Rb += inter[1::2]
    n = min(len(La), len(Lb))
    first = next((i for i in range(n) if La[i] != Lb[i] or Ra[i] != Rb[i]), None)
    if first is None:
        return f"seed {seed:5d}: OK  rate={int(rate)} patch={patch:2d} events={len(ev)} frames={n}"
    return (f"seed {seed:5d}: DIVERGE rate={int(rate)} patch={patch:2d} @frame {first} "
            f"plugL={La[first]:08x} portL={Lb[first]:08x} plugR={Ra[first]:08x} portR={Rb[first]:08x}")

if __name__ == "__main__":
    args = sys.argv[1:]
    seeds = (range(int(args[1]), int(args[2])) if args and args[0] == '--range'
             else [int(a) for a in args])
    for s in seeds:
        print(run_seed(s), flush=True)
