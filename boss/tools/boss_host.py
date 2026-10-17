#!/usr/bin/env python3
"""boss_host.py -- the BOSS plugin's own IAudioProcessor::process() under the oracle, as a DAW calls it on an
EFFECT: a stereo input bus and a stereo output bus, parameter changes as IParameterChanges, an optional
ProcessContext. PLUMBING ONLY: the host objects (process data, buses, queues) are the VST3 SDK's structs; every
sample is the plugin's own code.

USE (separate process from any ctypes port: the two-process rule)
    import boss_host as BH
    h = BH.BossProc.booted()                   # from scratchpad/boss/boot.snap (boss_boot.py), or a fresh boot
    h.setup(48000.0, 512)
    print(h.params()[:5])                      # the controller's parameter list: (id, title, steps, default)
    L, R = h.process(inL_bits, inR_bits, params=[(pid, 0, value)])
"""
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import boss_emu as B                                                    # noqa: E402

W = B.W
PROCESS_SLOT, SETUP_SLOT, SETPROC_SLOT, BUSARR_SLOT = 9, 7, 8, 3        # IAudioProcessor
SETACTIVE_SLOT, GETBUSCOUNT_SLOT, GETBUSINFO_SLOT, ACTIVATEBUS_SLOT = 11, 7, 8, 10   # IComponent
K_SPEAKER_STEREO = 3                                                    # kSpeakerL | kSpeakerR
K_PLAYING, K_TEMPO = 0x2, 0x400


