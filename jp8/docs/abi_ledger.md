# gen/abi_ledger.md -- JUPITER-8 PLUG-OUT oracle entry points (PORT_PIPELINE step 2)
Binary: truth/92e652dd-JUPITER-8VST3_64bit.vst3 (sha256 5a3746a8..., truth/SHA256SUMS). IB 0x180000000.
Tool: tools/verify/abi_check.py (every register below is READ-BEFORE-WRITTEN in the callee head;
machine-readable twin: gen/abi_ledger.json). Label: READ (static disassembly) unless PROVEN by execution.

## Which vtable is the engine (the first thing that had to be settled)
The JX-3P oracle's ENGINE_VTBL (jx_emu.py 0xA15B88) is RTTI-named `.?AVCWaveGen@@` (work/xmap8.py).
The JP8 twin is CWaveGen at rva **0xA704B0** (36 slots; JX has 38, so two slots are gone and the
NOTE/HOSTPARAM slot numbers shift by -0x10: roles were matched by STRUCTURE, then abi_check).
`CJp8Sim` (vtable 0xA1B678, 17 slots) is the PER-UNIT STATE class (every BUILD state block's first
qword == 0xA1B678, PROVEN recon boot), the twin of `CJx3pSim` 0x9BFD60 -- NOT the host entry set:
its slot 0x38 (0x426F70) is `xor al,al; ret`, slot 0x80 (0x426F50) is `ret`, slot 0x08 (0x3E3B40)
is a 3-arg table setter (edx<6), slot 0x18 (0x3E3B70) writes [rcx+0xA5BF70]=0x100. The
"CJp8Sim = BUILD/SETSR/RENDER/..." reading is REFUTED (READ, disassembly above).

## The ledger (CWaveGen slots; rcx = HOST, the CWaveGen object)
| Entry | rva | slot | args READ (abi_check) | JX twin | note |
|---|---|---|---|---|---|
| BUILD | 0x445020 | 0x08 | rcx | 0x3F8610 | `mov r15d,9; mov ecx,0xA9C0C0` -> 9 units x STATE_SZ 0xA9C0C0 (PROVEN: 9 allocs of 0xA9C0C0) |
| SETSR | 0x4464F0 | 0x18 | rcx, **xmm1 as FLOAT** (movaps at 0x4464FE) | 0x3F9970 | playbook 87 holds: rate is a float in xmm1, NOT rdx. PROVEN: HOST+8 reads 44100.0 after the call |
| RENDER (host process) | 0x445DC0 | 0x38 | rcx, r9 (+ stack arg6 nframes at [rbp+0x168]) | 0x3F9220 | needs a CONSTRUCTED CWaveGen (channel vectors +0x2E0.., assign objects); zero-filled HOST faults. NOT the oracle drive (JX never used it either) |
| HOSTPARAM | 0x4465B0 | 0x60 | rcx, edx=host id, r8d=value | 0x3F9A30 (slot 0x70) | host-id map root .data 0xD22478 (rip-relative load); map after static init = {0:18, 1:19, 2:20} (PROVEN), same 3 ids as the JX |
| NOTEOFF | 0x445C90 | 0x68 | rcx, dl=note (movzx), r8b=vel (movzx) | 0x3F90F0 (slot 0x78) | |
| NOTEON | 0x445CF0 | 0x70 | rcx, dl=note (movzx), r8b=vel (movzx) | 0x3F9150 (slot 0x80) | |
| DISPATCH | 0x437630 | Plugin slot 11 (0x58) of CPrmDSPJp8Plugin vtable 0xA54158 | rcx=proc, rdx=id (cmp), r8=flag, r9=value | 0x3EBB00 | same `cmp edx,0x138` jump-table idiom |
| ASG_NOTIFY | 0x37CD80 | CAssignJp8 vtbl 0x9F3158 slot 1 | rcx=assign obj, edx=what (cmp) | 0x356BF0 | assign objects' vptr at boot = 0x9F31F0 (PROVEN) -- a DERIVED class of the 0x9F3158 table; UNVERIFIED that slot 1 of 0x9F31F0 is the same function (see status D3) |
| VOICE_WRAP | 0x3F80B0 | plain fn | rcx=unit state, [edx=voice idx, passed through], r8=&{pMain,pSub} | 0x377080 | BYTE-FOR-BYTE the JX idiom: `cmp byte [rcx+0x14],0`, latch [rcx+0xA9C0B8]--, zero both outs, `jmp 0x440180` (tail). The host's per-unit process calls it at 0x44575B with rcx=[rsi+0x18], edx=r15d, r8=rsi+0x20 (READ) |
| MASTER_WRAP | 0x3F8040 | plain fn | rcx=state[8], rdx=a2[16] (passed through), r8=&{pL,pR} | 0x377010 | RENDER calls it per sample at 0x446229 with rcx=[HOST+0x2A0]=state[8] (READ) |

