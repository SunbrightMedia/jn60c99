#!/usr/bin/env python3
"""meter_emu.py -- the plugin's LFO LED store, output peaks and GUI meter functions under Unicorn
(CLAIMS A37, docs/LED_METER.md). Plumbing only, around the plugin's own code; used by
led_meter_gate.py and tools/dist/exe_oracle_check.py.

Rig(emu, host=None): fake objects in an emulator image (an e2e_emu.E2E or a HostProcess) --
a HOST (vtable slot 9 the meter read rva 0x34AF70, slot 10 the LED read rva 0x3C7180; its locks
at +16 / +40, its peaks at +32 / +36, its store at +1040) unless the running engine is given, a
core whose +0x110 is that HOST, a control, a root, a blitter whose two slots record their calls:
  store_set / store_get   the store's 7 fields (engine +1040)
  store_add(v), store_read(lo, hi)        rva 0x324A30 / 0x324980 (whole functions)
  tail(L, R)              rva 0x3C787B..0x3C79C4: the engine render's peak and merge (a segment)
  peak_read(ch), led_read()               rva 0x34AF70 / 0x3C7180 on the HOST (whole functions)
  led_frame(v, nframes)   rva 0x3250F2..: the LED's frame from the read (a segment)
  meter_tick(state, decay, ch, rect, horiz) -> (state, fill)
                          rva 0x31C46A..: the meter's tick, its read on the HOST (a segment)
  bar_draw(rect, fill, fade) -> blits     rva 0x31C210, horizontal (whole function)
Floats travel as their bits. A segment starts inside a function with its body's stack frame
built by hand (the saved slots, the return address) and runs to its return.

FedHost: a HostProcess whose served engine render does what the plugin's threads and render tail
do around the e2e composition: the voice stub calls the engine's vt+104 (rva 0x3C7230, the
store's add of unit 0's entry 29) after each of unit 0's samples (rva 0x3C6F00: if (!a2) ...),
and each served render runs the plugin's own tail on its output. Call bind() after start().
"""
import struct

import e2e_emu as E
import host_process_emu as H
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_RSP, UC_X86_REG_RIP, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                               UC_X86_REG_R9, UC_X86_REG_RAX, UC_X86_REG_RBX, UC_X86_REG_RSI, UC_X86_REG_RDI,
                               UC_X86_REG_R12, UC_X86_REG_XMM0, UC_X86_REG_XMM1, UC_X86_REG_XMM2, UC_X86_REG_XMM6)

IB = E.IB
STORE_ADD, STORE_READ, LED_READ, PEAK_READ = IB + 0x324A30, IB + 0x324980, IB + 0x3C7180, IB + 0x34AF70
TAIL, TAIL_END = IB + 0x3C787B, IB + 0x3C79C4
LED_FRAME, METER_TICK, BAR_DRAW = IB + 0x3250F2, IB + 0x31C46A, IB + 0x31C210
FMA3_FLAG = IB + 0x6D2671 + 0x5E536B        # the CRT's log10 (rva 0x6D2660) takes its FMA3 path when set
RET = E.SCRATCH + 0x5000
TOP = (E.STACK_BASE + E.STACK_SIZE - 0x10000) & ~0xF
MASK64 = 2 ** 64 - 1


