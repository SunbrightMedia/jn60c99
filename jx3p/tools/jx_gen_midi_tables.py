#!/usr/bin/env python3
"""jx_gen_midi_tables.py -- generate jx3p/src/jx_midi_tables.h: the JX-3P's host parameter and MIDI controller
intake tables, EXECUTED IN THE BOOTED PLUGIN (Unicorn only; two-process rule). The JUNO-60's generator
(tools/verify/gen_midi_tables.py) on the JX: its wrapper is the JUNO's machine code (jx3p/tools/fw_map.py maps
every function used here one to one), its tables are its own. The plugin is booted as a host does
(jx3p/tools/jx_host_emu.py) at two host rates; every table must be equal between the boots, or the generator
refuses.

  JX_MIDI_BASE     the first VST3 MIDI-mapping parameter id (core +48, read by process(), rva 0x34A240):
                   id - base = 0..127 CC n, 128 channel aftertouch, 129 pitch bend.
  JX_MIDI_PARAM[]  the core's parameter vector (core +24, 24-byte entries): per entry the id (rva 0x319B30,
                   EXECUTED), the range the parameter object gives (its vt+96 info: +44 min, +48 max,
                   EXECUTED) and the entry's byte +16 (the CC value conversion's truncate flag, rva 0x31A730).
  JX_CC_MAP[128]   CC number -> vector entry, -1 none (rva 0x319940 EXECUTED for every n): the plugin's
                   default CC assignments (no learn slot open at boot).
  JX_MIDI_IDMAP[]  the global id -> vector entry map (rva 0xCE8638) the render driver searches for a kind-1
                   record (rva 0x319990), walked; every key cross-checked by executing the lookup, and ids
                   outside it (the host entry's 744 ids, the host settings 0x0FFFC000..1F, the MIDI ids) must
                   return -1 there unless they are keys.

The render driver (rva 0x3210B6, READ: the JUNO's 0x3211D6) gives a kind-1 record to the engine's host
entry (vt+0x70 = 0x3F9A30) with the record's own id and round(min + (max - min) x value) (rva 0x31A820).

    python3 jx3p/tools/jx_gen_midi_tables.py > jx3p/src/jx_midi_tables.h
    python3 jx3p/tools/jx_gen_midi_tables.py --check     (equal to the committed header or exit 1)
"""
import hashlib
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
OUT = os.path.join(REPO, 'jx3p', 'src', 'jx_midi_tables.h')

CC_LOOKUP, ID_OF, ID_LOOKUP = 0x319940, 0x319B30, 0x319990      # = JUNO 0x319A60 / 0x319C50 / 0x319AB0
IDMAP_RVA = 0xCE8638                                            # the lookup's [rip+...] (JUNO 0xCB04F8)
SETTINGS = range(0x0FFFC000, 0x0FFFC020)


def read_all(host_rate):
    import jx_host_emu as X
    h = X.JXHost()
    h.start(host_rate, 512)
    uc = h.uc
    IB = X.J.IB
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
    s32 = lambda x: x - (1 << 32) if x & 0x80000000 else x
    m = h.core + 24
    base = i32(h.core + 48)
    if i32(m + 64) >= 0:
        raise SystemExit('a MIDI-learn slot is open at boot (core+88 = %d)' % i32(m + 64))
    vb, ve = q(m), q(m + 8)
    n = (ve - vb) // 24
    params = []
    for k in range(n):
        obj = q(vb + 24 * k)
        pid = h.call(IB + ID_OF, rcx=m, rdx=k, count=2_000_000) & 0xFFFFFFFF
        info = h.call(q(q(obj) + 96), rcx=obj, count=2_000_000)
        params.append((pid, i32(info + 44), i32(info + 48), uc.mem_read(vb + 24 * k + 16, 1)[0]))
    ccmap = [s32(h.call(IB + CC_LOOKUP, rcx=m, rdx=c, count=2_000_000) & 0xFFFFFFFF) for c in range(128)]
    head = q(IB + IDMAP_RVA)
    keys = []

    def walk(nd):
        if uc.mem_read(nd + 25, 1)[0]:
            return
        walk(q(nd))
        keys.append((struct.unpack('<I', uc.mem_read(nd + 28, 4))[0], i32(nd + 32)))
        walk(q(nd + 16))
    walk(q(head + 8))
    if len(keys) != q(IB + IDMAP_RVA + 8):
        raise SystemExit('id map: walked %d nodes, size says %d' % (len(keys), q(IB + IDMAP_RVA + 8)))
    kd = dict(keys)
    host_ids = set(h.id_map()) if hasattr(h, 'id_map') else set()
    probe = set(kd) | host_ids | set(SETTINGS) | {base + i for i in range(130)} | {0, 0xFFFFFFFF}
    for pid in sorted(probe):
        got = s32(h.call(IB + ID_LOOKUP, rcx=m, rdx=pid, count=2_000_000) & 0xFFFFFFFF)
        if got != kd.get(pid, -1):
            raise SystemExit('id map: lookup(0x%x) = %d, walk says %d' % (pid, got, kd.get(pid, -1)))
    return base, params, ccmap, keys, len(probe)


