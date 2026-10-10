#!/usr/bin/env python3
"""jx_lift.py -- the JUPITER-8 track's mechanical x86-64 -> C99 lifter (jp8/tools/jp8_lift.py, PROVEN there by its
layer gates) run on the JX-3P's checksummed binary: one C function per machine function, one C statement per
instruction, MSVC jump tables read from the image, indirect call/jmp sites dispatched through the table of lifted
functions (the targets the oracle reached: jx_dynreach.py --dyn). The JP8 tool is not changed: its source is
executed here with BIN pointing at the JX binary (resolved through tools/verify/truth.py's checksums). The output
includes jp8/src/jp8_cpu.h; jp8/src/jp8_rt.c is its runtime (JP8_RELOC: guest addresses kept, every access
translated into host arenas -- the JX's regions are the oracle's: page 0, image, stack, heap). One extension, here:
a jump table whose image-base lea sits in an earlier block (find_jumptable below).

    python3 jx3p/tools/jx_lift.py OUT.c ROOTS [--dyn reach.json ...] [--tooth RVA] [--name N]
      ROOTS: comma-separated rvas (hex), e.g. 3F9A30 (the engine's host entry, HOSTPARAM)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
LIFTER = os.path.join(REPO, 'jp8', 'tools', 'jp8_lift.py')
JXBIN = os.path.join(REPO, 'jx3p', 'truth', 'JX3P.vst3')
JP8_BIN_LINE = 'BIN = os.path.join(HERE, "..", "truth", "JUPITER-8VST3_64bit.vst3")'


def checksum():
    """the binary must be the one jx3p/truth/SHA256SUMS pins, or nothing is lifted"""
    import hashlib
    want = {}
    for line in open(os.path.join(REPO, 'jx3p', 'truth', 'SHA256SUMS')):
        if line.strip():
            digest, name = line.split(None, 1)
            want[name.strip()] = digest
    h = hashlib.sha256(open(JXBIN, 'rb').read()).hexdigest()
    if want.get('JX3P.vst3') != h:
        raise SystemExit('jx_lift: %s is not the checksummed binary (%s)' % (JXBIN, h))


def main():
    checksum()
    src = open(LIFTER).read()
    if src.count(JP8_BIN_LINE) != 1:
        raise SystemExit('jx_lift: the JP8 lifter changed (its BIN line is not where it was) -- refusing')
    src = src.replace(JP8_BIN_LINE, 'BIN = %r' % JXBIN)
    g = {'__name__': 'jx_lift_jp8', '__file__': LIFTER}
    exec(compile(src, LIFTER, 'exec'), g)
    # THE ONE EXTENSION (2026-10-10): MSVC's jump table where the image base's lea is in an EARLIER block than
    # the table load (rva 0x3EB408 / 0x3EB363: one lea before a jne serves two tables, the effect type's 0..5).
    # The JP8 lifter looks for the lea in the current block only, so such a site got the oracle's targets alone
    # and effect type 4 trapped ("indirect target 0x3eb426 not lifted"). The table's own form names it: mov eA,
    # [rB + rI*4 + tbl]; add rA, rB; jmp rA -- rB is the image base. Its entries are read as the lifter reads
    # every table (read_table: code rvas near the site; a neighbouring table's entries add labels, never a path).
    x86 = g['x86']
    find0 = g['find_jumptable']

    def find_jumptable(prev, ins):
        t = find0(prev, ins)
        if t is not None or len(prev) < 2:
            return t
        mov, add = prev[-2], prev[-1]
        if (mov.mnemonic == 'mov' and len(mov.operands) == 2 and mov.operands[1].type == x86.X86_OP_MEM and
                mov.operands[1].mem.scale == 4 and add.mnemonic == 'add' and len(add.operands) == 2 and
                add.operands[1].type == x86.X86_OP_REG and add.operands[1].reg == mov.operands[1].mem.base and
                ins.operands[0].type == x86.X86_OP_REG and add.operands[0].reg == ins.operands[0].reg):
            return mov.operands[1].mem.disp
        return None
    g['find_jumptable'] = find_jumptable
    sys.argv = [LIFTER] + sys.argv[1:]
    return g['main']()


if __name__ == '__main__':
    sys.exit(main())
