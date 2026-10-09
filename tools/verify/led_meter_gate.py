#!/usr/bin/env python3
"""led_meter_gate.py -- THE LFO LED AND THE LEVEL METERS, plugin vs port (CLAIMS A37).

The plugin's engine keeps a store for its LFO LED (engine +1040) and the two output peaks
(engine +32 / +36). The feeds (READ, docs/LED_METER.md): voice unit 0's render thread (rva
0x3C6F00) calls the engine's vt+104 (rva 0x3C7230) after each of its samples -- the store's add
(rva 0x324A30) of unit 0's entry 29 (rva 0x3C10B0: the value's bits); the engine render's tail
(rva 0x3C787B) merges each call's own peak into +32 / +36. The reads, at each 50 ms tick of the
GUI's window timer: the LED's (rva 0x3C7180 -> 0x324980; the frame, rva 0x325070), each meter's
(rva 0x34AF70; its tick, rva 0x31C450: the dB step through the CRT's log10, the decay, the bar's
fill rva 0x2C9A10); a meter draws its fill (rva 0x31C210).

PART 1 -- the plugin's own functions on any input (an E2E image under Unicorn; around each
function only plumbing: fake objects holding the inputs, a blitter whose two slots record):
  store   0x324A30 / 0x324980 over seeded op sequences: values -1, -0, +0, 1 and finite others;
          reads at (-1, 1) and at finite others; counts near the 32-bit wrap; every field after
          every op
  tail    0x3C787B..0x3C79C4 (the render's peak and merge) over seeded calls of 0..300 samples
          (NaN payloads of both signs, infinities, denormals, -0) onto held peaks (NaN, 0,
          others), each followed by the reads 0x34AF70 ch 0 and 1
  led     0x3C7180 on a set store, then 0x3250F2.. (the frame) on its value; frame counts 24
          and others
  meter   0x31C46A.. (the tick through 0x34AF70, log10 rva 0x6D2660, 0x2C9A10): the two floats
          next to each of the 998 dB steps, edges (0.001f, 1.0f and their neighbours, NaN,
          infinities, negatives, denormals), seeded peaks, states (also near the wrap), decays
          (<= 0 too), rects, both directions
  draw    0x31C210, horizontal, seeded rects / fills / fades: every blit's dst, size, src, alpha
  margin  (no plugin code) every float next to a dB step lies more than 1e-9 from it: any log10
          within 1e-12 -- the CRT's FMA3 path, glibc, emscripten's, mingw's -- gives the step
          the plugin's executed SSE2 path gives
PART 2 -- the feeds in the running plugin (host_process_emu, the product boot): the voice stub
calls the engine's vt+104 after each of unit 0's samples as the plugin's thread does, and each
served engine render runs the plugin's own tail on its output. At each ('read',): the LED's read
and both meters' reads (the plugin's functions), then the store and the held peaks. Chains:
fast and slow LFOs read every block and every 50 ms, host 44100 / 48000 / 96000 (the converter's
calls and the identity's segments), patch changes, silence and loud chords, a host-rate change, a
DAW state with the voice count at 1 (only unit 0 renders: where voice 1's square is not voice 0's).

  --ref           (Unicorn) writes scratchpad/led_meter_ref.pkl (.partial, then renamed); --ref --keep:
                  a part-2 chain whose steps did not change keeps its reference (part 1 always reruns)
  --port          (libjuno) every value of part 1 and part 2 must agree, bit for bit
  --port-tooth    the port check must FAIL on the port's own defects, built from the bridge with
                  -DLM_TOOTH=n (see TEETH)
"""
import os
import pickle
import random
import struct
import subprocess
import sys
from decimal import Decimal, getcontext

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
REF_PKL = os.environ.get('LED_METER_REF', os.path.join(REPO, 'scratchpad', 'led_meter_ref.pkl'))
HEADER, STRIDE, NAME = 23, 20223, 16
PRELUDE = 256
SEED = 37

