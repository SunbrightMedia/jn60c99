#!/usr/bin/env python3
"""jx_bank.py -- the JX-3P factory bank geometry and decode, PURE PYTHON
(no Unicorn, no ctypes), so both halves of a two-process gate can import
the ONE definition (jx_emu re-exports these names).

  blob_pos = 2*pool - 8   (2026-09-05; the earlier +8 was 16 bytes off --
                           METHOD_PLAYBOOK 88, jx3p/tools/jx_bank_census.py)
  dispatch id = pool + 740
"""
import os

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BANK_HEADER, BANK_STRIDE, BANK_BLOB_OFF = 23, 20223, 16
# 2026-09-05: the whole int2x4 panel block, pools 10..73 (the record's
# leaves 0..63 before the name). Pools 15/18/21/23/27 are the plugin's
# internal COLOR/CROSS/RING cells (recall census: constant 0 in the bank,
# left to the controller defaults); pools 66..73 add (MOD ID/PRM 1..3),
# VCA LEVEL (42..233 across the factory bank -- it was never recalled
# before), VCA LEVEL SW, OSC1/2 EXTEND. The int8x4 tree (pools 90..138) is
# zero on every factory patch and stays at the controller defaults.
ACTIVE_POOLS = [10, 11, 12, 13, 14, 16, 17, 19, 20, 22, 24, 25, 26, 28, 29, 30,
                31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46,
                47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62,
                63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73]
POOL_BASE_ID = 740


def bank_bytes():
    return open(os.path.join(REPO, "jx3p", "truth", "preset_bank_1.bin"), "rb").read()


def patch_blob(bank, idx):
    return bank[BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB_OFF:
                BANK_HEADER + (idx + 1) * BANK_STRIDE]


def pool_value(blob, pool):
    p = 2 * pool - 8
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)
