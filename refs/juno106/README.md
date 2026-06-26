# Juno-106 (Roland Cloud) decompile — cross-reference for the Juno-60 port

Same Roland Cloud ACB framework (imagebase 0x180000000; shared param system, FX
biquad templates, velocity tables, arp/voice machinery — verified: the FX/velocity
.rdata constants are byte-identical to the Juno-60). Function ADDRESSES differ
(separate binary), so match by signature/constants, not RVA.

Files (gunzip the .gz to use):
- decomp_all.c.gz       Hex-Rays decompile of all 77,525 functions (13 are None).
- asm_undecompiled.asm  disassembly of the 13 functions Hex-Rays could not lift.
- seg_rdata_*.bin.gz    .rdata blob (base 0x18096C648) — for constant provenance.
- manifest.tsv.gz       function name -> [start,end].
- segments.tsv          segment map. imagebase.txt = 0x180000000.

Use: gunzip -k decomp_all.c.gz then grep for shared-framework functions by their
constants (e.g. FX template 1.37884, velocity tables) to locate the equivalent of
a Juno-60 function, then diff behaviour.
