#!/usr/bin/env python3
"""jx_meter_gate.py -- the JX-3P's two level meters, plugin vs port (JX-22; the JUNO-60's A37 rules on the JX:
docs/LED_METER.md rules 5, 6, 9-12; jx3p/docs/HOST_LAYER.md 3p).

The engine side is the JX's own (READ from its render 0x3F9220): the output gain stage's loop takes, per channel,
the larger magnitude of the call's samples after their gain (`comiss peak, |x|; jae`), and merges it into the held
peaks at HOST+0x20 / +0x24 (maxss(held, peak), both channels). A meter's read (the engine's vt+72, rva 0x34AE30), its
tick (0x31C330: the dB step through the CRT's log10 0x708A70, the decay, the bar's fill 0x2C98F0) and its draw
(0x31C0F0) are the JUNO's code (fw_map --pair: equal).

PART 1 -- the plugin's own code on seeded and edge inputs, in plain IEEE mode on both sides:
  tails   the render's loop 0x3F96DA..0x3F98F1 (a segment of the real engine, booted at 96 kHz): the gain stage,
          the peaks and the merge on crafted samples (NaN payloads, infinities, denormals, signed zeros), held
          peaks and gain states (steady, muted, the delay ending inside the call, fading in, out, clamped, an
          unordered step); compared: every output sample, the held peaks, the five gain cells
  reads   the meter read on crafted held peaks, both channels: the value and the zero it leaves
  ticks   the meter's tick (a segment after its drag check, 0x31C34A) on every float next to each of the
          998 dB steps, edge floats, NaNs and seeded states / decays / rectangles: the state and the fill
  draws   the bar's draw with a blitter whose two slots record every blit
PART 2 -- the meters in the running plugin (jx_host_emu: its own process(), render driver, render object and
  engine render, the peaks its own): chains at 44.1 / 48 / 96 kHz with chords, a clock patch, an effects patch, a
  warm patch change and silence; both meters read (vt+72) after every block or every ~50 ms; compared: every read
  and every sample.

usage: jx_meter_gate.py [--tooth [--reuse]]
  the plugin's reference is made from the plugin each run and kept in scratchpad/jx_meter/meter_ref.pkl;
  --tooth: every JX_LM_TOOTH build of the bridge must FAIL; --reuse: take the reference the last plain run kept
  (make verify-jx3p runs the plain gate first)
exit 0 = EQUAL (or every tooth bites).
"""
import atexit
import ctypes
import os
import pickle
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import led_meter_gate as LMG                           # noqa: E402  (the JUNO gate's seeded inputs: plain data)

SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
TAIL, TAIL_END = 0x3F96DA, 0x3F98F1                    # the render's gain + peak loop and merge, to the cookie check
PEAK_READ, METER_TICK, BAR_DRAW = 0x34AE30, 0x31C34A, 0x31C0F0
LOG10_FLAG = 0x708A81 + 0x5E718B                       # the CRT log10's FMA3 path flag (cmp [rip+..], 0 at 0x708A7A)
H_GAIN, H_GSTEP, H_GLEFT, H_GDELAY, H_GTIME = 0x860, 0x864, 0x868, 0x86C, 0x870
f2b, b2f, qn = LMG.f2b, LMG.b2f, LMG.qn
NAN_BITS, EDGE_BITS = LMG.NAN_BITS, LMG.EDGE_BITS
TEETH = [(1, "the merge's operands swapped (the JUNO's left channel)"), (2, 'the peak taken before the gain'),
         (3, 'the peak test ordered (a NaN never replaces it)'), (4, 'the dB floor at 0.0001'),
         (5, 'the fade one step early')]
_TMP = []
atexit.register(lambda: [shutil.rmtree(d, ignore_errors=True) for d in _TMP])


