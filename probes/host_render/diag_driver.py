"""Diagnostic for tools/verify/host_process_gate.py (CLAIMS B14): run the first NSTEP steps of
one chain on both sides with the engine state captured after every block (voice v from unit v,
the master from unit 8: the regions every engine gate compares), and report the first block whose
audio or state differs and the first differing words.

    python3 probes/host_render/diag_driver.py --ref  CHAIN NSTEP   (Unicorn only)
    python3 probes/host_render/diag_driver.py --port CHAIN NSTEP   (libjuno only)
Writes / reads scratchpad/diag_driver.pkl."""
import os
import pickle
import struct
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_gate as G          # noqa: E402
import warm_render_gate as WR          # noqa: E402

PKL = os.path.join(REPO, 'scratchpad', 'diag_driver.pkl')


def chain(ci):
    """(name, rate, steps, setting, prelude). DIAG_CHAIN: a Python literal (name, rate, steps[,
    setting, prelude]) instead of the gate's chain ci"""
    if os.environ.get('DIAG_CHAIN'):
        import ast
        c = ast.literal_eval(os.environ['DIAG_CHAIN'])
        return c if len(c) == 5 else (c[0], c[1], c[2], G.SETTING[c[1]], G.PRELUDE)
    return G.chains()[ci]


ARP_NAMES = ['kb_ctr', 'requant', 'division', 'clk_on', 'clk20', 'clk24', 'state', 'next_step', 'pat_step',
             'count', 'sel_step', 'started', 'ud_dir', 'oct_adv', 'oct_shift', 'range', 'selector', 'field56',
             'sorted0', 'sorted1', 'sorted2', 'sorted3', 'pitch0', 'pitch1', 'pitch2', 'pitch3',
             'off0', 'off1', 'off2', 'off3', 'nslots', 'pat_len']


def arp_fields(h):
    """unit 0's keyboard object (engine+120) and CKbdArp (engine+112), the port's carp order"""
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
    u8 = lambda a: uc.mem_read(a, 1)[0]
    s8 = lambda a: struct.unpack('<b', uc.mem_read(a, 1))[0]
    kb, arp = q(h.HOST + 120), q(h.HOST + 112)
    sel_fn = q(arp + 3480) - E_IB()
    sel = {0x3BEFC0: 0, 0x3BE6E0: 3, 0x3BE850: 19, 0x3BE5C0: 20}.get(sel_fn, sel_fn)
    out = [i32(kb), u8(kb + 6), u8(kb + 5), u8(arp + 197), i32(arp + 20), i32(arp + 24), i32(arp + 44), i32(arp + 3048),
           i32(arp + 3056), i32(arp + 3320), i32(arp + 3464), u8(arp + 3460), u8(arp + 3461), u8(arp + 3468),
           i32(arp + 3472), i32(arp + 3476), sel, i32(arp + 56)]
    out += [s8(arp + 3064 + k) for k in range(4)]
    out += [u8(arp + 806 + 12 * k) for k in range(4)]
    out += [i32(arp + 812 + 12 * k) for k in range(4)]
    out += [s8(arp + 3054), s8(arp + 3055)]
    return out


def E_IB():
    import e2e_emu as E
    return E.IB


def ref(ci, nstep):
    import host_process_emu as H
    import e2e_emu as E
    bank = E.bank_bytes()
    name, rate, steps, setting, prelude = chain(ci)
    h = H.HostProcess()
    h.start(rate, 4096, setting=setting)
    payload = h.get_state()
    h.process(prelude)
    h.snap_all()
    out = []
    for si, stp in enumerate(steps[:nstep]):
        if stp[0] == 'patch':
            rec = bank[G.HEADER + stp[1] * G.STRIDE: G.HEADER + (stp[1] + 1) * G.STRIDE]
            h.load_patch(rec[G.NAME:])
        elif stp[0] == 'state':
            pl = b''.join(struct.pack('>Ii', a, b) for a, b in stp[1])
            h.set_state(struct.pack('>I', len(pl)) + pl)
        else:
            _, n, evs, ctx = stp
            c = None if ctx is None else (dict(tempo=ctx[1], playing=True) if ctx[0] else dict(state=0x2, tempo=ctx[1]))
            l, r = h.process(n, events=evs, ctx=c)
            parts = []
            for v in range(8):
                for a, b in WR.voice_regions(v):
                    parts.append(bytes(h.uc.mem_read(h.state[v] + a, b - a)))
            for a, b in WR.master_ranges():
                parts.append(bytes(h.uc.mem_read(h.state[8] + a, b - a)))
            out.append((si, l, r, zlib.compress(b''.join(parts), 6), arp_fields(h)))
    pickle.dump({'ci': ci, 'payload': payload, 'blocks': out}, open(PKL, 'wb'))
    print('wrote %s: %d blocks' % (PKL, len(out)))


