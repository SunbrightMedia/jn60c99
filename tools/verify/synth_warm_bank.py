#!/usr/bin/env python3
"""synth_warm_bank.py -- build a synthetic multi-record bank for the WARM gates.

WHY. warm_recall_gate.py runs N recalls through ONE engine and needs a bank whose
records differ in exactly the bytes under test. The factory bank cannot serve: it
is 64 real patches, and the parameter PAIRS a warm law turns on (previous DELAY
TYPE x new DELAY LEVEL, say) are not in it. G2 and G3 both need this.

WHAT IT BUILDS. A KoaBankFile-shaped bank whose every record starts as a COPY OF
FACTORY PATCH 0 and then has named blob bytes overridden. Starting from a real
patch matters: a zeroed record is not a legal patch, and a gate that runs on an
illegal patch measures a corner rather than a law.

⚠ THE BANK IS INPUT, NEVER GROUND TRUTH. The plugin is still the oracle; this
only decides which inputs it is asked about. Nothing here is committed as data
and no constant is ever derived from it.

⚠ BLOB-RELATIVE, and this project has paid for the confusion twice in one week.
Byte numbers here are BLOB-relative (blob = record - 16), the same convention
random_state_ab.synth_bank and recall_exhaustive_gate use. src/ reads RECORD
offsets: src/delay_recall.c rec_byte(rec, 3057) is blob 3041.

  blob 104  DELAY LEVEL      blob 106  DELAY TIME     blob 634  DELAY TYPE
  blob 618  EFFECT TYPE      blob 626  EFFECT TONE    blob 642  REVERB TYPE
  blob 3041 DELAY FEEDBACK   blob 3044 DELAY DIRECT

USAGE
    python3 tools/verify/synth_warm_bank.py out.bin  '634=0,104=200' '634=2,104=1'
    JUNO_WARM_BANK=out.bin python3 tools/verify/warm_recall_gate.py --ref --seq 0,1
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import truth                                        # noqa: E402

HEADER = 23
STRIDE = 20223
BLOB_OFF = 16


def build(specs, base_patch=0):
    """specs: list of {blob_byte: value}. Returns the bank bytes."""
    src = open(truth.BANK, 'rb').read()
    b0 = HEADER + base_patch * STRIDE
    rec0 = bytearray(src[b0:b0 + STRIDE])
    out = bytearray(src[:HEADER])
    for ov in specs:
        rec = bytearray(rec0)
        for bb, v in ov.items():
            # nibble pair, the port's own encoding (juno_bank_apply reads
            # blob[2*pos] / [2*pos+1]); BLOB_OFF converts to record-relative.
            rec[BLOB_OFF + bb] = (v >> 4) & 0xF
            rec[BLOB_OFF + bb + 1] = v & 0xF
        out += rec
    return bytes(out)


def parse(s):
    d = {}
    for part in s.split(','):
        part = part.strip()
        if not part:
            continue
        k, v = part.split('=')
        d[int(k)] = int(v)
    return d


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if len(args) < 3:
        print(__doc__)
        return 2
    outp, specs = args[0], [parse(a) for a in args[1:]]
    data = build(specs)
    open(outp, 'wb').write(data)
    print('wrote %s: %d records, %d bytes' % (outp, len(specs), len(data)))
    for i, ov in enumerate(specs):
        print('  record %d: %s' % (i, ', '.join('blob %d=%d' % kv
                                                for kv in sorted(ov.items()))))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
