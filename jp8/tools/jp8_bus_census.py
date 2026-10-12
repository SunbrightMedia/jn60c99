#!/usr/bin/env python3
"""jp8_bus_census.py -- oracle-only census (the JUNO-60's probes/host_api/bus_audio_census.py on the JUPITER-8): does
IComponent::activateBus (slot 10; a DAW activates the audio output and the event input at load) change what the
plugin's own process() renders? Two fresh boots (jp8_host_emu.JP8Host, the host gate's setup), one of them with
activateBus(kAudio, kOutput, 0, true) and activateBus(kEvent, kInput, 0, true) after the setup; then the same patch
load and the same blocks (a note, a chord over the eight voices, their release, a parameter change, idle). Reports
the answers, the bytes activateBus changed (core, heap), every instruction that reads them after (a read watch) and
whether any output word differs. Plumbing only.
usage: python3 jp8/tools/jp8_bus_census.py [patch=2]"""
import os
import sys
import struct
import hashlib
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import collections                                              # noqa: E402
import jp8_host_emu as X, jp8_host_seq as Q, jp8_bank as B      # noqa: E402
from unicorn import UC_HOOK_MEM_READ                            # noqa: E402
from unicorn.x86_const import UC_X86_REG_RIP                    # noqa: E402
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 2


def run(active):
    h = X.JP8Host()
    h.boot_host(log=lambda m: None)
    h.heap_reuse_on()
    h.host_setup(48000.0, Q.MAXBLOCK, Q.NPQ)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    heap0 = bytes(uc.mem_read(Q.HEAP_BASE, h.heap - Q.HEAP_BASE))
    answers = []
    if active:
        for typ, dirn in ((0, 1), (1, 0)):                     # (kAudio, kOutput), (kEvent, kInput)
            uc.mem_write(h._top() - 8 + 0x28, struct.pack('<Q', 1))   # the fourth argument (state = true)
            answers.append(h.call(q(q(h.comp) + 8 * 10), rcx=h.comp, rdx=typ, r8=dirn, r9=0, count=2_000_000_000) & 0xFFFFFFFF)
    heap1 = bytes(uc.mem_read(Q.HEAP_BASE, h.heap - Q.HEAP_BASE))
    changed = [Q.HEAP_BASE + i for i in range(min(len(heap0), len(heap1))) if heap0[i] != heap1[i]]
    readers = collections.Counter()           # every instruction that reads a byte activateBus changed, from here on
    if changed:
        def onread(uc_, access, address, size, value, ud):
            if any(address <= a < address + size for a in changed):
                readers[uc_.reg_read(UC_X86_REG_RIP) - X.IB] += 1
        h.uc.hook_add(UC_HOOK_MEM_READ, onread, begin=min(changed) - 8, end=max(changed) + 8)
    h.readers = readers
    h.load_patch(B.patch_blob(B.bank_bytes(), PATCH))
    words = bytearray()
    for b in [x for x in Q.blocks(PATCH)] + [(512, [], [], None)] * 4:
        n, evs, pars, ctx = b
        L, R = h.process(n, events=evs, params=pars, ctx=ctx)
        words += struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R)
    return answers, changed, bytes(words), h


a0, c0, w0, h0 = run(False)
a1, c1, w1, h1 = run(True)
print('activateBus answers: %s' % ', '.join('0x%x' % r for r in a1))
core = h1.core
print('bytes activateBus changed in the heap: %d (%s)' % (len(c1), ', '.join(
    '0x%x (core %+d)' % (a, a - core) for a in c1[:12])))
nd = sum(1 for i in range(0, len(w0), 4) if w0[i:i + 4] != w1[i:i + 4])
print('output: %d words, %d differ (sha256 %s / %s)' % (len(w0) // 4, nd, hashlib.sha256(w0).hexdigest()[:12],
      hashlib.sha256(w1).hexdigest()[:12]))
print('reads of those bytes after activateBus (the patch load and every block): %d (%s)' % (sum(h1.readers.values()),
      ', '.join('rva 0x%x x%d' % kv for kv in h1.readers.most_common(6)) or 'none'))
print('VERDICT: activateBus %s what process() renders (patch %d, %d blocks); %s' % ('CHANGES' if nd else 'does not change', PATCH,
      len(Q.blocks(PATCH)) + 4, 'no instruction read the bytes it set' if not h1.readers else 'the bytes it set ARE read'))
