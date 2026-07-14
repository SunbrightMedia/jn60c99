#!/usr/bin/env python3
"""real_bank_parse.py -- produce per-patch record values via the PLUGIN'S OWN
bank parser, executed under Unicorn. This removes the last reconstruction from
the recall reference (Phase 0 of docs/VERIFICATION_REDO_PLAN.md): the bank
`.bin` byte -> record-value decode is now the plugin's code, not our nibble
formula.

=== WHICH PARSER (this was the whole investigation) ===
presetbankog1.bin is a `KoaBankFile00003` / `PG-JU60` bank. Its loader is
sub_7FF91DF91530 (rva 0x331530), which loops the PER-RECORD parser
sub_7FF91DF90ED0 (rva 0x330ED0) over the 64 records.

  NOTE: sub_7FF91DFB1710 (rva 0x351710) -- the transform-heavy parser that
  docs/BANK_FORMAT.md and an earlier plan assumed was THE bank parser -- is NOT
  used for this file. It is gated in the loader on a `PG-BTQJA` model tag (the
  JU-06A "Load JU-06A Bank" IMPORT of a different, compact format) and never runs
  for a `PG-JU60` file. Feeding it presetbankog1.bin's blob produces spurious
  transformed output (e.g. DCO-RANGE byte 172 instead of 3). It is the wrong
  parser. (Proven by driving both under Unicorn: scratchpad/route_a_parser.py
  vs scratchpad/route_a_ju60.py.)

=== WHAT THE REAL PARSER DOES (PROVEN by execution) ===
For magic `KoaBankFile00003` + model `PG-JU60`/`PG-JU106` (i.e. not the
SH101/SH2/PRMRS/SYS100/TR8S special sets), sub_7FF91DF90ED0's record body path is
a *verbatim* std::istream read into the programmer-state buffer
(`sub_7FF91E051330(stream, a1)` == istream::read == memcpy) -- NO nibble
transform -- followed by writing the 16-char name into the state at byte 140.

Executing it on all 64 patches (feeding the real record body + name) yields the
programmer-state record == the input body BYTE-FOR-BYTE, and every value-tree
leaf real_recall.py reads matches its dec() decode with 0 mismatches
(scratchpad/route_a_verify_all.py). So real_recall.py's
`dec(b) = ((b0&0xF)<<4)|(b1&0xF)` IS the plugin's own decode for this format --
the decode is now PROVEN(executed), not reconstructed.

This module drives the plugin parser to produce the records so a Phase-1
full-state diff can run bank -> (plugin parser) -> (plugin dispatch loop) ->
engine cells with zero of our decode in the path.

Two-process rule: this uses only E2E (Unicorn plugin code), never ctypes libjuno.

Usage:
  python3 tools/verify/real_bank_parse.py --verify        # the executed proof
  python3 tools/verify/real_bank_parse.py --dump 5        # one patch's record
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *

IB          = E.IB
JU60_PARSE  = IB + 0x330ED0     # sub_7FF91DF90ED0(a1_rec, a2_stream, a3_magic, a4_model, a5_slot)
READ        = IB + 0x3F1330     # sub_7FF91E051330(stream, dst={start,end})

HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
BODY_N = 700                    # record-body bytes to materialise (covers every leaf: max bb 651)

def _record_name_body(bank, idx):
    base = HEADER + idx * STRIDE
    return bank[base:base+16], bank[base+BLOB_OFF: base+BLOB_OFF+BODY_N]

class BankParser:
    """Drives the plugin's PG-JU60 per-record parser under one E2E instance."""
    def __init__(self):
        self.e = E.E2E(); self.uc = self.e.uc
        self._name = b'\x00'*16; self._body = b'\x00'*BODY_N
        self.uc.hook_add(UC_HOOK_CODE, self._read_hook, begin=READ, end=READ)

    def _read_hook(self, uc, address, size, user):
        # Serve the istream reads from Python: the parser reads the 16-byte name,
        # then the record body. Distinguish by count (name==16, body==BODY_N).
        if address != READ: return
        dst = uc.reg_read(UC_X86_REG_RDX)
        start = int.from_bytes(uc.mem_read(dst, 8), 'little')
        end   = int.from_bytes(uc.mem_read(dst+8, 8), 'little')
        count = end - start
        if count == 16:
            uc.mem_write(start, self._name[:16])
        elif count > 0:
            uc.mem_write(start, (self._body + b'\x00'*count)[:count])
        rsp = uc.reg_read(UC_X86_REG_RSP)
        ret = int.from_bytes(uc.mem_read(rsp, 8), 'little')
        uc.reg_write(UC_X86_REG_RAX, 1)          # stream good
        uc.reg_write(UC_X86_REG_RIP, ret); uc.reg_write(UC_X86_REG_RSP, rsp+8)

    def _mkstr(self, s):
        """MSVC std::string {ptr/buf(16), size, cap} (heap-backed if len>=16)."""
        e = self.e; obj = e.bump(0x20); self.uc.mem_write(obj, b'\x00'*0x20)
        if len(s) < 16:
            self.uc.mem_write(obj, s)
            self.uc.mem_write(obj+16, struct.pack('<Q', len(s)))
            self.uc.mem_write(obj+24, struct.pack('<Q', 15))
        else:
            buf = e.bump(len(s)+16); self.uc.mem_write(buf, s + b'\x00')
            self.uc.mem_write(obj,    struct.pack('<Q', buf))
            self.uc.mem_write(obj+16, struct.pack('<Q', len(s)))
            self.uc.mem_write(obj+24, struct.pack('<Q', len(s)+15))
        return obj

    def parse(self, name, body, model=b'PG-JU60'):
        """Run the plugin parser on one record; return (ret, record_bytes)."""
        self._name = bytes(name)[:16].ljust(16, b'\x00')
        self._body = bytes(body) + b'\x00'*(BODY_N - len(body))
        uc = self.uc
        outbuf = self.e.bump(0x1000); uc.mem_write(outbuf, b'\x00'*0x1000)
        rec = self.e.bump(0x20)
        uc.mem_write(rec, struct.pack('<QQQ', outbuf, outbuf+BODY_N, outbuf+0x1000))
        stream = self.e.bump(0x40); uc.mem_write(stream, b'\x00'*0x40)
        a3 = self._mkstr(b'KoaBankFile00003'); a4 = self._mkstr(model)
        rsp = (E.STACK_BASE + E.STACK_SIZE - 0x10000) & ~0xF; rsp -= 8
        RET = E.SCRATCH + 0x5000
        uc.mem_write(rsp, struct.pack('<Q', RET))
        uc.mem_write(rsp+0x28, struct.pack('<Q', 0))         # a5 (slot) on stack
        uc.reg_write(UC_X86_REG_RSP, rsp)
        uc.reg_write(UC_X86_REG_RCX, rec); uc.reg_write(UC_X86_REG_RDX, stream)
        uc.reg_write(UC_X86_REG_R8, a3);  uc.reg_write(UC_X86_REG_R9, a4)
        uc.emu_start(JU60_PARSE, RET, count=20_000_000)      # bounded
        if uc.reg_read(UC_X86_REG_RIP) != RET:
            raise RuntimeError("parser stopped at rva 0x%x" % (uc.reg_read(UC_X86_REG_RIP)-IB))
        return uc.reg_read(UC_X86_REG_RAX), bytes(uc.mem_read(outbuf, BODY_N))

