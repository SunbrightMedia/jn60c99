#!/usr/bin/env python3
"""boss_license_locate.py -- READ-only: locate the licensing / authorization cluster in the BOSS image and map
it to function RVAs (f_<rva> in boss_lift.c). Two anchors, both static:
  (1) functions that REFERENCE a licence string (RCM / login / authoriz / licen / serial / demo / expired / ...);
  (2) functions that CALL a network or crypto import (WININET / WS2_32 / bcrypt) -- the licence's support layer
      (the DSP does no network, so these callers belong to the licence/telemetry path, READ).
Emits a TSV to stdout: rva <tab> kind <tab> detail. Reimplements no plugin logic; it only finds references.
"""
import os
import re
import struct
import sys
import bisect

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import boss_truth as T                                                  # noqa: E402
import pefile                                                           # noqa: E402
from capstone import Cs, CS_ARCH_X86, CS_MODE_64                        # noqa: E402
from capstone.x86 import X86_REG_RIP, X86_OP_MEM                        # noqa: E402

pe = pefile.PE(T.VST3)
IB = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()
md = Cs(CS_ARCH_X86, CS_MODE_64)
md.detail = True
md.skipdata = True

text = next(s for s in pe.sections if s.Name.startswith(b'.text'))
T_LO, T_HI = text.VirtualAddress, text.VirtualAddress + text.Misc_VirtualSize
FUNCS = sorted(f.struct.BeginAddress for f in pe.DIRECTORY_ENTRY_EXCEPTION)


def fn_of(rva):
    i = bisect.bisect_right(FUNCS, rva) - 1
    return FUNCS[i] if i >= 0 else None


MARKERS = (b'RCM', b'DoLogin', b'DO_LOGIN', b'LoginRequest', b'StartRCM', b'Login Thread',
           b'Authorization Thread', b'Authorized', b'Not Authorized', b'Serial Number', b'Demo Mode',
           b'Expired', b'CodeAuthorization', b'CodeExpired', b'CodeLicense', b'CodeUnauthorized',
           b'CodeActivator', b'Roland Cloud', b'rcmVer', b'admissionAuthority', b'Concerto')
LICEN_RE = re.compile(rb'(?i)licen[cs]')

# 1. licence string VAs (in .rdata / .data)
str_vas = set()
for s in pe.sections:
    if s.Name.startswith((b'.rdata', b'.data', b'_RDATA')):
        base, blob = s.VirtualAddress, IMG[s.VirtualAddress:s.VirtualAddress + s.Misc_VirtualSize]
        for mk in MARKERS:
            i = blob.find(mk)
            while i != -1:
                str_vas.add(IB + base + i)
                i = blob.find(mk, i + 1)
        for m in LICEN_RE.finditer(blob):
            str_vas.add(IB + base + m.start())

# 2. import thunk VAs for the network / crypto DLLs
net_thunks = {}
for e in pe.DIRECTORY_ENTRY_IMPORT:
    dll = e.dll.decode().lower()
    if dll.startswith(('wininet', 'ws2_32', 'bcrypt')):
        for imp in e.imports:
            net_thunks[imp.address] = (dll, imp.name.decode() if imp.name else 'ord%d' % imp.ordinal)

# walk .text once: a rip-relative operand hitting a licence string -> ref; a call to a net/crypto thunk -> net
hits = {}                                                               # fn_rva -> set(detail)
sys.stderr.write("licence string VAs: %d ; net/crypto thunks: %d\n" % (len(str_vas), len(net_thunks)))
code = IMG[T_LO:T_HI]
for ins in md.disasm(code, IB + T_LO):
    if ins.id == 0:          # skipdata pseudo-instruction (.byte); no operands
        continue

    f = fn_of(ins.address - IB)
    if f is None:
        continue
    # rip-relative data reference
    for op in ins.operands:
        if op.type == X86_OP_MEM and op.mem.base == X86_REG_RIP and op.mem.index == 0:  # [rip+disp]
            tgt = ins.address + ins.size + op.mem.disp
            if tgt in str_vas:
                hits.setdefault(f, set()).add('STR@0x%x' % (tgt - IB))
    # call to a net/crypto import thunk (mem [rip+disp] -> thunk VA)
    if ins.mnemonic == 'call':
        for op in ins.operands:
            if op.type == X86_OP_MEM and op.mem.base == X86_REG_RIP:
                tgt = ins.address + ins.size + op.mem.disp
                if tgt - IB in net_thunks:
                    hits.setdefault(f, set()).add('NET:%s!%s' % net_thunks[tgt - IB])

print('rva\tkind\tdetail')
for f in sorted(hits):
    det = sorted(hits[f])
    kind = 'str+net' if any(d.startswith('STR') for d in det) and any(d.startswith('NET') for d in det) \
        else ('string' if any(d.startswith('STR') for d in det) else 'net')
    print('0x%x\t%s\t%s' % (f, kind, ';'.join(det)[:200]))
sys.stderr.write('licence-cluster functions: %d (string-ref and/or net/crypto caller)\n' % len(hits))
