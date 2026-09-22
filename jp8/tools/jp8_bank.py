#!/usr/bin/env python3
"""jp8_bank.py -- the JUPITER-8 factory bank geometry and decode, PURE PYTHON
(no Unicorn, no ctypes) -- the JP8 twin of tools/verify/jx_bank.py.

Geometry (READ from the file, 2026-09-22): size 1,294,294 = 22 + 64*20223.
The header is the 22-byte magic "KoaBankFile00003PG-JP8" (JX: 23 bytes,
"PG-JX3P"); each 20223-byte record starts with the 16-char patch name
("PD Jupiter Glide", "PD Jupiter Str  ", "BR JP PWM Brass "...), the panel
blob follows at +16. Pool decode is the JX formula (blob_pos = 2*pool-8,
int2x4 nibble pair, playbook 88) -- PROVEN here by jp8_bank_census.py
(every value of every pool of every patch inside its ENGINE-DB range, and
the tooth bites at offset -6/-10). dispatch id = pool + 740 (ENGINE DB
750..813 = LFO WAVE .. BEND SW VCO2, the JP8 panel).
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
BANK = os.path.join(HERE, "..", "truth", "1_Preset.bin")
BANK_HEADER, BANK_STRIDE, BANK_BLOB_OFF, NPATCH = 22, 20223, 16, 64
NAME_LEN = 16
ACTIVE_POOLS = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
                26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41,
                42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
                58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73]
POOL_BASE_ID = 740


def bank_bytes():
    return open(BANK, "rb").read()


def patch_record(bank, idx):
    return bank[BANK_HEADER + idx * BANK_STRIDE: BANK_HEADER + (idx + 1) * BANK_STRIDE]


def patch_name(bank, idx):
    return patch_record(bank, idx)[:NAME_LEN].decode("latin1")


def patch_blob(bank, idx):
    return patch_record(bank, idx)[BANK_BLOB_OFF:]


def pool_value(blob, pool, off=-8):
    p = 2 * pool + off
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)