f2b = lambda f: struct.unpack('<I', struct.pack('<f', f))[0]
# a float a C function returns crosses ctypes as a double: a signaling NaN arrives quieted, so a
# returned value is compared quieted (the held bits themselves are compared raw, through the peek)
qn = lambda b: b | 0x00400000 if (b & 0x7F800000) == 0x7F800000 and (b & 0x007FFFFF) else b
b2f = lambda b: struct.unpack('<f', struct.pack('<I', b & 0xFFFFFFFF))[0]
NAN_BITS = (0x7FC00000, 0xFFC00000, 0x7FC12345, 0xFFA00001, 0x7F800001, 0x7FBFFFFF)
EDGE_BITS = (0x00000000, 0x80000000, 0x00000001, 0x80000001, 0x007FFFFF, 0x00800000, 0x7F7FFFFF,
             0xFF7FFFFF, 0x7F800000, 0xFF800000, 0x3F800000, 0xBF800000, 0x3A83126F, 0x3A83126E,
             0x3A831270, 0x3F7FFFFF, 0x3F800001, 0x3F000000)


# ------------------------------------------------------------------ part 1 inputs (seeded)
def rnd_float(r, nan=True):
    k = r.random()
    if k < 0.15 and nan:
        return r.choice(NAN_BITS)
    if k < 0.35:
        return r.choice(EDGE_BITS)
    if k < 0.75:
        return f2b(r.uniform(-1.5, 1.5))
    return r.getrandbits(32) if nan else f2b(r.uniform(-1e30, 1e30))


def store_cases():
    r = random.Random(SEED)
    out = []
    for s in range(48):
        if s < 16:
            st = [0, 0, 0, 0, 0, 0, 0]
        else:
            st = [f2b(r.choice((-1.0, 0.0, 1.0, -0.0, r.uniform(-3, 3)))), f2b(r.uniform(-500, 500)),
                  r.choice((0, 5, 4800, 0x7FFFFFFF, 0x80000000, r.getrandbits(32))),
                  r.choice((0, 7, 0x7FFFFFFE, 0x7FFFFFFF, r.getrandbits(32))),
                  r.choice((0, 3, 1200, 0x3FFFFFFF, 0x40000000, 0x7FFFFFFF, r.getrandbits(32))),
                  r.choice((0, 9, 0x7FFFFFFF, r.getrandbits(32))), r.choice((0, 1, 2, 7, 0xFFFFFFFF))]
        ops = []
        for i in range(160):
            if r.random() < 0.7:
                v = r.choice((-1.0, 1.0, -1.0, 1.0, 0.0, -0.0)) if r.random() < 0.85 else r.uniform(-4, 4)
                run = r.choice((1, 1, 1, 3, 17, 60))
                ops += [('add', f2b(v))] * run
            else:
                lo, hi = (-1.0, 1.0) if r.random() < 0.8 else (r.uniform(-5, 5), r.uniform(-5, 5))
                ops.append(('read', f2b(lo), f2b(hi)))
        out.append((st, ops))
    return out


def tail_cases():
    r = random.Random(SEED + 1)
    out = []
    for s in range(1200):
        n = r.choice((0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 16, 17, 64, 95, 96, 257, 300))
        nanp = 0.0 if s < 400 else 0.2
        def smp():
            if r.random() < nanp:
                return r.choice(NAN_BITS)
            if r.random() < 0.15:
                return r.choice(EDGE_BITS)
            return f2b(r.uniform(-2.0, 2.0) * r.choice((1.0, 1e-3, 1e-30, 1e10)))
        L = [smp() for _ in range(n)]
        R = [smp() for _ in range(n)]
        hold = [r.choice((0, 0, 0x80000000, f2b(r.uniform(0, 2)), r.choice(NAN_BITS), r.choice(EDGE_BITS)))
                for _ in range(2)]
        out.append((hold, L, R))
    return out


def led_cases():
    r = random.Random(SEED + 2)
    out = []
    for s in range(1500):
        st = [f2b(r.choice((-1.0, 1.0, 0.0))), f2b(r.uniform(-3000, 3000)),
              r.choice((0, 3, 100, 4800, 9600, 9601, 20000, 0x7FFFFFFF, 0x80000000, r.getrandbits(32))),
              r.getrandbits(8), r.choice((0, 1, 2, 100, 1200, 2400, 0x40000000, r.getrandbits(32))),
              r.choice((0, 1, 7, 2400, r.getrandbits(32))), r.choice((0, 1, 2, 3))]
        nf = 24 if s < 1200 else r.choice((1, 2, 0, -3, 25, 1000, 0x7FFFFFFF, -0x80000000))
        out.append((st, nf))
    return out


