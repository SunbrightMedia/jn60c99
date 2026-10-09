#!/usr/bin/env python3
"""rdata_check.py -- the port's tables taken from the plugin's read-only data, re-derived from the
plugin's own image (task #62: their first extractions -- an IDA script's tables_dump/tables.txt and
a curve_luts.json -- are not in the repository).

  src/juno_tables.h   juno_pitch_table[29][26] (doubles) at rva 0x9894E0 (unk_1809894E0, 208-byte rows),
                      juno_exp_acc0[32] at rva 0x98ACC0, juno_exp_ad3c[33] at rva 0x98AD3C (floats):
                      every value's bits compared with the image at that address
  src/juno_curve.c    JUNO_LUT0..n (float bits): each table's bytes must occur in the image (the
                      curve evaluator, rva 0x356380, indexes them; the arms' addresses are not in
                      the source, so the check finds them and prints where)

Pure reading (pefile on truth/JUNO60.vst3 via tools/verify/truth.py); no Unicorn, no port code.
usage: python3 tools/repro/rdata_check.py [--tooth]     (--tooth: one value changed, must FAIL)
"""
import os
import re
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
TOOTH = '--tooth' in sys.argv


def image():
    import pefile
    import truth
    pe = pefile.PE(truth.VST3)
    return bytes(pe.get_memory_mapped_image())


def c_array(src, name):
    """the initializer of `name[...] = { ... };` as a list of tokens"""
    a = src.index(name)
    body = src[src.index('{', a):src.index('};', a)]
    return [t for t in re.split(r'[\s,{}]+', body) if t]


def check_tables(img):
    src = open(os.path.join(REPO, 'src', 'juno_tables.h')).read()
    bad = 0
    pitch = [float(t) for t in c_array(src, 'juno_pitch_table[29][26]')]
    if TOOTH:
        pitch[100] = pitch[100] + 1e-9                      # TOOTH: one spline value moved
    want = img[0x9894E0:0x9894E0 + 29 * 208]
    got = b''.join(struct.pack('<d', v) for v in pitch)
    n = sum(1 for i in range(0, len(want), 8) if want[i:i + 8] != got[i:i + 8])
    print('juno_pitch_table: %d doubles, %s' % (len(pitch), 'IDENTICAL to rva 0x9894E0' if n == 0 and len(pitch) == 754
                                              else '%d DIFFER' % n))
    bad += n != 0 or len(pitch) != 754
    for name, rva, cnt in (('juno_exp_acc0[32]', 0x98ACC0, 32), ('juno_exp_ad3c[33]', 0x98AD3C, 33)):
        vals = [float(t.rstrip('fF')) for t in c_array(src, name)]
        got = b''.join(struct.pack('<f', v) for v in vals)
        ok = len(vals) == cnt and got == img[rva:rva + 4 * cnt]
        print('%s: %s' % (name.split('[')[0], 'IDENTICAL to rva 0x%X' % rva if ok else 'DIFFERS from rva 0x%X' % rva))
        bad += not ok
    return bad


def check_curves(img):
    src = open(os.path.join(REPO, 'src', 'juno_curve.c')).read()
    names = re.findall(r'static const uint32_t (JUNO_LUT\d+)\[(\d+)\]', src)
    bad = 0
    lines = []
    for k, (name, n) in enumerate(names):
        vals = [int(t, 16) for t in c_array(src, '%s[%s]' % (name, n))]
        if TOOTH and k == 3:
            vals[7] ^= 1                                     # TOOTH: one bit of one curve
        blob = struct.pack('<%dI' % len(vals), *vals)
        hits = [m.start() for m in re.finditer(re.escape(blob), img)]
        ok = len(vals) == int(n) and hits
        bad += not ok
        lines.append('%s[%s] %s' % (name, n, ('at rva ' + ','.join('0x%X' % h for h in hits[:3]) +
                                              (' (+%d more)' % (len(hits) - 3) if len(hits) > 3 else '')) if ok else 'NOT IN THE IMAGE'))
    print('juno_curve.c: %d tables, %d found in the plugin\'s image' % (len(names), len(names) - bad))
    for ln in lines:
        if 'NOT' in ln or '-v' in sys.argv:
            print('  ' + ln)
    return bad


def main():
    img = image()
    bad = check_tables(img) + check_curves(img)
    if TOOTH:
        print('rdata_check --tooth: %s' % ('BITES' if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    print('rdata_check: %s' % ('GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
