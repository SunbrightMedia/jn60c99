#!/usr/bin/env python3
"""jn_ops.py -- the two executors of a jn_search_seq plan: OracleOps on the host oracle (host_process_emu.HostProcess,
Unicorn) and LiftOps on the lifted JUNO host (libjunohost.so, ctypes). Each op makes EXACTLY the plugin calls the
matching junoh_* entry of lift/jn_host.c makes, in the same order (a Learn by id looks its record up with REC_ID over
every record, as jn_host.c's cc_record does), so the two sides run the same plugin code. Both precompute the record
table once after setup with the same REC_ID calls. Both digest the end-state memory (image + heap + host arena) the
same way. TWO-PROCESS RULE: this module imports Unicorn only inside OracleOps, and ctypes only inside LiftOps -- a
process uses one of them, never both.
run(op) -> (status, words): status 'ok' or 'throw' (the plugin threw a C++ exception: the oracle stops by name, the
lift traps by name); words the output samples of a block (L then R, uint32), b'' otherwise. Any other failure raises."""
import os
import sys
import struct
import hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import jn_search_seq as S                                          # noqa: E402

REC_ID, MODEL_SET, UITICK, CC_LEARN, CC_FORGET = 0x319C50, 0x283DB0, 0x320120, 0x31AA40, 0x3192E0
TRIO = (0x285320, 0x2853C0, 0x283120)
HEADER, STRIDE, NAME = 23, 20223, 16


def rec_tail(bank, idx):
    return bank[HEADER + idx * STRIDE + NAME: HEADER + (idx + 1) * STRIDE]