def margin_floats():
    """the two floats next to each dB step k = 1..998: y = log10(x) * 333 + 999 = k at
    x = 10^((k - 999) / 333); the step at 999 is x = 1.0 exactly (log10(1) = 0 everywhere)"""
    getcontext().prec = 60
    xs = []
    for k in range(1, 999):
        t = Decimal(10) ** (Decimal(k - 999) / Decimal(333))
        b = f2b(float(t))
        for d in (-2, -1, 0, 1, 2):
            xs.append(b + d)
    return sorted(set(xs))


def margin_check(xs):
    """min over the floats of |y - nearest step| for y in (0, 999), exact to 60 digits"""
    getcontext().prec = 60
    worst = None
    l10 = Decimal(10).ln()
    for b in xs:
        x = Decimal(b2f(b))
        if x <= 0:
            continue
        y = (x.ln() / l10) * 333 + 999
        if y <= 0 or y >= 999:
            continue
        d = abs(y - y.to_integral_value())
        if worst is None or d < worst[0]:
            worst = (d, b)
    return worst


def meter_cases():
    r = random.Random(SEED + 3)
    out = []
    rect = (1572, 52, 1800, 62)
    for b in margin_floats():
        out.append((b, 0, 8, rect, 1))
        out.append((b, 999000, 8, rect, 1))
    for b in EDGE_BITS + NAN_BITS:
        for st in (0, 500000, 999000):
            out.append((b, st, 8, rect, 1))
    for s in range(3000):
        b = rnd_float(r) if r.random() < 0.5 else f2b(r.uniform(0.0005, 1.2))
        st = r.choice((0, 62500, 999000, r.randrange(0, 1000000), r.getrandbits(32) - (1 << 31),
                       0x7FFFFFFF, -0x80000000, -5))
        dec = r.choice((8, 8, 8, 1, 2, 0, -1, 500001, 7, 0x7FFFFFFF, -0x80000000))
        x0, y0 = r.randrange(-50, 2000), r.randrange(-50, 200)
        rc = (x0, y0, x0 + r.choice((228, 0, 1, 10, 999, 5000, -20)), y0 + r.choice((10, 0, 1, 300, -4)))
        if r.random() < 0.05:
            rc = tuple(r.getrandbits(32) - (1 << 31) for _ in range(4))
        out.append((b, st, dec, rc, r.choice((1, 1, 1, 0))))
    return out


def draw_cases():
    r = random.Random(SEED + 4)
    out = []
    for s in range(1500):
        x0, y0 = r.randrange(0, 2000), r.randrange(0, 200)
        w = r.choice((228, 228, 10, 0, 1, 300))
        rect = (x0, y0, x0 + w, y0 + r.choice((10, 10, 1, 0, 30)))
        fw = r.choice((0, 1, 5, 9, 10, 11, w - 1, w, r.randrange(0, w + 1) if w > 0 else 0, -3, w + 4))
        fill = (rect[0], rect[1], rect[0] + fw, rect[3])
        fade = r.choice((10, 10, 10, 1, 2, 0, -2, 7, 300))
        out.append((rect, fill, fade))
    return out


# ------------------------------------------------------------------ part 2 chains
def on(p, v=0.8, ch=0, off=0):
    return ('on', off, ch, p, v)


def off(p, v=0.5, ch=0, off_=0):
    return ('off', off_, ch, p, v)


def blk(n, evs=()):
    return ('blk', n, list(evs))


RD = ('read',)
VOICES_ID = 0x0FFFC00E          # vm.vs.voiceCount