# ------------------------------------------------------------------ part 1 inputs (seeded)
def gain_states():
    """(gain, step, left, delay, time) as bits / ints: steady, muted, the delay ending, fading, clamping"""
    F = f2b
    return [(F(1.0), F(1.0 / 960), 0, 0, F(10.0)), (F(0.0), F(-1.0), 0, 48000, F(10.0)),
            (F(0.0), F(-1.0), 0, 3, F(10.0)), (F(0.0), F(-1.0), 0, 1, F(10.0)), (F(0.0), F(-1.0), 0, 1, F(0.0)),
            (F(0.0), F(-1.0), 0, 2, F(1e30)), (F(0.25), F(1.0 / 960), 500, 0, F(10.0)),
            (F(0.9), F(0.05), 10, 0, F(10.0)), (F(0.5), F(-0.1), 7, 0, F(10.0)), (F(0.0), 0x7FC00000, 0, 0, F(10.0)),
            (F(0.3), 0x7FC00000, 4, 0, F(10.0)), (F(0.0), F(0.0), 0, 0, F(10.0)), (F(0.0), F(-0.0), 0, 5, F(10.0)),
            (F(-0.5), F(0.25), 3, 0, F(10.0)), (F(1.0), F(1.0), -5, 0, F(10.0))]


def tail_cases():
    import random
    r = random.Random(LMG.SEED + 11)
    gs = gain_states()
    out = []
    for i, (hold, L, R) in enumerate(LMG.tail_cases()):
        g = gs[0] if i < 300 else (gs[i % len(gs)] if r.random() < 0.8 else
                                    (f2b(r.uniform(-0.5, 1.5)), f2b(r.uniform(-0.2, 0.2)), r.choice((0, 1, 9, 400, -1)),
                                     r.choice((0, 1, 2, 30)), f2b(r.choice((10.0, 0.5, 33.3)))))
        out.append((hold, L, R, g))
    return out


def read_cases():
    out = []
    for b in EDGE_BITS + NAN_BITS + (f2b(0.5), f2b(1e-3), f2b(2.0)):
        for c in (0, 1):
            out.append(((b, f2b(0.25)) if c == 0 else (f2b(0.25), b), c))
    return out


