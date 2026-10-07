#!/usr/bin/env python3
"""bank_census.py -- what a set of banks REACHES that the factory bank does not.

A raw-byte census, no decode: for each of the 79 host parameters
(src/juno_hostparams.c: its record offset and field type), the record bytes
each patch holds there. A value the factory bank never holds has never been
through a factory-bank gate; a bank that holds it makes the bank gates
(userbank_parity.py) reach it. Pure data: nothing here grades anything.

USAGE
    python3 -I tools/bank_census.py [bank directory]   (default scratchpad/userbanks)
"""
import glob
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HEADER, STRIDE = 23, 20223


def rows():
    src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
    return [(m.group(1).strip(), int(m.group(2)), int(m.group(3)))
            for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),\s*(-?\d+),\s*(-?\d+),', src)]


def records(path):
    b = open(path, 'rb').read()
    return [b[HEADER + k * STRIDE: HEADER + (k + 1) * STRIDE] for k in range(64)]


def raw(r, roff, typ):
    """the record bytes of one field: one byte (type 0), a nibble pair (1), eight nibbles (2, 3)"""
    if typ == 0:
        return (r[roff],)
    if typ in (2, 3):
        return tuple(r[roff - 6: roff + 2])
    return (r[roff], r[roff + 1])


def main():
    bdir = sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, 'scratchpad', 'userbanks')
    fac = records(os.path.join(REPO, 'truth', 'presetbankog1.bin'))
    banks = {os.path.basename(p): records(p) for p in sorted(glob.glob(os.path.join(bdir, '*.bin')))}
    if not banks:
        print('no banks in %s' % bdir)
        return 2
    total = 0
    print('%-22s %8s %8s %5s  %s' % ('parameter', 'factory', 'banks', 'new', 'new values (patches), first 8'))
    for name, roff, typ in rows():
        fv = {raw(r, roff, typ) for r in fac}
        seen = {}
        for rs in banks.values():
            for r in rs:
                k = raw(r, roff, typ)
                seen[k] = seen.get(k, 0) + 1
        new = sorted((k, v) for k, v in seen.items() if k not in fv)
        total += len(new)
        if new:
            show = '' if typ == 3 else ' '.join('%s(%d)' % ('.'.join('%X' % x for x in k), v) for k, v in new[:8])
            print('%-22s %8d %8d %5d  %s' % (name, len(fv), len(seen), len(new), show))
    print('\n%d banks, %d patches; %d raw parameter values the factory bank never holds'
          % (len(banks), 64 * len(banks), total))
    return 0


if __name__ == '__main__':
    sys.exit(main())