def chains():
    out = []
    # 1. a fast LFO (patch 60) read every block of 512, then every 2400 samples (50 ms), notes held
    s = [('patch', 60), blk(512, [on(60), on(64), on(67)])] + [blk(512), RD] * 30
    s += [blk(600), blk(600), blk(600), blk(600), RD] * 12 + [blk(512, [off(60), off(64), off(67)])]
    s += [blk(600), blk(600), blk(600), blk(600), RD] * 8
    out.append(('fast48', 48000.0, s))
    # 2. slow LFOs (patches 2, 28): the mean branch, 50 ms reads, a release, a patch change
    s = [('patch', 2), blk(600, [on(48, 0.6)])] + [blk(600), blk(600), blk(600), blk(600), RD] * 40
    s += [blk(600, [off(48)]), ('patch', 28), blk(600, [on(55), on(59)])] + [blk(1200), blk(1200), RD] * 20
    out.append(('slow48', 48000.0, s))
    # 3. host 44100: the converter's engine calls of every length; irregular reads
    s = [('patch', 25), blk(441, [on(57, 0.9), on(64, 0.3, 0, 100)])]
    for k in range(60):
        s += [blk((37, 441, 100, 1024, 1, 7, 512)[k % 7])] + ([RD] if k % 3 == 2 else [])
    s += [blk(441, [off(57), off(64)])] + [blk(2205), RD] * 10
    out.append(('conv44', 44100.0, s))
    # 4. host 96000: identity segments split by events at offsets
    s = [('patch', 56)]
    for k in range(40):
        s += [blk(960, [on(48 + k % 12, 0.5, 0, (k * 37) % 960)] if k % 4 == 0 else
                  [off(48 + (k - 2) % 12, 0.5, 0, (k * 53) % 960)] if k % 4 == 2 else []), RD]
    s += [blk(4000), RD] * 6
    out.append(('ident96', 96000.0, s))
    # 5. silence, then a loud chord, then a patch change while it sounds
    s = [('patch', 40)] + [blk(1200), RD] * 6 + [blk(600, [on(n, 1.0) for n in (36, 43, 48, 55, 60, 64)])]
    s += [blk(1200), RD] * 12 + [('patch', 49), blk(1200), RD, blk(1200), RD]
    s += [blk(600, [off(n) for n in (36, 43, 48, 55, 60, 64)])] + [blk(1200), RD] * 8
    out.append(('loud48', 48000.0, s))
    # 6. a host-rate change on the running instance (48000 -> 44100 -> 96000)
    s = [('patch', 31), blk(480, [on(62)])] + [blk(480), RD] * 8 + [('rate', 44100.0)]
    s += [blk(441), RD] * 8 + [('rate', 96000.0)] + [blk(960), RD] * 8 + [blk(960, [off(62)]), RD]
    out.append(('rate', 48000.0, s))
    # 7. patch changes under the reads: each load re-times the LFO
    s = [blk(512, [on(60), on(67)])]
    for p in (0, 9, 17, 33, 47, 58, 63):
        s += [('patch', p)] + [blk(512), RD] * 4 + [blk(2400), RD] * 2
    out.append(('patches', 48000.0, s))
    # 8. a DAW state with the voice count at 1 (the setting's menu stops at 2, a state carries 1):
    #    only unit 0 renders, the one case where voice 1's square is not voice 0's (tooth 7); then 6
    s = [('state', [(VOICES_ID, 1)]), ('patch', 60), blk(512, [on(60)])] + [blk(1200), RD] * 12
    s += [('state', [(VOICES_ID, 6)]), blk(1200, [on(64)])] + [blk(1200), RD] * 6
    out.append(('voices1', 48000.0, s))
    return out