# ------------------------------------------------------------------ the plugin's side (a worker: Unicorn only)
class Rig:
    """fake objects around the plugin's real engine (jx_emu.JX booted at 96 kHz): a core whose +0x110 is the
    engine, a control, its vtable of returns, a blitter whose two slots record their calls (the JUNO's
    tools/verify/meter_emu.py, at the JX's addresses). Plumbing only."""

    def __init__(self):
        import jx_emu as J
        from unicorn import UC_HOOK_CODE
        self.J = J
        jx = J.JX().boot(96000.0, snap=False, static_init=True)
        self.jx, self.uc = jx, jx.uc
        uc = self.uc
        if struct.unpack('<I', bytes(uc.mem_read(J.IB + LOG10_FLAG, 4)))[0] != 0:
            raise RuntimeError('the CRT FMA3 flag is set: log10 would take a path the emulator cannot run')
        self.HOST = jx.HOST
        self.RET = J.SCRATCH + 0x5000
        self.TOP = (J.STACK_BASE + J.STACK_SIZE - 0x10000) & ~0xF
        b = jx.bump
        self.stubs = b(0x40)
        uc.mem_write(self.stubs, b'\xC3' * 0x40)
        self.retstub, self.blit, self.ablit = self.stubs, self.stubs + 0x10, self.stubs + 0x20
        self.core, self.ctl, self.cvt = b(0x200), b(0x400), b(0x100)
        self.buf, self.ptrs = b(0x1000), b(0x20)
        self.holder, self.blitter, self.bvt = b(0x100), b(0x40), b(0x40)
        uc.mem_write(self.core, b'\0' * 0x200)
        uc.mem_write(self.core + 0x110, struct.pack('<Q', self.HOST))
        uc.mem_write(self.cvt, b''.join(struct.pack('<Q', self.retstub) for _ in range(32)))
        uc.mem_write(self.holder + 0x30, struct.pack('<Q', self.blitter))
        uc.mem_write(self.blitter, struct.pack('<Q', self.bvt))
        uc.mem_write(self.bvt, struct.pack('<QQQQ', self.retstub, self.retstub, self.blit, self.ablit))
        self.blits = []
        uc.hook_add(UC_HOOK_CODE, self._on_blit, begin=self.blit, end=self.ablit)

    def rd(self, a, n):
        return bytes(self.uc.mem_read(a, n))

    def _on_blit(self, uc, addr, size, ud):
        from unicorn.x86_const import UC_X86_REG_RSP, UC_X86_REG_R8, UC_X86_REG_R9
        rsp = uc.reg_read(UC_X86_REG_RSP)
        q = lambda a: struct.unpack('<Q', self.rd(a, 8))[0]
        ii = lambda a: struct.unpack('<ii', self.rd(a, 8))
        if addr == self.blit:
            d, sz, src = ii(uc.reg_read(UC_X86_REG_R8)), ii(uc.reg_read(UC_X86_REG_R9)), ii(q(rsp + 0x28))
            self.blits.append((d[0], d[1], sz[0], sz[1], src[0], src[1], -1))
        elif addr == self.ablit:
            d, a = ii(uc.reg_read(UC_X86_REG_R8)), uc.reg_read(UC_X86_REG_R9) & 0xFFFFFFFF
            sz, src = ii(q(rsp + 0x28)), ii(q(rsp + 0x30))
            self.blits.append((d[0], d[1], sz[0], sz[1], src[0], src[1], struct.unpack('<i', struct.pack('<I', a))[0]))

    def _ieee(self):
        from unicorn.x86_const import UC_X86_REG_MXCSR
        self.uc.reg_write(UC_X86_REG_MXCSR, 0x1F80)

    def fcall(self, rva, rcx=0, rdx=0):
        from unicorn.x86_const import UC_X86_REG_RSP, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_RIP, UC_X86_REG_XMM0
        uc = self.uc
        rsp = self.TOP - 8
        uc.mem_write(rsp, struct.pack('<Q', self.RET))
        uc.reg_write(UC_X86_REG_RSP, rsp)
        uc.reg_write(UC_X86_REG_RCX, rcx)
        uc.reg_write(UC_X86_REG_RDX, rdx)
        self._ieee()
        uc.emu_start(self.J.IB + rva, self.RET, count=50_000_000)
        if uc.reg_read(UC_X86_REG_RIP) != self.RET:
            raise RuntimeError('call rva 0x%x did not return' % rva)
        return uc.reg_read(UC_X86_REG_XMM0) & 0xFFFFFFFF

    def segment(self, begin, until, regs=(), frame=()):
        from unicorn.x86_const import UC_X86_REG_RSP, UC_X86_REG_RIP
        uc = self.uc
        S = self.TOP - 0x2000
        for off, data in frame:
            uc.mem_write(S + off, data)
        uc.reg_write(UC_X86_REG_RSP, S)
        for rg, v in regs:
            uc.reg_write(rg, v & (2 ** 64 - 1))
        self._ieee()
        uc.emu_start(begin, until, count=50_000_000)
        if uc.reg_read(UC_X86_REG_RIP) != until:
            raise RuntimeError('segment 0x%x stopped at rva 0x%x' % (begin, uc.reg_read(UC_X86_REG_RIP) - self.J.IB))

    def cells(self, vals=None):
        offs = (H_GAIN, H_GSTEP, H_GLEFT, H_GDELAY, H_GTIME, 0x20, 0x24)
        if vals is not None:
            for o, v in zip(offs, vals):
                self.uc.mem_write(self.HOST + o, struct.pack('<I', v & 0xFFFFFFFF))
        return [struct.unpack('<I', self.rd(self.HOST + o, 4))[0] for o in offs]

    def tail(self, L, R):
        from unicorn.x86_const import UC_X86_REG_R12, UC_X86_REG_R13, UC_X86_REG_R14
        n = len(L)
        self.uc.mem_write(self.buf, struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R))
        self.uc.mem_write(self.ptrs, struct.pack('<QQ', self.buf, self.buf + 4 * n))
        self.segment(self.J.IB + TAIL, self.J.IB + TAIL_END,
                     regs=((UC_X86_REG_R12, self.ptrs), (UC_X86_REG_R13, self.HOST), (UC_X86_REG_R14, n)))
        o = self.rd(self.buf, 8 * n)
        return list(struct.unpack('<%dI' % n, o[:4 * n])), list(struct.unpack('<%dI' % n, o[4 * n:]))

    def meter_tick(self, state, decay, ch, rect, horiz, fade=10):
        from unicorn.x86_const import UC_X86_REG_RBX
        c, uc = self.ctl, self.uc
        uc.mem_write(c, b'\0' * 0x400)
        uc.mem_write(c, struct.pack('<Q', self.cvt))
        uc.mem_write(c + 0x18, struct.pack('<4i', *rect))
        uc.mem_write(c + 0x80, bytes([1 if horiz else 0]))
        uc.mem_write(c + 0x84, struct.pack('<4i', -7, -7, -7, -7))
        uc.mem_write(c + 0xC0, struct.pack('<Q', self.core))
        uc.mem_write(c + 0xC8, struct.pack('<iiii', decay, ch, fade, state))
        self.segment(self.J.IB + METER_TICK, self.RET, regs=((UC_X86_REG_RBX, c),),
                     frame=((0x38, struct.pack('<Q', self.RET)),))
        return struct.unpack('<i', self.rd(c + 0xD4, 4))[0], struct.unpack('<4i', self.rd(c + 0x84, 16))

    def bar_draw(self, rect, fill, fade):
        c, uc = self.ctl, self.uc
        uc.mem_write(c, b'\0' * 0x400)
        uc.mem_write(c, struct.pack('<Q', self.cvt))
        uc.mem_write(c + 0x18, struct.pack('<4i', *rect))
        uc.mem_write(c + 0x28, struct.pack('<Q', self.holder))
        uc.mem_write(c + 0x80, bytes([1]))
        uc.mem_write(c + 0x84, struct.pack('<4i', *fill))
        uc.mem_write(c + 0xD0, struct.pack('<i', fade))
        del self.blits[:]
        self.fcall(BAR_DRAW, rcx=c, rdx=0x1234)
        return list(self.blits)


