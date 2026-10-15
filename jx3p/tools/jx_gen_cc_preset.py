#!/usr/bin/env python3
"""jx_gen_cc_preset.py -- generate jx3p/gui/win/jx_cc_preset.h: the CC map preset the JX-3P plugin's option menu
applies ("Set MIDI Control Mapping for SYSTEM-8", the menuButton's menu, rva 0x4147B0), from the booted plugin.

What a worker process EXECUTES on the plugin (Unicorn there, nothing here: the two-process rule):
  the record names (rva 0x411A80: one per CC map record, the records' order), the preset's entries (rva 0x410A00:
  a name and a CC each, the preset's order), every record's id (rva 0x319B30 over the map), and -- to check this
  file's reading against the plugin itself -- the plugin's own apply (rva 0x31A3D0 with 0) and test (rva 0x31A2B0
  with 0 and -1) on the booted map: the records' CCs and the map's (CC -> record) pairs after the apply must be the
  ones this file's rules give (jx3p/gui/win/jx_bridge_exe.c jx3p_cc_preset / jx3p_cc_preset_is).
Written:
  JX_CC_PRESET_SET[]  (record id, CC) in the records' order: each record named in the preset with the CC of its
                      FIRST entry (the apply's search stops there); a later record with the same CC takes the CC
  JX_CC_PRESET_CHK[]  (record id, CC) for EVERY entry naming a record (the test reads them all)
    python3 jx3p/tools/jx_gen_cc_preset.py           write the header
    python3 jx3p/tools/jx_gen_cc_preset.py --check   exit 1 if the committed header differs
"""
import multiprocessing as mp
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(REPO, 'jx3p', 'gui', 'win', 'jx_cc_preset.h')
NAMES, PRESET, APPLY, TEST = 0x411A80, 0x410A00, 0x31A3D0, 0x31A2B0