# ------------------------------------------------------------------ the reference (Unicorn)
def build_ref():
    import e2e_emu as E
    import meter_emu as M
    from unicorn.x86_const import UC_X86_REG_MXCSR
    ref = {'_chains': chains()}

    # ---- part 1: one image, fake objects (meter_emu.Rig); plain IEEE mode (MXCSR 0x1F80: no DAZ,
    # no FTZ), where the emulator's SSE equals the CPU's (MEASURED: under DAZ its maxss returns a
    # denormal operand's own bits, the CPU's the zero DAZ makes of it -- playbook 120; part 2 shows
    # the product's samples never reach that case)
    e = E.E2E()
    e.uc.reg_write(UC_X86_REG_MXCSR, 0x1F80)
    rig = M.Rig(e)
    res = []
    for st, ops in store_cases():
        rig.store_set(st)
        seq = []
        for op in ops:
            if op[0] == 'add':
                rig.store_add(op[1])
                seq.append((None, rig.store_get()))
            else:
                v = rig.store_read(op[1], op[2])
                seq.append((v, rig.store_get()))
        res.append(seq)
    ref['store'] = res
    sys.stderr.write('part 1 store: %d sequences\n' % len(res))
    res = []
    for hold, L, R in tail_cases():
        rig.uc.mem_write(rig.HOST + 16, b'\0' * 8)
        rig.holds_set(hold)
        rig.tail(L, R)
        held = rig.holds_get()
        r0, r1 = rig.peak_read(0), rig.peak_read(1)
        res.append((held, r0, r1, rig.holds_get()))
    ref['tail'] = res
    sys.stderr.write('part 1 tail: %d calls\n' % len(res))
    res = []
    for st, nf in led_cases():
        rig.store_set(st)
        rig.uc.mem_write(rig.HOST + 40, b'\0' * 8)
        v = rig.led_read()
        res.append((v, rig.led_frame(v, nf), rig.store_get()))
    ref['led'] = res
    sys.stderr.write('part 1 led: %d reads\n' % len(res))
    res = []
    for pk, st, dec, rc, horiz in meter_cases():
        rig.uc.mem_write(rig.HOST + 16, b'\0' * 8)
        rig.holds_set((pk, f2b(0.5)))
        nst, fill = rig.meter_tick(st, dec, 0, rc, horiz)
        res.append((nst, fill, rig.holds_get()))
    ref['meter'] = res
    sys.stderr.write('part 1 meter: %d ticks\n' % len(res))
    res = []
    for rect, fill, fade in draw_cases():
        res.append(rig.bar_draw(rect, fill, fade))
    ref['draw'] = res
    sys.stderr.write('part 1 draw: %d draws\n' % len(res))
    if e.faults or e.unhandled or getattr(e, 'hit_fatal', 0):
        raise SystemExit('part 1: the emulator faulted (%d) or met imports %s' % (e.faults, dict(e.unhandled)))
    del e, rig
    if os.environ.get('LM_PART') == '1':
        ref['_chains'] = []

    # ---- part 2: the running plugin (meter_emu.FedHost)
    import truth
    bank = open(truth.BANK, 'rb').read()
    only = os.environ.get('LM_ONLY')                 # debugging: one chain by name
    if only:
        ref['_chains'] = [ch for ch in ref['_chains'] if ch[0] == only]
    keep = set()
    if os.path.exists(REF_PKL) and '--keep' in sys.argv:   # --keep: an unchanged chain keeps its reference
        old = pickle.load(open(REF_PKL, 'rb'))
        for ci, ch in enumerate(ref['_chains']):
            for oi, och in enumerate(old['_chains']):
                if repr(och) == repr(ch) and oi in old:
                    ref[ci] = old[oi]
                    keep.add(ci)
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        if ci in keep:
            sys.stderr.write('ref chain %d %s: kept\n' % (ci, name))
            continue
        h = M.FedHost()
        h.start(rate, 4096)
        h.bind()
        h.process(PRELUDE)
        h.snap_all()
        PL, PR, reads = [], [], []
        for stp in steps:
            k = stp[0]
            if k == 'patch':
                h.load_patch(bank[HEADER + stp[1] * STRIDE + NAME: HEADER + (stp[1] + 1) * STRIDE])
            elif k == 'state':
                pl = b''.join(struct.pack('>Ii', a, b) for a, b in stp[1])
                if h.set_state(struct.pack('>I', len(pl)) + pl) != 0:
                    raise SystemExit('setState failed')
            elif k == 'rate':
                h.set_active(0)
                h.setup_processing(stp[1])
                h.set_active(1)
            elif k == 'read':
                led, p0, p1 = h.rig.led_read(), h.rig.peak_read(0), h.rig.peak_read(1)
                reads.append((led, p0, p1, tuple(h.rig.store_get()) + tuple(h.rig.holds_get())))
            elif k == 'blk':
                _, n, evs = stp
                l, r = h.process(n, events=evs, ctx=dict(tempo=120.0, playing=True))
                PL += l
                PR += r
        if h.faults or getattr(h, 'hit_fatal', 0):
            raise SystemExit('chain %s: the emulator faulted' % name)
        ref[ci] = (PL, PR, reads)
        sys.stderr.write('ref chain %d %s: %d samples, %d reads, led %s\n' % (
            ci, name, len(PL), len(reads), ' '.join('%.3f' % b2f(x[0]) for x in reads[:12])))
        sys.stderr.flush()
        del h
    pickle.dump(ref, open(REF_PKL + '.partial', 'wb'))       # whole or nothing (playbook 142)
    os.replace(REF_PKL + '.partial', REF_PKL)
    print('wrote', REF_PKL)
    return 0


