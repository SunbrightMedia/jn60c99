#!/usr/bin/env python3
"""Diff the plugin's OWN recall enumerator index set (0x3B48A0, executed under
Unicorn) against the exact leaf/index set the port + every gate actually applies.
Any index the enumerator recalls but the applied set misses is a DROPPED leaf:
the port silently omits it AND the ref uses the same set -> gate blind spot.
Single Unicorn process, no libjuno -> covenant + two-process clean."""
import sys
sys.path.insert(0, 'tools/verify')
import plugin_recall_set as PRS
import real_recall as R
import e2e_emu as E

# 1) plugin's own recall enumerator index set (executed)
enum = set(PRS.recall_indices())

# 2) exact applied set = everything prepare_recall dispatches
leaves = set(disp for (disp, _) in R.leaf_table())
FX_LEAVES      = {1179, 1181}
EXTRA_LEAVES   = {1028, 1058}
DELAY_FILT     = {1180, 1182, 1183, 1184, 1185}
REVERB_FINEFX  = {1323, 1324, 1325, 1326, 1327}
CHORUS_FINEFX  = {1210, 1211, 1212}
applied = leaves | FX_LEAVES | EXTRA_LEAVES | DELAY_FILT | REVERB_FINEFX | CHORUS_FINEFX

print("enumerator indices : %d" % len(enum))
print("applied  indices   : %d (leaf_table=%d + extras)" % (len(applied), len(leaves)))
print()
missed = sorted(enum - applied)
print("ENUMERATOR RECALLS but port/gate DROPS (%d): %s" % (len(missed), missed))
print()
extra = sorted(applied - enum)
print("port applies but enumerator does NOT (%d): %s" % (len(extra), extra))
print()
print("full enumerator set:", sorted(enum))