def part1_plugin(out):
    rig = Rig()
    res = {'tails': [], 'reads': [], 'ticks': [], 'draws': []}
    for hold, L, R, g in tail_cases():
        rig.cells(list(g) + list(hold))
        oL, oR = rig.tail(L, R)
        res['tails'].append((oL, oR, rig.cells()))
    for hold, ch in read_cases():
        rig.cells(list(gain_states()[0]) + list(hold))
        v = rig.fcall(PEAK_READ, rcx=rig.HOST, rdx=ch)
        res['reads'].append((v, rig.cells()[5:]))
    for b, st, dec, rc, hz in LMG.meter_cases():
        ch = (b ^ st) & 1
        hold = (b, f2b(0.5)) if ch == 0 else (f2b(0.5), b)
        rig.cells(list(gain_states()[0]) + list(hold))
        s, fill = rig.meter_tick(st, dec, ch, rc, hz)
        res['ticks'].append((s, fill, rig.cells()[5:]))
    for rect, fill, fade in LMG.draw_cases():
        res['draws'].append(rig.bar_draw(rect, fill, fade))
    pickle.dump(res, open(out, 'wb'))


# ------------------------------------------------------------------ part 2 chains
def chains():
    """(name, host rate, patch, block, blocks, reads every k blocks, schedule kind, recall (block, patch) or None)"""
    return [('chord48', 48000, 5, 512, 190, 1, ('poly', 1), None),
            ('clock96', 96000, 34, 480, 400, 10, ('poly', 2), None),
            ('fx44', 44100, 49, 441, 200, 5, ('note', 0.55, 1.2), None),
            ('warm48', 48000, 0, 512, 190, 1, ('poly', 3), (95, 20)),
            ('silent48', 48000, 0, 512, 100, 1, ('none',), None)]