# ------------------------------------------------------------------ the port (libjuno)
def check_port(libpath=None, quiet=False):
    import ctypes
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    if libpath is None:
        import freshlib
        lib = freshlib.load()
    else:
        lib = ctypes.CDLL(libpath)
    V = ctypes.c_void_p
    U9 = ctypes.c_uint32 * 9
    I4 = ctypes.c_int * 4

    class Note(ctypes.Structure):
        _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                    ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]

    class Param(ctypes.Structure):
        _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]
    for fn, at, rt in (('juno_gui_create', [ctypes.c_float, ctypes.c_int], V), ('juno_gui_state', [V], V),
                       ('juno_rr_settle', [V], None), ('juno_gui_plugin_init', [V], ctypes.c_int),
                       ('juno_gui_destroy', [V], None), ('juno_gui_unported', [V], ctypes.c_int),
                       ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_set_active', [V, ctypes.c_int], None),
                       ('juno_gui_setup_processing', [V, ctypes.c_double], None),
                       ('juno_set_fp_oracle_mode', [ctypes.c_int], None),
                       ('juno_gui_lfo_led', [V], ctypes.c_float), ('juno_gui_peak', [V, ctypes.c_int], ctypes.c_float),
                       ('juno_gui_lfo_led_frame', [V, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_meter_tick', [V, ctypes.c_int, ctypes.c_int, ctypes.c_int, V, ctypes.c_int, V], ctypes.c_int),
                       ('juno_gui_bar_draw', [V, V, ctypes.c_int, ctypes.c_int, V, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_lm_peek', [V, V], None),
                       ('juno_gui_lm_op', [V, ctypes.c_int, ctypes.c_float, ctypes.c_float, V, ctypes.c_int, V], None),
                       ('juno_gui_process_ex', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.POINTER(Param), ctypes.c_int,
                                                ctypes.c_int, ctypes.c_double, ctypes.POINTER(ctypes.c_float),
                                                ctypes.POINTER(ctypes.c_float), ctypes.c_int], ctypes.c_int)):
        getattr(lib, fn).argtypes = at
        getattr(lib, fn).restype = rt
    bad = 0
    say = (lambda s: None) if quiet else print
    fb = lambda x: f2b(x) if isinstance(x, float) else x
    c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
    libm = ctypes.CDLL('libm.so.6')
    libm.fesetenv.argtypes = [ctypes.c_void_p]
    if libm.fesetenv(ctypes.c_void_p(-1)) != 0:     # FE_DFL_ENV: MXCSR 0x1F80, as part 1's reference
        raise SystemExit('fesetenv failed')
    out9 = U9()
    res = ctypes.c_float()

    def peek():
        lib.juno_gui_lm_peek(c, out9)
        return list(out9)

    def setst(st7, hold=(0, 0)):
        lib.juno_gui_lm_op(c, 2, 0.0, 0.0, U9(*(list(st7) + list(hold))), 0, None)

    # part 1: store
    nd, first = 0, None
    for si, ((st, ops), rseq) in enumerate(zip(store_cases(), ref['store'])):
        setst(st)
        for oi, (op, (rv, rst)) in enumerate(zip(ops, rseq)):
            if op[0] == 'add':
                lib.juno_gui_lm_op(c, 0, b2f(op[1]), 0.0, None, 0, None)
                pv = None
            else:
                lib.juno_gui_lm_op(c, 1, b2f(op[1]), b2f(op[2]), None, 0, ctypes.byref(res))
                pv = f2b(res.value)
            pst = peek()[:7]
            if pv != rv or pst != list(rst):
                nd += 1
                if first is None:
                    first = (si, oi, op, rv, pv, rst, pst)
                break
    say('part 1 store   %4d sequences: %s' % (len(ref['store']), 'BIT-EXACT' if not nd else
        '%d differ, first %s' % (nd, first)))
    bad += bool(nd)
    # tail
    nd, first = 0, None
    for ti, ((hold, L, R), rr) in enumerate(zip(tail_cases(), ref['tail'])):
        setst([0] * 7, hold)
        n = len(L)
        lib.juno_gui_lm_op(c, 3, 0.0, 0.0, (ctypes.c_uint32 * max(1, 2 * n))(*(L + R)), n, None)
        held = tuple(peek()[7:9])
        r0, r1 = f2b(lib.juno_gui_peak(c, 0)), f2b(lib.juno_gui_peak(c, 1))
        got = (held, qn(r0), qn(r1), tuple(peek()[7:9]))
        if got != (tuple(rr[0]), qn(rr[1]), qn(rr[2]), tuple(rr[3])):
            nd += 1
            if first is None:
                first = (ti, n, [hex(x) for x in hold], tuple(rr), got)
    say('part 1 tail    %4d calls:     %s' % (len(ref['tail']), 'BIT-EXACT' if not nd else
        '%d differ, first %s' % (nd, first)))
    bad += bool(nd)
    # led
    nd, first = 0, None
    for li, ((st, nf), (rv, rframe, rst)) in enumerate(zip(led_cases(), ref['led'])):
        setst(st)
        frame = lib.juno_gui_lfo_led_frame(c, nf)
        pst = peek()[:7]
        setst(st)
        pv = f2b(lib.juno_gui_lfo_led(c))
        if (pv, frame, pst) != (rv, rframe, list(rst)):
            nd += 1
            if first is None:
                first = (li, st, nf, (rv, rframe, rst), (pv, frame, pst))
    say('part 1 led     %4d reads:     %s' % (len(ref['led']), 'BIT-EXACT' if not nd else
        '%d differ, first %s' % (nd, first)))
    bad += bool(nd)
    # meter
    nd, first = 0, None
    fill = I4()
    for mi, ((pk, st, dec, rc, horiz), (rst, rfill, rhold)) in enumerate(zip(meter_cases(), ref['meter'])):
        setst([0] * 7, (pk, f2b(0.5)))
        nst = lib.juno_gui_meter_tick(c, 0, dec, st, I4(*rc), horiz, fill)
        got = (nst, tuple(fill), tuple(peek()[7:9]))
        if got != (rst, tuple(rfill), tuple(rhold)):
            nd += 1
            if first is None:
                first = (mi, hex(pk), st, dec, rc, horiz, (rst, rfill, rhold), got)
    say('part 1 meter   %4d ticks:     %s' % (len(ref['meter']), 'BIT-EXACT' if not nd else
        '%d differ, first %s' % (nd, first)))
    bad += bool(nd)
    # draw
    nd, first = 0, None
    ob = (ctypes.c_int * (7 * 400))()
    for di, ((rect, fillr, fade), rbl) in enumerate(zip(draw_cases(), ref['draw'])):
        nb = lib.juno_gui_bar_draw(I4(*rect), I4(*fillr), 1, fade, ob, 400)
        got = [tuple(ob[7 * i: 7 * i + 7]) for i in range(min(nb, 400))]
        if got != [tuple(x) for x in rbl]:
            nd += 1
            if first is None:
                first = (di, rect, fillr, fade, rbl[:3], got[:3], len(rbl), nb)
    say('part 1 draw    %4d draws:     %s' % (len(ref['draw']), 'BIT-EXACT' if not nd else
        '%d differ, first %s' % (nd, first)))
    bad += bool(nd)
    lib.juno_gui_destroy(c)
    # margin
    w = margin_check(margin_floats())
    ok = w is None or w[0] > Decimal('1e-9')
    say('part 1 margin  %4d floats:    the nearest lies %.3e from its step (%s)' % (
        len(margin_floats()), float(w[0]), 'more than 1e-9: every log10 within 1e-12 agrees' if ok else 'TOO CLOSE'))
    bad += not ok

    # part 2
    import truth
    bank = open(truth.BANK, 'rb').read()
    if repr(ref['_chains']) != repr(chains()):
        say('part 2: the reference does not hold this gate\'s chains (a partial or stale reference)')
        bad += 1
    for ci, (name, rate, steps) in enumerate(ref['_chains']):
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_set_fp_oracle_mode(1)
        lib.juno_gui_plugin_init(c)
        L0, R0 = (ctypes.c_float * PRELUDE)(), (ctypes.c_float * PRELUDE)()
        lib.juno_gui_process_ex(c, (Note * 1)(), 0, (Param * 1)(), 0, 0, 120.0, L0, R0, PRELUDE)
        lib.juno_rr_settle(lib.juno_gui_state(c))
        PL, PR, reads = [], [], []
        for stp in steps:
            k = stp[0]
            if k == 'patch':
                lib.juno_gui_queue_patch(c, bank, len(bank), stp[1])
            elif k == 'state':
                b = b''.join(struct.pack('>Ii', a, v) for a, v in stp[1])
                b = struct.pack('>I', len(b)) + b
                lib.juno_gui_queue_state(c, b, len(b))
            elif k == 'rate':
                lib.juno_gui_set_active(c, 0)
                lib.juno_gui_setup_processing(c, stp[1])
                lib.juno_gui_set_active(c, 1)
            elif k == 'read':
                led = f2b(lib.juno_gui_lfo_led(c))
                p0 = f2b(lib.juno_gui_peak(c, 0))
                p1 = f2b(lib.juno_gui_peak(c, 1))
                reads.append((led, p0, p1, tuple(peek())))
            elif k == 'blk':
                _, n, evs = stp
                arr = (Note * max(1, len(evs)))()
                for i, (kk, o, ch, p, v) in enumerate(evs):
                    arr[i] = Note(o, 0 if kk == 'on' else 1, ch, p, v)
                L = (ctypes.c_float * n)()
                R = (ctypes.c_float * n)()
                lib.juno_gui_process_ex(c, arr, len(evs), (Param * 1)(), 0, 1, 120.0, L, R, n)
                PL += list(struct.unpack('<%dI' % n, bytes(L)))
                PR += list(struct.unpack('<%dI' % n, bytes(R)))
        unp = lib.juno_gui_unported(c)
        lib.juno_gui_destroy(c)
        RL, RR, RD_ = ref[ci]
        adiff = [i for i in range(len(RL)) if RL[i] != PL[i] or RR[i] != PR[i]]
        rdiff = [i for i in range(len(RD_)) if tuple(RD_[i][:3]) != reads[i][:3] or tuple(RD_[i][3]) != reads[i][3]]
        if not quiet:
            j = rdiff[0] if rdiff else 0
            print('part 2 chain %d %-8s %6d samples %s; %3d reads %s%s' % (
                ci, name, len(RL), 'bit-exact' if not adiff else 'AUDIO DIFFERS at %d' % adiff[0], len(RD_),
                'BIT-EXACT (LED %s)' % ' '.join('%.2f' % b2f(x[0]) for x in RD_[:8]) if not rdiff else
                'DIFFER at read %d: plugin led %.6g peaks %.6g %.6g store %s / port led %.6g peaks %.6g %.6g store %s' % (
                    j, b2f(RD_[j][0]), b2f(RD_[j][1]), b2f(RD_[j][2]), RD_[j][3],
                    b2f(reads[j][0]), b2f(reads[j][1]), b2f(reads[j][2]), reads[j][3]),
                '' if not unp else '  -- REACHED AN UNPORTED PATH'))
        bad += bool(adiff) or bool(rdiff) or bool(unp)
    return bad


TEETH = [(1, 'the store resets on a fall too (no >= 0 test)'), (2, 'the mean branch from a longer period only (>)'),
         (3, 'the blink toggle never wraps'), (4, 'the blink blend without the lo term'),
         (5, 'the right peak merged in the left order (NaN)'), (6, 'the peak in plain order (no groups of four)'),
         (7, "the LED fed voice 1's square"), (8, 'the LED fed before the sample'),
         (9, 'the LED frame rounded'), (10, 'the dB floor at 0.0001'), (11, 'the fade one step early')]


def tooth_lib(n):
    work = os.path.join(REPO, 'scratchpad', 'led_meter_teeth')
    os.makedirs(work, exist_ok=True)
    out = os.path.join(work, 'libjuno_t%d.so' % n)
    src = os.path.join(REPO, 'src')
    subprocess.check_call(['gcc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                           '-DLM_TOOTH=%d' % n, '-o', out, os.path.join(REPO, 'gui', 'juno_bridge.c')] +
                          sorted(os.path.join(src, f) for f in os.listdir(src) if f.endswith('.c')) + ['-lm'])
    return out


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return build_ref()
    if a == ['--port']:
        bad = check_port()
        print('\n=== THE LFO LED AND THE LEVEL METERS (CLAIMS A37): plugin vs port ===')
        print('GATE: %s' % ('FAIL' if bad else 'PASS'))
        return 1 if bad else 0
    if a == ['--port-tooth']:
        res = []
        for n, what in TEETH:
            b = check_port(tooth_lib(n), quiet=True)
            print('tooth %2d %-48s %s (%d parts differ)' % (n, what, 'BITES' if b else 'DID NOT BITE', b))
            res.append(b)
        return 0 if all(res) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
