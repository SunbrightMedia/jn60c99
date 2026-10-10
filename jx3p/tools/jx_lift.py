#!/usr/bin/env python3
"""jx_lift.py -- the JUPITER-8 track's mechanical x86-64 -> C99 lifter (jp8/tools/jp8_lift.py, PROVEN there by its
layer gates) run on the JX-3P's checksummed binary: one C function per machine function, one C statement per
instruction, MSVC jump tables read from the image, indirect call/jmp sites dispatched through the table of lifted
functions (the targets the oracle reached: jx_dynreach.py --dyn). The JP8 tool is not changed: its source is
executed here with BIN pointing at the JX binary (resolved through tools/verify/truth.py's checksums). The output
includes jp8/src/jp8_cpu.h; jp8/src/jp8_rt.c is its runtime (JP8_RELOC: guest addresses kept, every access
translated into host arenas -- the JX's regions are the oracle's: page 0, image, stack, heap).

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
    sys.argv = [LIFTER] + sys.argv[1:]
    return g['main']()


if __name__ == '__main__':
    sys.exit(main())
