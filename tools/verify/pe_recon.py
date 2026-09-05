#!/usr/bin/env python3
"""pe_recon.py -- the BINARY CENSUS, mechanical (charter section 1: census
from the binary BEFORE gates). Everything the JX-3P robustness arc found by
hand on 2026-09-04, as one command that works on any ZenCore-family .vst3
(JUNO, JX-3P, ...) and most MSVC x64 PE plugins:

  sections     -- and the RUNTIME-FILLED tail of each (VirtualSize beyond
                  SizeOfRawData: zero in the file, filled by code at startup;
                  the JX pulse wavetable region lived there, silently zero
                  under the emulator)
  crt_init     -- entry point + the C (XI) and C++ (XC) initializer tables
                  found from the _initterm lea pairs next to the entry point
  params       -- the parameter NAME table and the ENGINE DB rows
                  {min,max,default,flags} keyed by id (found from the
                  'MASTER TUNE' string and the Pitch Bend row signature)
  vtable       -- for each known method rva, the vtable that holds it and
                  all its slots
  callers      -- rel32 call sites of a function
  refs         -- rel32 / absolute references to a data address

usage:
  pe_recon.py <pe> sections
  pe_recon.py <pe> crt_init
  pe_recon.py <pe> params [id ...]            (no ids = summary + count)
  pe_recon.py <pe> vtable <rva> [<rva> ...]
  pe_recon.py <pe> callers <rva>
  pe_recon.py <pe> refs <rva>
  pe_recon.py <pe> all --json > recon.json
Every number is READ (static) -- label it so downstream.
"""
import sys, json, struct, re
import pefile

try:
    import capstone
except ImportError:
    capstone = None