## HOST record (READ from BUILD: `lea rsi,[rcx+0xA8]`; [rsi-8]=state [rsi+8]=proc [rsi+0x10]=assign, stride 64)
state[i] @ HOST+0xA0+64i, proc[i] @ HOST+0xB0+64i, assign[i] @ HOST+0xB8+64i (JX: +80/+96/+104). HOST+8 = float SR.
LATCH_OFF 0xA9C0B8 (reads 960 at clean boot, PROVEN). Ramp header: arr @st+0x58, id list [st+0x70, st+0x78), 40-byte slots
(target @+0, limit @+0x14, active @+0x1C) -- 353 active ramps per unit at clean boot (PROVEN), snap law = JX/JUNO.
XC static-init table (0x9B8658, 0x9BA0C0): 845 entries, 841 ok, 3 skipped by address (0xB7244, 0xB6DD0, 0x5C83C0 -- the
JX trio's twins), 1 stray page at ctor #1 (0xB720C, the JX template condition). Runtime .data tail [0xD20A00,0xD2BBE0): 3441 B filled.

## Addendum 2026-09-22 (third agent) -- what the ledger could not show, PROVEN by execution
- DISPATCH 0x437630 r8 = flag: flag 1 applies r9 = value in the ENGINE frame at once (id 769 VCO2 SUB
  RANGE, engine DB -36..36: value 0 -> pitch 261.36 Hz for key 60, value 36 -> +36 semitones). flag 0
  left the pitch cell untouched in this drive (gen/d2_2_*_0.log). The factory bank stores the RAW frame
  (Script.xml int2x4 0..72, default 36), so the recall adds the engine-DB min (gen/jp8_emu.py JP8.recall).
- SETSR 0x4464F0: per unit it calls proc vtable 0x18, 0x43A930(proc, edi = int(rate)), 0x440450(state,
  xmm1 = float rate) and proc vtable 0x28; 0x440450 stores [state+0x10] = rate, rewrites every ramp
  slot's rate at +0x18 and tail-calls CJp8Sim slots 0x50 (0x3F8240) and 0x58 (0x412890). READ.
- 0x3F8240 (CJp8Sim slot 0x50, 11,753 instructions) begins `cvttss2si eax,[rcx+0x10]; cmp eax,0xAC44;
  jne generic`: a 44100-SPECIALISED constant set (rate ratio cell state+0x8B0 = 96000/44100 = 2.17687,
  written at 0x4020FE from [rsp+0x16C8]) versus a generic set whose ratio is 1.0 (96000 reference).
  PROVEN by gen/jp8_srtrace.py: +0x8B0 = 2.17687 at 44100 and 1.0 at 12000/22050/24000/48000/88200/96000.
  Consequence for the per-unit drive (VOICE_WRAP once per host sample): pitch right at 44100 and 96000,
  f/96000 per sample elsewhere (48000 = one octave low). The JX shows the same law (ctrl_jx_*.log);
  the host layer (RENDER 0x445DC0) must be what serves other rates. = defect D3 in JP8_STATUS.md.
- Instruction counting: a UC_HOOK_BLOCK added AFTER the render blocks were translated is not called for
  cached TBs (listen_p0_n60.log: 343 instr/sample, 90x low). Flush (uc.ctl_flush_tb) + UC_HOOK_CODE.