def chain_events(c):
    import jx_product_gate as PG
    name, rate, patch, blk, nblk, every, kind, rc = c
    if kind[0] == 'poly':
        return PG.poly_schedule(nblk, blk, int(0.55 * rate), kind[1])
    if kind[0] == 'note':
        return PG.schedule(nblk, blk, int(kind[1] * rate), int(kind[2] * rate))
    return [[] for _ in range(nblk)]


def part2_plugin(ci, out):
    import jx_bank as B
    import jx_host_emu as X
    from unicorn.x86_const import UC_X86_REG_XMM0
    c = chains()[ci]
    name, rate, patch, blk, nblk, every, kind, rc = c
    bank = open(os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin'), 'rb').read()
    tail = lambda p: bank[B.BANK_HEADER + p * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (p + 1) * B.BANK_STRIDE]
    h = X.JXHost()
    h.start(float(rate), blk)
    h.load_patch(tail(patch))
    res = []
    for b, ev in enumerate(chain_events(c)):
        if rc and b == rc[0]:
            h.load_patch(tail(rc[1]))
        L, R = h.process(blk, events=ev)
        reads = None
        if (b + 1) % every == 0:
            reads = []
            for ch in (0, 1):
                h.call(X.IB + PEAK_READ, rcx=h.HOST, rdx=ch)
                reads.append(h.uc.reg_read(UC_X86_REG_XMM0) & 0xFFFFFFFF)
        res.append((list(L), list(R), reads))
    pickle.dump(res, open(out, 'wb'))


# ------------------------------------------------------------------ the port's side (a worker: ctypes only)
def port_worker(so, out):
    import jx_guest
    lib = ctypes.CDLL(so)
    I = ctypes.c_int
    U = ctypes.c_uint32
    lib.jx3p_product_init.argtypes = [ctypes.c_char_p, ctypes.c_char_p, I]
    lib.jx3p_peak.restype = ctypes.c_float
    lib.jx3p_peak.argtypes = [I]
    lib.jx3p_meter_tick.argtypes = [I, I, I, ctypes.POINTER(I), I, ctypes.POINTER(I)]
    lib.jx3p_bar_draw.argtypes = [ctypes.POINTER(I), ctypes.POINTER(I), I, I, ctypes.POINTER(I), I]
    lib.jx3p_product_note.argtypes = [I, I, I, I, ctypes.c_float]
    img = jx_guest.path(96).encode()
    bank = os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode()
    cells = (U * 7)()
    lib.jx3p_gain_cells.restype = None

    def peek():
        lib.jx3p_gain_cells(cells, 0)
        return list(cells)

    def setc(v):
        for k in range(7):
            cells[k] = v[k] & 0xFFFFFFFF
        lib.jx3p_gain_cells(cells, 1)
    res = {'tails': [], 'reads': [], 'ticks': [], 'draws': []}
    if lib.jx3p_product_init(img, bank, 96000) < 0:
        raise SystemExit('jx3p_product_init failed')
    # PART 1, plain IEEE mode (no jx_enable_hw_ftz in this process)
    for hold, L, R, g in tail_cases():
        setc(list(g) + list(hold))
        n = len(L)
        Lb = (ctypes.c_uint32 * max(1, n))(*L)
        Rb = (ctypes.c_uint32 * max(1, n))(*R)
        lib.jx3p_gain_tail(ctypes.cast(Lb, ctypes.POINTER(ctypes.c_float)),
                           ctypes.cast(Rb, ctypes.POINTER(ctypes.c_float)), n)
        res['tails'].append((list(Lb)[:n], list(Rb)[:n], peek()))
    for hold, ch in read_cases():
        setc(list(gain_states()[0]) + list(hold))
        v = lib.jx3p_peak(ch)
        res['reads'].append((f2b(v), peek()[5:]))
    fill = (I * 4)()
    for b, st, dec, rc, hz in LMG.meter_cases():
        ch = (b ^ st) & 1
        setc(list(gain_states()[0]) + list((b, f2b(0.5)) if ch == 0 else (f2b(0.5), b)))
        s = lib.jx3p_meter_tick(ch, dec, st, (I * 4)(*rc), hz, fill)
        res['ticks'].append((s, tuple(fill), peek()[5:]))
    ob = (I * (7 * 400))()
    for rect, fl, fade in LMG.draw_cases():
        n = lib.jx3p_bar_draw((I * 4)(*rect), (I * 4)(*fl), 1, fade, ob, 400)
        res['draws'].append([tuple(ob[7 * k:7 * k + 7]) for k in range(min(n, 400))])
    # PART 2, in the oracle's FP mode (the product path's own)
    lib.jx_set_fp_oracle_mode(1)    # the oracle's mode: DAZ on, FTZ off -- Unicorn never flushes a result (playbook 120)
    res['chains'] = []
    for c in chains():
        name, rate, patch, blk, nblk, every, kind, rc = c
        if lib.jx3p_product_init(img, bank, rate) < 0:
            raise SystemExit('jx3p_product_init(%d) failed' % rate)
        lib.jx3p_product_load_patch(patch)
        Lb = (ctypes.c_float * blk)(); Rb = (ctypes.c_float * blk)()
        arr = (I * 1)()
        out_c = []
        for b, ev in enumerate(chain_events(c)):
            if rc and b == rc[0]:
                lib.jx3p_product_load_patch(rc[1])
            for e in ev:
                if lib.jx3p_product_note(0 if e[0] == 'on' else 1, e[1], e[2], e[3], e[4]) != 0:
                    raise SystemExit('jx3p_product_note refused')
            lib.jx3p_product_block(Lb, Rb, blk, arr, 0)
            reads = [f2b(lib.jx3p_peak(ch)) for ch in (0, 1)] if (b + 1) % every == 0 else None
            out_c.append((list(struct.unpack('<%dI' % blk, bytes(Lb))), list(struct.unpack('<%dI' % blk, bytes(Rb))),
                          reads))
        res['chains'].append(out_c)
    pickle.dump(res, open(out, 'wb'))


# ------------------------------------------------------------------ the gate
def build_lib(tooth=0):
    d = tempfile.mkdtemp(prefix='jxmeter_')
    _TMP.append(d)
    so = os.path.join(d, 'libjx_t%d.so' % tooth)
    subprocess.check_call(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                           '-DJX_LM_TOOTH=%d' % tooth, '-o', so] + [os.path.join(REPO, s) for s in SRCS] + ['-lm'])
    return so