class Rig:
    def __init__(self, emu, host=None):
        self.e, self.uc = emu, emu.uc
        uc = self.uc
        if struct.unpack('<I', bytes(uc.mem_read(FMA3_FLAG, 4)))[0] != 0:
            raise RuntimeError('the CRT FMA3 flag is set: log10 would take a path the emulator cannot run')
        b = emu.bump
        self.stubs = b(0x40)
        uc.mem_write(self.stubs, b'\xC3' * 0x40)
        self.retstub, self.blit, self.ablit = self.stubs, self.stubs + 0x10, self.stubs + 0x20
        if host is None:
            host = b(0x1000)
            vt = b(0x100)
            uc.mem_write(host, b'\0' * 0x1000)
            uc.mem_write(host, struct.pack('<Q', vt))
            uc.mem_write(vt, b''.join(struct.pack('<Q', self.retstub) for _ in range(32)))
            uc.mem_write(vt + 8 * 9, struct.pack('<QQ', PEAK_READ, LED_READ))
        self.HOST = host
        self.core, self.ctl, self.cvt, self.root = b(0x200), b(0x400), b(0x100), b(0x200)
        self.buf, self.ptrs = b(0x1000), b(0x20)
        self.holder, self.blitter, self.bvt = b(0x100), b(0x40), b(0x40)
        uc.mem_write(self.core, b'\0' * 0x200)
        uc.mem_write(self.core + 0x110, struct.pack('<Q', host))
        uc.mem_write(self.cvt, b''.join(struct.pack('<Q', self.retstub) for _ in range(32)))
        uc.mem_write(self.holder + 0x30, struct.pack('<Q', self.blitter))
        uc.mem_write(self.blitter, struct.pack('<Q', self.bvt))
        uc.mem_write(self.bvt, struct.pack('<QQQQ', self.retstub, self.retstub, self.blit, self.ablit))
        self.blits = []
        uc.hook_add(UC_HOOK_CODE, self._on_blit, begin=self.blit, end=self.ablit)

    # ---------------------------------------------------------------- plumbing
    def rd(self, a, n):
        return bytes(self.uc.mem_read(a, n))

    def _on_blit(self, uc, addr, size, ud):
        rsp = uc.reg_read(UC_X86_REG_RSP)
        q = lambda a: struct.unpack('<Q', self.rd(a, 8))[0]
        ii = lambda a: struct.unpack('<ii', self.rd(a, 8))
        if addr == self.blit:      # (this, ctx, &dst, &size, &src)
            d, sz, src = ii(uc.reg_read(UC_X86_REG_R8)), ii(uc.reg_read(UC_X86_REG_R9)), ii(q(rsp + 0x28))
            self.blits.append((d[0], d[1], sz[0], sz[1], src[0], src[1], -1))
        elif addr == self.ablit:   # (this, ctx, &dst, alpha, &size, &src)
            d, a = ii(uc.reg_read(UC_X86_REG_R8)), uc.reg_read(UC_X86_REG_R9) & 0xFFFFFFFF
            sz, src = ii(q(rsp + 0x28)), ii(q(rsp + 0x30))
            self.blits.append((d[0], d[1], sz[0], sz[1], src[0], src[1], struct.unpack('<i', struct.pack('<I', a))[0]))

    def fcall(self, fn, rcx=0, rdx=0, xmm=()):
        """a whole function, RET on the stack; returns xmm0's low 32 bits"""
        uc = self.uc
        rsp = TOP - 8
        uc.mem_write(rsp, struct.pack('<Q', RET))
        uc.reg_write(UC_X86_REG_RSP, rsp)
        uc.reg_write(UC_X86_REG_RCX, rcx & MASK64)
        uc.reg_write(UC_X86_REG_RDX, rdx & MASK64)
        for rg, v in xmm:
            uc.reg_write(rg, v)
        uc.emu_start(fn, RET, count=50_000_000)
        if uc.reg_read(UC_X86_REG_RIP) != RET:
            raise RuntimeError('call rva 0x%x did not return' % (fn - IB))
        return uc.reg_read(UC_X86_REG_XMM0) & 0xFFFFFFFF

    def segment(self, begin, until, regs=(), xmm=(), frame=()):
        """from begin to until with the body's stack pointer S and the frame's slots written"""
        uc = self.uc
        S = TOP - 0x2000
        for off, data in frame:
            uc.mem_write(S + off, data)
        uc.reg_write(UC_X86_REG_RSP, S)
        for rg, v in regs:
            uc.reg_write(rg, v & MASK64)
        for rg, v in xmm:
            uc.reg_write(rg, v)
        uc.emu_start(begin, until, count=50_000_000)
        if uc.reg_read(UC_X86_REG_RIP) != until:
            raise RuntimeError('segment rva 0x%x stopped at 0x%x' % (begin - IB, uc.reg_read(UC_X86_REG_RIP)))

    # ---------------------------------------------------------------- the store and the peaks
    def store_set(self, st7):
        self.uc.mem_write(self.HOST + 1040, struct.pack('<7I', *[x & 0xFFFFFFFF for x in st7]))

    def store_get(self):
        return list(struct.unpack('<7I', self.rd(self.HOST + 1040, 28)))

    def holds_set(self, h2):
        self.uc.mem_write(self.HOST + 32, struct.pack('<II', *[x & 0xFFFFFFFF for x in h2]))

    def holds_get(self):
        return struct.unpack('<II', self.rd(self.HOST + 32, 8))

    def store_add(self, v):
        self.fcall(STORE_ADD, rcx=self.HOST + 1040, xmm=((UC_X86_REG_XMM1, v), (UC_X86_REG_XMM2, v)))

    def store_read(self, lo, hi):
        return self.fcall(STORE_READ, rcx=self.HOST + 1040, xmm=((UC_X86_REG_XMM1, lo), (UC_X86_REG_XMM2, hi)))

    def tail(self, L, R):
        """one engine render call's tail on the samples L, R (bits) of the HOST"""
        n = len(L)
        self.uc.mem_write(self.buf, struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R))
        self.uc.mem_write(self.ptrs, struct.pack('<QQ', self.buf, self.buf + 4 * n))
        self.segment(TAIL, TAIL_END, regs=((UC_X86_REG_RSI, n), (UC_X86_REG_R12, self.ptrs)),
                     frame=((0x28, struct.pack('<Q', self.HOST)),))

    def peak_read(self, ch):
        return self.fcall(PEAK_READ, rcx=self.HOST, rdx=ch)

    def led_read(self):
        return self.fcall(LED_READ, rcx=self.HOST, rdx=0)

    # ---------------------------------------------------------------- the GUI's ticks and draw
    def led_frame(self, v, nframes):
        self.uc.mem_write(self.root + 0x128, struct.pack('<i', 12345))
        self.segment(LED_FRAME, RET, regs=((UC_X86_REG_RAX, nframes & 0xFFFFFFFF), (UC_X86_REG_RDI, self.root)),
                     xmm=((UC_X86_REG_XMM6, v),), frame=((0x38, struct.pack('<Q', RET)),))
        return struct.unpack('<i', self.rd(self.root + 0x128, 4))[0]

    def meter_tick(self, state, decay, ch, rect, horiz, fade=10):
        c = self.ctl
        uc = self.uc
        uc.mem_write(c, b'\0' * 0x400)
        uc.mem_write(c, struct.pack('<Q', self.cvt))
        uc.mem_write(c + 0x18, struct.pack('<4i', *rect))
        uc.mem_write(c + 0x80, bytes([1 if horiz else 0]))
        uc.mem_write(c + 0x84, struct.pack('<4i', -7, -7, -7, -7))
        uc.mem_write(c + 0xC0, struct.pack('<Q', self.core))
        uc.mem_write(c + 0xC8, struct.pack('<iiii', decay, ch, fade, state))
        self.segment(METER_TICK, RET, regs=((UC_X86_REG_RBX, c),), frame=((0x38, struct.pack('<Q', RET)),))
        return struct.unpack('<i', self.rd(c + 0xD4, 4))[0], struct.unpack('<4i', self.rd(c + 0x84, 16))

    def bar_draw(self, rect, fill, fade):
        c = self.ctl
        uc = self.uc
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


