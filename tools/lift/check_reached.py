#!/usr/bin/env python3
"""check_reached.py -- L2 completeness of the JUNO lift (docs/JUNO_LIFT.md): NO lifted trap sits on a reached
instruction. The lifter emits jp8_trap(c, 0xRVA, ...) for an instruction form it cannot yet express (AVX / FMA in
CRT branches the oracle does not take, int3 padding after no-return calls, ...). That is only safe where the
instruction never runs in the product. This gate takes the trap rvas from the generated lift and the EXECUTED rva
set from the L1 census (scratchpad/lift/juno_executed.json): their intersection MUST be empty. A non-empty
intersection means a product path reaches an un-lifted instruction -- the lifter must grow to cover its form (L3).

usage: python3 tools/lift/check_reached.py [--self-test]
  --self-test: inject a reached rva as a fake trap and confirm this gate FAILS (seen-to-fail, mantra 5)
exit 0 when no reached instruction is a trap; 1 otherwise.
"""
import os
import re
import sys
import json

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
LIFT = os.path.join(REPO, 'lift', 'jn_lift.c')
EXE = os.path.join(REPO, 'scratchpad', 'lift', 'juno_executed.json')
TRAP = re.compile(r'jp8_trap\(c,\s*(0x[0-9a-f]+)')


def trap_rvas(text):
    return {int(m, 16) for m in TRAP.findall(text)}


def main():
    if not os.path.exists(LIFT):
        print('MISSING %s -- run tools/lift/gen_juno_lift.sh (L2)' % LIFT)
        return 2
    if not os.path.exists(EXE):
        print('MISSING %s -- run tools/verify/juno_lift_reach.py (L1)' % EXE)
        return 2
    executed = set(json.load(open(EXE)))
    traps = trap_rvas(open(LIFT).read())
    if '--self-test' in sys.argv:                       # plant a reached rva as a trap: the gate must then FAIL
        traps = set(traps) | {min(executed)}
    bad = sorted(traps & executed)
    print('L2 check: %d trap rvas, %d executed instructions; %d reached traps'
          % (len(traps), len(executed), len(bad)))
    if bad:
        print('REACHED TRAPS (the lifter must cover these forms, L3):')
        for r in bad[:40]:
            print('  %#x' % r)
        return 1
    print('PASS: no reached instruction is a trap -- every executed instruction is lifted')
    return 0


if __name__ == '__main__':
    sys.exit(main())