def header():
    a = read_all(48000.0)
    b = read_all(44100.0)
    if a[:4] != b[:4]:
        raise SystemExit('the MIDI tables differ between two boots -- refusing')
    base, params, ccmap, keys, nprobe = a
    for k, e in keys:
        if not 0 <= e < len(params) or params[e][0] != k:
            raise SystemExit('id map key 0x%x -> entry %d, whose id is not the key' % (k, e))
    blob = struct.pack('<I', base) + b''.join(struct.pack('<IiiB', *p) for p in params) + \
        struct.pack('<128i', *ccmap) + b''.join(struct.pack('<Ii', *k) for k in keys)
    sha = hashlib.sha256(blob).hexdigest()
    out = ['/* jx_midi_tables.h -- GENERATED by jx3p/tools/jx_gen_midi_tables.py from the booted plugin; do not',
           ' * edit. The JX-3P\'s host parameter and MIDI controller intake: the VST3 MIDI-mapping base, the core\'s',
           ' * parameter vector, the default CC assignments and the id map the render driver searches for a',
           ' * kind-1 record (the JUNO-60\'s src/midi_tables.h, the JX\'s own values). */',
           '#ifndef JX_MIDI_TABLES_H', '#define JX_MIDI_TABLES_H', '#include <stdint.h>',
           '#define JX_MIDI_SHA256 "%s"' % sha,
           '#define JX_MIDI_BASE 0x%08Xu     /* id - base: 0..127 CC, 128 channel aftertouch, 129 bend */' % base,
           '/* id; the range its object gives (vt+96 info +44 / +48); the CC conversion\'s truncate flag',
           ' * (entry byte +16, rva 0x31A730) */',
           'typedef struct { uint32_t id; int32_t min, max; uint8_t trunc; } jx_midi_param;',
           '#define JX_MIDI_PARAM_N %d' % len(params),
           'static const jx_midi_param JX_MIDI_PARAM[JX_MIDI_PARAM_N] = {']
    for pid, lo, hi, fl in params:
        out.append('    { 0x%08Xu, %d, %d, %d },' % (pid, lo, hi, fl))
    out.append('};')
    out.append('/* CC number -> JX_MIDI_PARAM entry, -1: none (rva 0x319940, the boot\'s map) */')
    out.append('static const int8_t JX_CC_MAP[128] = {')
    for r in range(0, 128, 16):
        out.append('    ' + ', '.join('%d' % x for x in ccmap[r:r + 16]) + ',')
    out.append('};')
    out.append('/* the id map (rva 0xCE8638), ascending ids: id -> JX_MIDI_PARAM entry */')
    out.append('typedef struct { uint32_t id; int32_t entry; } jx_midi_idmap;')
    out.append('#define JX_MIDI_IDMAP_N %d' % len(keys))
    out.append('static const jx_midi_idmap JX_MIDI_IDMAP[JX_MIDI_IDMAP_N] = {')
    for k, v in keys:
        out.append('    { 0x%08Xu, %d },' % (k, v))
    out.append('};')
    out.append('#endif')
    note = 'base 0x%x, %d params, %d CCs mapped, %d ids in the map (%d ids probed through the lookup), sha256 %s' % (
        base, len(params), sum(1 for x in ccmap if x >= 0), len(keys), nprobe, sha)
    return '\n'.join(out) + '\n', note


def main():
    txt, note = header()
    sys.stderr.write(note + '\n')
    if '--check' in sys.argv:
        same = os.path.exists(OUT) and open(OUT).read() == txt
        print('jx_gen_midi_tables --check: %s' % ('EQUAL to the committed header' if same else 'DIFFERS -- RED'))
        return 0 if same else 1
    sys.stdout.write(txt)
    return 0


if __name__ == '__main__':
    sys.exit(main())
