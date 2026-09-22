#!/usr/bin/env python3
"""jp8_reach.py -- STATIC reach of a render entry (recursive descent with capstone): every function reached by
direct call, every block by direct jump, MSVC x64 jump tables ({lea rB,[rip+IB]; mov eA,[rB+rI*4+tbl]; add rA,rB; jmp rA}
resolved from the image), indirect call/jmp sites listed, mnemonic histogram, and the instructions the lifter must
support. Writes <out>.json. usage: jp8_reach.py <root rva hex> <out.json> [max_funcs]"""
import sys, os, json, struct, collections
import pefile, capstone
from capstone import x86
BIN=os.path.join(os.path.dirname(os.path.abspath(__file__)),"..","truth","JUPITER-8VST3_64bit.vst3")
pe=pefile.PE(BIN); IB=pe.OPTIONAL_HEADER.ImageBase; IMG=pe.get_memory_mapped_image()
text=[s for s in pe.sections if s.Name.startswith(b'.text')][0]; CLO=text.VirtualAddress; CHI=CLO+text.Misc_VirtualSize
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64); md.detail=True
root=int(sys.argv[1],16); out=sys.argv[2]; maxf=int(sys.argv[3]) if len(sys.argv)>3 else 100000
def dis(rva):
    for ins in md.disasm(bytes(IMG[rva:rva+16]),IB+rva): return ins
    return None
funcs={}          # rva -> {blocks:{rva:[insn rvas]}, calls:set, indirect:[...]}
work=[root]; seen_f=set()
mnem=collections.Counter(); indirect=[]; jtabs={}; unsup=collections.Counter(); ninstr=0
def find_jumptable(ins_list, jmp_ins):
    """look back up to 12 instructions for the MSVC pattern: lea rB,[rip+X] (X == image base) ; mov eA,[rB+rI*4+disp] ; add rA,rB"""
    base_reg=None; tbl=None; idx_reg=None
    for prev in reversed(ins_list[-12:]):
        if prev.mnemonic=="mov" and len(prev.operands)==2 and prev.operands[1].type==x86.X86_OP_MEM and prev.operands[1].mem.scale==4 and tbl is None:
            m=prev.operands[1].mem; tbl=m.disp; base_reg=m.base; idx_reg=m.index
        if prev.mnemonic=="lea" and tbl is not None and prev.operands[0].reg==base_reg:
            m=prev.operands[1].mem
            if m.base==x86.X86_REG_RIP and prev.address+prev.size+m.disp==IB: return tbl
    return None
while work and len(seen_f)<maxf:
    f=work.pop()
    if f in seen_f or not (CLO<=f<CHI): continue
    seen_f.add(f); blocks={}; bwork=[f]; seen_b=set(); calls=set()
    while bwork:
        b=bwork.pop()
        if b in seen_b or not (CLO<=b<CHI): continue
        seen_b.add(b); insns=[]; rva=b
        while True:
            ins=dis(rva)
            if ins is None: unsup["<undecodable@%x>"%rva]+=1; break
            insns.append(ins); mnem[ins.mnemonic]+=1; ninstr+=1
            m=ins.mnemonic; op=ins.operands
            if m=="ret" or m=="int3" or m=="hlt": break
            if m=="jmp":
                if op[0].type==x86.X86_OP_IMM:
                    t=op[0].imm-IB; bwork.append(t)
                    if not (b<=t<b+0x10000) and dis(t) and False: pass
                else:
                    tbl=find_jumptable(insns[:-1],ins)
                    if tbl is not None:
                        # table of 32-bit RVAs; size unknown -> read entries while they land in .text near the jump
                        ents=[]; k=0
                        while k<512:
                            e=struct.unpack_from("<I",IMG,tbl+4*k)[0]
                            if not (CLO<=e<CHI) or abs(e-rva)>0x20000: break
                            ents.append(e); k+=1
                        jtabs["%x"%(ins.address-IB)]=dict(table="%x"%tbl,targets=["%x"%e for e in ents])
                        bwork+=ents
                    else: indirect.append(dict(site="%x"%(ins.address-IB),kind="jmp",text=ins.op_str))
                break
            if m.startswith("j"):
                bwork.append(op[0].imm-IB); bwork.append(rva+ins.size); break
            if m=="call":
                if op[0].type==x86.X86_OP_IMM: t=op[0].imm-IB; calls.add(t); work.append(t)
                else: indirect.append(dict(site="%x"%(ins.address-IB),kind="call",text=ins.op_str,func="%x"%f))
            rva+=ins.size
        blocks["%x"%b]=[("%x"%i.address-IB if False else "%x"%(i.address-IB)) for i in insns]
    funcs["%x"%f]=dict(nblocks=len(blocks),ninstr=sum(len(v) for v in blocks.values()),calls=sorted("%x"%c for c in calls))