class FedHost(H.HostProcess):
    def bind(self):
        a = E.Asm()
        a.raw(0x55)
        a.movabs_rbp(E.PB_VOICE)
        a.raw(0x48, 0x83, 0xEC, 0x30)
        a.label('loop')
        a.raw(0x48, 0x8B, 0x45, 0x10)
        a.raw(0x48, 0x89, 0x45, 0x28)
        a.raw(0x48, 0x8B, 0x45, 0x18)
        a.raw(0x48, 0x89, 0x45, 0x30)
        a.raw(0x48, 0x8B, 0x4D, 0x00)
        a.raw(0x8B, 0x55, 0x08)
        a.raw(0x4C, 0x8D, 0x45, 0x28)
        a.movabs_rax(E.VOICE_WRAP)
        a.raw(0xFF, 0xD0)                                   # VOICE_WRAP(state, unit, outs)
        a.raw(0x48, 0x83, 0x45, 0x10, 0x04)
        a.raw(0x48, 0x83, 0x45, 0x18, 0x04)
        a.raw(0x83, 0x7D, 0x08, 0x00)                       # unit 0 (rva 0x3C6F00: if (!a2) ...)
        a.jnz('skip')
        a.raw(0x48, 0xB9, *struct.pack('<Q', self.HOST))    # mov rcx, the engine
        a.raw(0x48, 0x8B, 0x01)                             # mov rax, [rcx]
        a.raw(0xFF, 0x50, 0x68)                             # call [rax + 0x68]: the engine's vt+104
        a.label('skip')
        a.raw(0x48, 0xFF, 0x4D, 0x20)
        a.jnz('loop')
        a.raw(0x48, 0x83, 0xC4, 0x30)
        a.raw(0x5D)
        a.raw(0xC3)
        code = a.done()
        if len(code) >= 0x400:
            raise RuntimeError('the voice stub overruns the master stub')
        self.uc.mem_write(self.SVOICE, code)
        self.rig = Rig(self, host=self.HOST)
        return self

    def _serve(self, req):
        super()._serve(req)
        uc = self.uc
        S = (req['rsp'] - 0x180000) & ~0xF                   # below the served render's stack
        uc.mem_write(S + 0x28, struct.pack('<Q', self.HOST))
        uc.reg_write(UC_X86_REG_RSP, S)
        uc.reg_write(UC_X86_REG_RSI, req['n'])
        uc.reg_write(UC_X86_REG_R12, req['a4'])
        uc.emu_start(TAIL, TAIL_END, count=50_000_000)
        if uc.reg_read(UC_X86_REG_RIP) != TAIL_END:
            raise RuntimeError('the render tail stopped at rva 0x%x' % (uc.reg_read(UC_X86_REG_RIP) - IB))
