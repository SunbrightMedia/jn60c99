#!/usr/bin/env python3
"""boss_throw_probe.py -- READ-only plumbing: boot the BOSS plugin under the oracle and report the C++ exception
that stops the boot. It records, at the MSVC throw helper _CxxThrowException (rva 0xb4d888): the thrown type
(decoded from ThrowInfo), the throw-site caller, a .text backtrace with which frames carry a language handler
(a __try/catch), whether the throw is on the main stack or inside a spawned worker thread, and the std error
code dispatched by _Throw_Cpp_error (rva 0xb0a778). It serves nothing and bypasses nothing: it only observes.

Run via tools/run_job.sh (the boot is ~10 min: InitDll reads BX00_DATA.BIN one byte per std::istream::get).

WHAT IT FOUND (2026-10-17): the boot is NOT stopped by a licence check -- no licence file or registry key is
read before the stop. A worker thread throws std::system_error (_Thrd_busy, code 3) from a timed mutex lock
(_Mtx_lock, rva 0xb09ba0) during a call_once static init (rva 0x47e8e0); enclosing frames carry catch handlers,
so a real run delivers it to a catch and continues. The oracle's single-tid, run-to-completion thread model
makes the lock look self-owned, so the lock returns busy where a real interleaving would not. The fix is in the
oracle's thread scheduling (plumbing), not in the plugin and not in any licence path. See boss/docs/S3_STATUS.md.
"""
import collections
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import boss_emu as B                                                    # noqa: E402
import pefile                                                           # noqa: E402
import bisect                                                           # noqa: E402

IB = B.IB
IMG = B.IMG
TEXT_LO, TEXT_HI = 0x1000, 0x1000 + 0xcaa3cf
_pe = pefile.PE(B.BIN)
EXC = sorted((e.struct.BeginAddress, e.struct.EndAddress, e.struct.UnwindData)
             for e in _pe.DIRECTORY_ENTRY_EXCEPTION)
_starts = [b for b, _, _ in EXC]


def _fn(rva):
    k = bisect.bisect_right(_starts, rva) - 1
    return EXC[k] if 0 <= k and EXC[k][0] <= rva < EXC[k][1] else None


def has_handler(rva):
    e = _fn(rva)
    return None if not e else bool((IMG[e[2]] >> 3) & 0x3)              # UNWIND_INFO flags: EHANDLER|UHANDLER


def type_name(ti_rva):
    try:
        cta = struct.unpack_from('<I', IMG, ti_rva + 12)[0]
        n = struct.unpack_from('<I', IMG, cta)[0]
        ct0 = struct.unpack_from('<I', IMG, cta + 4)[0]
        td = struct.unpack_from('<I', IMG, ct0 + 4)[0]
        return '%d types, [0]=%s' % (n, IMG[td + 16:td + 16 + 128].split(b'\0')[0].decode('latin1'))
    except Exception as ex:
        return 'decode-failed %r' % ex


codes, last_imps, hits = [], collections.deque(maxlen=30), []
h = B.BossHost()
uc = h.uc


def rec_imp(uc2, address, size, user):                                  # PASSIVE: original _imp hook still runs it
    nm = h.stub2name.get(address, ('', ''))[1]
    if nm:
        last_imps.append(nm)


def on_dispatch(uc2, address, size, user):
    codes.append(uc2.reg_read(B.UC_X86_REG_RCX) & 0xFFFFFFFF)


def on_throw(uc2, address, size, user):
    rsp = uc2.reg_read(B.UC_X86_REG_RSP)
    rdx = uc2.reg_read(B.UC_X86_REG_RDX)
    ret = struct.unpack('<Q', bytes(uc2.mem_read(rsp, 8)))[0] - IB
    bt = []
    for off in range(0, 0x400, 8):
        v = struct.unpack('<Q', bytes(uc2.mem_read(rsp + off, 8)))[0] - IB
        if TEXT_LO <= v < TEXT_HI:
            bt.append(v)
        if len(bt) >= 12:
            break
    hits.append(dict(caller=ret, typ=type_name(rdx - IB) if rdx > IB else 'ti=0x%x' % rdx,
                     in_thread=getattr(h, '_nested_top', None) is not None,
                     code=codes[-1] if codes else None, bt=bt, imps=list(last_imps)))


uc.hook_add(B.UC_HOOK_CODE, rec_imp, begin=B.STUB_BASE, end=B.STUB_BASE + 8 * len(B.IMPORTS) + 8)
uc.hook_add(B.UC_HOOK_CODE, on_dispatch, begin=IB + 0xb0a778, end=IB + 0xb0a778)
uc.hook_add(B.UC_HOOK_CODE, on_throw, begin=IB + 0xb4d888, end=IB + 0xb4d888)

try:
    h.boot(log=lambda m: None)
    print('BOOT RETURNED (no throw)', flush=True)
except Exception as e:
    print('stopped:', e, flush=True)

for i, x in enumerate(hits):
    print('\nthrow #%d  in_thread=%s  std_code=%s' % (i, x['in_thread'], x['code']), flush=True)
    print('  thrown type : %s' % x['typ'], flush=True)
    print('  throw site  : rva 0x%x (handler on that fn: %s)' % (x['caller'], has_handler(x['caller'])), flush=True)
    print('  backtrace   : %s' % ' '.join('0x%x(h=%s)' % (r, has_handler(r)) for r in x['bt']), flush=True)
    print('  last imports: %s' % ' '.join(x['imps']), flush=True)
