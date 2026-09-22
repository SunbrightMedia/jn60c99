#!/usr/bin/env python3
"""jp8_lift.py -- mechanical x86-64 -> C99 lifter for the JUPITER-8 PLUG-OUT (PORT_PIPELINE step 5, no IDA dump).

Source of truth: the checksummed binary (jp8/truth/, resolved through jp8_emu's BIN). Method: recursive descent
from the given roots (capstone), one C function per machine function, one C statement per instruction, labels
at every jump target, MSVC x64 jump tables read from the image, indirect call/jmp sites dispatched at runtime
through the table of lifted functions (targets first seen by jp8_dynreach.py are lifted as roots too). Memory is
the process address space itself (jp8_cpu.h: the gate maps the oracle's regions at the same addresses), so
pointer-valued cells need no relocation. Anything the lifter cannot express is emitted as jp8_trap(rva): reaching
it aborts, which turns the gate RED (charter section 3: no silent placeholder).

The lifter is HARNESS: it never reimplements plugin logic; every emitted statement is the instruction's own
semantics. The C twin is judged only by the oracle's executed output (jp8_voice_gate.sh, EXACTLY 0).

usage: jp8_lift.py <out.c> <root rva hex>[,<rva>...] [--dyn dynreach.json] [--name voice]
"""
import sys, os, json, struct, collections
import pefile, capstone
from capstone import x86

HERE = os.path.dirname(os.path.abspath(__file__))
BIN = "/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3"
pe = pefile.PE(BIN); IB = pe.OPTIONAL_HEADER.ImageBase; IMG = pe.get_memory_mapped_image()
text = [s for s in pe.sections if s.Name.startswith(b'.text')][0]
CLO = text.VirtualAddress; CHI = CLO + text.Misc_VirtualSize
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64); md.detail = True

