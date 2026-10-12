#!/usr/bin/env python3
"""jp8_ctx_census.py -- which bytes of the VST3 ProcessContext the JUPITER-8 reads (EXECUTED): the host oracle runs the
host gate's drive (jp8_host_seq.steps: JP8_HOST_SWEEP / JP8_HOST_PATCHES / JP8_HOST_RATE as the gate's) with a memory-read
hook on the 160-byte context host_process_emu hands process(), and prints every (offset, size) read with the code that
reads it and how often. The fields: 0 state, 8 sampleRate, 16 projectTimeSamples, 24 systemTime, 32
continousTimeSamples, 40 projectTimeMusic (ppq), 48 barPositionMusic, 56 / 64 cycleStart / cycleEnd, 72 tempo, 80 / 84
timeSig, 88.. chord, 112.. smpteOffset, frameRate, samplesToNextClock.
    JP8_HOST_SWEEP=0 JP8_HOST_PATCHES=2 python3 jp8/tools/jp8_ctx_census.py"""
import sys, os, time, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import jp8_host_emu as X, jp8_bank as B, jp8_host_seq as Q
from unicorn import UC_HOOK_MEM_READ
from unicorn.x86_const import UC_X86_REG_RIP
FIELDS = {0: 'state', 8: 'sampleRate', 16: 'projectTimeSamples', 24: 'systemTime', 32: 'continousTimeSamples', 40: 'projectTimeMusic (ppq)',
          48: 'barPositionMusic', 56: 'cycleStartMusic', 64: 'cycleEndMusic', 72: 'tempo', 80: 'timeSigNumerator', 84: 'timeSigDenominator'}
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
h = X.JP8Host(); h.boot_host(log=log); uc = h.uc
ST = Q.steps(); h.heap_reuse_on(); h.host_setup(ST[0][1], Q.MAXBLOCK, Q.NPQ)
reads = collections.Counter(); nblk = collections.Counter()
def on_read(uc_, access, addr, size, value, ud):
    reads[(addr - h._ctx, size, uc_.reg_read(UC_X86_REG_RIP) - X.IB)] += 1
uc.hook_add(UC_HOOK_MEM_READ, on_read, begin=h._ctx, end=h._ctx + 159)
# THE TRANSPORT RECORD process() builds from the context on its own stack (rva 0x36C28B-0x36C2E0, READ): rbp-0x70
# playing (dword), -0x6C ppq valid (byte), -0x68 ppq, -0x60 tempo valid, -0x58 tempo, -0x50 cycle valid, -0x48 / -0x40
# cycle start / end; rva 0x36C327 hands its address on. Every read of it while that process() runs: its readers.
REC = {0: 'playing', 4: 'ppq valid', 8: 'ppq', 0x10: 'tempo valid', 0x18: 'tempo', 0x20: 'cycle valid', 0x28: 'cycle start',
       0x30: 'cycle end'}
rec = {'at': None, 'on': False}; rreads = collections.Counter()
def on_rec_read(uc_, access, addr, size, value, ud):
    if rec['on'] and rec['at'] is not None and rec['at'] <= addr < rec['at'] + 0x38:
        rreads[(addr - rec['at'], size, uc_.reg_read(UC_X86_REG_RIP) - X.IB)] += 1
def at_hand(uc_, addr, size, ud):
    from unicorn.x86_const import UC_X86_REG_RBP
    a = uc_.reg_read(UC_X86_REG_RBP) - 0x70
    if rec['at'] is None:
        rec['at'] = a; uc_.hook_add(UC_HOOK_MEM_READ, on_rec_read, begin=a, end=a + 0x37)
    elif rec['at'] != a:
        raise SystemExit('the transport record moved: 0x%x -> 0x%x' % (rec['at'], a))
    rec['on'] = True
from unicorn import UC_HOOK_CODE
uc.hook_add(UC_HOOK_CODE, at_hand, begin=X.IB + 0x36C327, end=X.IB + 0x36C327)
bank = B.bank_bytes(); states = {}; cstates = {}; blob = lambda p: B.patch_blob(bank, p)
for st in ST[1:]:
    if st[0] == 'block': nblk['with a context' if st[4] is not None else 'without'] += 1
    rec['on'] = False
    h.run_step(st, blob, Q.state_variant, states, cstates)
rec['on'] = False
log('%d steps, blocks %s' % (len(ST) - 1, dict(nblk)))
for (off, size, pc), n in sorted(reads.items()):
    print('  +%-3d %-24s %d bytes  by rva 0x%06x  x%d' % (off, FIELDS.get(off, '?'), size, pc, n))
print('fields read: %s' % ', '.join(sorted(set(FIELDS.get(o, '+%d' % o) for o, _, _ in reads))))
print('the transport record (at 0x%x) -- its readers while process() runs:' % (rec['at'] or 0))
for (off, size, pc), n in sorted(rreads.items()):
    print('  +0x%-3x %-12s %d bytes  by rva 0x%06x  x%d' % (off, REC.get(off, '?'), size, pc, n))
print('record fields read: %s' % ', '.join(sorted(set(REC.get(o, '+0x%x' % o) for o, _, _ in rreads))))
