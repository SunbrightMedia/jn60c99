#!/usr/bin/env python3
"""l3_flags.py -- L3 of the JUNO lift (docs/JUNO_LIFT.md): the proof behind "an undefined flag is not compared".
The per-instruction test (l3_harness.c) compares only the flags x86 DEFINES after an instruction (Intel SDM); the lift
holds some value in the others, and never holds AF at all. That is exact only if no lifted code READS a flag while
it may be undefined. This check proves it, statically, over EVERY lifted function of lift/jn_lift.c: a forward
data-flow over the function's own control flow (the lift's labels, jumps, jump tables) with the set of flags that
may be undefined -- all of them at a function's entry and after a call (the Windows x64 ABI keeps no flag across a
call; a compiler never reads one at entry), the SDM's undefined outputs added per instruction, a defined output
removing it. Any read of a flag in that set is a VIOLATION; any read of AF at all is one (the model has no AF).
usage: python3 tools/lift/l3_flags.py [--tooth]   (--tooth: imul's ZF counted as defined -- a planted wrong table
must be seen: the check then must NOT report the read it would hide... so the tooth instead drops ZF from cmp's
defined outputs, and the check MUST report violations)"""
import os
import re
import sys
import collections

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth                                                       # noqa: E402
os.environ['LIFT_BIN'] = truth.VST3
sys.path.insert(0, os.path.join(REPO, 'jp8', 'tools'))
import jp8_lift as L                                               # noqa: E402
from capstone import x86                                           # noqa: E402

LIFT = os.path.join(REPO, 'lift', 'jn_lift.c')
FUNC = re.compile(r'^static void f_([0-9a-f]+)\(CPU \*c\) \{')
LINE = re.compile(r'^  /\*([0-9a-f]+) (.*?)\*/ (.*)$')
ALL = frozenset('CPAZSO')                                          # CF PF AF ZF SF OF
CCREAD = {'e': 'Z', 'z': 'Z', 'ne': 'Z', 'nz': 'Z', 'b': 'C', 'c': 'C', 'nae': 'C', 'ae': 'C', 'nb': 'C', 'nc': 'C',
          'be': 'CZ', 'na': 'CZ', 'a': 'CZ', 'nbe': 'CZ', 'l': 'SO', 'nge': 'SO', 'ge': 'SO', 'nl': 'SO',
          'le': 'ZSO', 'ng': 'ZSO', 'g': 'ZSO', 'nle': 'ZSO', 's': 'S', 'ns': 'S', 'p': 'P', 'pe': 'P', 'np': 'P',
          'po': 'P', 'o': 'O', 'no': 'O'}
# mnemonic -> (flags read, flags defined after, flags undefined after); unchanged flags keep their state
ARITH = (set(), set('CPAZSO'), set())
TABLE = {
    'add': ARITH, 'sub': ARITH, 'cmp': ARITH, 'neg': ARITH, 'xadd': ARITH,
    'adc': ({'C'}, set('CPAZSO'), set()), 'sbb': ({'C'}, set('CPAZSO'), set()),
    'inc': (set(), set('PAZSO'), set()), 'dec': (set(), set('PAZSO'), set()),
    'and': (set(), set('CPZSO'), {'A'}), 'or': (set(), set('CPZSO'), {'A'}), 'xor': (set(), set('CPZSO'), {'A'}),
    'test': (set(), set('CPZSO'), {'A'}),
    'mul': (set(), set('CO'), set('PAZS')), 'imul': (set(), set('CO'), set('PAZS')),
    'div': (set(), set(), set('CPAZSO')), 'idiv': (set(), set(), set('CPAZSO')),
    'bt': (set(), {'C'}, set('PASO')), 'bts': (set(), {'C'}, set('PASO')), 'btr': (set(), {'C'}, set('PASO')),
    'btc': (set(), {'C'}, set('PASO')),
    'bsf': (set(), {'Z'}, set('CPASO')), 'bsr': (set(), {'Z'}, set('CPASO')),
    'comiss': (set(), set('CPAZSO'), set()), 'ucomiss': (set(), set('CPAZSO'), set()),
    'comisd': (set(), set('CPAZSO'), set()), 'ucomisd': (set(), set('CPAZSO'), set()),
    'cmc': ({'C'}, {'C'}, set()), 'stc': (set(), {'C'}, set()), 'clc': (set(), {'C'}, set()),
    'popcnt': (set(), set('CPAZSO'), set()), 'lzcnt': (set(), set('CPAZSO'), set()), 'tzcnt': (set(), set('CPAZSO'), set()),
    'lahf': (set('SZAPC'), set(), set()), 'pushfq': (set('CPAZSO'), set(), set()), 'pushf': (set('CPAZSO'), set(), set()),
    'sahf': (set(), set('SZAPC'), set()),
    'scasb': (set(), set('CPAZSO'), set()), 'cmpsb': (set(), set('CPAZSO'), set()),
}
NOFLAGS_OK = None                                                   # every other mnemonic: no flag read or written