def census(_):
    """a worker: the plugin booted as jx_panel_gate.py boots it (Unicorn only)"""
    sys.path.insert(0, HERE)
    import jx_panel_gate as G
    g = G.Plugin(48000.0)
    h, IB, q = g.h, g.IB, g.q

    def cstr(a):
        out = b''
        while True:
            c = bytes(g.uc.mem_read(a + len(out), 64))
            if b'\0' in c:
                return (out + c.split(b'\0')[0]).decode('latin1')
            out += c

    def vec(v, stride):
        b, e = q(v), q(v + 8)
        return [b + stride * k for k in range((e - b) // stride)]

    mp_ = h.core + 24                                   # the CC map (the core + 0x18, as the menu's r13)
    names = [cstr(q(a)) for a in vec(h.call(IB + NAMES, count=500_000_000), 8)]
    preset = [(cstr(q(a)), struct.unpack('<i', bytes(g.uc.mem_read(a + 8, 4)))[0])
              for a in vec(h.call(IB + PRESET, rcx=0, count=500_000_000), 16)]
    recs = vec(mp_, 24)
    if len(recs) != len(names):
        raise SystemExit('the map has %d records, the names list %d' % (len(recs), len(names)))
    ids = list(g.rec_id)

    def map_now():
        rcc = [struct.unpack('<i', bytes(g.uc.mem_read(r + 0xC, 4)))[0] for r in vec(mp_, 24)]
        st = h.get_state()
        n = struct.unpack('>I', st[:4])[0] // 8
        pairs = sorted((k - 0x10000000, v) for k, v in (struct.unpack('>Ii', st[4 + 8 * j: 12 + 8 * j]) for j in range(n))
                       if k >= 0x10000000 and v >= 0)
        return rcc, pairs

    test_boot = (h.call(IB + TEST, rcx=mp_, rdx=0, count=500_000_000) & 0xFF,
                 h.call(IB + TEST, rcx=mp_, rdx=0xFFFFFFFF, count=500_000_000) & 0xFF)
    boot = map_now()
    h.call(IB + APPLY, rcx=mp_, rdx=0, count=2_000_000_000)
    applied = map_now()
    test_applied = (h.call(IB + TEST, rcx=mp_, rdx=0, count=500_000_000) & 0xFF,
                    h.call(IB + TEST, rcx=mp_, rdx=0xFFFFFFFF, count=500_000_000) & 0xFF)
    h.call(IB + APPLY, rcx=mp_, rdx=0xFFFFFFFF, count=2_000_000_000)
    cleared = map_now()
    test_cleared = (h.call(IB + TEST, rcx=mp_, rdx=0, count=500_000_000) & 0xFF,
                    h.call(IB + TEST, rcx=mp_, rdx=0xFFFFFFFF, count=500_000_000) & 0xFF)
    return dict(names=names, preset=preset, ids=ids, boot=boot, applied=applied, cleared=cleared,
                tests=(test_boot, test_applied, test_cleared))


def rules(names, preset):
    """this file's reading of rva 0x31A3D0 / 0x31A2B0: the records' CCs and the map after the apply; the test"""
    setl, chk = [], []
    for r, nm in enumerate(names):
        hits = [cc for n2, cc in preset if n2 == nm]
        if hits:
            setl.append((r, hits[0]))
        chk += [(r, cc) for cc in hits]
    rcc = [-1] * len(names)
    mp_ = {}
    for r, cc in setl:
        rcc[r] = cc
        mp_[cc] = r
    return setl, chk, rcc, sorted(mp_.items())


def test(rcc, mp_pairs, chk, k):
    if k < 0:
        return int(not mp_pairs)
    for r in range(len(rcc)):
        mine = [cc for r2, cc in chk if r2 == r]
        if mine and any(cc != rcc[r] for cc in mine):
            return 0
        if not mine and rcc[r] >= 0:
            return 0
    return 1


def header(c):
    names, preset, ids = c['names'], c['preset'], c['ids']
    setl, chk, rcc, pairs = rules(names, preset)
    a_rcc, a_pairs = c['applied']
    if rcc != a_rcc:
        raise SystemExit('the records\' CCs after the plugin\'s apply differ from this file\'s rules: %s'
                         % [(names[r], a_rcc[r], rcc[r]) for r in range(len(rcc)) if rcc[r] != a_rcc[r]][:6])
    if [(cc, ids[r]) for cc, r in pairs] != [(cc, v) for cc, v in a_pairs]:
        raise SystemExit('the map after the plugin\'s apply differs from this file\'s rules')
    c_rcc, c_pairs = c['cleared']
    if any(v != -1 for v in c_rcc) or c_pairs:
        raise SystemExit('the plugin\'s clear left CCs')
    tb, ta, tc = c['tests']
    for (rc, prs), got in ((c['boot'], tb), (c['applied'], ta), (c['cleared'], tc)):
        want = (test(rc, prs, chk, 0), test(rc, prs, chk, -1))
        if tuple(got) != want:
            raise SystemExit('the plugin\'s test gave %s, this file\'s rules %s' % (got, want))
    if any(not 0 <= cc < 128 for _, cc in chk):
        raise SystemExit('a preset CC outside 0..127')
    out = ['/* GENERATED by jx3p/tools/jx_gen_cc_preset.py from the JX-3P plugin (EXECUTED) -- do not edit.',
           ' * The CC map preset of the option menu\'s "Set MIDI Control Mapping for SYSTEM-8" (the menuButton\'s menu,',
           ' * rva 0x4147B0): the records named by the preset (rva 0x410A00, %d entries) among the map\'s %d records'
           % (len(preset), len(names)),
           ' * (rva 0x411A80). SET: in the records\' order, the CC of each named record\'s first entry (rva 0x31A3D0);',
           ' * CHK: every entry naming a record (rva 0x31A2B0). Checked against the plugin\'s own apply and test: the',
           ' * records\' CCs and the map after the apply equal; the test %s at boot, %s after the apply, %s cleared'
           % (tb, ta, tc) + ' (with 0, -1). */',
           '#ifndef JX_CC_PRESET_H', '#define JX_CC_PRESET_H', '#include <stdint.h>',
           'typedef struct { uint32_t id; int8_t cc; } jx_cc_preset_ent;',
           '#define JX_CC_PRESET_SET_N %d' % len(setl),
           'static const jx_cc_preset_ent JX_CC_PRESET_SET[JX_CC_PRESET_SET_N] = {']
    out += ['    {0x%08Xu, %d},   /* %s */' % (ids[r], cc, names[r]) for r, cc in setl]
    out += ['};', '#define JX_CC_PRESET_CHK_N %d' % len(chk),
            'static const jx_cc_preset_ent JX_CC_PRESET_CHK[JX_CC_PRESET_CHK_N] = {']
    out += ['    {0x%08Xu, %d},   /* %s */' % (ids[r], cc, names[r]) for r, cc in chk]
    out += ['};', '#endif', '']
    return '\n'.join(out)


def main():
    ctx = mp.get_context('spawn')
    with ctx.Pool(1) as pool:
        c = pool.map(census, [0])[0]
    text = header(c)
    if '--check' in sys.argv:
        old = open(OUT).read() if os.path.exists(OUT) else ''
        if old != text:
            print('jx_gen_cc_preset: %s differs from the plugin\'s preset -- regenerate' % OUT)
            return 1
        setl, chk = rules(c['names'], c['preset'])[:2]
        print('jx_gen_cc_preset: %s == the plugin\'s preset (%d set, %d checked)' % (os.path.relpath(OUT, REPO),
                                                                                    len(setl), len(chk)))
        return 0
    open(OUT, 'w').write(text)
    print('jx_gen_cc_preset: wrote %s' % os.path.relpath(OUT, REPO))
    return 0


if __name__ == '__main__':
    sys.exit(main())