def plugin_ref(tmp):
    import multiprocessing as mp
    jobs = [('p1', os.path.join(tmp, 'p1.pkl'))] + [('p2', ci, os.path.join(tmp, 'p2_%d.pkl' % ci))
                                                     for ci in range(len(chains()))]
    with mp.get_context('spawn').Pool(3) as pool:
        pool.map(_run_plugin_job, jobs, chunksize=1)
    ref = pickle.load(open(jobs[0][1], 'rb'))
    ref['chains'] = [pickle.load(open(j[2], 'rb')) for j in jobs[1:]]
    return ref


def _run_plugin_job(j):
    if j[0] == 'p1':
        part1_plugin(j[1])
    else:
        part2_plugin(j[1], j[2])


def compare(ref, got, quiet):
    bad = 0

    def fail(msg):
        nonlocal bad
        bad += 1
        if not quiet and bad <= 12:
            print('  FAIL ' + msg)
    for i, (a, b) in enumerate(zip(ref['tails'], got['tails'])):
        if a[0] != b[0] or a[1] != b[1]:
            fail('tail %d: the samples after the gain differ' % i)
        elif a[2] != b[2]:
            fail('tail %d: cells / held peaks plugin %s port %s' % (i, [hex(x) for x in a[2]], [hex(x) for x in b[2]]))
    for i, (a, b) in enumerate(zip(ref['reads'], got['reads'])):
        if qn(a[0]) != qn(b[0]) or list(a[1]) != list(b[1]):
            fail('read %d: plugin %s port %s' % (i, (hex(a[0]), a[1]), (hex(b[0]), b[1])))
    for i, (a, b) in enumerate(zip(ref['ticks'], got['ticks'])):
        if (a[0], tuple(a[1]), list(a[2])) != (b[0], tuple(b[1]), list(b[2])):
            fail('tick %d: plugin %s port %s' % (i, a, b))
    for i, (a, b) in enumerate(zip(ref['draws'], got['draws'])):
        if [tuple(x) for x in a] != [tuple(x) for x in b]:
            fail('draw %d: plugin %s port %s' % (i, a[:3], b[:3]))
    nread = 0
    for ci, (ra, rb) in enumerate(zip(ref['chains'], got['chains'])):
        for k, (a, b) in enumerate(zip(ra, rb)):
            if a[0] != b[0] or a[1] != b[1]:
                fail('chain %s block %d: the samples differ' % (chains()[ci][0], k))
                break
            if a[2] is not None:
                nread += 1
                if [qn(x) for x in a[2]] != [qn(x) for x in b[2]]:
                    fail('chain %s block %d: the meters read plugin %s port %s' % (
                        chains()[ci][0], k, [hex(x) for x in a[2]], [hex(x) for x in b[2]]))
    counts = (len(ref['tails']), len(ref['reads']), len(ref['ticks']), len(ref['draws']), nread)
    return bad, counts


