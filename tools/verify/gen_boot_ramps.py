#!/usr/bin/env python3
"""gen_boot_ramps.py -- generate src/boot_ramps.h: the ramps the plugin's build leaves in flight
(CLAIMS B15), EXECUTED IN THE BOOTED PLUGIN (Unicorn only; two-process rule).

The plugin's constructor builds its engine at 96000 and every unit arms the same ramps from 0
(its cells still 0) toward their built values; nothing renders before the first process(), so
the product start (the default engine-rate setting) runs them from the first sample. This
generator boots the plugin as a host does at 44100, 48000 and 96000 (the boots must agree, or it
refuses) and, for every ramped cell of the port (src/ramp_cells.h: voice v from unit v, the
master from unit 8), reads the record: an ACTIVE record must have start 0, accumulator 0, step 0,
the cell 0, the rate 96000, the subdivision 10 and an increment that is target / steps for one
time index of the setter's table (rva 0x9DEB50) -- the generator names the time index and the
port arms the cell itself (src/recall_ramp.c juno_rr_boot); an IDLE record's stored target must
be the cell or 0.0 where src/ramp_cells.h's JUNO_RAMP_BUILD0 says so. Anything else refuses.

    python3 tools/verify/gen_boot_ramps.py > src/boot_ramps.h"""
import hashlib
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)

TIME_MS = [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0, 32.0, 36.0, 40.0, 48.0, 56.0, 64.0, 72.0, 80.0, 96.0]


def ramp_cells():
    src = open(os.path.join(REPO, 'src', 'ramp_cells.h')).read()
    a = src.index('JUNO_RAMP_CELL[JUNO_RAMP_N]')
    cells = [int(x) for x in re.findall(r'(\d+)u', src[a:src.index('};', a)])]
    b = src.index('JUNO_RAMP_BUILD0[JUNO_RAMP_N]')
    body = src[src.index('{', b) + 1:src.index('}', b)]
    build0 = [int(x) for x in re.findall(r'\b([01])\b', body)]
    if len(cells) != len(build0):
        raise SystemExit('ramp_cells.h: %d cells, %d BUILD0 flags' % (len(cells), len(build0)))
    return cells, build0


def unit_of(c):
    if 176 <= c < 176 + 8 * 10512:
        return (c - 176) // 10512
    if 101488 <= c < 101488 + 8 * 32:
        return (c - 101488) // 32
    return 8


def boot(rate, cells):
    import host_process_emu as H
    import e2e_emu as E
    h = H.HostProcess()
    h.start(rate, 512)
    uc = h.uc
    recs = []
    for u in range(9):
        st = h.state[u]
        base = struct.unpack('<Q', uc.mem_read(st + 88, 8))[0]
        a = struct.unpack('<Q', uc.mem_read(st + 112, 8))[0]
        b = struct.unpack('<Q', uc.mem_read(st + 120, 8))[0]
        act = set(struct.unpack('<%di' % ((b - a) // 4), uc.mem_read(a, b - a))) if b > a else set()
        out, k = {}, 0
        while True:
            raw = bytes(uc.mem_read(base + 40 * k, 40))
            outp = struct.unpack_from('<Q', raw, 0)[0]
            if not outp or not (st <= outp < st + E.STATE_SZ):
                break
            out[outp - st] = (1 if k in act else 0,) + struct.unpack_from('<IIIIIIII', raw, 8) + \
                (struct.unpack('<I', uc.mem_read(outp, 4))[0],)
            k += 1
        recs.append(out)
    return [recs[unit_of(c)][c] for c in cells]


def main():
    cells, build0 = ramp_cells()
    tabs = [boot(r, cells) for r in (48000.0, 44100.0, 96000.0)]
    if not all(t == tabs[0] for t in tabs):
        raise SystemExit('the boot records differ between host rates -- refusing')
    tab = tabs[0]
    f = lambda x: struct.unpack('<f', struct.pack('<I', x))[0]
    armed = []
    for i, (c, r) in enumerate(zip(cells, tab)):
        active, incr, accum, start, target, rate, act2, subdiv, step, val = r
        if active:
            # not yet stepped: the cell still holds the start the arm read (the build's earlier
            # value: 0 for most cells)
            if (accum, step) != (0, 0) or val != start or f(rate) != 96000.0 or subdiv != 10:
                raise SystemExit('cell %d: an active record that has moved, or not at 96000 / 10: %r' % (c, r))
            if f(target) == f(start):
                # toward its own start: the increment is 0 (no nudge either way, rva 0x3C2EE9), the
                # record ends at its first step whatever its time -- any time index is the same
                if incr & 0x7FFFFFFF:
                    raise SystemExit('cell %d: toward its start with increment %08x' % (c, incr))
                armed.append((c, 0, start))
                continue
            steps = (f(target) - f(start)) / f(incr)
            t = min(range(16), key=lambda k: abs(TIME_MS[k] * 96000.0 / 1000.0 / 10 - steps))
            if abs(TIME_MS[t] * 9.6 - steps) > 1e-3 * steps:
                raise SystemExit('cell %d: %.6f steps match no time index' % (c, steps))
            armed.append((c, t, start))
        else:
            if target != val and not (target == 0 and build0[i]):
                raise SystemExit('cell %d: idle, stored target %08x, cell %08x, BUILD0 %d' % (c, target, val, build0[i]))
    blob = b''.join(struct.pack('<IiI', c, t, b) for c, t, b in armed)
    out = ['/* boot_ramps.h -- GENERATED by tools/verify/gen_boot_ramps.py from the booted plugin; do not',
           ' * edit. The ramps the plugin\'s build leaves in flight (CLAIMS B15): every cell below holds its',
           ' * start after the build (the bits given: 0 for most), its record armed from it toward the built',
           ' * value at the time index given (the setter\'s table, rva 0x9DEB50), rate 96000, subdivision 10',
           ' * -- the same on every unit and at every host rate (the default engine-rate setting).',
           ' * juno_rr_boot (src/recall_ramp.c) arms them. */',
           '#ifndef JUNO_BOOT_RAMPS_H', '#define JUNO_BOOT_RAMPS_H', '#include <stdint.h>',
           '#define JUNO_BOOT_RAMPS_SHA256 "%s"' % hashlib.sha256(blob).hexdigest(),
           '#define JUNO_BOOT_RAMP_N %d' % len(armed),
           'typedef struct { uint32_t cell; uint8_t t; uint32_t start; } juno_boot_ramp;   /* start: float bits */',
           'static const juno_boot_ramp JUNO_BOOT_RAMP[JUNO_BOOT_RAMP_N] = {']
    for k in range(0, len(armed), 4):
        out.append('    ' + ' '.join('{ %du, %d, 0x%08xu },' % ct for ct in armed[k:k + 4]))
    out += ['};', '#endif']
    sys.stdout.write('\n'.join(out) + '\n')
    ts = sorted(set(t for c, t, b in armed))
    sys.stderr.write('%d cells armed at the boot (time indices %s, %d from a start other than 0), sha256 %s\n' % (
        len(armed), ts, sum(1 for c, t, b in armed if b), hashlib.sha256(blob).hexdigest()))
    return 0


if __name__ == '__main__':
    sys.exit(main())
