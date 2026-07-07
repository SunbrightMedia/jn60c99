#!/usr/bin/env python3
"""Derive the 279 runtime_coeffs from the binary via full-instance emulation,
retiring the capture in src/runtime_coeffs_data.c.

Builds the engine (sub_7FF91E0268D0), runs the PREPARE sequence (filled in from
the map-prepare-chain workflow), then reads the 11MB DSP state block at the
captured offsets and reports match / mismatch / still-zero, and can emit a new
binary-derived runtime_coeffs_data.c.
"""
import re, struct, sys
import emu2
from emu2 import IB, f32
from unicorn import UcError
from unicorn.x86_const import *

RC = "/home/user/jn60c99/src/runtime_coeffs_data.c"

def parse_captured():
    txt = open(RC).read()
    pairs = re.findall(r"\{(\d+),0x([0-9a-fA-F]+)u\}", txt)
    return [(int(o), int(b, 16)) for o, b in pairs]

def build():
    e = emu2.Emu()
    e.HOST = e.bump(0x8000); e.uc.mem_write(e.HOST, b"\x00"*0x8000)
    try: e.call(emu2.BUILD, rcx=e.HOST)
    except UcError: pass
    e.states = [a for a, s in e.allocs if s == 0xA83010]
    # locate the plugin object (vtable 0x9C3018) and its 11MB state (the one just
    # before it, or its wrapper's pointee)
    e.plugs = []
    for a, s in e.allocs:
        try: v = int.from_bytes(e.uc.mem_read(a, 8), 'little')
        except: continue
        if v == IB + 0x9C3018: e.plugs.append(a)
    e.ST = e.states[0]
    return e

def rd(e, off):
    return struct.unpack("<I", e.uc.mem_read(e.ST + off, 4))[0]

def compare(e, coeffs):
    match = mism = zero = 0
    misms = []
    for off, bits in coeffs:
        got = rd(e, off)
        if got == bits: match += 1
        elif got == 0: zero += 1
        else:
            mism += 1
            misms.append((off, bits, got))
    return match, mism, zero, misms

def report(e, coeffs, label=""):
    m, mm, z, misms = compare(e, coeffs)
    print(f"[{label}] MATCH {m}/{len(coeffs)}  MISMATCH {mm}  ZERO {z}")
    for off, b, g in misms[:15]:
        print(f"    off {off}: cap 0x{b:08x} ({f32(b):.6g})  emu 0x{g:08x} ({f32(g):.6g})")
    return m, mm, z

def emit_new_table(e, coeffs, path):
    """Write a binary-derived runtime_coeffs_data.c from the emulated state."""
    rows = []
    for off, _cap in coeffs:
        rows.append((off, rd(e, off)))
    # (emission code filled in once the emulation reproduces the values)
    return rows

if __name__ == "__main__":
    coeffs = parse_captured()
    print(f"captured coeffs: {len(coeffs)}")
    e = build()
    print(f"state block 0x{e.ST:x}, plugin objs {len(e.plugs)}")
    report(e, coeffs, "post-construct")
    # PREPARE SEQUENCE goes here (from workflow plan):
    #   e.uc.mem_write(e.ST+16, struct.pack('<f', 96000.0))   # sample rate
    #   e.call(IB+0x<prepare_rva>, rcx=..., ...)
    #   ...
    # report(e, coeffs, "post-prepare")
