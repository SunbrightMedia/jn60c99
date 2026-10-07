#!/usr/bin/env python3
"""host_process_emu.py -- the plugin as a HOST runs it: its own
IAudioProcessor::process (rva 0x34A380) on the booted plugin (probes/b6/wrapper_emu.py).
The oracle of the HOST RENDER LAYER gates (docs/HOST_RENDER_LAYER.md, CLAIMS B13/B14).

Everything above the engine render is the plugin's own code: process() turns host events and
parameter queues into its queue records and its transport struct; the render driver (rva
0x320B20) runs the engine-rate check, the tempo, the arp tick clock and the records at their
offsets; the core's render object (identity rva 0x344270, rate converter rva 0x343E30) asks the
engine for samples. THE ONE REPLACEMENT is the engine render's thread transport (CWaveGen vt+56,
rva 0x3C7400): it signals voice workers through events this emulator does not run, so each call
is served by the e2e_emu composition (assigner voice-count sync, assigner clock, VOICE_WRAP per
unit over the block, MASTER_WRAP per sample: E2E.render, the path every engine gate uses),
writing the master's output into the buffers the plugin passed. Not reproduced: the render's peak
meter (engine+32/+36, read by the GUI only).

The call is served by stopping the emulation at the render's entry, saving the CPU context,
rendering on a stack below the suspended frames, restoring the context and resuming at the
return address (rax = 0; the callers ignore the value).

USE
    h = HostProcess(); h.start(48000.0, 512, setting=2)      # setting: vm.vs.sampleRate index or None
    h.set_active(0); h.setup_processing(44100.0); h.set_active(1)   # a host-rate change while running
    L, R = h.process(512, events=[...], params=[...], ctx=dict(tempo=128.5, playing=True))
events: ('on', offset, channel, pitch, velocity_float) / ('off', offset, channel, pitch, velocity_float)
params: (param id, offset, value_double) -- the LAST point of a queue is what the plugin reads
ctx: None (no ProcessContext) or dict(tempo=, playing=, ppq=, cycle=(start, end), state=raw flags)
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
import wrapper_emu as W                                     # noqa: E402
from unicorn import UC_HOOK_CODE                            # noqa: E402
from unicorn.x86_const import (UC_X86_REG_RSP, UC_X86_REG_RIP, UC_X86_REG_RAX, UC_X86_REG_RCX,   # noqa: E402
                               UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9)

E = W.E
IB = E.IB
ENGINE_RENDER = IB + 0x3C7400       # CWaveGen vt+56
PROCESS_SLOT = 9                    # IAudioProcessor::process (rva 0x34A380)
SAMPLERATE_ID = 0x0FFFC015          # vm.vs.sampleRate
K_PLAYING, K_PPQ, K_TEMPO, K_CYCLE = 0x2, 0x200, 0x400, 0x1000
MAXBLOCK = 4096


class HostProcess(W.Wrapper):
    def __init__(self):
        super().__init__()
        for k, n in (('events', 6), ('pchanges', 6), ('pqueue', 7)):
            self.vt[k] = self._vtable(k, n)
        self._req = None
        self._nested_top = None
        self.renders = []                   # engine sample counts the plugin asked for, in order
        self.uc.hook_add(UC_HOOK_CODE, self._on_render, begin=ENGINE_RENDER, end=ENGINE_RENDER)

    # ------------------------------------------------------------ the one replacement
    def _on_render(self, uc, addr, size, ud):
        rsp = uc.reg_read(UC_X86_REG_RSP)
        q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
        i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
        self._req = dict(ctx=uc.context_save(), ret=q(rsp), rsp=rsp, engine=uc.reg_read(UC_X86_REG_RCX),
                         a4=uc.reg_read(UC_X86_REG_R9), nch=i32(rsp + 0x28), n=i32(rsp + 0x30))
        uc.emu_stop()

    def _serve(self, req):
        uc = self.uc
        if req['engine'] != self.HOST or req['nch'] != 2:
            raise RuntimeError('engine render on 0x%x with %d channels' % (req['engine'], req['nch']))
        n = req['n']
        self._nested_top = (req['rsp'] - 0x100000) & ~0xF
        try:
            if n > 0:
                L, R = E.E2E.render(self, n, block=n)
            else:                                   # the preamble still runs (voice-count sync, clock += 0)
                L, R = [], []
                nv = self.rd_i32(self.HOST + E.HOST_NVOICE)
                for v in range(8):
                    if self.call(E.ASG_GET_COUNT, rcx=self.assign[v]) & 0xFFFFFFFF != nv & 0xFFFFFFFF:
                        self.call(E.ASG_SET_COUNT, rcx=self.assign[v], rdx=nv & 0xFFFFFFFF)
        finally:
            self._nested_top = None
        q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
        if n > 0:
            uc.mem_write(q(req['a4']), struct.pack('<%dI' % n, *L))
            uc.mem_write(q(req['a4'] + 8), struct.pack('<%dI' % n, *R))
        self.renders.append(n)

    def _top(self):
        return self._nested_top if self._nested_top is not None else (E.STACK_BASE + E.STACK_SIZE - 0x10000) & ~0xF

    def call(self, fn, rcx=0, rdx=0, r8=0, r9=0, count=0):
        uc = self.uc
        rsp = self._top() - 8
        RET = E.SCRATCH + 0x5000
        uc.reg_write(UC_X86_REG_RSP, rsp)
        for r, v in ((UC_X86_REG_RCX, rcx), (UC_X86_REG_RDX, rdx), (UC_X86_REG_R8, r8), (UC_X86_REG_R9, r9)):
            uc.reg_write(r, v & (2 ** 64 - 1))
        uc.mem_write(rsp, struct.pack('<Q', RET))
        start = fn
        while True:
            self._req = None
            uc.emu_start(start, RET, count=count)
            req = self._req
            if req is None:
                rip = uc.reg_read(UC_X86_REG_RIP)
                if rip != RET:
                    raise RuntimeError('call to 0x%x stopped at rva 0x%x' % (fn - IB, rip - IB))
                return uc.reg_read(UC_X86_REG_RAX)
            if self._nested_top is not None:
                raise RuntimeError('engine render reached from inside a served render')
            self._serve(req)
            uc.context_restore(req['ctx'])
            uc.reg_write(UC_X86_REG_RIP, req['ret'])
            uc.reg_write(UC_X86_REG_RSP, req['rsp'] + 8)
            uc.reg_write(UC_X86_REG_RAX, 0)
            start = req['ret']

    def _run(self, stub):
        uc = self.uc
        rsp = self._top() - 8
        RET = E.SCRATCH + 0x5000
        uc.reg_write(UC_X86_REG_RSP, rsp)
        uc.mem_write(rsp, struct.pack('<Q', RET))
        uc.emu_start(stub, RET, count=0)
        rip = uc.reg_read(UC_X86_REG_RIP)
        if rip != RET:
            raise RuntimeError('stub stopped at 0x%x (rva 0x%x)' % (rip, rip - IB))

    # ------------------------------------------------------------ host objects
    def _com(self, uc, name, this, a1, a2, a3):
        _, kind, slot = name.split(':')
        slot = int(slot)
        if kind not in ('events', 'pchanges', 'pqueue'):
            return super()._com(uc, name, this, a1, a2, a3)
        o = self.objs[this]
        ret = lambda v: self._ret(uc, v)
        if slot in (1, 2):
            return ret(1)
        if kind == 'events':                         # IEventList
            if slot == 3:
                return ret(len(o['list']))
            if slot == 4:                            # getEvent(index, Event&)
                i = a1 & 0xFFFFFFFF
                if i >= len(o['list']):
                    return ret(1)
                uc.mem_write(a2, o['list'][i])
                return ret(0)
            return ret(1)
        if kind == 'pchanges':                       # IParameterChanges
            if slot == 3:
                return ret(len(o['queues']))
            if slot == 4:
                i = a1 & 0xFFFFFFFF
                return ret(o['queues'][i] if i < len(o['queues']) else 0)
            return ret(0)
        # IParamValueQueue
        if slot == 3:
            return ret(o['id'])
        if slot == 4:
            return ret(len(o['points']))
        if slot == 5:                                # getPoint(index, int32& offset, double& value)
            i = a1 & 0xFFFFFFFF
            if i >= len(o['points']):
                return ret(1)
            off, val = o['points'][i]
            uc.mem_write(a2, struct.pack('<i', off))
            uc.mem_write(a3, struct.pack('<d', val))
            return ret(0)
        return ret(1)

    # ------------------------------------------------------------ host lifecycle
    def start(self, host_sr, max_block=MAXBLOCK, setting=None, state=None, log=lambda s: None):
        """boot as a host does; optional DAW state (bytes) and/or vm.vs.sampleRate index;
        setupProcessing(host_sr, max_block); setActive(1)"""
        uc = self.uc
        self.boot_host(log=log)
        q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
        if state is not None or setting is not None:
            st = state if state is not None else self.get_state()
            if setting is not None:
                n = struct.unpack('>I', st[:4])[0]
                ent = [list(struct.unpack('>Ii', st[4 + i:12 + i])) for i in range(0, n, 8)]
                if not any(a == SAMPLERATE_ID for a, b in ent):
                    ent.append([SAMPLERATE_ID, setting])
                ent = [[a, (setting if a == SAMPLERATE_ID else b)] for a, b in ent]
                st = struct.pack('>I', 8 * len(ent)) + b''.join(struct.pack('>Ii', a, b) for a, b in ent)
            r = self.set_state(st)
            if r != 0:
                raise RuntimeError('setState -> 0x%x' % r)
        setup = self.alloc_com(24)
        uc.mem_write(setup, struct.pack('<iii4xd', 0, 0, max_block, float(host_sr)))
        r = self.vcall(self.audio, 7, setup, count=4_000_000_000) & 0xFFFFFFFF
        if r != 0:
            raise RuntimeError('setupProcessing -> 0x%x' % r)
        r = self.vcall(self.comp, 11, 1, count=4_000_000_000) & 0xFFFFFFFF
        if r != 0:
            raise RuntimeError('setActive -> 0x%x' % r)
        # the engine the plugin built (rva 0x320420): bind the e2e render to it
        self.HOST = q(self.core + 272)
        self.state, self.proc, self.assign, self.noteobj = [], [], [], []
        for i in range(9):
            self.state.append(q(self.HOST + 80 + 64 * i))
            self.proc.append(q(self.HOST + 96 + 64 * i))
            self.assign.append(q(self.HOST + 104 + 64 * i))
            self.noteobj.append(q(self.HOST + 120 + 64 * i))
        self.host_sr, self.max_block = float(host_sr), max_block
        self._bufL, self._bufR = self.alloc_com(4 * max_block), self.alloc_com(4 * max_block)
        chans = self.alloc_com(16)
        uc.mem_write(chans, struct.pack('<QQ', self._bufL, self._bufR))
        self._bus = self.alloc_com(24)
        uc.mem_write(self._bus, struct.pack('<iiQQ', 2, 0, 0, chans))
        self._ctx = self.alloc_com(160)
        self._pd = self.alloc_com(96)
        self._ev = self.new_obj('events', list=[])
        self._pc = self.new_obj('pchanges', queues=[])
        self._pq = []                               # reusable IParamValueQueue objects
        return self

    def set_active(self, on):
        """IComponent::setActive (rva 0x34AA50): the core's setup at the stored rate (rva 0x321AC0),
        the all-sound-off record (rva 0x3208E0), the base"""
        r = self.vcall(self.comp, 11, 1 if on else 0, count=4_000_000_000) & 0xFFFFFFFF
        if r != 0:
            raise RuntimeError('setActive -> 0x%x' % r)

    def setup_processing(self, host_sr, max_block=None):
        """IAudioProcessor::setupProcessing (rva 0x3CB150): the plugin stores the setup; the blocks
        stay within the max block start() allocated"""
        mb = self.max_block if max_block is None else max_block
        if mb > self.max_block:
            raise ValueError('max block %d above the %d start() allocated' % (mb, self.max_block))
        setup = self.alloc_com(24)
        self.uc.mem_write(setup, struct.pack('<iii4xd', 0, 0, mb, float(host_sr)))
        r = self.vcall(self.audio, 7, setup, count=4_000_000_000) & 0xFFFFFFFF
        if r != 0:
            raise RuntimeError('setupProcessing -> 0x%x' % r)
        self.host_sr = float(host_sr)

    def process(self, n, events=(), params=(), ctx=None, nch=2):
        """one host block through the plugin's own process(); returns (Lbits, Rbits). n = 0: the
        host's flush call (no samples); nch: the output bus's channel count for this call (the
        plugin returns at once below 2, rva 0x34A380)"""
        uc = self.uc
        if not 0 <= n <= self.max_block:
            raise ValueError('block %d' % n)
        evs = []
        for e in events:
            kind, off, ch, pitch, vel = e
            b = bytearray(48)
            struct.pack_into('<ii', b, 0, 0, off)
            if kind == 'on':
                struct.pack_into('<HH', b, 16, 0, 0)
                struct.pack_into('<hhff', b, 24, ch, pitch, 0.0, vel)
                struct.pack_into('<ii', b, 36, -1, -1)
            else:
                struct.pack_into('<HH', b, 16, 0, 1)
                struct.pack_into('<hhfi', b, 24, ch, pitch, vel, -1)
            evs.append(bytes(b))
        self.objs[self._ev]['list'] = evs
        groups = {}
        for pid, off, val in params:
            groups.setdefault(pid, []).append((off, val))
        while len(self._pq) < len(groups):
            self._pq.append(self.new_obj('pqueue', id=0, points=[]))
        qs = []
        for k, (pid, pts) in enumerate(groups.items()):
            o = self.objs[self._pq[k]]
            o['id'], o['points'] = pid, pts
            qs.append(self._pq[k])
        self.objs[self._pc]['queues'] = qs
        cptr = 0
        if ctx is not None:
            st = ctx.get('state')
            if st is None:
                st = (K_PLAYING if ctx.get('playing') else 0) | (K_TEMPO if 'tempo' in ctx else 0) | \
                     (K_PPQ if 'ppq' in ctx else 0) | (K_CYCLE if 'cycle' in ctx else 0)
            c = bytearray(160)
            struct.pack_into('<I', c, 0, st)
            struct.pack_into('<d', c, 8, self.host_sr)
            struct.pack_into('<d', c, 40, ctx.get('ppq', 0.0))
            cs, ce = ctx.get('cycle', (0.0, 0.0))
            struct.pack_into('<dd', c, 56, cs, ce)
            struct.pack_into('<d', c, 72, ctx.get('tempo', 0.0))
            uc.mem_write(self._ctx, bytes(c))
            cptr = self._ctx
        pd = bytearray(96)
        struct.pack_into('<iiiii', pd, 0, 0, 0, n, 0, 1)
        struct.pack_into('<QQQQQQQ', pd, 24, 0, self._bus, self._pc if params else 0, 0, self._ev if events else 0, 0, cptr)
        uc.mem_write(self._pd, bytes(pd))
        if n:
            uc.mem_write(self._bufL, b'\0' * (4 * n))
            uc.mem_write(self._bufR, b'\0' * (4 * n))
        if nch != 2:
            bus = bytes(uc.mem_read(self._bus, 24))
            uc.mem_write(self._bus, struct.pack('<i', nch) + bus[4:])
        r = self.vcall(self.audio, PROCESS_SLOT, self._pd, count=0) & 0xFFFFFFFF
        if nch != 2:
            uc.mem_write(self._bus, bus)
        if r != 0:
            raise RuntimeError('process -> 0x%x' % r)
        if not n:
            return [], []
        return (list(struct.unpack('<%dI' % n, uc.mem_read(self._bufL, 4 * n))),
                list(struct.unpack('<%dI' % n, uc.mem_read(self._bufR, 4 * n))))

    def core_i32(self, off):
        return struct.unpack('<i', self.uc.mem_read(self.core + off, 4))[0]

    def core_i64(self, off):
        return struct.unpack('<q', self.uc.mem_read(self.core + off, 8))[0]