class BossProc(B.BossHost):
    def __init__(self):
        super().__init__()
        for k, n in (('events', 6), ('pchanges', 6), ('pqueue', 7)):
            self.vt[k] = self._vtable(k, n)
        self.ctrl = None

    @classmethod
    def booted(cls, snap=None):
        snap = snap or os.path.join(B.SNAP_DIR, 'boot.snap')
        if os.path.exists(snap):
            return B.load_snapshot(snap, cls=cls)
        h = cls()
        h.boot(log=lambda s: None)
        return h

    # ------------------------------------------------------------ host objects (IEventList, IParameterChanges, IParamValueQueue)
    def _com(self, uc, name, this, a1, a2, a3):
        _, kind, slot = name.split(':')
        slot = int(slot)
        if kind not in ('events', 'pchanges', 'pqueue'):
            return super()._com(uc, name, this, a1, a2, a3)
        o = self.objs[this]
        ret = lambda v: self._ret(uc, v)
        if slot in (1, 2):
            return ret(1)
        if slot == 0:
            uc.mem_write(a2, struct.pack('<Q', 0))
            return ret(W.E_NOINTERFACE)
        if kind == 'events':
            if slot == 3:
                return ret(len(o['list']))
            if slot == 4:
                i = a1 & 0xFFFFFFFF
                if i >= len(o['list']):
                    return ret(1)
                uc.mem_write(a2, o['list'][i])
                return ret(0)
            return ret(1)
        if kind == 'pchanges':
            if slot == 3:
                return ret(len(o['queues']))
            if slot == 4:
                i = a1 & 0xFFFFFFFF
                return ret(o['queues'][i] if i < len(o['queues']) else 0)
            return ret(0)
        if slot == 3:
            return ret(o['id'])
        if slot == 4:
            return ret(len(o['points']))
        if slot == 5:
            i = a1 & 0xFFFFFFFF
            if i >= len(o['points']):
                return ret(1)
            off, val = o['points'][i]
            uc.mem_write(a2, struct.pack('<i', off))
            uc.mem_write(a3, struct.pack('<d', val))
            return ret(0)
        return ret(1)

    # ------------------------------------------------------------ the controller (what a DAW asks at load)
    def controller(self):
        """the edit controller from the component's controller class id, initialized, connected both ways,
        a component handler set, the component state handed over (setComponentState)"""
        if self.ctrl:
            return self.ctrl
        buf = self.alloc_com(0x40)
        r = self.vcall(self.comp, 5, buf) & 0xFFFFFFFF                  # IComponent::getControllerClassId
        if r:
            raise RuntimeError('getControllerClassId -> 0x%x' % r)
        cid = bytes(self.uc.mem_read(buf, 16))
        ctrl = self.create(cid, B.IID_IEDITCONTROLLER)
        r = self.vcall(ctrl, 3, self.new_obj('hostctx')) & 0xFFFFFFFF
        if r:
            raise RuntimeError('controller initialize -> 0x%x' % r)
        cp_p, cp_c = self.qi(self.comp, B.IID_ICONNECTIONPOINT), self.qi(ctrl, B.IID_ICONNECTIONPOINT)
        if cp_p and cp_c:
            self.vcall(cp_p, 3, cp_c)
            self.vcall(cp_c, 3, cp_p)
        self.vcall(ctrl, 16, self.new_obj('handler'))
        self.vcall(ctrl, 5, self.stream(self.get_state()))
        self.ctrl = ctrl
        return ctrl

    def params(self):
        """IEditController::getParameterCount / getParameterInfo: [(id, title, stepCount, default, flags)]"""
        c = self.controller()
        n = self.vcall(c, 8) & 0xFFFFFFFF
        buf = self.alloc_com(792)
        out = []
        for i in range(n):
            self.uc.mem_write(buf, b'\0' * 792)
            if self.vcall(c, 9, i, buf) & 0xFFFFFFFF:
                continue
            b = bytes(self.uc.mem_read(buf, 792))
            pid = struct.unpack_from('<I', b, 0)[0]
            title = b[4:260].decode('utf-16le').split('\0')[0]
            steps = struct.unpack_from('<i', b, 772)[0]
            dflt = struct.unpack_from('<d', b, 776)[0]
            flags = struct.unpack_from('<i', b, 788)[0]
            out.append((pid, title, steps, dflt, flags))
        return out

    def buses(self):
        """IComponent::getBusCount(media, dir) for audio (0) / event (1) x input (0) / output (1)"""
        return {(m, d): self.vcall(self.comp, GETBUSCOUNT_SLOT, m, d) & 0xFFFFFFFF for m in (0, 1) for d in (0, 1)}

    # ------------------------------------------------------------ host lifecycle
    def setup(self, host_sr, max_block=4096, log=lambda s: None):
        uc = self.uc
        self.nbus = self.buses()
        log('buses (media, dir) -> count: %r' % self.nbus)
        arr = self.alloc_com(16)
        uc.mem_write(arr, struct.pack('<QQ', K_SPEAKER_STEREO, K_SPEAKER_STEREO))
        r = self.vcall(self.audio, BUSARR_SLOT, arr, self.nbus[(0, 0)], arr + 8, self.nbus[(0, 1)]) & 0xFFFFFFFF
        log('setBusArrangements(stereo in, stereo out) -> 0x%x' % r)
        for d in (0, 1):
            for k in range(self.nbus[(0, d)]):
                self.vcall(self.comp, ACTIVATEBUS_SLOT, 0, d, k, 1)
        setup = self.alloc_com(24)
        uc.mem_write(setup, struct.pack('<iii4xd', 0, 0, max_block, float(host_sr)))
        r = self.vcall(self.audio, SETUP_SLOT, setup) & 0xFFFFFFFF
        if r:
            raise RuntimeError('setupProcessing -> 0x%x' % r)
        r = self.vcall(self.comp, SETACTIVE_SLOT, 1) & 0xFFFFFFFF
        if r:
            raise RuntimeError('setActive -> 0x%x' % r)
        r = self.vcall(self.audio, SETPROC_SLOT, 1) & 0xFFFFFFFF
        log('setProcessing(1) -> 0x%x' % r)
        self.host_sr, self.max_block = float(host_sr), max_block
        self._buf = [self.alloc_com(4 * max_block) for _ in range(4)]          # in L, in R, out L, out R
        chans_in, chans_out = self.alloc_com(16), self.alloc_com(16)
        uc.mem_write(chans_in, struct.pack('<QQ', self._buf[0], self._buf[1]))
        uc.mem_write(chans_out, struct.pack('<QQ', self._buf[2], self._buf[3]))
        self._bin, self._bout = self.alloc_com(24), self.alloc_com(24)
        uc.mem_write(self._bin, struct.pack('<iiQQ', 2, 0, 0, chans_in))      # AudioBusBuffers
        uc.mem_write(self._bout, struct.pack('<iiQQ', 2, 0, 0, chans_out))
        self._ctx = self.alloc_com(160)
        self._pd = self.alloc_com(96)
        self._ev = self.new_obj('events', list=[])
        self._pc = self.new_obj('pchanges', queues=[])
        self._pq = []
        return self

    def process(self, inL, inR, params=(), ctx=None):
        """one host block: inL / inR = float32 bit patterns (ints); params = (id, offset, normalized value);
        returns (outL bits, outR bits)"""
        uc = self.uc
        n = len(inL)
        if len(inR) != n or not 0 <= n <= self.max_block:
            raise ValueError('block')
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
            c = bytearray(160)
            struct.pack_into('<I', c, 0, (K_PLAYING if ctx.get('playing') else 0) | (K_TEMPO if 'tempo' in ctx else 0))
            struct.pack_into('<d', c, 8, self.host_sr)
            struct.pack_into('<d', c, 72, ctx.get('tempo', 0.0))
            uc.mem_write(self._ctx, bytes(c))
            cptr = self._ctx
        pd = bytearray(96)                                     # ProcessData
        struct.pack_into('<iiiii', pd, 0, 0, 0, n, self.nbus[(0, 0)], self.nbus[(0, 1)])
        struct.pack_into('<QQQQQQQ', pd, 24, self._bin if self.nbus[(0, 0)] else 0, self._bout,
                         self._pc if params else 0, 0, self._ev, 0, cptr)
        uc.mem_write(self._pd, bytes(pd))
        if n:
            uc.mem_write(self._buf[0], struct.pack('<%dI' % n, *inL))
            uc.mem_write(self._buf[1], struct.pack('<%dI' % n, *inR))
            uc.mem_write(self._buf[2], b'\0' * (4 * n))
            uc.mem_write(self._buf[3], b'\0' * (4 * n))
        r = self.vcall(self.audio, PROCESS_SLOT, self._pd, count=0) & 0xFFFFFFFF
        if r:
            raise RuntimeError('process -> 0x%x' % r)
        if not n:
            return [], []
        return (list(struct.unpack('<%dI' % n, uc.mem_read(self._buf[2], 4 * n))),
                list(struct.unpack('<%dI' % n, uc.mem_read(self._buf[3], 4 * n))))