def port(ci, nstep):
    import ctypes
    import numpy as np
    import freshlib
    import truth
    d = pickle.load(open(PKL, 'rb'))
    assert d['ci'] == ci
    name, rate, steps, setting, prelude = chain(ci)
    lib = freshlib.load()
    V = ctypes.c_void_p

    class Note(ctypes.Structure):
        _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                    ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_state.restype = V
    lib.juno_gui_state.argtypes = [V]
    lib.juno_gui_unit_noise.restype = V
    lib.juno_gui_unit_noise.argtypes = [V, ctypes.c_int]
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                   ('juno_gui_process', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.c_int, ctypes.c_double,
                                         ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float), ctypes.c_int]),
                   ('juno_set_fp_oracle_mode', [ctypes.c_int])):
        getattr(lib, fn).argtypes = at
    lib.juno_set_fp_oracle_mode(1)
    bankb = open(truth.BANK, 'rb').read()
    c = lib.juno_gui_create(ctypes.c_float(rate), 0)
    lib.juno_set_fp_oracle_mode(1)            # after create, which sets the production FTZ
    lib.juno_gui_plugin_init(c)
    lib.juno_gui_queue_state(c, d['payload'], len(d['payload']))
    L0, R0 = (ctypes.c_float * prelude)(), (ctypes.c_float * prelude)()
    lib.juno_gui_process(c, (Note * 1)(), 0, 0, 120.0, L0, R0, prelude)
    lib.juno_rr_settle.argtypes = [V]
    lib.juno_rr_settle(lib.juno_gui_state(c))
    # word index -> (unit, offset) for the report
    where = []
    for v in range(8):
        for a, b in WR.voice_regions(v):
            where += [(v, a + 4 * k) for k in range((b - a) // 4)]
    for a, b in WR.master_ranges():
        where += [(8, a + 4 * k) for k in range((b - a) // 4)]
    bi = 0
    for si, stp in enumerate(steps[:nstep]):
        if stp[0] == 'patch':
            lib.juno_gui_queue_patch(c, bankb, len(bankb), stp[1])
        elif stp[0] == 'state':
            b = b''.join(struct.pack('>Ii', a, v) for a, v in stp[1])
            b = struct.pack('>I', len(b)) + b
            lib.juno_gui_queue_state(c, b, len(b))
        else:
            _, n, evs, ctx = stp
            arr = (Note * max(1, len(evs)))()
            for i, (k, off, ch, pch, vel) in enumerate(evs):
                arr[i] = Note(off, 0 if k == 'on' else 1, ch, pch, vel)
            L = (ctypes.c_float * n)()
            R = (ctypes.c_float * n)()
            valid, tempo = (0, 120.0) if ctx is None else (1 if ctx[0] else 0, ctx[1])
            lib.juno_gui_process(c, arr, len(evs), valid, tempo, L, R, n)
            gl = list(struct.unpack('<%dI' % n, bytes(L)))
            gr = list(struct.unpack('<%dI' % n, bytes(R)))
            rsi, wl, wr, wst, warp = d['blocks'][bi]
            bi += 1
            stp_ = lib.juno_gui_state(c)
            parts = []
            for v in range(8):
                for a, b in WR.voice_regions(v):
                    parts.append(ctypes.string_at(lib.juno_gui_unit_noise(c, v), b - a) if (a, b) == WR.SHARED
                                 else ctypes.string_at(stp_ + a, b - a))
            for a, b in WR.master_ranges():
                parts.append(ctypes.string_at(stp_ + a, b - a))
            got = np.frombuffer(b''.join(parts), dtype='<u4')
            want = np.frombuffer(zlib.decompress(wst), dtype='<u4')
            dd = np.nonzero(got != want)[0]
            da = [i for i in range(n) if gl[i] != wl[i] or gr[i] != wr[i]]
            print('step %3d block %3d (n=%d, %d events, ctx %s): audio %s, state %s' % (
                si, bi - 1, n, len(evs), ctx, 'ok' if not da else '%d differ from %d' % (len(da), da[0]),
                'ok' if not len(dd) else '%d words differ: %s' % (len(dd), ' '.join(
                    'u%d+%d plug %08x port %08x' % (where[x][0], where[x][1], int(want[x]), int(got[x])) for x in dd[:6]))))
            ga = (ctypes.c_int * 32)()
            lib.juno_gui_arp_debug(c, ga)
            ga = list(ga)
            adiff = [(ARP_NAMES[k], warp[k], ga[k]) for k in range(32) if warp[k] != ga[k]]
            if adiff and os.environ.get('DIAG_ARP'):
                print('      arp fields differ (name, plugin, port):', adiff)
            if (len(dd) or da) and si >= int(os.environ.get('DIAG_FROM', '0')):
                break


if __name__ == '__main__':
    mode, ci, ns = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    ref(ci, ns) if mode == '--ref' else port(ci, ns)