# ------------------------------------------------------------------ registers
GPR = ["rax", "rcx", "rdx", "rbx", "rsp", "rbp", "rsi", "rdi", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"]
REG = {}
for i, n in enumerate(GPR):
    REG[n] = (i, 64, 0)
    if i < 8:
        b = n[1:]
        REG["e" + b] = (i, 32, 0); REG[b] = (i, 16, 0)
        if b in ("ax", "bx", "cx", "dx"):
            REG[b[0] + "l"] = (i, 8, 0); REG[b[0] + "h"] = (i, 8, 1)
        else:
            REG[b + "l"] = (i, 8, 0)
    else:
        REG[n + "d"] = (i, 32, 0); REG[n + "w"] = (i, 16, 0); REG[n + "b"] = (i, 8, 0)
for i in range(16): REG["xmm%d" % i] = (i, 128, 0)

def reg(ins, rid):
    return REG[ins.reg_name(rid)]

class Emit:
    def __init__(self): self.lines = []
    def __call__(self, s): self.lines.append(s)

def dis(rva):
    for ins in md.disasm(bytes(IMG[rva:rva + 16]), IB + rva): return ins
    return None

def find_jumptable(prev, ins):
    """MSVC x64: lea rB,[rip+X] with X == image base; mov eA,[rB+rI*4+tbl]; add rA,rB; jmp rA -> tbl (RVA table)"""
    tbl = None; base = None
    for p in reversed(prev[-14:]):
        if tbl is None and p.mnemonic == "mov" and len(p.operands) == 2 and p.operands[1].type == x86.X86_OP_MEM and p.operands[1].mem.scale == 4:
            tbl = p.operands[1].mem.disp; base = p.operands[1].mem.base
        elif tbl is not None and p.mnemonic == "lea" and p.operands[0].reg == base:
            m = p.operands[1].mem
            if m.base == x86.X86_REG_RIP and p.address + p.size + m.disp == IB: return tbl
    return None

def read_table(tbl, near):
    ents = []; k = 0
    while k < 1024:
        e = struct.unpack_from("<I", IMG, tbl + 4 * k)[0]
        if not (CLO <= e < CHI) or abs(e - near) > 0x40000: break
        ents.append(e); k += 1
    return ents

# ------------------------------------------------------------------ discovery
def discover(roots, dyn_ind):
    """returns funcs: {entry: {insns:{rva:ins}, targets:set(rva), ijmp:{site:[targets]}}}"""
    funcs = {}; work = list(roots); calls_seen = set(roots)
    while work:
        f = work.pop()
        if f in funcs or not (CLO <= f < CHI): continue
        insns = {}; targets = set(); ijmp = {}; bwork = [f]
        while bwork:
            rva = bwork.pop()
            if rva in insns or not (CLO <= rva < CHI): continue
            prev = []
            while rva not in insns:
                ins = dis(rva)
                if ins is None: break
                insns[rva] = ins; prev.append(ins)
                m = ins.mnemonic.replace("bnd ", ""); op = ins.operands
                if m in ("ret", "int3", "hlt", "ud2"): break
                if m == "jmp":
                    if op[0].type == x86.X86_OP_IMM:
                        t = op[0].imm - IB; targets.add(t); bwork.append(t)
                    else:
                        tbl = find_jumptable(prev[:-1], ins); ts = []
                        if tbl is not None: ts = read_table(tbl, rva)
                        ts += [int(x, 16) for x in dyn_ind.get("%x" % rva, [])]
                        ts = sorted(set(ts)); ijmp[rva] = ts
                        for t in ts: targets.add(t); bwork.append(t)
                    break
                if m.startswith("j") or m.startswith("loop"):
                    t = op[0].imm - IB; targets.add(t); bwork.append(t); targets.add(rva + ins.size); bwork.append(rva + ins.size); break
                if m == "call":
                    if op[0].type == x86.X86_OP_IMM:
                        t = op[0].imm - IB
                        if t not in calls_seen: calls_seen.add(t); work.append(t)
                    else:
                        for x in dyn_ind.get("%x" % rva, []):
                            t = int(x, 16)
                            if t not in calls_seen: calls_seen.add(t); work.append(t)
                rva += ins.size
        funcs[f] = dict(insns=insns, targets=targets, ijmp=ijmp)
    return funcs

# ------------------------------------------------------------------ operand helpers
def ea(ins, op):
    m = op.mem; parts = []
    if m.base == x86.X86_REG_RIP:
        return "0x%xULL" % ((ins.address + ins.size + m.disp) & 0xFFFFFFFFFFFFFFFF)
    if m.segment != 0:
        if ins.reg_name(m.segment) != "gs": return None
        # gs:[disp] -- the TEB under Windows; under Unicorn the GS base is 0 and page 0 is mapped, so the plugin reads
        # page-0 bytes there (__chkstk's stack limit). The C side keeps the oracle's page 0 at JP8_GS_BASE (jp8_cpu.h).
        parts.append("JP8_GS_BASE")
    if m.base != 0: parts.append("R(%d)" % reg(ins, m.base)[0])
    if m.index != 0: parts.append("R(%d)*%d" % (reg(ins, m.index)[0], m.scale))
    parts.append("0x%xULL" % (m.disp & 0xFFFFFFFFFFFFFFFF))
    return "(" + "+".join(parts) + ")"

def rd_int(ins, op, sz=None):
    """value of an integer operand as uint64_t (zero-extended)"""
    sz = sz or op.size * 8
    if op.type == x86.X86_OP_IMM:
        return "0x%xULL" % (op.imm & ((1 << sz) - 1))
    if op.type == x86.X86_OP_REG:
        i, s, hi = reg(ins, op.reg)
        if s == 128: raise ValueError("xmm as int")
        if hi: return "((R(%d)>>8)&0xFF)" % i
        return "(R(%d)&0x%xULL)" % (i, (1 << s) - 1) if s < 64 else "R(%d)" % i
    a = ea(ins, op)
    if a is None: raise ValueError("segment")
    return {8: "M8", 16: "M16", 32: "M32", 64: "M64"}[sz] + "(%s)" % a

def wr_int(ins, op, expr, sz=None):
    sz = sz or op.size * 8
    if op.type == x86.X86_OP_REG:
        i, s, hi = reg(ins, op.reg)
        if hi: return "R(%d)=(R(%d)&~0xFF00ULL)|((((uint64_t)(%s))&0xFF)<<8);" % (i, i, expr)
        if s == 64: return "R(%d)=(uint64_t)(%s);" % (i, expr)
        if s == 32: return "R(%d)=((uint64_t)(%s))&0xFFFFFFFFULL;" % (i, expr)
        return "R(%d)=(R(%d)&~0x%xULL)|(((uint64_t)(%s))&0x%xULL);" % (i, i, (1 << s) - 1, expr, (1 << s) - 1)
    a = ea(ins, op)
    if a is None: raise ValueError("segment")
    return {8: "M8", 16: "M16", 32: "M32", 64: "M64"}[sz] + "(%s)=(%s);" % (a, expr)

def xsrc(ins, op, kind):
    """xmm-or-memory source as a C lvalue-ish expression of the given lane kind: 'f'(float lane0) 'd' 'u' 'q' or 'X' (whole)"""
    if op.type == x86.X86_OP_REG:
        i = reg(ins, op.reg)[0]
        return {"f": "XF(%d,0)", "d": "XD(%d,0)", "u": "XU(%d,0)", "q": "XQ(%d,0)", "X": "c->x[%d]"}[kind] % i
    a = ea(ins, op)
    if a is None: raise ValueError("segment")
    if kind == "X": return "JP8_MX(%s)" % a
    return {"f": "MF", "d": "MD", "u": "M32", "q": "M64"}[kind] + "(%s)" % a

CC = {"e": "CC_E", "z": "CC_E", "ne": "CC_NE", "nz": "CC_NE", "b": "CC_B", "c": "CC_B", "nae": "CC_B", "ae": "CC_AE", "nb": "CC_AE", "nc": "CC_AE",
      "be": "CC_BE", "na": "CC_BE", "a": "CC_A", "nbe": "CC_A", "l": "CC_L", "nge": "CC_L", "ge": "CC_GE", "nl": "CC_GE", "le": "CC_LE", "ng": "CC_LE",
      "g": "CC_G", "nle": "CC_G", "s": "CC_S", "ns": "CC_NS", "p": "CC_P", "pe": "CC_P", "np": "CC_NP", "po": "CC_NP", "o": "CC_O", "no": "CC_NO"}

ALU = {"add": "op_add", "sub": "op_sub", "and": "op_and", "or": "op_or", "xor": "op_xor", "adc": "op_adc", "sbb": "op_sbb"}
SHIFT = {"shl": "op_shl", "sal": "op_shl", "shr": "op_shr", "sar": "op_sar", "rol": "op_rol", "ror": "op_ror", "rcr": "op_rcr", "rcl": "op_rcl"}
FOPS = {"addss": ("f", "+"), "subss": ("f", "-"), "mulss": ("f", "*"), "divss": ("f", "/"),
        "addsd": ("d", "+"), "subsd": ("d", "-"), "mulsd": ("d", "*"), "divsd": ("d", "/")}
OPM = {"+": "ADD", "-": "SUB", "*": "MUL", "/": "DIV"}          # JP8_<OP><SS|SD>(a,b): jp8_cpu.h picks plain C or soft FTZ/DAZ
POPS = {"addps": ("f", "+", 4), "subps": ("f", "-", 4), "mulps": ("f", "*", 4), "divps": ("f", "/", 4),
        "addpd": ("d", "+", 2), "subpd": ("d", "-", 2), "mulpd": ("d", "*", 2), "divpd": ("d", "/", 2)}
BITOPS = {"xorps": "^", "xorpd": "^", "pxor": "^", "andps": "&", "andpd": "&", "pand": "&", "orps": "|", "orpd": "|", "por": "|"}

class Lifter:
    def __init__(self, funcs, name, tooth=None, trace=False):
        self.funcs = funcs; self.name = name; self.unsup = collections.Counter(); self.n = 0; self.tooth = tooth; self.tooth_done = False; self.trace = trace

    def lift(self):
        e = Emit()
        e("/* GENERATED by jp8/tools/jp8_lift.py -- do not edit. Roots: %s. %d functions, %d instructions. */" %
          (", ".join("0x%x" % r for r in sorted(self.funcs)), len(self.funcs), sum(len(f["insns"]) for f in self.funcs.values())))
        e('#include "jp8_cpu.h"')
        for f in sorted(self.funcs): e("static void f_%x(CPU *c);" % f)
        for f in sorted(self.funcs): self.lift_func(e, f)
        e("typedef struct { uint64_t rva; void (*fn)(CPU *); } jp8_fn_t;")
        e("static const jp8_fn_t jp8_fns_%s[] = {" % self.name)
        for f in sorted(self.funcs): e("  {0x%x, f_%x}," % (f, f))
        e("};")
        e("const jp8_fn_t *jp8_fntab_%s = jp8_fns_%s; const int jp8_nfn_%s = %d;" % (self.name, self.name, self.name, len(self.funcs)))
        e("void jp8_icall(CPU *c, uint64_t target) {")
        e("  uint64_t rva = target - 0x%xULL; int lo = 0, hi = %d;" % (IB, len(self.funcs) - 1))
        e("  while (lo <= hi) { int mid = (lo + hi) / 2; if (jp8_fns_%s[mid].rva == rva) { jp8_fns_%s[mid].fn(c); return; }" % (self.name, self.name))
        e("    if (jp8_fns_%s[mid].rva < rva) lo = mid + 1; else hi = mid - 1; }" % self.name)
        e("  if (target >= 0x600000000ULL && target < 0x600100000ULL) { jp8_import(c, (int)((target - 0x600000000ULL) / 8)); return; }")
        e("  { static char msg[64]; snprintf(msg, sizeof msg, \"indirect target 0x%llx not lifted\", (unsigned long long)rva); jp8_trap(c, rva, msg); }")
        e("}")
        e("void jp8_run(CPU *c, uint64_t rva) { jp8_icall(c, rva + 0x%xULL); }" % IB)
        # the import stubs: index i (sorted by IAT rva, as jp8_emu enumerates them) -> name, for jp8_import()
        imps = sorted((e_.address - IB, imp.name.decode() if imp.name else "ord%d" % imp.ordinal) for e in pe.DIRECTORY_ENTRY_IMPORT for imp in e.imports for e_ in [imp])
        e("const char *jp8_import_names[] = {")
        for rva, nm in imps: e('  "%s",' % nm)
        e("};")
        e("const int jp8_nimports = %d;" % len(imps))
        return "\n".join(e.lines) + "\n"

    def lift_func(self, e, f):
        F = self.funcs[f]; insns = F["insns"]; targets = F["targets"]
        if F.get("alloc"):
            e("static void f_%x(CPU *c) { jp8_alloc(c); }   /* the CRT allocator: the oracle hooks this rva (jp8_emu ALLOC) and bumps; so does the runtime */" % f)
            return
        e("static void f_%x(CPU *c) {" % f)
        e("  X t0, t1; uint64_t a0, a1; (void)t0; (void)t1; (void)a0; (void)a1;")
        e("  goto L_%x;   /* the entry: blocks reached by backward jumps sort BEFORE it (paid 2026-09-22, note-off) */" % f)
        last = None
        for rva in sorted(insns):
            ins = insns[rva]
            if rva in targets or rva == f: e("L_%x:" % rva)
            elif last is not None and last != rva:
                e("L_%x: /* gap */" % rva)      # not a target but not fall-through either: unreachable label keeps C valid
            try:
                stmt = self.stmt(ins, F)
            except Exception as ex:
                stmt = None; self.unsup["%s (%s)" % (ins.mnemonic, str(ex)[:40])] += 1
            if stmt is None:
                self.unsup[ins.mnemonic] += 1
                stmt = 'jp8_trap(c, 0x%x, "%s %s");' % (rva, ins.mnemonic, ins.op_str.replace('"', ''))
            if self.tooth is not None and rva == self.tooth:
                if ins.mnemonic in FOPS:
                    k, o = FOPS[ins.mnemonic]; wrong = {"+": "-", "-": "+", "*": "/", "/": "*"}[o]
                    a_, b_ = "JP8_" + OPM[o], "JP8_" + OPM[wrong]
                    if not stmt.count(a_): raise SystemExit("tooth: %s not found in %s" % (a_, stmt))
                    stmt = "/* TOOTH: %s replaced by %s */ " % (o, wrong) + stmt.replace(a_, b_, 1)
                    self.tooth_done = True
                else: raise SystemExit("--tooth must name an addss/subss/mulss/divss instruction (got %s at 0x%x)" % (ins.mnemonic, rva))
            e("  %s/*%x %s %s*/ %s" % ("jp8_tr(c,0x%x); " % rva if self.trace else "", rva, ins.mnemonic, ins.op_str.replace("*/", "* /"), stmt))
            self.n += 1
            last = rva + ins.size
        e("}")

    # -------------------------------------------------------------- per instruction
    def stmt(self, ins, F):
        m = ins.mnemonic; op = ins.operands
        if m.startswith("bnd "): m = m[4:]
        if m.startswith("lock "): m = m[5:]
        if m.startswith("rep "):
            if m == "rep movsb": return "JP8_MOVSB();"
            if m in ("rep stosb", "rep stosd", "rep stosq", "rep stosw"):
                w = {"rep stosb": 1, "rep stosw": 2, "rep stosd": 4, "rep stosq": 8}[m]
                return "while (R(1)) { %s(R(7))=(uint%d_t)R(0); R(7)+=%d; R(1)--; }" % ({1: "M8", 2: "M16", 4: "M32", 8: "M64"}[w], w * 8, w)
            return None
        rva = ins.address - IB
        if m in ("nop", "endbr64", "pause", "sfence", "lfence", "mfence", "prefetcht0", "prefetcht1", "prefetcht2", "prefetchnta", "fwait", "wait"):
            return ";"
        if m in ("int3", "ud2", "hlt", "cpuid", "rdtsc", "syscall", "int"):
            return None
        # ---- control flow
        if m == "ret": return "return;"
        if m == "jmp":
            if op[0].type == x86.X86_OP_IMM:
                t = op[0].imm - IB
                if t in F["insns"]: return "goto L_%x;" % t
                if t in self.funcs: return "f_%x(c); return;" % t          # tail call to a lifted function
                return None
            tgt = rd_int(ins, op[0], 64)
            cases = "".join(" case 0x%xULL: goto L_%x;" % (t + IB, t) for t in F["ijmp"].get(rva, []) if t in F["insns"])
            return "a0=%s; switch (a0) {%s default: jp8_icall(c, a0); return; }" % (tgt, cases)
        if m == "call":
            if op[0].type == x86.X86_OP_IMM:
                t = op[0].imm - IB
                if t in self.funcs: return "R(4)-=8; f_%x(c); R(4)+=8;" % t
                return None
            return "a0=%s; R(4)-=8; jp8_icall(c, a0); R(4)+=8;" % rd_int(ins, op[0], 64)
        if m[0] == "j" and m[1:] in CC:
            t = op[0].imm - IB
            return "if (%s) goto L_%x;" % (CC[m[1:]], t)
        if m.startswith("cmov") and m[4:] in CC:
            return "if (%s) { %s }" % (CC[m[4:]], wr_int(ins, op[0], rd_int(ins, op[1])))
        if m.startswith("set") and m[3:] in CC:
            return wr_int(ins, op[0], "(%s)?1:0" % CC[m[3:]], 8)
        # ---- integer moves
        if m in ("mov", "movabs"):
            if op[0].type == x86.X86_OP_REG and reg(ins, op[0].reg)[1] == 128 or op[1].type == x86.X86_OP_REG and reg(ins, op[1].reg)[1] == 128: return None
            sz = op[0].size * 8
            src = rd_int(ins, op[1], sz) if op[1].type != x86.X86_OP_IMM else "0x%xULL" % (op[1].imm & ((1 << sz) - 1))
            return wr_int(ins, op[0], src, sz)
        if m == "movzx": return wr_int(ins, op[0], rd_int(ins, op[1]))
        if m == "movsx": return wr_int(ins, op[0], "sext(%d,%s)" % (op[1].size * 8, rd_int(ins, op[1])))
        if m == "movsxd": return wr_int(ins, op[0], "sext(32,%s)" % rd_int(ins, op[1], 32))
        if m == "cdqe": return "R(0)=sext(32,R(0)&0xFFFFFFFFULL);"
        if m == "cwde": return "R(0)=(R(0)&~0xFFFFFFFFULL)|(sext(16,R(0)&0xFFFF)&0xFFFFFFFFULL);"
        if m == "cdq": return "R(2)=((int32_t)(R(0)&0xFFFFFFFFULL)<0)?0xFFFFFFFFULL:0;"
        if m == "cqo": return "R(2)=((int64_t)R(0)<0)?~0ULL:0;"
        if m == "lea":
            a = ea(ins, op[1]); return wr_int(ins, op[0], a) if a else None
        if m == "xchg":
            return "a0=%s; %s %s" % (rd_int(ins, op[0]), wr_int(ins, op[0], rd_int(ins, op[1])), wr_int(ins, op[1], "a0"))
        if m == "xadd":
            return "a0=%s; a1=%s; %s %s" % (rd_int(ins, op[0]), rd_int(ins, op[1]), wr_int(ins, op[0], "op_add(c,%d,a0,a1)" % (op[0].size * 8)), wr_int(ins, op[1], "a0"))
        if m == "push":
            return "R(4)-=8; M64(R(4))=%s;" % ("sext(%d,%s)" % (op[0].size * 8, rd_int(ins, op[0])) if op[0].type == x86.X86_OP_IMM else rd_int(ins, op[0], 64))
        if m == "pop": return "a0=M64(R(4)); R(4)+=8; %s" % wr_int(ins, op[0], "a0", 64)
        if m == "leave": return "R(4)=R(5); R(5)=M64(R(4)); R(4)+=8;"
        # ---- integer arithmetic
        if m in ALU:
            sz = op[0].size * 8
            return wr_int(ins, op[0], "%s(c,%d,%s,%s)" % (ALU[m], sz, rd_int(ins, op[0]), rd_int(ins, op[1], sz)), sz)
        if m == "cmp":
            sz = op[0].size * 8; return "op_sub(c,%d,%s,%s);" % (sz, rd_int(ins, op[0]), rd_int(ins, op[1], sz))
        if m == "test":
            sz = op[0].size * 8; return "op_and(c,%d,%s,%s);" % (sz, rd_int(ins, op[0]), rd_int(ins, op[1], sz))
        if m == "inc": return wr_int(ins, op[0], "op_inc(c,%d,%s)" % (op[0].size * 8, rd_int(ins, op[0])))
        if m == "dec": return wr_int(ins, op[0], "op_dec(c,%d,%s)" % (op[0].size * 8, rd_int(ins, op[0])))
        if m == "neg": return wr_int(ins, op[0], "op_neg(c,%d,%s)" % (op[0].size * 8, rd_int(ins, op[0])))
        if m == "not": return wr_int(ins, op[0], "~(%s)" % rd_int(ins, op[0]))
        if m in SHIFT:
            cnt = rd_int(ins, op[1], 8) if op[1].type != x86.X86_OP_IMM else "%d" % op[1].imm
            return wr_int(ins, op[0], "%s(c,%d,%s,(unsigned)(%s))" % (SHIFT[m], op[0].size * 8, rd_int(ins, op[0]), cnt))
        if m == "imul":
            sz = op[0].size * 8
            if len(op) == 1:
                if sz == 64: return "{ __int128 p=(__int128)(int64_t)R(0)*(int64_t)%s; R(0)=(uint64_t)p; R(2)=(uint64_t)(p>>64); c->cf=c->of=(p!=(__int128)(int64_t)R(0)); }" % rd_int(ins, op[0])
                if sz == 32: return "{ int64_t p=(int64_t)(int32_t)R(0)*(int64_t)(int32_t)%s; R(0)=(uint64_t)p&0xFFFFFFFFULL; R(2)=((uint64_t)p>>32)&0xFFFFFFFFULL; c->cf=c->of=(p!=(int64_t)(int32_t)p); }" % rd_int(ins, op[0])
                return None
            if len(op) == 2: return wr_int(ins, op[0], "op_imul2(c,%d,%s,%s)" % (sz, rd_int(ins, op[0]), rd_int(ins, op[1], sz)))
            return wr_int(ins, op[0], "op_imul2(c,%d,%s,0x%xULL)" % (sz, rd_int(ins, op[1]), op[2].imm & ((1 << sz) - 1)))
        if m == "mul":
            sz = op[0].size * 8
            if sz == 64: return "{ unsigned __int128 p=(unsigned __int128)R(0)*%s; R(0)=(uint64_t)p; R(2)=(uint64_t)(p>>64); c->cf=c->of=(R(2)!=0); }" % rd_int(ins, op[0])
            if sz == 32: return "{ uint64_t p=(R(0)&0xFFFFFFFFULL)*%s; R(0)=p&0xFFFFFFFFULL; R(2)=p>>32; c->cf=c->of=(R(2)!=0); }" % rd_int(ins, op[0])
            return None
        if m in ("div", "idiv"):
            sz = op[0].size * 8; s = rd_int(ins, op[0])
            if m == "div":
                if sz == 64: return "{ unsigned __int128 n=((unsigned __int128)R(2)<<64)|R(0); uint64_t d=%s; if(!d) jp8_trap(c,0x%x,\"div0\"); R(0)=(uint64_t)(n/d); R(2)=(uint64_t)(n%%d); }" % (s, rva)
                if sz == 32: return "{ uint64_t n=((R(2)&0xFFFFFFFFULL)<<32)|(R(0)&0xFFFFFFFFULL); uint64_t d=%s; if(!d) jp8_trap(c,0x%x,\"div0\"); R(0)=(n/d)&0xFFFFFFFFULL; R(2)=(n%%d)&0xFFFFFFFFULL; }" % (s, rva)
            else:
                if sz == 64: return "{ __int128 n=((__int128)(int64_t)R(2)<<64)|(unsigned __int128)R(0); int64_t d=(int64_t)%s; if(!d) jp8_trap(c,0x%x,\"div0\"); R(0)=(uint64_t)(int64_t)(n/d); R(2)=(uint64_t)(int64_t)(n%%d); }" % (s, rva)
                if sz == 32: return "{ int64_t n=(int64_t)(((R(2)&0xFFFFFFFFULL)<<32)|(R(0)&0xFFFFFFFFULL)); int64_t d=(int64_t)(int32_t)%s; if(!d) jp8_trap(c,0x%x,\"div0\"); R(0)=((uint64_t)(n/d))&0xFFFFFFFFULL; R(2)=((uint64_t)(n%%d))&0xFFFFFFFFULL; }" % (s, rva)
            return None
        if m in ("bsr", "bsf"):
            sz = op[0].size * 8; src = rd_int(ins, op[1], sz)
            body = "(63-__builtin_clzll(a0))" if m == "bsr" else "__builtin_ctzll(a0)"
            return "a0=%s; c->zf=(a0==0); if (a0) { %s }" % (src, wr_int(ins, op[0], body))
        if m in ("tzcnt", "lzcnt", "popcnt"):
            sz = op[0].size * 8; src = rd_int(ins, op[1], sz)
            body = {"tzcnt": "(a0?__builtin_ctzll(a0):%d)" % sz, "lzcnt": "(a0?__builtin_clzll(a0)-(64-%d):%d)" % (sz, sz), "popcnt": "__builtin_popcountll(a0)"}[m]
            return "a0=%s; c->zf=(a0==0); c->cf=(a0==0); %s" % (src, wr_int(ins, op[0], body))
        if m in ("bt", "bts", "btr", "btc"):
            sz = op[0].size * 8; bit = rd_int(ins, op[1], 8) if op[1].type != x86.X86_OP_IMM else "%d" % op[1].imm
            if op[0].type == x86.X86_OP_MEM and op[1].type == x86.X86_OP_REG: return None   # bit-string form over memory: not needed
            base = "op_bt(c,%d,%s,%s)" % (sz, rd_int(ins, op[0]), bit)
            if m == "bt": return base + ";"
            upd = {"bts": "(%s)|(1ULL<<((%s)&%d))", "btr": "(%s)&~(1ULL<<((%s)&%d))", "btc": "(%s)^(1ULL<<((%s)&%d))"}[m] % (rd_int(ins, op[0]), bit, sz - 1)
            return base + "; " + wr_int(ins, op[0], upd)
        # ---- SSE data movement
        if m in ("movaps", "movups", "movapd", "movupd", "movdqa", "movdqu", "movntps", "movntpd", "movntdq", "lddqu"):
            if op[0].type == x86.X86_OP_REG and op[1].type == x86.X86_OP_REG: return "c->x[%d]=c->x[%d];" % (reg(ins, op[0].reg)[0], reg(ins, op[1].reg)[0])
            if op[0].type == x86.X86_OP_REG: return "jp8_ldx(&c->x[%d],%s);" % (reg(ins, op[0].reg)[0], ea(ins, op[1]))
            return "jp8_stx(%s,&c->x[%d]);" % (ea(ins, op[0]), reg(ins, op[1].reg)[0])
        if m == "movss" or m == "movsd" and len(op) == 2 and (op[0].type == x86.X86_OP_REG and reg(ins, op[0].reg)[1] == 128 or op[1].type == x86.X86_OP_REG and reg(ins, op[1].reg)[1] == 128):
            lane = "u" if m == "movss" else "q"; A = "XU" if m == "movss" else "XQ"
            if op[0].type == x86.X86_OP_REG and op[1].type == x86.X86_OP_REG:
                return "%s(%d,0)=%s(%d,0);" % (A, reg(ins, op[0].reg)[0], A, reg(ins, op[1].reg)[0])
            if op[0].type == x86.X86_OP_REG:
                d = reg(ins, op[0].reg)[0]
                if m == "movss": return "XU(%d,0)=%s; XU(%d,1)=0; XU(%d,2)=0; XU(%d,3)=0;" % (d, xsrc(ins, op[1], "u"), d, d, d)
                return "XQ(%d,0)=%s; XQ(%d,1)=0;" % (d, xsrc(ins, op[1], "q"), d)
            s = reg(ins, op[1].reg)[0]
            return ("M32(%s)=XU(%d,0);" if m == "movss" else "M64(%s)=XQ(%d,0);") % (ea(ins, op[0]), s)
        if m in ("movd", "movq"):
            w = 32 if m == "movd" else 64
            if op[0].type == x86.X86_OP_REG and reg(ins, op[0].reg)[1] == 128:
                d = reg(ins, op[0].reg)[0]
                if op[1].type == x86.X86_OP_REG and reg(ins, op[1].reg)[1] == 128:
                    return "XQ(%d,0)=XQ(%d,0); XQ(%d,1)=0;" % (d, reg(ins, op[1].reg)[0], d)
                return ("XU(%d,0)=(uint32_t)(%s); XU(%d,1)=0; XQ(%d,1)=0;" if w == 32 else "XQ(%d,0)=%s; XQ(%d,1)=0;") % ((d, rd_int(ins, op[1], w), d, d) if w == 32 else (d, rd_int(ins, op[1], w), d))
            s = reg(ins, op[1].reg)[0]
            return wr_int(ins, op[0], "XU(%d,0)" % s if w == 32 else "XQ(%d,0)" % s, w)
        if m in ("movlps", "movlpd"):
            if op[0].type == x86.X86_OP_REG: return "XQ(%d,0)=M64(%s);" % (reg(ins, op[0].reg)[0], ea(ins, op[1]))
            return "M64(%s)=XQ(%d,0);" % (ea(ins, op[0]), reg(ins, op[1].reg)[0])
        if m in ("movhps", "movhpd"):
            if op[0].type == x86.X86_OP_REG: return "XQ(%d,1)=M64(%s);" % (reg(ins, op[0].reg)[0], ea(ins, op[1]))
            return "M64(%s)=XQ(%d,1);" % (ea(ins, op[0]), reg(ins, op[1].reg)[0])
        if m == "movlhps": return "XQ(%d,1)=XQ(%d,0);" % (reg(ins, op[0].reg)[0], reg(ins, op[1].reg)[0])
        if m == "movhlps": return "XQ(%d,0)=XQ(%d,1);" % (reg(ins, op[0].reg)[0], reg(ins, op[1].reg)[0])
        if m in ("unpcklps", "unpckhps", "unpcklpd", "unpckhpd", "punpckldq", "punpckhdq", "punpcklqdq", "punpckhqdq"):
            d = reg(ins, op[0].reg)[0]; s = xsrc(ins, op[1], "X")
            if m in ("unpcklps", "punpckldq"): return "t0=%s; t1=c->x[%d]; XU(%d,0)=t1.u[0]; XU(%d,1)=t0.u[0]; XU(%d,2)=t1.u[1]; XU(%d,3)=t0.u[1];" % (s, d, d, d, d, d)
            if m in ("unpckhps", "punpckhdq"): return "t0=%s; t1=c->x[%d]; XU(%d,0)=t1.u[2]; XU(%d,1)=t0.u[2]; XU(%d,2)=t1.u[3]; XU(%d,3)=t0.u[3];" % (s, d, d, d, d, d)
            if m in ("unpcklpd", "punpcklqdq"): return "t0=%s; XQ(%d,1)=t0.q[0];" % (s, d)
            return "t0=%s; XQ(%d,0)=XQ(%d,1); XQ(%d,1)=t0.q[1];" % (s, d, d, d)
        if m in ("shufps", "shufpd", "pshufd"):
            d = reg(ins, op[0].reg)[0]; s = xsrc(ins, op[1], "X"); imm = op[2].imm & 0xFF
            if m == "shufps":
                return "t0=c->x[%d]; t1=%s; XU(%d,0)=t0.u[%d]; XU(%d,1)=t0.u[%d]; XU(%d,2)=t1.u[%d]; XU(%d,3)=t1.u[%d];" % (d, s, d, imm & 3, d, (imm >> 2) & 3, d, (imm >> 4) & 3, d, (imm >> 6) & 3)
            if m == "pshufd":
                return "t1=%s; XU(%d,0)=t1.u[%d]; XU(%d,1)=t1.u[%d]; XU(%d,2)=t1.u[%d]; XU(%d,3)=t1.u[%d];" % (s, d, imm & 3, d, (imm >> 2) & 3, d, (imm >> 4) & 3, d, (imm >> 6) & 3)
            return "t0=c->x[%d]; t1=%s; XQ(%d,0)=t0.q[%d]; XQ(%d,1)=t1.q[%d];" % (d, s, d, imm & 1, d, (imm >> 1) & 1)
        if m == "movmskps":
            s = reg(ins, op[1].reg)[0]; return wr_int(ins, op[0], "((XU(%d,0)>>31)|((XU(%d,1)>>31)<<1)|((XU(%d,2)>>31)<<2)|((XU(%d,3)>>31)<<3))" % (s, s, s, s), 32)
        if m == "movmskpd":
            s = reg(ins, op[1].reg)[0]; return wr_int(ins, op[0], "((XQ(%d,0)>>63)|((XQ(%d,1)>>63)<<1))" % (s, s), 32)
        # ---- SSE arithmetic
        if m in FOPS:
            k, o = FOPS[m]; d = reg(ins, op[0].reg)[0]; A = "XF" if k == "f" else "XD"
            return "%s(%d,0)=JP8_%s%s(%s(%d,0),%s);" % (A, d, OPM[o], "SS" if k == "f" else "SD", A, d, xsrc(ins, op[1], k))
        if m in POPS:
            k, o, n = POPS[m]; d = reg(ins, op[0].reg)[0]; A = "XF" if k == "f" else "XD"
            return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("%s(%d,%d)=JP8_%s%s(%s(%d,%d),t1.%s[%d]);" % (A, d, l, OPM[o], "SS" if k == "f" else "SD", A, d, l, k, l) for l in range(n))
        if m in BITOPS:
            d = reg(ins, op[0].reg)[0]; return "t1=%s; XQ(%d,0)%s=t1.q[0]; XQ(%d,1)%s=t1.q[1];" % (xsrc(ins, op[1], "X"), d, BITOPS[m], d, BITOPS[m])
        if m in ("andnps", "andnpd", "pandn"):
            d = reg(ins, op[0].reg)[0]; return "t1=%s; XQ(%d,0)=~XQ(%d,0)&t1.q[0]; XQ(%d,1)=~XQ(%d,1)&t1.q[1];" % (xsrc(ins, op[1], "X"), d, d, d, d)
        if m in ("minss", "maxss", "minsd", "maxsd"):
            d = reg(ins, op[0].reg)[0]; k = "f" if m.endswith("ss") else "d"; A = "XF" if k == "f" else "XD"
            return "%s(%d,0)=%s_s%s(%s(%d,0),%s);" % (A, d, "fmin" if m.startswith("min") else "fmax", "s" if k == "f" else "d", A, d, xsrc(ins, op[1], k))
        if m in ("minps", "maxps"):
            d = reg(ins, op[0].reg)[0]; fn = "fmin_ss" if m == "minps" else "fmax_ss"
            return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("XF(%d,%d)=%s(XF(%d,%d),t1.f[%d]);" % (d, l, fn, d, l, l) for l in range(4))
        if m in ("minpd", "maxpd"):
            d = reg(ins, op[0].reg)[0]; fn = "fmin_sd" if m == "minpd" else "fmax_sd"
            return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("XD(%d,%d)=%s(XD(%d,%d),t1.d[%d]);" % (d, l, fn, d, l, l) for l in range(2))
        if m == "sqrtss": return "XF(%d,0)=JP8_SQRTSS(%s);" % (reg(ins, op[0].reg)[0], xsrc(ins, op[1], "f"))
        if m == "sqrtsd": return "XD(%d,0)=JP8_SQRTSD(%s);" % (reg(ins, op[0].reg)[0], xsrc(ins, op[1], "d"))
        if m == "sqrtps":
            d = reg(ins, op[0].reg)[0]; return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("XF(%d,%d)=JP8_SQRTSS(t1.f[%d]);" % (d, l, l) for l in range(4))
        if m in ("comiss", "ucomiss"): return "cmp_f(c,XF(%d,0),%s);" % (reg(ins, op[0].reg)[0], xsrc(ins, op[1], "f"))
        if m in ("comisd", "ucomisd"): return "cmp_d(c,XD(%d,0),%s);" % (reg(ins, op[0].reg)[0], xsrc(ins, op[1], "d"))
        if m in ("cmpss", "cmpsd") and len(op) == 3:
            d = reg(ins, op[0].reg)[0]; p = op[2].imm & 7
            if m == "cmpss": return "XU(%d,0)=cmp_pred_f(%d,XF(%d,0),%s);" % (d, p, d, xsrc(ins, op[1], "f"))
            return "XQ(%d,0)=cmp_pred_d(%d,XD(%d,0),%s);" % (d, p, d, xsrc(ins, op[1], "d"))
        if m in ("cmpps", "cmppd") and len(op) == 3:
            d = reg(ins, op[0].reg)[0]; p = op[2].imm & 7
            if m == "cmpps": return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("XU(%d,%d)=cmp_pred_f(%d,XF(%d,%d),t1.f[%d]);" % (d, l, p, d, l, l) for l in range(4))
            return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("XQ(%d,%d)=cmp_pred_d(%d,XD(%d,%d),t1.d[%d]);" % (d, l, p, d, l, l) for l in range(2))
        # ---- conversions
        if m == "cvtss2sd": return "XD(%d,0)=JP8_CVTSS2SD(%s);" % (reg(ins, op[0].reg)[0], xsrc(ins, op[1], "f"))
        if m == "cvtsd2ss": return "XF(%d,0)=JP8_CVTSD2SS(%s);" % (reg(ins, op[0].reg)[0], xsrc(ins, op[1], "d"))
        if m == "cvtps2pd":
            d = reg(ins, op[0].reg)[0]
            src = "t1=c->x[%d];" % reg(ins, op[1].reg)[0] if op[1].type == x86.X86_OP_REG else "t1.q[0]=M64(%s);" % ea(ins, op[1])
            return "%s XD(%d,0)=JP8_CVTSS2SD(t1.f[0]); XD(%d,1)=JP8_CVTSS2SD(t1.f[1]);" % (src, d, d)
        if m == "cvtpd2ps":
            d = reg(ins, op[0].reg)[0]
            return "t1=%s; XF(%d,0)=JP8_CVTSD2SS(t1.d[0]); XF(%d,1)=JP8_CVTSD2SS(t1.d[1]); XQ(%d,1)=0;" % (xsrc(ins, op[1], "X"), d, d, d)
        if m == "cvtsi2ss":
            d = reg(ins, op[0].reg)[0]; sz = op[1].size * 8
            return "XF(%d,0)=(float)(int%d_t)(%s);" % (d, sz, rd_int(ins, op[1], sz))
        if m == "cvtsi2sd":
            d = reg(ins, op[0].reg)[0]; sz = op[1].size * 8
            return "XD(%d,0)=(double)(int%d_t)(%s);" % (d, sz, rd_int(ins, op[1], sz))
        if m in ("cvttss2si", "cvtss2si", "cvttsd2si", "cvtsd2si"):
            sz = op[0].size * 8; k = "f" if "ss2" in m else "d"; t = "t" if m.startswith("cvtt") else "r"
            fn = "cvt%s_%s2%s" % (t, k, "i" if sz == 32 else "l")
            return wr_int(ins, op[0], "(uint64_t)(int%d_t)%s(%s)" % (sz, fn, xsrc(ins, op[1], k)), sz)
        if m == "cvtdq2ps":
            d = reg(ins, op[0].reg)[0]; return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("XF(%d,%d)=(float)t1.i[%d];" % (d, l, l) for l in range(4))
        if m == "cvtdq2pd":
            d = reg(ins, op[0].reg)[0]
            src = "t1=c->x[%d];" % reg(ins, op[1].reg)[0] if op[1].type == x86.X86_OP_REG else "t1.q[0]=M64(%s);" % ea(ins, op[1])
            return "%s XD(%d,0)=(double)t1.i[0]; XD(%d,1)=(double)t1.i[1];" % (src, d, d)
        if m in ("cvtps2dq", "cvttps2dq"):
            d = reg(ins, op[0].reg)[0]; fn = "cvtr_f2i" if m == "cvtps2dq" else "cvtt_f2i"
            return "t1=%s; " % xsrc(ins, op[1], "X") + " ".join("XI(%d,%d)=%s(t1.f[%d]);" % (d, l, fn, l) for l in range(4))
        if m in ("cvtpd2dq", "cvttpd2dq"):
            d = reg(ins, op[0].reg)[0]; fn = "cvtr_d2i" if m == "cvtpd2dq" else "cvtt_d2i"
            return "t1=%s; XI(%d,0)=%s(t1.d[0]); XI(%d,1)=%s(t1.d[1]); XQ(%d,1)=0;" % (xsrc(ins, op[1], "X"), d, fn, d, fn, d)
        # ---- packed integer
        if m in ("paddd", "psubd", "pcmpeqd", "pcmpgtd", "paddq", "psubq", "pmuludq"):
            d = reg(ins, op[0].reg)[0]; s = xsrc(ins, op[1], "X")
            if m == "paddd": return "t1=%s; " % s + " ".join("XU(%d,%d)+=t1.u[%d];" % (d, l, l) for l in range(4))
            if m == "psubd": return "t1=%s; " % s + " ".join("XU(%d,%d)-=t1.u[%d];" % (d, l, l) for l in range(4))
            if m == "pcmpeqd": return "t1=%s; " % s + " ".join("XU(%d,%d)=(XU(%d,%d)==t1.u[%d])?0xFFFFFFFFu:0;" % (d, l, d, l, l) for l in range(4))
            if m == "pcmpgtd": return "t1=%s; " % s + " ".join("XU(%d,%d)=(XI(%d,%d)>t1.i[%d])?0xFFFFFFFFu:0;" % (d, l, d, l, l) for l in range(4))
            if m == "paddq": return "t1=%s; XQ(%d,0)+=t1.q[0]; XQ(%d,1)+=t1.q[1];" % (s, d, d)
            if m == "psubq": return "t1=%s; XQ(%d,0)-=t1.q[0]; XQ(%d,1)-=t1.q[1];" % (s, d, d)
            if m == "pmuludq": return "t1=%s; XQ(%d,0)=(uint64_t)XU(%d,0)*t1.u[0]; XQ(%d,1)=(uint64_t)XU(%d,2)*t1.u[2];" % (s, d, d, d, d)
        if m in ("psrld", "pslld", "psrad", "psrlq", "psllq", "psrldq", "pslldq"):
            d = reg(ins, op[0].reg)[0]
            if op[1].type == x86.X86_OP_IMM: cnt = "%d" % op[1].imm
            else: cnt = "((XQ(%d,0)>63)?64:(unsigned)XQ(%d,0))" % (reg(ins, op[1].reg)[0], reg(ins, op[1].reg)[0])
            if m == "psrld": return "{ unsigned n=%s; if(n>31){XQ(%d,0)=0;XQ(%d,1)=0;} else { " % (cnt, d, d) + " ".join("XU(%d,%d)>>=n;" % (d, l) for l in range(4)) + " } }"
            if m == "pslld": return "{ unsigned n=%s; if(n>31){XQ(%d,0)=0;XQ(%d,1)=0;} else { " % (cnt, d, d) + " ".join("XU(%d,%d)<<=n;" % (d, l) for l in range(4)) + " } }"
            if m == "psrad": return "{ unsigned n=%s; if(n>31)n=31; " % cnt + " ".join("XI(%d,%d)>>=n;" % (d, l) for l in range(4)) + " }"
            if m == "psrlq": return "{ unsigned n=%s; if(n>63){XQ(%d,0)=0;XQ(%d,1)=0;} else { XQ(%d,0)>>=n; XQ(%d,1)>>=n; } }" % (cnt, d, d, d, d)
            if m == "psllq": return "{ unsigned n=%s; if(n>63){XQ(%d,0)=0;XQ(%d,1)=0;} else { XQ(%d,0)<<=n; XQ(%d,1)<<=n; } }" % (cnt, d, d, d, d)
            n = op[1].imm
            if m == "psrldq": return "{ t0=c->x[%d]; memset(&c->x[%d],0,16); if(%d<16) memcpy(c->x[%d].b,t0.b+%d,16-%d); }" % (d, d, n, d, n, n)
            return "{ t0=c->x[%d]; memset(&c->x[%d],0,16); if(%d<16) memcpy(c->x[%d].b+%d,t0.b,16-%d); }" % (d, d, n, d, n, n)
        if m == "pmovmskb":
            s = reg(ins, op[1].reg)[0]; return wr_int(ins, op[0], "(" + "|".join("((XU(%d,%d)>>%d&1)<<%d)" % (s, b // 4, (b % 4) * 8 + 7, b) for b in range(16)) + ")", 32)
        # ---- MXCSR
        if m == "ldmxcsr": return "JP8_LDMXCSR(c,M32(%s));" % ea(ins, op[0])
        if m == "stmxcsr": return "M32(%s)=JP8_STMXCSR(c);" % ea(ins, op[0])
        if m in ("roundss", "roundsd", "roundps", "roundpd"):
            d = reg(ins, op[0].reg)[0]; mode = op[2].imm & 7
            fn = {0: "nearbyint", 1: "floor", 2: "ceil", 3: "trunc"}.get(mode if not (mode & 4) else -1)
            if fn is None: return None
            if m == "roundss": return "XF(%d,0)=%sf(JP8_DAZF(%s));" % (d, fn, xsrc(ins, op[1], "f"))
            if m == "roundsd": return "XD(%d,0)=%s(JP8_DAZD(%s));" % (d, fn, xsrc(ins, op[1], "d"))
            return None
        return None

def main():
    args = sys.argv[1:]
    out = args[0]; roots = [int(x, 16) for x in args[1].split(",")]
    dyn = {}; name = "voice"
    for k, a in enumerate(args):                       # every --dyn file is merged (a union of reaches)
        if a == "--dyn":
            for site, ts in json.load(open(args[k + 1])).get("indirect", {}).items():
                dyn[site] = sorted(set(dyn.get(site, [])) | set(ts))
    alloc = int(args[args.index("--alloc") + 1], 16) if "--alloc" in args else None
    if "--name" in args: name = args[args.index("--name") + 1]
    tooth = int(args[args.index("--tooth") + 1], 16) if "--tooth" in args else None
    trace = "--trace" in args
    # dynamic targets of CALL sites are function entries; targets of JMP sites are interior labels (jump tables)
    extra = sorted(set(int(t, 16) for site, ts in dyn.items() for t in ts
                       if (dis(int(site, 16)) is not None and dis(int(site, 16)).mnemonic.replace("bnd ", "") == "call")))
    funcs = discover(roots + extra, dyn)
    if alloc is not None and alloc in funcs: funcs[alloc]["alloc"] = True
    L = Lifter(funcs, name, tooth, trace); src = L.lift()
    if tooth is not None and not L.tooth_done: raise SystemExit("--tooth rva 0x%x was not lifted" % tooth)
    open(out, "w").write(src)
    ninstr = sum(len(F["insns"]) for F in funcs.values())
    print("lifted %d functions, %d instructions -> %s (%d lines); unsupported (trap) %d: %s" % (
        len(funcs), ninstr, out, src.count("\n"), sum(L.unsup.values()), ", ".join("%s:%d" % kv for kv in L.unsup.most_common(40))))

if __name__ == "__main__":
    main()
