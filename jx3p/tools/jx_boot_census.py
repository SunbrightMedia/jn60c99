#!/usr/bin/env python3
"""jx_boot_census.py -- the JX-3P's first second as a DAW runs it (EXECUTED through the plugin's own
process(); jx3p/tools/jx_host_emu.py). For one host rate: the engine-event queue initialize leaves
(kind, offset, id, value), whether writePatch (0x0FFFC01D) is in it, then process() in host blocks: per
block the worker jobs (the voice units rendered), the engine's rate and voice count, the output gain
stage (HOST+0x860 gain, +0x864 step, +0x868 left, +0x86C delay) and the block's peak -- with a key
pressed at a given time. Numbers for jx3p/docs/HOST_LAYER.md section 4; it grades nothing.

  python3 -u jx3p/tools/jx_boot_census.py [HOST_RATE=48000] [SECONDS=1.2] [KEY_AT_SECONDS=0.1]
  python3 -u jx3p/tools/jx_boot_census.py --records [HOST_RATE]   every queue record (kind, offset, host
                                                                 id, value, the engine id the controller's
                                                                 map gives a parameter id); no render
"""
import math
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_host_emu as X  # noqa: E402

WRITE_PATCH, VOICE_COUNT, SAMPLE_RATE = 0x0FFFC01D, 0x0FFFC00E, 0x0FFFC015


def f32(b):
    return struct.unpack('<f', struct.pack('<I', b))[0]


def records(rate):
    h = X.JXHost()
    h.start(rate, 512)
    try:
        hmap = h.host_map()
    except Exception as e:                                   # the map is the controller's (jx_emu.host_map)
        hmap, why = {}, str(e)[:80]
    else:
        why = ''
    q = h.queue()
    print('host %g: %d records%s' % (rate, len(q), ('; no host map: ' + why) if why else ''))
    for i, (kind, off, rec) in enumerate(q):
        pid = struct.unpack_from('<I', rec, 12)[0]
        val = struct.unpack_from('<i', rec, 20)[0]
        eng = hmap.get(pid)
        print('  %2d kind %d off %d id 0x%08X (%d) value %d%s  raw %s' % (
            i, kind, off, pid, pid, val, '' if eng is None else '  -> engine %d' % eng, rec.hex()))


def main():
    if sys.argv[1:2] == ['--records']:
        return records(float(sys.argv[2]) if len(sys.argv) > 2 else 48000.0)
    rate = float(sys.argv[1]) if len(sys.argv) > 1 else 48000.0
    secs = float(sys.argv[2]) if len(sys.argv) > 2 else 1.2
    key_at = float(sys.argv[3]) if len(sys.argv) > 3 else 0.1
    h = X.JXHost()
    h.start(rate, 512)
    rd = lambda off, fmt: struct.unpack(fmt, h.uc.mem_read(h.HOST + off, struct.calcsize(fmt)))[0]
    q = h.queue()
    print('host %g: initialize left %d engine-event records' % (rate, len(q)))
    ids = {}
    for kind, off, rec in q:
        pid = struct.unpack_from('<I', rec, 12)[0]           # the record layout of probes/b6/state_load_census.py
        val = struct.unpack_from('<i', rec, 20)[0]
        ids.setdefault(kind, []).append((pid, val))
    for kind, lst in sorted(ids.items()):
        vs = [p for p, _ in lst if p >= 0x0FFFC000]
        print('  kind %d: %d records; host settings among them: %s' % (
            kind, len(lst), ', '.join('0x%08X=%d' % (p, v) for p, v in lst if p >= 0x0FFFC000) or 'none'))
    print('  writePatch (0x0FFFC01D) queued: %s' % any(p == WRITE_PATCH for l in ids.values() for p, _ in l))
    n_blocks = int(secs * rate / 512)
    key_block = int(key_at * rate / 512)
    first_sound = None
    for b in range(n_blocks):
        ev = [('on', 0, 0, 60, 0.8)] if b == key_block else []
        j0 = len(h.jobs)
        L, R = h.process(512, events=ev)
        fl = [f32(x) for x in L]
        peak = max((abs(x) for x in fl if math.isfinite(x)), default=0.0)
        nonfin = sum(1 for x in fl if not math.isfinite(x))
        if first_sound is None:
            nz = next((i for i, x in enumerate(fl) if x != 0.0), None)
            if nz is not None:
                first_sound = b * 512 + nz
        if b < 4 or b == key_block or b % 10 == 0 or b == n_blocks - 1:
            print('block %3d (%.3f s): jobs %d (units %s), engine rate %r, voices %d, gain %.4f step %.3g left %d '
                  'delay %d, peak %.4g%s%s' % (
                      b, b * 512 / rate, len(h.jobs) - j0, sorted({u for u, _ in h.jobs[j0:]}),
                      rd(8, '<f'), rd(0x38, '<i'), rd(0x860, '<f'), rd(0x864, '<f'), rd(0x868, '<i'),
                      rd(0x86C, '<i'), peak, ', NON-FINITE %d' % nonfin if nonfin else '',
                      '  <- key 60 pressed' if b == key_block else ''))
    print('first non-zero output sample: %s' % (first_sound if first_sound is not None else 'none'))


if __name__ == '__main__':
    main()
