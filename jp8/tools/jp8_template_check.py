#!/usr/bin/env python3
"""jp8_template_check.py -- the SHIPPED host template (jp8/gen/jp8h_template.bin.gz, what jp8/apps/jp8_render boots
from) must be, byte for byte, the template the host oracle makes (jp8_host_ref.py: the plugin's own memory before
setupProcessing, the same at every first rate). The host gate runs it after each rate's references, so a committed
template that no longer matches the plugin's boot turns the gate red.
    python3 jp8/tools/jp8_template_check.py <template.bin.gz> <refdir/meta.json> [--tooth]
--tooth flips one byte of the shipped template before the hash: the check must then say DIFFERENT (exit 1).
exit 0 = EQUAL."""
import sys, gzip, hashlib, json
if len(sys.argv) < 3:
    sys.exit(__doc__)
raw = bytearray(gzip.open(sys.argv[1]).read())
if '--tooth' in sys.argv[3:]:
    raw[len(raw) // 2] ^= 0x01
got = hashlib.sha256(raw).hexdigest()
want = json.load(open(sys.argv[2]))['template_sha256']
side = open(sys.argv[1][:-len('.bin.gz')] + '.sha256').read().split() if sys.argv[1].endswith('.bin.gz') else []
ok = got == want and (not side or want in side)
print('shipped template %s (%d bytes), the oracle\'s %s%s: %s' % (got[:16], len(raw), want[:16],
      '' if not side else ', its .sha256 file %s' % ('agrees' if want in side else 'DISAGREES'), 'EQUAL' if ok else 'DIFFERENT'))
sys.exit(0 if ok else 1)