print("root 0x%x: %d functions, %d instructions, %d indirect sites (%d call, %d jmp), %d jump tables"%(root,len(funcs),ninstr,len(indirect),
      sum(1 for i in indirect if i["kind"]=="call"),sum(1 for i in indirect if i["kind"]=="jmp"),len(jtabs)))
print("top mnemonics: "+", ".join("%s:%d"%kv for kv in mnem.most_common(60)))
rare=[k for k,v in mnem.items() if k not in ("mov","movss","movaps","addss","mulss","subss","lea","cmp","test","jmp","je","jne","call","ret","add","sub","and","or","xor","push","pop","movsxd","movzx","movsx","cvttss2si","cvtsi2ss","cvtss2sd","cvtsd2ss","cvtps2pd","cvtpd2ps","divss","sqrtss","minss","maxss","comiss","ucomiss","xorps","andps","andnps","orps","shl","shr","sar","imul","inc","dec","jl","jle","jg","jge","jb","jbe","ja","jae","js","jns","cmovl","cmovg","cmovle","cmovge","cmove","cmovne","cmovb","cmova","cmovbe","cmovae","cmovs","cmovns","setne","sete","setl","setg","setle","setge","setb","seta","setbe","setae","neg","not","movd","movq","movups","movdqa","movdqu","nop","cdq","cqo","idiv","div","movsd","addsd","mulsd","subsd","divsd","sqrtsd","cvttsd2si","cvtsi2sd","comisd","ucomisd","xorpd","andpd","andnpd","orpd","minsd","maxsd","unpcklps","unpcklpd","shufps","pshufd","pxor","pand","por","pandn","paddd","psubd","pcmpeqd","pcmpgtd","psrld","pslld","psrad","psrlq","psllq","cvtdq2ps","cvtps2dq","cvttps2dq","movlhps","movhlps","movlps","movhps","addps","mulps","subps","divps","sqrtps","minps","maxps","cmpps","cmpss","rcpss","rsqrtss","roundss","roundsd","roundps","movmskps","pmovmskb","punpckldq","punpcklqdq","punpckhdq","movhpd","movlpd","bt","bts","btr","xchg","cmpxchg","rol","ror","sbb","adc","cwde","cdqe","cbw","movabs","stosd","stosq","rep","leave","enter","int","cpuid","rdtsc","prefetcht0","prefetchnta","pause","lock","test","bsr","bsf","tzcnt","lzcnt","popcnt","cmpsd","cmpsb","movsb","movsq","clc","stc","cld","std","sahf","lahf","fld","fstp","fild","fistp","fmul","fadd","fsub","fdiv","fxch","fldz","fld1","fabs","fchs","fsqrt","fcomip","fucomip","fnstcw","fldcw","wait","fwait","fnstsw","ftst","frndint","fprem","fprem1","fscale","fyl2x","f2xm1","fpatan","fptan","fsin","fcos","fsincos","fldl2e","fldln2","fldlg2","fldpi","fldl2t")]
print("other mnemonics: "+", ".join("%s:%d"%(k,mnem[k]) for k in sorted(rare)))
json.dump(dict(root="%x"%root,funcs=funcs,indirect=indirect,jump_tables=jtabs,mnemonics=mnem,ninstr=ninstr),open(out,"w"),indent=0)
