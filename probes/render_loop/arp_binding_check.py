#!/usr/bin/env python3
"""Is the port's ARP record-byte binding correct?

Port (src/juno_apply.c ~757): sw=record 298, type=record 306, step=record 314.
Plugin name table + position map: 831 ARPEGGIO SW=282, 832 TYPE=290,
833 STEP=298, 834 SCATTER TYPE=306, 835 SCATTER DEPTH=314, 836 OCTAVE SHIFT=322.
If the plugin is right, the port is reading SW from STEP's byte, TYPE from
SCATTER TYPE's byte and STEP from SCATTER DEPTH's byte.

DECISIVE TEST: the 7 factory ARP patches [1,9,17,25,33,41,49] must have the arp
ENABLE byte set; every other patch must have it clear. Whichever record byte
shows that pattern IS the arp switch."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import real_bank_parse as RB, truth

ARP = {1, 9, 17, 25, 33, 41, 49}
recs = RB.parse_records(open(truth.BANK, 'rb').read())
BYTES = [282, 290, 298, 306, 314, 322]
NAMES = {282: '831 ARPEGGIO SW', 290: '832 ARPEGGIO TYPE', 298: '833 ARPEGGIO STEP',
         306: '834 SCATTER TYPE', 314: '835 SCATTER DEPTH', 322: '836 OCTAVE SHIFT'}
print("FACTORY bank — record bytes vs the known 7 arp patches\n")
for bb in BYTES:
    on_arp  = sorted({RB.record_value(recs[p], bb) for p in range(64) if p in ARP})
    on_rest = sorted({RB.record_value(recs[p], bb) for p in range(64) if p not in ARP})
    verdict = ''
    if on_arp and on_rest and set(on_arp).isdisjoint(on_rest) and on_rest == [0]:
        verdict = '   <=== behaves like the ARP ENABLE flag'
    print("  byte %3d (%-18s) arp-patch values %-12s  other-patch values %s%s"
          % (bb, NAMES[bb], on_arp, on_rest, verdict))
print("\nper-arp-patch detail:")
print("  patch  282  290  298  306  314  322")
for p in sorted(ARP):
    print("   %3d  %4d %4d %4d %4d %4d %4d" % ((p,) + tuple(RB.record_value(recs[p], b) for b in BYTES)))
print("\nthree non-arp patches for contrast:")
for p in (0, 2, 3):
    print("   %3d  %4d %4d %4d %4d %4d %4d" % ((p,) + tuple(RB.record_value(recs[p], b) for b in BYTES)))