def run_port(ref, tooth, quiet):
    so = build_lib(tooth)
    out = os.path.join(os.path.dirname(so), 'port.pkl')
    subprocess.check_call([sys.executable, os.path.abspath(__file__), '--port-worker', so, out])
    return compare(ref, pickle.load(open(out, 'rb')), quiet)


def main():
    a = sys.argv[1:]
    if a[:1] == ['--port-worker']:
        port_worker(a[1], a[2])
        return 0
    worst = LMG.margin_check(LMG.margin_floats())
    if worst is None or worst[0] < 1e-9:
        raise SystemExit('a float next to a dB step lies within 1e-9 of it: the C log10 may step differently')
    keep = os.path.join(REPO, 'scratchpad', 'jx_meter', 'meter_ref.pkl')
    if '--reuse' in a and os.path.exists(keep):
        ref = pickle.load(open(keep, 'rb'))
    else:
        tmp = tempfile.mkdtemp(prefix='jxmeter_ref_')
        _TMP.append(tmp)
        ref = plugin_ref(tmp)
        os.makedirs(os.path.dirname(keep), exist_ok=True)
        pickle.dump(ref, open(keep + '.partial', 'wb'))
        os.replace(keep + '.partial', keep)
    nonzero = sum(1 for c in ref['chains'] for blk in c if blk[2] and any(x & 0x7FFFFFFF for x in blk[2]))
    if '--tooth' in a:
        res = []
        for n, what in TEETH:
            b, _ = run_port(ref, n, True)
            print('tooth %d %-52s %s (%d differ)' % (n, what, 'BITES' if b else 'DID NOT BITE', b))
            res.append(b)
        return 0 if all(res) else 1
    bad, (nt, nr, nk, nd, nread) = run_port(ref, 0, False)
    print('jx_meter_gate: part 1 -- %d tails, %d reads, %d ticks (every float next to the 998 dB steps; the margin '
          '%.3g), %d draws; part 2 -- %d chains, %d meter reads (%d with a peak): %s' % (
              nt, nr, nk, float(worst[0]), nd, len(chains()), nread, nonzero, 'EQUAL' if not bad else '%d DIFFER' % bad))
    if not nonzero:
        print('jx_meter_gate: REACH -- no meter read saw a peak: the chains grade nothing')
        return 1
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