class PE:
    def __init__(self, path):
        self.pe = pefile.PE(path)
        self.ib = self.pe.OPTIONAL_HEADER.ImageBase
        self.img = bytes(self.pe.get_memory_mapped_image())
        self.code_lo, self.code_hi = None, None
        for s in self.pe.sections:
            if s.Name.startswith(b".text"):
                self.code_lo = s.VirtualAddress
                self.code_hi = s.VirtualAddress + s.Misc_VirtualSize

    def q(self, rva): return struct.unpack_from("<Q", self.img, rva)[0]
    def i32(self, rva): return struct.unpack_from("<i", self.img, rva)[0]

    def is_code(self, va):
        return self.ib + self.code_lo <= va < self.ib + self.code_hi

    def cstr(self, rva, limit=96):
        e = self.img.index(b"\0", rva)
        if e - rva > limit:
            return None
        try:
            return self.img[rva:e].decode("latin1")
        except Exception:
            return None

    # ---------------------------------------------------------------- sections
    def sections(self):
        out = []
        for s in self.pe.sections:
            va, vs, rs = s.VirtualAddress, s.Misc_VirtualSize, s.SizeOfRawData
            row = {"name": s.Name.rstrip(b"\0").decode("latin1"),
                   "va": "0x%x" % va, "vsize": "0x%x" % vs, "rawsize": "0x%x" % rs}
            if vs > rs:
                row["runtime_filled"] = ["0x%x" % (va + rs), "0x%x" % (va + vs)]
            out.append(row)
        return out

    # ---------------------------------------------------------------- crt init
    def crt_init(self):
        ep = self.pe.OPTIONAL_HEADER.AddressOfEntryPoint
        res = {"entry_point": "0x%x" % ep, "tables": []}
        if capstone is None:
            res["note"] = "capstone missing; lea-pair scan skipped"
            return res
        md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
        md.detail = True
        lo = max(0, ep - 0x1000); hi = ep + 0x4000
        prev = None
        for ins in md.disasm(self.img[lo:hi], self.ib + lo):
            if ins.mnemonic == "lea" and "rip" in ins.op_str:
                tgt = ins.address + ins.size + ins.disp - self.ib
                reg = ins.op_str.split(",")[0]
                if prev and ins.address == prev[0] + prev[1] and \
                   {reg, prev[3]} == {"rcx", "rdx"}:
                    a, b = (tgt, prev[2]) if reg == "rcx" else (prev[2], tgt)
                    if 0 < b - a < 0x20000 and (b - a) % 8 == 0:
                        n = (b - a) // 8
                        ptrs = [self.q(a + 8 * i) for i in range(n)]
                        live = [p for p in ptrs if p and self.is_code(p)]
                        if live:
                            res["tables"].append({
                                "begin": "0x%x" % a, "end": "0x%x" % b,
                                "entries": n, "code_ptrs": len(live),
                                "kind": "XC (C++ ctors)" if n > 32 else "XI (C init)"})
                prev = (ins.address, ins.size, tgt, reg)
        return res

    def crt_ctor_ptrs(self):
        """the C++ initializer list, as rvas, for an emulator to run"""
        best = None
        for t in self.crt_init()["tables"]:
            if best is None or t["entries"] > best["entries"]:
                best = t
        if not best:
            return []
        a, b = int(best["begin"], 16), int(best["end"], 16)
        return [self.q(a + 8 * i) - self.ib for i in range((b - a) // 8)
                if self.q(a + 8 * i)]

    # ---------------------------------------------------------------- params
    def name_table(self):
        s = self.img.find(b"MASTER TUNE\0")
        if s < 0:
            return None
        ptr = struct.pack("<Q", self.ib + s)
        hit = self.img.find(ptr)
        if hit < 0:
            return None
        def ok(off):
            p = struct.unpack_from("<Q", self.img, off)[0]
            return self.ib <= p < self.ib + len(self.img) and \
                self.cstr(p - self.ib) is not None
        base = hit
        while base >= 8 and ok(base - 8):
            base -= 8
        end = hit
        while end + 8 < len(self.img) and ok(end + 8):
            end += 8
        return base, (end - base) // 8 + 1

    def engine_db(self, names_base):
        # Pitch Bend row {-8192, 8191, 0} at 16*493 identifies the DB
        pat = struct.pack("<iii", -8192, 8191, 0)
        for m in re.finditer(re.escape(pat), self.img):
            base = m.start() - 16 * 493
            if base < 0:
                continue
            mn, mx, df, _ = struct.unpack_from("<iiii", self.img, base + 16 * 20)
            if (mn, mx, df) == (-100, 100, 0):        # MASTER TUNE row agrees
                return base
        return None

    def params(self, ids=None):
        nt = self.name_table()
        if not nt:
            return {"error": "name table not found"}
        base, count = nt
        db = self.engine_db(base)
        res = {"name_table": "0x%x" % base, "names": count,
               "engine_db": ("0x%x" % db) if db is not None else None, "rows": {}}
        rng = ids if ids else range(min(count, 1500))
        for i in rng:
            p = struct.unpack_from("<Q", self.img, base + 8 * i)[0]
            nm = self.cstr(p - self.ib) if self.ib <= p < self.ib + len(self.img) else None
            row = {"name": nm}
            if db is not None:
                mn, mx, df, fl = struct.unpack_from("<iiii", self.img, db + 16 * i)
                row.update({"min": mn, "max": mx, "default": df, "flags": "0x%x" % (fl & 0xFFFFFFFF)})
            if ids or (nm and nm != "_reserve_"):
                res["rows"][i] = row
        if not ids:
            res["rows"] = {k: v for k, v in list(res["rows"].items())[:0]}
            res["named"] = sum(1 for i in range(min(count, 1500))
                               if self.cstr((struct.unpack_from("<Q", self.img, base + 8 * i)[0]) - self.ib) not in (None, "_reserve_"))
        return res

    # ---------------------------------------------------------------- vtables
    def vtable(self, rva):
        ptr = struct.pack("<Q", self.ib + rva)
        hit = self.img.find(ptr)
        if hit < 0:
            return None
        a = hit
        while a >= 8 and self.is_code(self.q(a - 8)):
            a -= 8
        slots = []
        i = 0
        while self.is_code(self.q(a + 8 * i)):
            slots.append("0x%x" % (self.q(a + 8 * i) - self.ib))
            i += 1
        return {"vtable": "0x%x" % a, "slot_of_rva": "0x%x" % (hit - a), "slots": slots}

    # ---------------------------------------------------------------- xrefs
    def callers(self, rva):
        img = self.img
        out = []
        for a in range(self.code_lo, self.code_hi - 5):
            if img[a] == 0xE8 and struct.unpack_from("<i", img, a + 1)[0] == rva - a - 5:
                out.append("0x%x" % a)
        return out

    def refs(self, rva):
        img = self.img
        out = {"rel32": [], "abs64": []}
        for a in range(self.code_lo, self.code_hi - 4):
            if struct.unpack_from("<i", img, a)[0] == rva - a - 4:
                out["rel32"].append("0x%x" % a)
        pat = struct.pack("<Q", self.ib + rva)
        for m in re.finditer(re.escape(pat), img):
            out["abs64"].append("0x%x" % m.start())
        return out


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    pe = PE(sys.argv[1])
    cmd, args = sys.argv[2], sys.argv[3:]
    as_json = "--json" in args
    args = [a for a in args if a != "--json"]
    if cmd == "sections":
        res = pe.sections()
    elif cmd == "crt_init":
        res = pe.crt_init()
    elif cmd == "params":
        res = pe.params([int(a) for a in args] if args else None)
    elif cmd == "vtable":
        res = {a: pe.vtable(int(a, 16)) for a in args}
    elif cmd == "callers":
        res = {a: pe.callers(int(a, 16)) for a in args}
    elif cmd == "refs":
        res = {a: pe.refs(int(a, 16)) for a in args}
    elif cmd == "all":
        res = {"sections": pe.sections(), "crt_init": pe.crt_init(),
               "params": pe.params()}
    else:
        raise SystemExit("unknown command %s" % cmd)
    print(json.dumps(res, indent=1))


if __name__ == "__main__":
    main()