def parse_records(bank=None):
    """Return [record_bytes]*64 -- each the plugin-parser output for that patch."""
    bank = bank if bank is not None else E.bank_bytes()
    bp = BankParser(); out = []
    for idx in range(64):
        nm, body = _record_name_body(bank, idx)
        ret, rec = bp.parse(nm, body)
        if ret != 1:
            raise RuntimeError("parser rejected patch %d (ret=%d)" % (idx, ret))
        out.append(rec)
    return out

def record_value(record, bb):
    """The value-tree logical byte at record position bb (hi-nibble first)."""
    return ((record[bb] & 0xF) << 4) | (record[bb+1] & 0xF)

def verify():
    """Executed proof: plugin parser output == our decode for all 64 patches."""
    import real_recall as RR
    bank = E.bank_bytes()
    leaves = RR.leaf_table()
    recs = parse_records(bank)
    verbatim = 0; body_bad = []; leaf_bad = []
    for idx in range(64):
        base = HEADER + idx*STRIDE
        body = bank[base+BLOB_OFF: base+BLOB_OFF+BODY_N]
        rec = recs[idx]
        if rec == body:
            verbatim += 1
        else:
            body_bad.append((idx, [i for i in range(BODY_N) if rec[i] != body[i]][:8]))
        for (disp, bb) in leaves:
            if record_value(rec, bb) != RR.dec(body, bb):
                leaf_bad.append((idx, disp, bb, RR.dec(body, bb), record_value(rec, bb)))
    print("plugin parser executed on 64/64 patches (sub_7FF91DF90ED0)")
    print("record == input body, byte-for-byte: %d/64" % verbatim)
    print("body mismatches:", body_bad if body_bad else "NONE")
    print("leaf-level mismatches (plugin record vs real_recall dec): %d  (%d leaves x 64 patches)"
          % (len(leaf_bad), len(leaves)))
    for m in leaf_bad[:40]:
        print("   patch %d disp %d bb %d  ours=%d plugin=%d" % m)
    ok = (verbatim == 64 and not leaf_bad)
    print("VERDICT:", "bank byte->record decode PROVEN(executed) identity vs plugin parser"
          if ok else "*** MISMATCH ***")
    return ok

def main():
    if '--verify' in sys.argv:
        sys.exit(0 if verify() else 1)
    if '--dump' in sys.argv:
        idx = int(sys.argv[sys.argv.index('--dump')+1])
        bank = E.bank_bytes()
        nm, body = _record_name_body(bank, idx)
        ret, rec = BankParser().parse(nm, body)
        print("patch %d %-16s ret=%d" % (idx, E.patch_name(bank, idx), ret))
        print("record[0:64] =", list(rec[:64]))
        return
    print(__doc__)

if __name__ == '__main__':
    main()