class OracleOps:
    """the oracle side: h is a HostProcess after setup (or start)"""

    def __init__(self, h, bank):
        sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
        sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
        import host_process_emu as H                              # noqa: E402  (Unicorn: this process only)
        self.H, self.h, self.uc, self.bank = H, h, h.uc, bank
        self.IB = H.IB
        q = self.q
        vb, ve = q(h.core + 24), q(h.core + 32)
        self.recs = [(self._rec_id(i), q(vb + 24 * i)) for i in range((ve - vb) // 24)]

    def q(self, a):
        return struct.unpack('<Q', self.uc.mem_read(a, 8))[0]

    def _rec_id(self, i):
        return self.h.call(self.IB + REC_ID, rcx=self.h.core + 24, rdx=i) & 0xFFFFFFFF

    def _cc_record(self, pid):                                     # jn_host.c cc_record: REC_ID over all, last match
        h, k = self.h, -1
        n = (self.q(h.core + 32) - self.q(h.core + 24)) // 24
        for j in range(n):
            if self._rec_id(j) == pid:
                k = j
        return k

    def run(self, op):
        h, IB, H = self.h, self.IB, self.H
        try:
            if op[0] == 'proc':
                pars = [((p[0][1] if p[0][0] == 'id' else self.recs[p[0][1]][0]), p[1], p[2]) for p in op[3]]
                cf = S.ctx_fields(op[4])
                ctx = None if cf is None else dict(state=cf[0], ppq=cf[1], cycle=(cf[2], cf[3]), tempo=cf[4])
                L, R = h.process(op[1], events=list(op[2]), params=pars, ctx=ctx)
                return 'ok', (struct.pack('<%dI' % len(L), *L) + struct.pack('<%dI' % len(R), *R)) if op[1] else b''
            if op[0] == 'rate':
                h.set_active(0); h.setup_processing(op[1]); h.set_active(1)
            elif op[0] == 'active':
                h.set_active(0); h.set_active(1)
            elif op[0] == 'uitick':
                h.call(IB + UITICK, rcx=h.core, count=2_000_000_000)
            elif op[0] == 'learn':
                k = self._cc_record(self.recs[op[1]][0])
                h.call(IB + CC_LEARN, rcx=h.core + 24, rdx=k if k >= 0 else 0xFFFFFFFF)
            elif op[0] == 'forget':
                k = self._cc_record(self.recs[op[1]][0])
                if k >= 0:
                    h.call(IB + CC_FORGET, rcx=h.core + 24, rdx=k)
            elif op[0] == 'commit':
                model = self.q(self.q(h.core + 8))
                for rva in TRIO:
                    h.call(IB + rva, rcx=model, count=500_000_000)
            elif op[0] == 'getset':
                r = h.set_state(h.get_state())
                if r & 0xFFFFFFFF:
                    raise RuntimeError('setState -> 0x%x' % r)
            elif op[0] == 'patch':
                h.load_patch(rec_tail(self.bank, op[1]))
            elif op[0] == 'model':
                model = self.q(self.q(h.core + 8))
                h.call(IB + MODEL_SET, rcx=model, rdx=self.recs[op[1]][1], r8=op[2] & 0xFFFFFFFF, r9=1, count=500_000_000)
            else:
                raise ValueError('op %r' % (op,))
        except H.W.PluginThrow:
            return 'throw', b''
        return 'ok', b''

    def layout(self):
        E = self.H.E
        return dict(IB=E.IB, IMGSZ=E.IMGSZ, HEAP_BASE=E.HEAP_BASE, COM=self.H.W.COM)

    def digest(self):
        E, h = self.H.E, self.h
        m = hashlib.sha256()
        m.update(bytes(self.uc.mem_read(E.IB, E.IMGSZ)))
        m.update(bytes(self.uc.mem_read(E.HEAP_BASE, h.heap - E.HEAP_BASE)))
        m.update(bytes(self.uc.mem_read(self.H.W.COM, h.com_next - self.H.W.COM)))
        return m.hexdigest(), h.heap, h.com_next

    def dump(self, d):
        """the digested regions as files (a divergence's diff: JN_DUMP_AT)"""
        E, h = self.H.E, self.h
        os.makedirs(d, exist_ok=True)
        for nm, a, n in (('image', E.IB, E.IMGSZ), ('heap', E.HEAP_BASE, h.heap - E.HEAP_BASE),
                         ('com', self.H.W.COM, h.com_next - self.H.W.COM)):
            open(os.path.join(d, nm + '.bin'), 'wb').write(bytes(self.uc.mem_read(a, n)))


class LiftOps:
    """the lifted side: lib is libjunohost.so after junoh_init; lay the memory layout (IB, IMGSZ, HEAP_BASE, COM)"""

    def __init__(self, lib, bank, lay):
        import ctypes                                             # noqa: E402  (ctypes: this process only)
        self.ct, self.lib, self.bank, self.lay = ctypes, lib, bank, lay
        U32, U64, I, D, VP, SZ = ctypes.c_uint32, ctypes.c_uint64, ctypes.c_int, ctypes.c_double, ctypes.c_void_p, ctypes.c_size_t

        class EV(ctypes.Structure):
            _fields_ = [('on', I), ('offset', I), ('channel', I), ('pitch', I), ('velocity', ctypes.c_float)]

        class PAR(ctypes.Structure):
            _fields_ = [('id', U32), ('offset', I), ('value', D)]

        class CTX(ctypes.Structure):
            _fields_ = [('state', U32), ('ppq', D), ('cs', D), ('ce', D), ('tempo', D)]
        self.EV, self.PAR, self.CTX = EV, PAR, CTX
        sig = dict(junoh_set_rate=(I, [D]), junoh_set_active=(I, [I]), junoh_ui_tick=(I, []),
                   junoh_cc_learn=(I, [U32]), junoh_cc_forget=(I, [U32]), junoh_commit=(I, []),
                   junoh_rec_id=(I, [I, ctypes.POINTER(U32), ctypes.POINTER(U64)]),
                   junoh_get_state=(I, [VP, SZ, ctypes.POINTER(SZ)]),
                   junoh_set_state=(I, [VP, SZ, ctypes.POINTER(U32)]),
                   junoh_load_patch=(I, [VP, SZ]), junoh_model_set=(I, [U64, U32]),
                   junoh_process=(I, [I, ctypes.POINTER(EV), I, ctypes.POINTER(PAR), I, ctypes.POINTER(CTX),
                                      ctypes.POINTER(U32), ctypes.POINTER(U32)]),
                   junoh_heap_top=(U64, []), junoh_com_next=(U64, []), junoh_guest=(VP, [U64, SZ]),
                   junoh_error=(ctypes.c_char_p, []))
        for fn, (res, args) in sig.items():
            getattr(lib, fn).restype = res
            getattr(lib, fn).argtypes = args
        self.recs = []
        while True:                                               # junoh_rec_id: E_ARG past the last record (no call)
            pid, obj = U32(0), U64(0)
            if lib.junoh_rec_id(len(self.recs), ctypes.byref(pid), ctypes.byref(obj)):
                break
            self.recs.append((pid.value, obj.value))

    def _chk(self, rc):
        if rc:
            msg = self.lib.junoh_error().decode('latin1', 'replace')
            if 'C++ exception' in msg:
                raise _Throw(msg)
            raise RuntimeError('rc=%d: %s' % (rc, msg))

    def run(self, op):
        ct, lib = self.ct, self.lib
        try:
            if op[0] == 'proc':
                n = op[1]
                evs = [self.EV(1 if e[0] == 'on' else 0, e[1], e[2], e[3], e[4]) for e in op[2]]
                pars = [self.PAR((p[0][1] if p[0][0] == 'id' else self.recs[p[0][1]][0]), p[1], float(p[2])) for p in op[3]]
                cf = S.ctx_fields(op[4])
                cx = None if cf is None else ct.byref(self.CTX(*cf))
                L = (ct.c_uint32 * max(n, 1))(); R = (ct.c_uint32 * max(n, 1))()
                self._chk(lib.junoh_process(n, (self.EV * len(evs))(*evs) if evs else None, len(evs),
                                            (self.PAR * len(pars))(*pars) if pars else None, len(pars), cx, L, R))
                return 'ok', (struct.pack('<%dI' % n, *L[:n]) + struct.pack('<%dI' % n, *R[:n])) if n else b''
            if op[0] == 'rate':
                self._chk(lib.junoh_set_rate(op[1]))
            elif op[0] == 'active':
                self._chk(lib.junoh_set_active(0)); self._chk(lib.junoh_set_active(1))
            elif op[0] == 'uitick':
                self._chk(lib.junoh_ui_tick())
            elif op[0] == 'learn':
                self._chk(lib.junoh_cc_learn(self.recs[op[1]][0]))
            elif op[0] == 'forget':
                self._chk(lib.junoh_cc_forget(self.recs[op[1]][0]))
            elif op[0] == 'commit':
                self._chk(lib.junoh_commit())
            elif op[0] == 'getset':
                cap = 1 << 20; buf = ct.create_string_buffer(cap); nb = ct.c_size_t(0); r = ct.c_uint32(0)
                self._chk(lib.junoh_get_state(buf, cap, ct.byref(nb)))
                if nb.value > cap:
                    raise RuntimeError('state larger than the buffer')
                self._chk(lib.junoh_set_state(buf, nb.value, ct.byref(r)))
                if r.value:
                    raise RuntimeError('setState -> 0x%x' % r.value)
            elif op[0] == 'patch':
                rec = rec_tail(self.bank, op[1]); b = ct.create_string_buffer(rec, len(rec))
                self._chk(lib.junoh_load_patch(b, len(rec)))
            elif op[0] == 'model':
                self._chk(lib.junoh_model_set(self.recs[op[1]][1], op[2] & 0xFFFFFFFF))
            else:
                raise ValueError('op %r' % (op,))
        except _Throw:
            return 'throw', b''
        return 'ok', b''

    def _mem(self, base, size):
        if not size:
            return b''
        p = self.lib.junoh_guest(base, size)
        if not p:
            raise RuntimeError('junoh_guest(0x%x, %d) -> NULL' % (base, size))
        return self.ct.string_at(p, size)

    def digest(self):
        lay, lib = self.lay, self.lib
        ht, cn = lib.junoh_heap_top(), lib.junoh_com_next()
        m = hashlib.sha256()
        m.update(self._mem(lay['IB'], lay['IMGSZ']))
        m.update(self._mem(lay['HEAP_BASE'], ht - lay['HEAP_BASE']))
        m.update(self._mem(lay['COM'], cn - lay['COM']))
        return m.hexdigest(), ht, cn

    def dump(self, d):
        """the digested regions as files (a divergence's diff: JN_DUMP_AT)"""
        lay, lib = self.lay, self.lib
        ht, cn = lib.junoh_heap_top(), lib.junoh_com_next()
        os.makedirs(d, exist_ok=True)
        for nm, a, n in (('image', lay['IB'], lay['IMGSZ']), ('heap', lay['HEAP_BASE'], ht - lay['HEAP_BASE']),
                         ('com', lay['COM'], cn - lay['COM'])):
            open(os.path.join(d, nm + '.bin'), 'wb').write(self._mem(a, n))


class _Throw(Exception):
    pass