def effect(ins, tooth):
    """(read, defined, undefined) for one instruction, the SDM's rules; shifts / rotates by their count"""
    m = ins.mnemonic
    for p in ('lock ', 'bnd ', 'rep ', 'repne ', 'repe '):
        if m.startswith(p):
            m = m[len(p):]
    if m[0] == 'j' and m[1:] in CCREAD:
        return set(CCREAD[m[1:]]), set(), set()
    if m.startswith('set') and m[3:] in CCREAD:
        return set(CCREAD[m[3:]]), set(), set()
    if m.startswith('cmov') and m[4:] in CCREAD:
        return set(CCREAD[m[4:]]), set(), set()
    if m in ('shl', 'sal', 'shr', 'sar', 'rol', 'ror', 'rcl', 'rcr'):
        rot = m in ('rol', 'ror', 'rcl', 'rcr')
        rd = {'C'} if m in ('rcl', 'rcr') else set()
        op = ins.operands
        sz = op[0].size * 8
        if len(op) == 1 or op[1].type == x86.X86_OP_IMM:
            n = 1 if len(op) == 1 else op[1].imm & (63 if sz == 64 else 31)
            if n == 0:
                return rd, set(), set()
            if rot:
                return rd, ({'C', 'O'} if n == 1 else {'C'}), (set() if n == 1 else {'O'})
            undef = {'A'} | ({'O'} if n != 1 else set()) | ({'C'} if n >= sz else set())
            return rd, set('CPZSO') - undef, undef
        # a count in cl: 0 changes nothing; any defined output may stay as it was -> only undefinedness is added
        return rd, set(), ({'O'} if rot else {'O', 'A'}) | ({'C'} if (not rot and sz < 32) else set())
    if m in TABLE:
        r, d, u = TABLE[m]
        if tooth and m == 'cmp':
            return set(r), set(d) - {'Z'}, set(u) | {'Z'}
        return set(r), set(d), set(u)
    return set(), set(), set()


def main():
    tooth = '--tooth' in sys.argv
    funcs, cur = {}, None
    for ln in open(LIFT):
        mf = FUNC.match(ln)
        if mf:
            cur = int(mf.group(1), 16); funcs[cur] = []
            continue
        mt = LINE.match(ln)
        if mt and cur is not None and mt.group(2) != 'hook':
            funcs[cur].append((int(mt.group(1), 16), mt.group(3)))
    # entries: a pdata function (a CALL target, the ABI holds: no flag lives in) starts with every flag undefined. The
    # lift also roots INTERIOR targets (a jump's target, a jump table's case: tools/lift/jn_extra_roots.py) as functions
    # of their own for the indirect dispatch; their flags come from the jumping code, so they are judged inside the
    # pdata function that holds them (where the flow is real), and only a read there counts.
    L.pe.parse_data_directories()
    # a CHAINED unwind entry (UNW_FLAG_CHAININFO) is a fragment of its parent's body (shrink-wrapping), entered by
    # falling or jumping in, never called: it is judged like an interior root
    pdata = {e.struct.BeginAddress for e in getattr(L.pe, 'DIRECTORY_ENTRY_EXCEPTION', [])
             if not (e.unwindinfo and e.unwindinfo.Flags & 4)}
    covered = set()
    viol, nins, reads, interior = [], 0, 0, []
    for f, body in sorted(funcs.items(), key=lambda kv: kv[0] not in pdata):
        if not body:
            continue
        stmts = {}
        for rva, s in body:
            stmts.setdefault(rva, s)
        order = sorted(stmts)
        decoded = {r: L.dis(r) for r in order}
        succ = {}
        for r in order:
            ins, s = decoded[r], stmts[r]
            m = ins.mnemonic.replace('bnd ', '')
            outs = [t for t in (int(x, 16) for x in re.findall(r'goto L_([0-9a-f]+);', s)) if t in stmts]
            nxt = [r + ins.size] if r + ins.size in stmts else []
            if m == 'ret' or s.startswith('jp8_trap('):
                succ[r] = []
            elif m == 'jmp':                                       # a label, a jump table's cases, or a tail call
                succ[r] = outs
            else:                                                  # jcc: its label and the next; else the next
                succ[r] = outs + nxt
        # forward data-flow: the flags that may be undefined at each instruction's entry
        entry = f if f in stmts else order[0]
        state = {entry: set(ALL)}
        work = [entry]
        while work:
            r = work.pop()
            u = set(state[r])
            ins = decoded[r]
            rd, d, ud = effect(ins, tooth)
            if ins.mnemonic in ('call', 'bnd call'):
                after = set(ALL)                                    # the ABI: no flag survives a call
            else:
                after = (u - d) | ud
            for t in succ[r]:
                if t not in state:
                    state[t] = set(after); work.append(t)
                elif not after <= state[t]:
                    state[t] |= after; work.append(t)
        for r in order:
            if r not in state:
                continue                                            # not reachable from the entry inside this body
            nins += 1
            rd, d, ud = effect(decoded[r], tooth)
            if rd:
                reads += 1
            bad = rd & (state[r] | {'A'})
            if f in pdata:
                covered.add(r)
            if bad:
                v = (f, r, decoded[r].mnemonic + ' ' + decoded[r].op_str, ''.join(sorted(bad)))
                (viol if f in pdata or r not in covered else interior).append(v)
    for v in viol[:40]:
        print('VIOLATION in f_%x at %#x: %s reads %s while it may be undefined' % v)
    print('l3_flags: %d functions (%d pdata entries), %d instructions, %d flag reads; %d reads of a possibly undefined '
          'flag (%d more inside interior roots, each judged in its pdata function instead)%s' % (
              len(funcs), len(pdata & set(funcs)), nins, reads, len(viol), len(interior),
              ' (TOOTH: cmp leaves ZF undefined)' if tooth else ''))
    if tooth:
        print('TOOTH %s' % ('bit' if viol else 'DID NOT BITE'))
        return 0 if viol else 1
    return 1 if viol else 0


if __name__ == '__main__':
    sys.exit(main())
