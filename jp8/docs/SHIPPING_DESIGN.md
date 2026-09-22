# JP8 SHIPPING DESIGN -- workflow reports (2026-09-22)

Four agents (boot memory census, lifter relocation/WASM/C99 audit, JX shipping mirror, adversarial skeptic), read-only on the repo;
their scratch probes are preserved in `jp8/work/design/`. The SKEPTIC's item 1 (the HOST is never constructed) supersedes the
snap-based plans in reports A and C. Labels as written by the agents.

## Skeptic (read first)

ADVERSARIAL REVIEW: JP8 SHIPPING PLAN (reports A + B + C)

I did not change the repo. I wrote scratch files only in `/tmp/claude-0/-home-user-jn60c99/3260b962-c2aa-553d-b245-0100f4709902/scratchpad/design/adv/`. Each Unicorn run was 12–30 s. Labels: PROVEN = executed, READ = static disassembly, INFERRED = deduction.

**1. CRITICAL: the oracle's HOST is never constructed. The "broken boot" (F1) and the snap both come from the harness, not from the plugin.**
- READ: the processor at 0x33a8db calls factory 0x444fe0. The factory calls `ALLOC(0x8D0)` and then ctor 0x444000.
  - The ctor calls base ctor 0x36c890, which writes `[HOST+8] = 96000.0` (the constant at .rdata 0xA18A44).
  - The ctor also writes `[HOST+0x38] = 8` and vtable 0xA704B0.
  - At 0x33a8ed the processor calls BUILD (vtbl+8) at once. SETSR comes later.
- READ: BUILD reads `movss xmm1,[HOST+8]` (0x44508a, 0x445267) into every `state+0x10` (0x4400f0). `jp8_emu.build()` gives BUILD a zero-filled HOST, so the rate is 0.0.
- PROVEN (`hostctor.py`, patch 2):

| HOST | NaN / inf steps after BUILD | idle master, dry |
|---|---|---|
| zero (today) | 378 / 2,799 | 1.98 clamp, dry 65 |
| `HOST+8 := 96000.0` | 0 / 0 | 1.57e-13, dry 0 |
| real ctor 0x444000 | 0 / 0 | 1.57e-13, dry 0 |

  - With either fix, all 3,555 ramps settle within 4,096 samples with NO snap.
  - The poke and the real ctor give identical output words over 11,096 samples (idle, 2 notes, release).
- PROVEN: report C's T1 drive (zero HOST + snap) is not the plugin.
  - Patch 63: 1,700 of 22,192 master words and 861 dry samples differ from the constructed-HOST drive. The first difference is at the note-on (sample 4096); max |diff| is 8.8e-4.
  - Patches 0 and 2: the outputs are equal, but 7,794 / 8,010 heap dwords differ. All are in the ramp records. The snapped heap keeps 252 NaN and 1,359 inf steps in inactive records.
- READ: SETSR returns at once when the new rate equals `[HOST+8]` (0x446501 `je`). So with a real HOST, SETSR(96000) does nothing. The planned 96 kHz lane runs a path that the plugin never runs.
- Every current reference (layers 1–3, SWEEP_44100, listen2) is on a zero-HOST drive.
- **Fix:**
  - `build()` runs ctor 0x444000.
  - Remove `snap_ramps` and `clear_latch` from all boots and from the product.
  - Add 0x444000 as a lift root. It makes 150,032 allocations and uses eh-vector-ctor callbacks.
  - Run the dynamic reach and all references again.
  - Delete T3 (the snap tooth). Add a HOST tooth: `HOST+8 := 0` must make Control 1 and the NaN census fail.
- JX, INFERRED: JX BUILD 0x3F8610 reads `[r12+8]` in the same way, and `jx_emu.build()` also uses a zero HOST (READ). JX lessons 9 and 11 are probably the same harness defect.

**2. HIGH: the recall law is not the plugin's host path for id 756 (LFO KEY TRIG).**
- READ: HOSTPARAM 0x4465B0 has a per-id switch over ids 707..871 (tables 0x4467e4 / 0x4467b8), for each unit:
  - For 756 it calls direct setter 0x442c30 → 0x442260. That sets mode byte `[[obj+0x18]+0xC] = v` and dirty byte `+0xB = 1`. Then it dispatches (flag 0) and calls notify(4).
  - For 769 it applies `v-36`. This matches the "+min" law.
  - The 62 other pool ids take the generic path, which skips values outside the DB range.
- PROVEN (`lfokt.py`, `recallshape.py`, patch 0): after the oracle recall both bytes stay 0. The host-shaped recall sets them.
  - 18 heap dwords differ.
  - The outputs are equal on a one-note drive of 14k samples. The reader of the bytes was not reached on this drive (INFERRED: LFO retrigger on later notes, or host RENDER).
- Affected patches (LFO KEY TRIG = 1): 0, 3, 7, 12, 18, 20, 24, 25, 26, 28, 32, 39.
- PROVEN: "notify after every write" and "notify once" differ only in these 18 dwords.
- The host map has only 3 entries, but HOSTPARAM handles 707..871, 20, 22 and 665. So the real map is built outside static init (INFERRED). Report A's "the host map can become constants" is wrong for `jp8_param`.
- **Fix:** run the recall and `jp8_param` through HOSTPARAM's own per-id body (for example, enter after the map lookup with esi = engine id, edi = value), on both sides. Tooth: patch 0 with a multi-note LFO drive.

**3. HIGH: the full-chain gate cannot fail on any law that both sides share (playbooks 86 r3, 87 r2, 93).**
- The shared laws are HOST construction, recall law, stub render shape and boot order. Items 1 and 2 pass Run A, Run B, Control 1, T1 and T2.
- Report C's census "0 live ramps with a NaN step" is always green after a snap (the NaN steps stay in inactive records, PROVEN).
- READ: the stub shape matches the worker 0x445670 and the master loop at 0x4461d0. Host RENDER also does three things the stubs never do:
  - It adds nframes to `[assign0+0xB0]` on every block (0x445edc → 0x37df50).
  - It keeps the voice count in step with `[HOST+0x38]`.
  - Voice 0's worker updates a tracker at HOST+0x460 on every sample.
- PROVEN: there were 0 reads of `[assign+0xB0]` in a 10-note drive. The assigner voice count after BUILD is 8, the same as the ctor's value.
- **Fix:**
  - Census every ramp record (live and inactive) for NaN and inf.
  - Add one oracle control through RENDER 0x445DC0 with a worker shim: record the CreateThread entries and run each worker's block at the wait 0x4432e0. It must give the same words as the stubs.
  - State the frozen clock in the scope table (probably the arpeggiator).

**4. HIGH: the boot order changes the sound (this is the plugin's own behaviour).**
- PROVEN (`orderprobe.py`, patch 63, constructed HOST): "SETSR → host_init → recall" and "host_init → recall → SETSR" give different output. 16,382 of 24,576 words differ from sample 4097; max |diff| is 0.176.
- **Fix:** fix the order (ctor → BUILD → SETSR → host_init, then recall), state it in the scope table, and refuse a rate change after a recall.
- Closed, PROVEN (`mxprobe.py`): BUILD and SETSR at MXCSR 0x1F80 or 0x9FC0 give identical heap hashes after BUILD, after SETSR, and at the end of the patch 63 drive. Report C's "BUILD at 1F80, SETSR at 9FC0" order is safe.

**5. MED-HIGH: a template cut down to one drive's read census fails silently.**
- The switch index tables are byte tables in .text, for example `movzx eax, byte [r12+rax+0x4467e4]`. If a table is missing, it reads 0, and the code takes case 0 with no trap. The band checks do not see this.
- **Fix:** carry all of .rdata and .data (as report C does). Fold every .text table into `static const` arrays in the lift. The CHECK build must trap on any image read outside the carried runs.

**6. MEDIUM: the three skipped ctors are not proven free (playbook 90).**
- The skip list was chosen "by the JX indices".
- PROVEN (`skipctor.py`):

| ctor | result when run | .data written |
|---|---|---|
| 0x5C83C0 (#95) | returns cleanly, no fault | 11 B (0xd26120, 0xd2bba0..a9) |
| 0xB7244 (#4) | UC_ERR_EXCEPTION after writing | 31 B + 64 B heap |
| 0xB6DD0 (#89) | UC_ERR_INSN_INVALID | 0 B |

- None of these bytes is in report A's read set, but that set comes from one drive.
- `host_init` has `timeout_us=1_000_000`, a wall-clock bound (playbook 90 rule 1).
- **Fix:** run #95. Watch the 42 bytes for reads on all 64 patches. Bound `host_init` by instruction count only.

**7. MEDIUM: the stack residue is not reproduced on the C side.**
- READ: the lifted `call` only does `R(4)-=8` and writes no return address. The C render glue does not write the stub's frame bytes, and the RET value 0x105000 is also missing.
- Lesson 12 shows that BUILD copies stack residue into the heap. In the identity build, stmxcsr puts the host's sticky flags into stack slots.
- **Fix:**
  - The lifter writes the return address on every call.
  - The glue writes the oracle's sentinel and stub bytes.
  - Add the stack range to Control 1 and to the end hash.
  - Use a soft MXCSR in every build.

**8. MEDIUM: FP semantics, and which build the gate grades.**
- **(a)** The gate builds at -O1. Report B found that fmin with DAZ behaves differently at -O0 and -O1. **Fix:** gate the exact shipping artifact and log its hash.
- **(b)** The oracle differs from x86 hardware (tininess, min/max with a denormal, flags) and runs the non-FMA CRT path (JX lesson 2). **Fix:** state "exact to the Unicorn oracle" in the scope table. Ship SOFTFP mode 1 on every target, or fail the gate on any corner hit.
- **(c)** The FTZ tail-tooth divergence point (sample 27,370) and **(d)** the NaN tooth (heap+0x38700) were both measured on the zero-HOST drive, where NaN steps came from rate 0. **Fix:** measure both again on the ctor drive. Keep a synthetic Unicorn-graded vector tooth.
- **(e)** WebAssembly NaN bits depend on the CPU architecture, so a node test on x86 cannot see an ARM difference. **Fix:** run the node test on ARM as well, or force the NaN rules.

**9. MEDIUM: gaps between the two runtime designs.**
- **(a)** Report B treats band 0x60 as call targets only. Report C puts PB data at 0x60000A000, which VOICE_WRAP dereferences through r8. Map it as data, or move PB into BUF on both sides.
- **(b)** Report C's regions have none at guest 0. The TLS chain `gs:[0x58]→[0]→[0x18]` would fault. Add a zero band 0.
- **(c)** The `delta[guest>>32]` index has no bound. The cookie page is at 0x2B99….
- **(d)** `jp8_bump` calls `abort()`, and `jp8_trap` aborts when no jmp_buf is set. In a DAW this kills the host. Use longjmp and return `JP8_E_TRAP`.
- **(e)** The runtime globals allow one engine per process, one thread. State this in the scope table.
- **(f)** `jp8_heap_set` resets `jp8_hc` to 0x9000. Give `heap_set` the hc0 argument so the call order cannot be wrong.

**10. LOW-MED: unhandled imports.**
- The oracle returns 0 without a message for an import it does not handle. The C runtime traps.
- The oracle keeps TLS values in a Python dict, which no dump carries.
- **Fix:** assert that `jp.unhandled` does not grow after the cut and that `jp.tls` is empty.

**11. LOW: known oracle static-init faults are frozen into the template.**
- These are: CRT init not run (default cookie, ctor #1 calls a fake RET), HeapReAlloc without a copy, HeapSize returns 0, QueryPerformanceFrequency returns 0.
- **Fix:** state them in the scope table. Assert faults == 1 in static init and 0 after the cut.

**12. LOW: reach gaps.**
- The drive uses one velocity only (100).
- It has no pitch bend (slot 0x88 → id 493).
- It has no slot 0xa0 call (0x446a20 → id 375).
- It has no parameter changes.
- **Fix:** list these in the scope table, and add a velocity lane (1, 64, 127).

Files are in `/tmp/claude-0/-home-user-jn60c99/3260b962-c2aa-553d-b245-0100f4709902/scratchpad/design/adv/`:
- Probe scripts: `hostctor.py`, `recallshape.py`, `lfokt.py`, `hpswitch.py`, `skipctor2.py`, `clockprobe.py`, `polyprobe.py`, `mxprobe.py`, `orderprobe.py`.
- Disassembly helpers: `dx.py`, `calls.py`, `xref.py`.
- Output word files: `words_*.bin`, `dry_*.bin`, `rs_*.bin`, `ord_*.bin`.

## A. Boot memory census

**JP8 memory census of the boot, run on the oracle `jp8_emu.JP8`**

The drive is: `JP8()` → `run_static_init` → build → FTZ → `set_sr(44100)` → `host_init` (3 writes) → `recall(2)` with flag 0 and notify, no snap → `render_both(4096)` → `note_on(60)` → 512 samples → `note_off(60)` → 512 samples. I imported `jp8_emu` read-only with bytecode writes off, so nothing in the repo changed. Two full pass-A runs gave the same numbers. Labels: PROVEN = executed, READ = static disassembly, INFERRED = deduction.

**1. After `run_static_init` only (PROVEN)**
- **Image vs pristine PE:** 6,726 B in 15 pages.
  - `.rdata`: 2,774 B in 2 pages. All of it is the IAT. The harness `JP8()` constructor wrote it (import stubs), before any ctor ran.
  - `.data`: 3,952 B in 13 pages. This is the static init's own work: 511 B in 4 pages of the file-backed part (9 clusters, 0xd06e40..0xd074b0) plus 3,441 B in 9 pages of the runtime tail [0xD20A00, 0xD2BBE0).
  - Static init wrote 7,259 `.data` bytes in total (some with the same value). It wrote 0 B to `.text` or any other section.
- **Heap:** 197,792 B bumped, 147,467 B nonzero, 48 pages. 1,430 allocations: 1,412 through CRT ALLOC 0x6F5B04, 12 HeapAlloc, 6 HeapReAlloc. 1 HeapFree.
  - Sizes by count: 40 B ×747, 47 ×158, 43 ×131, 51 ×127, 55 ×63, 39 ×63.
  - Largest: 53,067 / 26,563 / 18,311 B (caller 0x365d4f).
  - 2,268 qwords point into the heap. `.data` holds 689 qwords that point into the heap.
- **Harness defect (PROVEN, no effect on render):** `HeapReAlloc` returns a new block and does not copy the old one. The growths 256→8192 lost 3,969 nonzero bytes. `HeapSize` is not handled and returns 0 (6 calls, caller 0x76d679).
  - The first old pointer is 0x0AE64B77E88C8000. That is the /GS cookie rotated right by 50, which is how the CRT encodes a null pointer. So this is probably the UCRT onexit table (INFERRED).
- **gs page 0 region [0, 1 MB):** 0 nonzero bytes and 0 writes. 43 reads:
  - `gs:[0x58]` → `[0]` → `[0x18]` at 7 sites (the TLS/magic-static epoch pattern).
  - `gs:[0x10]` ×6, read by the `__chkstk` probe at 0x6f68fc.
- **Other regions:** 1 stray page at 0x2b992ddfa000. Its only nonzero byte is the 0xC3 that the harness `_fetch` wrote at 0x2b992ddfa232. That address is the /GS cookie value (`.data` 0xd06048 = 0x00002B992DDFA232, PROVEN). Maximum stack depth is 53,408 B.

**2. After the full boot, and after the renders (PROVEN)**

| point | heap bumped | nonzero B | nonzero pages / 25,108 | allocations |
|---|---|---|---|---|
| after recall | 102,846,112 | 1,690,667 | 1,176 | 2,641 (1,430 static + 1,211 build) |
| after 4096 samples | same | 1,773,523 | 1,198 | +0 |
| after note on/off + 1024 samples | same | 1,793,804 | 1,203 | +0 |

- Set-rate, `host_init`, recall, render and the note calls make 0 allocations. Nothing is written past the bump pointer (I checked 64 MB). Heap bytes that changed from boot to end: 117,500 B in 419 pages.
- **Build allocations by bytes:** 11,124,928 ×9 (the state blocks, from BUILD 0x445080) = 100.1 MB, 97.4% of the heap. Then 54,519 ×9 (caller 0x42729f), 5,416 ×72, 35,639 ×9, 4,280 ×72, 16,423 ×16, 2,264 / 2,216 / 2,160 ×72 each, 12,456 ×9.
- **State blocks:** each voice block has 21.2 KB nonzero in 63 pages. The master (unit 8) has 111,612 B in 91 pages.
  - All 9 blocks have the same layout: a dense header [0, 0x33000) with about 20.8 KB nonzero, then single pages spaced 0x200000 apart. So each block is mostly large zero buffers (INFERRED: delay/reverb lines, carried by all 9 units).
  - The master writes 0x22e142..0x232246, which is 16,644 B = one float per live sample (4,160 samples), and 0x42e152..0x432613 (INFERRED: a stereo delay).
  - The master also writes 0xa5b000–0xa68000 (45.6 KB), 0xa69000–0xa6d000 (12.1 KB) and 0xa97000–0xa9c000 (16.6 KB) (INFERRED: reverb).
- **Pointer cells:** each block has only 13 (12 into the heap, 1 into the image), all in its first 0xA0 bytes, and none point back into the same block. The other 2.72 MB of heap holds 25,119 heap-range and 13,606 image-range qwords (candidate pointers).
- **Stack depth by stage (B):** build 6,366, set-rate 6,128, `host_init` 296, recall 488, render 510, note-on 456, note-off 344.

**3. Image reads (hooks installed after a TB flush)**

The detector was seen to fire: a control stub that read `.text` 0x1000 and `.rdata` 0xA00000 was logged with its exact pc.

| group | `.text` | `.rdata` | `.data` | other sections | page 0 |
|---|---|---|---|---|---|
| static | 20 B | 119,156 | 1,577 read / 7,259 written | 0 | 43 read, 0 written |
| boot (build + set-rate + `host_init`) | 2,058 B, 16 pages | 28,900 (IAT 48) | 40 | 0 | 18 read (`gs:[0x10]`) |
| recall | 402 | 1,644 | 16 | 0 | 0 |
| play (5,120 samples + note on/off) | 87 | 888 | 16 | 0 | 0 |
| union after static init | 2,123 B / 50 runs / 17 pages | 29,580 / 5,512 runs / 64 pages | 52 B / 8 cells | 0 | — |

- After static init, **0 bytes of the image are written**, in every section.
- **`.text` reads:** 34 instructions. All are MSVC switch tables: `mov r32,[base+idx*4+disp]` or `movzx eax,byte[base+idx+disp]` (READ).
  - The hot one is VOICE_WRAP 0x3f810f. It reads the 8-entry table 0x3f81e4..0x3f8200 once per voice per live sample.
  - The lifted C does this read at run time from a fixed address: `jp8_lift.c:104901`, `M32(0x180000000+rax*4+0x3f81e4)` (READ).
- **`.data` cells read after static init:** 0xcbc2c4, 0xcbc2d0, 0xd06048 (the cookie), 0xd06068, 0xd22478 (the host-map root), 0xd27900, 0xd28f8c, 0xd29020.
  - The host-map root is the only cell that static init changed.
  - Play reads only 0xd06068, 0xd27900 and 0xd28f8c.
- **`.rdata`:** the only read bytes that differ from pristine are 24 B in 6 IAT slots, all used by BUILD.
  - Play reads vtable runs 0xa1a6a0–0xa1a760 and 0xa1b200–0xa1b390.
- **Heap objects from static init:** boot reads 167 B of them, only through the HOSTPARAM host-map walk (pcs 0x446635..0x44666d). Recall reads 0 and play reads 0. Nothing writes them.
- **Decision:** the template does not need the whole image. It needs these data only: 2,123 B of switch tables (0 if the lifter folds them into C switches), about 29.6 KB of `.rdata` for boot (888 B for play), 52 B of `.data`, and the host map. The host map only maps host ids 0,1,2 to engines 18,19,20 (INFERRED: it can become constants).

**4. Imports by stage (PROVEN; * = not handled, returns 0)**
- **Static init:** Enter/LeaveCriticalSection 831 each, InitializeCriticalSection 13, HeapAlloc 12, HeapReAlloc 6, HeapSize 6*, InitializeCriticalSectionEx 3, EncodePointer 2, GetSystemInfo 2, CreateEventW 2, HeapFree 1, InitializeSListHead 1, InitializeSecurityDescriptor 1, GetCurrentThread*, GetThreadTimes*, SetSecurityDescriptorDacl*, CoCreateGuid*, timeBeginPeriod*, QueryPerformanceFrequency* (1 each).
- **Build:** CreateThread 8, ResumeThread 8*, CreateEventA 8, GetModuleHandleExW 8*, GetProcessHeap 8, HeapAlloc 16. BUILD starts 8 threads, which never run under the oracle.
- **Set-rate, `host_init`, recall, notify, render, note on/off:** 0 imports.

**5. Wall times**

Measured on 4 CPUs with 3 busy.

| stage | wall (s) | emulation (s) |
|---|---|---|
| `JP8()` constructor | 0.011 | — |
| static init | 0.17–0.22 | same |
| build | 2.28–2.30 | same |
| FTZ + set-rate | 0.99–1.24 | same |
| `host_init` | 3.45–4.87 | 0.005–0.011 |
| recall | 3.57–5.17 | 0.023–0.043 |
| render 4096 (first 960 latched) | 1.77–2.18 | same |

- Boot emulation totals about 3.7 s. Boot wall time is about 11–15 s; most of the extra is the `pe_recon` parse.
- One live sample takes about 0.5–0.7 ms.

**Warning: this drive is not silent at idle (PROVEN for patch 2)**
- With flag 0 and no snap, samples 0–959 are 0. From sample 960 the dry voice sum rises from 9.4 to 65.24 and stays there. Master L/R stays pinned at 1.980578 with 0 NaN, and this happens before any note.
- The same boot with snap is silent: dry 0, master 1.57e-13.
- The lift_seq 'boot' layer uses this no-snap shape. So its EXACTLY 0 result is probably measured against a clamped master (INFERRED for patch 5).

**Commands**, all run from `/tmp/claude-0/-home-user-jn60c99/3260b962-c2aa-553d-b245-0100f4709902/scratchpad/design/`:
- `PYTHONDONTWRITEBYTECODE=1 python3 jp8_memcensus.py A passA2.json 4096`
- `PYTHONDONTWRITEBYTECODE=1 python3 jp8_memcensus.py B passC.json 4096`
- `PYTHONDONTWRITEBYTECODE=1 python3 jp8_reach_analyze.py`
- `PYTHONDONTWRITEBYTECODE=1 JP8_EMU_QUIET=1 python3 jp8_idleprobe.py nosnap 4096` (then `snap 2048`)

Files are in that folder:
- `jp8_memcensus.py`
- `jp8_reach_analyze.py`
- `jp8_idleprobe.py`
- `passA.json`
- `passA2.json` (+ `.heap_end.npy`)
- `passB.json`
- `passC.json` (+ per-group `rd_*` / `hrd_*` `.npy`)

## B. Relocation / WASM / C99 audit

The RELOC and soft-FP design works, and I proved it in scratch against the oracle. The portable build is about 3 times too slow for real time. Two new findings matter now: the oracle itself is not x86-exact in some FTZ/DAZ corners, and the plugin writes NaNs into its state.

Labels: PROVEN = executed (C twin vs oracle dumps, or Unicorn vs the CPU); READ = static; INFERRED = deduction. I did not touch the tree. My copy of jp8_lift.c is byte-identical (sha 00594053…) to what the original lifter makes from build/jp8_lift/dynreach*.json (PROVEN).

## 0. What I proved in scratch

My C-only harnesses reproduce the gate result first: layer 1 (ref_render p02/p63) and layer 3 (snapGate3 ref_boot p02/p63, with stack.bin) are EXACTLY 0 in the identity build.

| Build | Layer 1 p02/p63 | Layer 3 boot p02/p63 | Long release tail (patch 2) |
|---|---|---|---|
| Proposed files, all flags off | .text/.rodata sha c2236c8d…/4ced8804…, same as today's object; runtime disassembly identical | — | — |
| `JP8_RELOC` + `JP8_RELOC_CHECK=1`, host arenas from calloc, nothing mapped at guest addresses | EXACTLY 0, no trap | EXACTLY 0, no trap | 400k samples and final heap hash equal to identity |
| `JP8_RELOC` + `JP8_SOFTFP=1` or `=2`, host FTZ/DAZ off | EXACTLY 0 | EXACTLY 0 | 400k samples equal to the hardware-FTZ tail |
| AArch64, `-std=c99`, RELOC + SOFTFP=2 + NaN rules, under qemu-aarch64 | EXACTLY 0 | EXACTLY 0 | 40k-sample heap hash equal to x86 |
| wasm32 (clang-18, `-std=c99 -pedantic`) | 0 diagnostics; object compiles (8.8 MB, needs only `__multi3`) | — | not run (no runtime) |

**FTZ tooth (PROVEN, oracle-graded):**
- The identity build with MXCSR 0x1F80 (FTZ/DAZ off) is still EXACTLY 0 on the 192-sample layer-1 drive. The current gates therefore cannot see FTZ.
- On the patch-2 release tail it diverges at tail sample 27,370 (voice 6 main).
- The oracle's own 28,000-sample tail (scratch Unicorn run, 35 s) equals the hardware-FTZ build, the soft-FP x86 builds and the AArch64 build. It differs from the FTZ-off build at the same point.

**NaN tooth (PROVEN):** AArch64 without the NaN rules fails layer 3 with 3,851 heap dwords (x86 0xFFC00000 against ARM 0x7FC00000, from heap+0x38700). With the rules it is EXACTLY 0.

**Proposed-lifter tooth (PROVEN):** the patched lifter's `--tooth 0x3965cb` fails p63 in the portable build (70 heap dwords).

**Oracle vs x86 hardware (PROVEN):** Unicorn 2.1.4 and real SSE hardware were run on the same instructions at MXCSR 0x9FC0.

| Vector | Hardware | Oracle |
|---|---|---|
| mulss / divss / cvtsd2ss, exact value in [FLT_MIN−2⁻¹⁵⁰, FLT_MIN(1−2⁻²⁵)) | 0 (tininess after rounding) | 0x00800000 |
| minss/maxss with a denormal operand | flushed ±0 | original denormal bits |
| stmxcsr after an inexact op | 0x9FE0 / 0x9FF0 | 0x9FC0 (flags never set) |
| DAZ on add, comiss, mul inputs | 0 / ZF=1 / 0 | same |

- gcc `-O1` compiles `fmin_ss` to `minss`, which gives the hardware result. `-O0` compiles it to comiss+select, which gives the oracle result. So today's twin follows the hardware in these corners, and the result depends on the optimisation level.
- None of these corners occurs on the drives above: modes 1 and 2 are byte-equal over 400k samples. The mode choice has no tooth yet.

## 1. Where host code touches guest memory

Counts are from jp8_lift.c (762 functions, 156,488 instructions).

| Pattern | Sites | Note |
|---|---|---|
| M32 / M64 / MF / M8 / M16 / MD | 62,763 / 14,596 / 10,280 / 769 / 185 / 62 | MS8/16/32: 0. Every one is `*(volatile T*)(uintptr_t)a` |
| jp8_ldx / jp8_stx | 1,312 / 1,738 | memcpy of 16 bytes |
| inline `(*(X*)(uintptr_t)a)` | 154 | packed memory operand; X is 8-byte aligned |
| All guest-access sites by base | ≈91.7k | rip-constant (image) 2,330; rsp 13,194; rbp 7,180; other registers 69,000 |
| rep movsb as `memcpy` | 1 (0x72e4be, not reached) | memcpy is not x86 forward copy when dst overlaps src |
| rep stos loops through M macros | 17 | 6 reached: 0x421022, 0x421040, 0x421114, 0x421585, 0x4215a4, 0x426f45 |
| gs segment | 1 (0x6f68fc, `gs:[0x10]`, __chkstk) | goes through JP8_GS_BASE |
| Stack via M64(R(4)) | push 755, pop 1,294, `leave` | Direct calls (4,856) do `R(4)-=8/+=8` but never write the return slot. The oracle writes RET there; stack.bin carries it (READ) |
| jp8_icall / switch dispatch | 1,286 / 187 | values only; import stubs 0x600000000+8i are never data |
| ldmxcsr / stmxcsr | 10 / 6 | these set and read the **real** MXCSR |
| `(uintptr_t)` in lift | 156 | the 154 X-casts plus memcpy |
| `__int128` / `__builtin_clzll` / traps | 43 (+ op_imul2 ×41, cpu.h 2) / 4 / 280 (+19 div0) | — |

**Runtime (READ):**
- `jp8_map` uses mmap MAP_FIXED_NOREPLACE at the guest address.
- `jp8_load` freads to the guest address; `jp8_bump` memsets it.
- `jp8_alloc` / `jp8_import` return guest bump pointers. GetProcessHeap returns 0x4242000000 and Create*/Open* return 0x9010+16k; these are opaque and never dereferenced.
- `jp8_call_x` sets the real MXCSR and never restores it.

**Harness (READ):** jp8_lift_c.py uses ctypes string_at/memmove/memset on guest addresses (BUF, GS mirror, HOST+0xA0, whole-heap compare).

**Host pointers into guest memory:** I found none. Every stored value is a register value, a constant or a bump pointer (READ). The relocated heap is byte-identical to the oracle's on layers 1 and 3 and after 400k samples. A host pointer stored into guest memory would show as a heap diff (PROVEN on those drives).

## 2. JP8_RELOC — the proposed change

Guest addresses keep the oracle's 64-bit values. Every access goes through a 256 MB band table.

| Region | Guest range | Band |
|---|---|---|
| page 0 (gs base 0) | 0x0 – 0x100000 | 0x00 |
| image | 0x180000000 + 0xDE7000 | 0x18 |
| stack | 0x200000000 + 32 MB | 0x20 |
| heap | 0x310000000 – 0x3178304A0 (max seen) | 0x31 |
| stubs | 0x600000000 (call targets only) | 0x60 |
| BUF | 0x700000000 + 4 MB | 0x70 |

No region crosses a band edge. The CHECK=1 runs trapped on nothing (PROVEN). Band 0 makes gs:[x] and null-page reads behave as in the oracle, which the identity path cannot do (mmap_min_addr).

```c
#ifdef JP8_RELOC
#define JP8_NBANDS 128u
extern uintptr_t jp8_bdelta[JP8_NBANDS]; extern uint32_t jp8_blo[JP8_NBANDS], jp8_bhi[JP8_NBANDS];
extern void jp8_fault(uint64_t a, unsigned n);
static inline void *jp8_h(uint64_t a, unsigned n) {
    uint64_t i = a >> 28; uint32_t k = (uint32_t)(i & (JP8_NBANDS - 1));
#if JP8_RELOC_CHECK == 1
    uint32_t off = (uint32_t)(a & 0x0FFFFFFFu);
    if (i >= JP8_NBANDS || off < jp8_blo[k] || off + n > jp8_bhi[k]) jp8_fault(a, n);
#endif
    return (void *)((uintptr_t)a + jp8_bdelta[k]);   /* delta mod 2^width: works for wasm32 too */
}
#define JP8_H(a, n) jp8_h((uint64_t)(a), (n))
#define JP8_GS_BASE 0x0ULL
#else
#define JP8_H(a, n) ((void *)(uintptr_t)(a))
#define JP8_GS_BASE 0x700020000ULL
#endif
#define M32(a)    (*(JP8_MQ uint32_t *)JP8_H(a, 4))      /* same for M8..MD; JP8_MQ defaults to volatile */
#define JP8_MX(a) (*(X *)JP8_H(a, 16))
static inline void jp8_ldx(X *d, uint64_t a) { memcpy(d, (const void *)JP8_H(a, 16), 16); }
```

**jp8_rt.c (RELOC branch):**
- `jp8_map` callocs `size+4096` and aligns so host ≡ guest mod 4096. It sets delta, lo and hi, and refuses a region that crosses a band or shares one.
- `jp8_host(a)` is exported for harnesses.
- `jp8_load` and `jp8_bump` check their span, then use JP8_H.
- `jp8_fault` longjmps through jp8_trap.

**Lifter:** `JP8_MX(a)` replaces the X-cast, and `JP8_MOVSB()` replaces the memcpy. The default JP8_MOVSB keeps the proven memcpy; RELOC uses the exact forward M8 loop.

**jp8_lift_c.py (proposed; I did not change it):**
- `hp=lib.jp8_host` when it exists; `rd`, `wr` and `memset` go through `hp(a)`.
- In RELOC, map band 0 with `jp8_map(0,0x100000)` and load page0.bin at guest 0 instead of GS_BASE.

## 3. WASM / non-x86 portability

**x86 dependencies (READ unless marked):**
- xmmintrin.h and `_mm_setcsr/_mm_getcsr`. `jp8_call_x` leaves 0x9FC0 in the caller's thread, so a DAW or ctypes thread inherits FTZ/DAZ.
- stmxcsr returns host sticky flags into guest stack slots, and the stack is state (lesson 12).
- Plain C float ops rely on the hardware flush (FOPS, POPS, cvtss2sd/cvtsd2ss, cmp_f/cmp_d, fmin/fmax). Denormals do occur (PROVEN, tail sample 27,370).
- `cvtr_*` use nearbyint, so they depend on the host rounding mode. This is safe only because RC is always 0. The only executed ldmxcsr sites (0x76f3f2/0x76f401, 0x770152) OR in 0x1F80 or restore a saved value (READ + dynreach). _set_fpsr at 0x79dd90 is not reached.
- `cvtt_*` range handling is portable. There is no x87 or long double.
- 64-bit uintptr_t is needed only by the identity path. MAP_FIXED_NOREPLACE is Linux-only.
- Unaligned lvalue access is UB but works on x86, AArch64 and WASM; it faults on Xtensa and ARMv7.
- Little-endian is assumed.
- x86 NaN rules are needed (PROVEN on AArch64).
- emscripten's `_mm_setcsr` is a no-op (INFERRED). That is why the header now fails the build with `#error` on non-x86-64 unless JP8_SOFTFP is set (PROVEN on aarch64 and wasm32).

**Exact soft FTZ/DAZ (`JP8_SOFTFP`):**
- DAZ on every FP input, done branchless (a branch per operand cost 5× from BTB misses in this code size, measured).
- Plain IEEE op, then flush a denormal result to ±0 with x86 NaN rules applied.
- Mode 2 only: when the result is exactly ±FLT_MIN or ±DBL_MIN, recompute with one operand scaled by 2⁶⁴ (2⁶⁰⁰). That product cannot underflow, so its rounding is x86's unbounded one. Flush if it is below 2⁻⁶² (2⁻⁴²²). For cvtsd2ss, flush if |x| < 0x1.ffffffp-127. Add and sub need no slow path because a tiny sum is exact.
- Mode 1 (the oracle's semantics): no slow path; min/max compare flushed values and return the original bits.
- MXCSR becomes a software register. ldmxcsr traps unless `(v & 0xE040) == 0x8040` (FTZ, DAZ, round-to-nearest). stmxcsr returns c->mxcsr, as the oracle does.
- Core of the code:

```c
static inline float jp8_dazf(float x){uint32_t u=jp8_fb(x);return jp8_bf(u&(0x80000000u|(0u-(uint32_t)((u&0x7F800000u)!=0))));}
static inline float jp8_mulss(float a,float b){float r;a=jp8_dazf(a);b=jp8_dazf(b);r=a*b;
#if JP8_SOFTFP==2
 if(JP8_RARE(jp8_isminf(r))&&fabsf((a*0x1p64f)*b)<0x1p-62f)return jp8_sz_f(r);
#endif
 return jp8_fixf(r,a,b);}  /* fixf: NaN -> first NaN operand quieted, else 0xFFC00000; then FTZ */
```

**Lifter emission change:**
- FOPS/POPS become `JP8_ADDSS(a,b)`, `JP8_MULSD(a,b)` and so on. Default is `((a)+(b))`.
- The four cvt forms, sqrt, round, ldmxcsr and stmxcsr also go through macros.
- The tooth now swaps the macro name.

**Cost (x86):** about +40 µs per sample, roughly 2.7× the identity build, for about 12.2k FP ops per sample.

**Byte-identical on x86 with all flags off:** yes (PROVEN, sha above). On x86, the SOFTFP lane can be proven by running with hardware FTZ off.

## 4. C99 strictness

- `gcc -std=c99 -pedantic`: the only extension is `__int128`, with 124 warnings (121 in jp8_lift.c, 3 in cpu.h).
- clang `-Weverything`: only style warnings. The large counts are 5,385 unused labels, 350 extra semicolons and 135 64→32 truncations; there are no extension warnings.
- None of these are used: statement expressions, computed goto, typeof, zero-length arrays, VLAs, asm, `__attribute__`.
- `__builtin_clzll` appears 4 times (bsr at 0x770460–0x770793). -pedantic does not flag it.
- The runtime uses `_GNU_SOURCE`, sys/mman.h, MAP_FIXED_NOREPLACE and xmmintrin.h. All sit on the identity path; the RELOC/SOFTFP runtime is plain C99.
- The AArch64 build used `-std=c99` (PROVEN). `-fno-strict-aliasing` and `-ffp-contract=off` stay required (gcc contracts to fmadd on ARM in GNU mode).

**How to remove `__int128` (only needed for MSVC and 32-bit gcc such as Xtensa or ARMv7):** emit `JP8_MUL1_64` / `IMUL1_64` / `DIV1_64` / `IDIV1_64` macros. Their default text is today's block. The fallback is a 32×32 limb mulhi plus a 64-step shift-subtract 128/64 divide (1 div r64 site). gcc/clang on 64-bit targets and clang wasm32 are fine as is.

## 5. Performance

Dynamic count, patch 2 release (C twin counter): **30,398 statements per sample** (oracle measured 30,495 for the same patch). About 1% of statements were not counted because their operand text contains `*`.

| Per sample | Count |
|---|---|
| FP arithmetic | 9,608 |
| FP compare / min / max | 1,988 |
| Conversions | 608 |
| Memory-referencing | 15,056 |
| Flag-setting ALU helpers | 1,398 |
| Calls | 363 |

Speed: Xeon @2.1 GHz, gcc 13.3, machine shared with 3 background jobs.

| Build | µs per sample (8 voices + master) | × one core at 44.1 kHz |
|---|---|---|
| identity -O1 (gate build) | 20.5–20.7 | 0.91 (real-time factor 1.09) |
| identity -O2 / non-volatile / restrict | 20.0 / 21.4 / 20.6–21.4 | no gain |
| RELOC, unchecked | 24.1 | 1.06 |
| RELOC CHECK=1 / branchless CHECK=2 | 75.8 / 79.7 | 3.3 / 3.5 |
| RELOC + SOFTFP=1 with NaN rules / SOFTFP=2 | 63.9 / 68.6 | 2.8 / 3.0 |
| AArch64 under qemu (emulated, not a hardware figure) | 1,360–1,710 | — |
| Oracle (Unicorn) | about 850 | — |

Result: the identity twin just runs in real time on one core. The portable twin does not; it needs about 3 cores. WASM will be slower again (INFERRED).

## Risks

1. **The oracle is not x86-exact** in the tininess and min/max-denormal corners, and it never sets MXCSR flags. The current twin follows the hardware there, depending on the compiler. The corners are not hit so far. **Decision for you:** which semantics count as truth. Before that, run a corner census (count slow-path hits and min/max denormals) over the 64-patch reach.
2. **The current gates cannot detect FTZ.** The 192-sample drive is EXACTLY 0 even with FTZ off. Add a 28k-sample release-tail lane; its tooth is the MXCSR 0x1F80 build, which fails at sample 27,370.
3. **NaN rules only get a tooth off x86.** Add a qemu-aarch64 layer-3 lane (about 4 s per patch), or an x86 tooth with a wrong default NaN.
4. **MXCSR leaks to the caller.** jp8_call_x leaves 0x9FC0 in the caller's thread. The shipping API must save and restore it.
5. **The bounds check costs 3.7×.** Use it in gates only. The ship build is unchecked: a wild access can corrupt up to 256 MB beyond an arena. Masking is a cheaper way to contain it.
6. **rep movsb is lifted as memcpy.** It is wrong for overlapping copies; the site is not reached yet.
7. **Heap band limit.** The heap must stay under 256 MB (band 0x31). Today it is 120 MB.
8. **Runtime layout limits.** Guest call depth becomes host C recursion (set emscripten STACK_SIZE). Runtime globals mean one engine per process. Unaligned lvalues fault on Xtensa.
9. **Not yet dump-free.** Runtime still needs img.bin (the post-static-init image, including the IAT stub values), about 197 KB of static-init heap, stack.bin residue and page0.bin.
10. **Word counts in S3_STATUS are byte counts** (READ, jp8_lift_c.py prints `nw` in bytes). 13,824 / 46,080 / 167,616 should read 3,456 / 11,520 / 41,904 words. Every word is still compared.

## Files

All in `/tmp/claude-0/-home-user-jn60c99/3260b962-c2aa-553d-b245-0100f4709902/scratchpad/design/`:
- Diffs to apply: `jp8_cpu.h.diff`, `jp8_rt.c.diff`, `jp8_lift.py.diff` (the scratch-only BIN path line is removed)
- Full proposed files: `proto/jp8_cpu.h`, `proto/jp8_rt.c`, `proto/jp8_lift_proto.py`, `proto/jp8_lift.c`
- Harnesses: `bench/bench.c`, `bench/bench3.c`, `bench/run.sh`
- FP vector tests: `fp/vectors.py`, `fp/uc_fp.py`, `fp/hw_fp.c`
- Oracle tail run: `oracle/tail_oracle.py`, `oracle/o_p02_28k.bin`

## C. JX shipping mirror

# JP8 shipping path: a plan that follows the JX-3P path

I only wrote files in `/tmp/claude-0/-home-user-jn60c99/3260b962-c2aa-553d-b245-0100f4709902/scratchpad/design/ship/`. I did not change the repo. I set PYTHONDONTWRITEBYTECODE=1 for every Python run, so no `.pyc` files went into the repo.

## 0. New facts from this task (read these first)

| # | Fact | Label |
|---|------|-------|
| F1 | **The layer-3 gate is EXACTLY 0 on a broken boot.** The oracle's own reference words show this (`build/snapGate2/build/jp8_lift/ref_boot/p02/words.bin`, and `p63` is the same). Samples 0..959 are zero (the latch). From sample 960, master L and R stay at the 1.981 clamp in every window. At idle, all 8 voices output up to 13.77. | PROVEN (the oracle's words) |
| F1b | **Cause:** in the oracle's final heap, each unit has 37 ramps that never end. Their step, accumulator and target cell are all NaN (for example state+0x14e0 and +0x73b0). The C twin shows each stage; this path is gated EXACTLY 0 end to end. BUILD arms 353 ramps per unit before SETSR, so the rate is 0. That gives 311 steps of ±inf and 42 NaN steps (0/0, where base == limit). SETSR and the 3 host_init writes do not re-arm them. The recall re-arms 5 of the NaN ramps. On the first tick, the inf ramps land on their limit. The NaN ramps poison their cells for ever. A snap writes the limit, and for these ramps limit == base, which is the value the ramp was meant to hold. | PROVEN (oracle heap); stage census = C twin |
| F2 | **The T1 boot order is sane and matches the oracle EXACTLY 0.** T1 = static init → BUILD → FTZ → SETSR 44100 → host_init (3 writes) → **snap, latch left live** → recall with flag 0 + notify, no snap after it → render → note on 60 → render → note off → render. Patch 5, 12,288 samples, oracle numbers: latch zero, idle master 1.145e-3 and dry 0, note master 0.598 and dry 0.053, release decays, NaN 0. The C twin started from the post-static-init dumps, with the snap written in C. Result: 221,184 words and the whole heap EXACTLY 0 in **both** render orders: (A) the stubs' voice-major 256-sample blocks at the oracle's guest buffer and PB addresses, and (B) sample-major order with other buffers. Snap tooth (skip 1 ramp of unit 8): 1,981 words and 24,604 heap dwords differ. **The first difference is at sample 11,297.** A 1,200-sample gate would not see it. | PROVEN (1 patch, 1 key) |
| F3 | BUILD at MXCSR 0x1F80 and at 0x9FC0 gives the same heap hash. | C twin (INFERRED for the oracle) |
| F4 | **Translated guest addresses work.** Host = guest + delta[guest>>32]. The regions are plain arrays: no mmap, no MAP_FIXED. The layer-1 drive stays EXACTLY 0 (3,456 words + the 102.8 MB heap). Native speed: -O1 23.1 µs/sample (identity mapping at -O1: 21.2); -O2 20.9 µs/sample = 0.92 of one core at 44100. Removing `volatile` gives no gain. | PROVEN |
| F5 | **The same source compiled to wasm32 is EXACTLY 0 on the layer-1 drive.** I used clang 18 `--target=wasm32 -O2`, freestanding, no emscripten, soft MXCSR, no FTZ. In node 22: 3,456 words + heap hash equal. Render-only lift: 3.0 MB wasm / 459 KB gz, 36.3 µs/sample (1.60 cores). Full current lift (762 functions): 6.2 MB / 723 KB gz, 35.0 µs/sample (1.54 cores). | PROVEN (192-sample reach) |
| F6 | FTZ changes the result on long runs. In a 400k-sample free run, MXCSR 0x1F80 and 0x9FC0 first differ at sample 27,370 (1.49 M of 7.2 M words differ). A sibling agent made these output files in scratch (`../bench/w_hw_*.bin`). I ran the comparison. | PROVEN (the comparison) |
| F7 | Costs, lifted C, native: BUILD 0.10–0.24 s, SETSR 0.04 s, recall 0.7–1.0 ms, render 19–27 µs/sample. Unicorn oracle on the T1 drive: 10.7 s to boot, about 0.43 ms/sample (block stubs, no hooks). | PROVEN |
| F8 | Sizes after static init. Heap: 193 KB used, 147 KB nonzero, 238 KB zlib. Stack residue: 47.7 KB nonzero in [0x201FE2F60, 0x201FF0015], 77 KB zlib. .rdata: 3.16 MB (1.16 MB zlib). .data: 0.46 MB (86 KB zlib). .text: 10 MB (4.0 MB zlib), but a sibling census on one drive saw only 2,123 bytes of .text read after init (jump tables). | PROVEN (sizes); census = sibling, 1 patch |

## 1. What the JX path is (READ)

**API** (`jx3p/gui/jx_bridge.c`, one static instance; the caller must call `jx_enable_hw_ftz()`):
```c
int  jx3p_init(const char *template_path, const char *bank_path, const char *master_recall_path);
void jx3p_recall(int idx);
void jx3p_note_on(int note, int vel);
void jx3p_note_off(int note);          /* vel 0x40 inside */
void jx3p_render(float *L, float *R, int n);
void jx3p_render_dry(float *L, float *R, int n);
/* diagnostics: jx3p_vstate(v), jx3p_mstate(), jx3p_wrap_flag(u,f), jx3p_vcell(i); preview-only: jx3p_nan_scrub, jx3p_efx_hold */
```

**Template** (`jx_template_export.py` → `jx3p/gen/jx_template.bin`, format JXT3, raw + `.gz`):
- It comes from `JX().boot(44100, snap=True, host_init=True)`: static init → BUILD → SETSR (float) → FTZ → host_init → snap + clear latch.
- It holds 53 regions: 8 voice DSP windows (0x60000 each, pointer at +136 set to zero); 9 × {note manager 0x7A8, nstore 0xDB0, ktrack 0xB0}; 9 proc headers (0x700); 8 voice high windows [0xA60000, +0x4D000); the master (0xAAD000).
- It holds 19 links: voice link objects, 9 wrapper+ramp records, the dispatch seam, the master link. Then a crc32.
- NaN census of the DSP regions must be 0.

**Recall is not live in the JX.** `jx_master_recall_export.py` (JXM3) boots fresh for each patch, runs `recall(notify=False)`, and stores sparse diffs against the clean boot (master, voice windows, high windows, 9 wrap records). `jx3p_recall(p)` = reset to the template + apply the diffs. A base-match tooth refuses an aux built on a different template.

**Full gate** (`jx_full_gate.sh`):
- Oracle: fresh boot for each patch (snap, host_init) → recall → idle `JX_FULL_IDLE` (4096) through the block stubs (256) → `note_on(60,100)` → n samples (12000). It writes L/R words and final states.
- C: `jx3p_init` → recall → the same drive.
- It compares only the **L/R bits**; states are for information. Default patches 0,5,20,49; the logged result is 64/64.
- Tooth: `-DJX_FULL_TOOTH=1` makes `val += 1` in `jx_dispatch_note_cb` (one semitone). The gate must fail.

**Listen proof on the C twin** (`jx_listen_c.py`):
- Idle 4096, runaway check < 0.01.
- Keys 48/60/72: note on, skip 1024, measure 16384 (f0 by autocorrelation, harmonicity ≥ 0.80), note off, 44100-sample tail (last 4096 < 5% of first, or < 1e-4).
- `track_verdict`: one whole-semitone offset ±25 cents. Dry by default; `--master` uses the master output.

**Web** (`jx3p/gui/web/build.sh`, `jx_artifact_page.py`):
- Two emcc builds: ES6 module for Pages, classic for the artifact.
- `.gz` assets are fetched, inflated with DecompressionStream and written to the wasm FS.
- ScriptProcessor(256) on an AudioContext at 44100.
- BUILD_VER hashes code and data. There is a `docs/jx3p` mirror.
- The artifact page inlines the wasm as base64 through `instantiateWasm`.
- The FTZ caveat is stated.

## 2. JP8 plan, file by file

**Cut point: post-static-init (PSI) is right, with one correction.** BUILD, SETSR, host_init and recall all run live in the lifted code. Layer 3 already proves that path. The correction: the product must **snap after host_init** (F1b: without it the boot is NaN-poisoned). The latch stays live, and the recall is live (flag 0, the walker settles it).

Why PSI:
- The template is small and does not depend on the rate. `init(96000)` works through the live SETSR.
- The only harness law in the product is a 15-line snap. Control 1 and a tooth grade it (F2 proves it equals `jp8_emu.snap_ramps`).

Fallback: a post-snap template, exactly the JX shape. The same gate grades it; only `jp8_init` changes.

Research item: find the host's real boot order. If SETSR can run before the ramps are armed, the snap can go.

**`jp8/src/jp8.h`**
```c
enum { JP8_OK=0, JP8_E_TEMPLATE=-1, JP8_E_RATE=-2, JP8_E_TRAP=-3, JP8_E_ARG=-4, JP8_E_STATE=-5 };
int  jp8_init(const void *tmpl, size_t len, float sample_rate); /* 44100 | 96000 only (D3) */
int  jp8_recall(int patch);                 /* 0..63 */
int  jp8_note_on(int key, int vel);         /* NOTEON 0x445CF0: rcx=HOST, dl=key, r8b=vel */
int  jp8_note_off(int key, int vel);        /* NOTEOFF 0x445C90; gates use 64 */
int  jp8_render(float *L, float *R, int n); /* any n */
void jp8_free(void);
const char *jp8_error(void);
/* gates / listen */
int  jp8_render_words(uint32_t *w18, int n);  /* per sample: v0 main,v0 sub..v7 sub,L,R (bits) */
void *jp8_guest(uint64_t gaddr, size_t len);  /* host ptr if inside one arena, else NULL */
uint64_t jp8_unit_state(int u);               /* guest address, u 0..8 */
/* later */
int  jp8_param(int engine_id, int value);     /* DISPATCH flag 0 x 9 units + ASG_NOTIFY(4) */
```

**`jp8/src/jp8_engine.c`**

`jp8_init`:
1. Check the crc. Refuse any rate that is not 44100 or 96000.
2. `calloc` the arenas, fill the template runs, call `jp8_slot()`, `jp8_heap_set(heap_ptr0, limit)`, `jp8_hc_set(hc0)`.
3. HOST = `jp8_alloc(0x8000)`.
4. MXCSR 0x1F80: BUILD(HOST). Read st/pr/as at HOST+0xA0/+0xB0/+0xB8 + 64·u.
5. MXCSR 0x9FC0: SETSR(HOST, float in xmm1); 3 × HOSTPARAM (host ids 0,1,2 = raw 1,10,100 → engine 18 Local SW, 19 Master Tune SYS-1, 20 MASTER TUNE).
6. Snap, using the exact law of `jp8_emu.snap_ramps`: for every id, *target = [a+0x14], [a+0xC] = 0, [a+0x1C] = 0; then [st+0x78] = [st+0x70]. The latch is **not** cleared.

`jp8_recall`: units outer, pools inner, `DISPATCH(pr[u], id, 0, val)`; then `ASG_NOTIFY(as[u], 4)` for u = 0..8.

`jp8_render` follows the stubs' semantics exactly (the scratch `t1_c.c` render_A):
- Blocks of ≤ 256 samples, voice-major.
- Voice PB block at guest 0x60000A000, with a3 at +0x28. Master PB at 0x60000A100: a3 at +0x20, a2[16] at +0x30, a2 advanced by 4 each sample.
- Buffers at `render_both`'s guest layout: BUF + 4·256·k.
- Wrapper calls enter at rsp 0x201FEFFB8 (set c->r[4] = 0x201FEFFC0). Direct calls enter at 0x201FEFFF8 (set c->r[4] = 0x201FF0000).

Other rules:
- Use one `setjmp` for each API call, not one for each unit call. After a trap: engine dead, output zeros, `JP8_E_TRAP` (the audio stays unbroken).
- Save the host's MXCSR on entry and restore it on exit.
- Tooth switches: `-DJP8_FULL_TOOTH` (note_on uses key+1) and `-DJP8_SNAP_TOOTH` (skip the last ramp of unit 8).

**`jp8/src/jp8_cpu.h`, `jp8/src/jp8_rt.c`, `jp8/tools/jp8_lift.py`**
- The M8…MD macros and `jp8_ldx`/`jp8_stx` go through `JP8_HA(a)`.
- The lifter emits `JP8_HA` for the 153 `(*(X*)(uintptr_t)K)` loads and for the `rep movsb` memcpy. This is the only raw-pointer use left; the scratch `lift_rt.c` / `lift_full_t.c` show the transform.
- Split the runtime: the core `jp8_rt.c` (slots, bump allocator, imports, `jp8_call_nj` with no setjmp) and `jp8_rt_dumps.c` (loads layer-gate dumps into the slots).
- `JP8_CHECKED` build: any access outside every arena traps.
- Optional hardening, gated: the lifter should store the return address on `call`. Today it only does `R(4)-=8`, so the C stack bytes at return slots are not the oracle's. The heaps are still EXACT today.
- The lifter should also emit the jump-table byte ranges it read. That is the exact .text read set for the template.

**`jp8/tools/jp8_template_export.py` → `jp8/gen/jp8_template.bin(.gz)`**
- Process A: `JP8().run_static_init()`. Assert that static init gives 841 ok / 3 skipped / 1 fault.
- Format JP8T1: `"JP8T" u32 ver, u32 nreg, {u64 guest_base, u64 arena_size, u32 nruns, runs{u32 off,u32 len,bytes}}`, then `u64 heap_ptr0 (0x3100304A0), u64 heap_limit, u64 hc0 (0x9020), u32 static stats[3], u32 crc32`.
- Regions:
  - image, slot 1: .rdata + .data in full, as oracle memory (includes the IAT stub pointers), plus the lifter's .text table ranges;
  - heap, slot 3: arena 0x7000000, runs [0, 0x304A0);
  - stack, slot 2: [0x201F00000, +1 MB), with the residue;
  - BUF, slot 7: [0x700000000, +0x21000), with page 0 at +0x20000 (the gs page);
  - STUB, slot 6: [0x60000A000, +0x1000), empty.
- Self-check: read the file back and compare every region with oracle memory byte for byte (the JX base-match lesson).
- Estimated size: about 1.5 MB gz (INFERRED from F8).

**`jp8/tools/jp8_recall_export.py` → `jp8/gen/jp8_recall_tab.h`** (pure Python: jp8_bank + pe_recon)
- `jp8_recall_id[64]` (740 + ACTIVE_POOLS), `jp8_recall_val[64][64]` (engine frame = raw + DB min), the 3 host_init rows, and the 64 patch names.
- Tooth: the existing `jp8_bank_census.py`.

**`jp8/tools/jp8_full_seq.py`** (shared, pure):
```
SR=44100; BLOCK=256
base = render 4096 (latch + idle) | on 60/100 | render 4000 | on 64, on 67 | render 3000 | off 60,64,67 (vel 64) | render 6000   = 17,096 samples
p%8==0: + on 72 | render 1000 | recall (p+1)%64 | render 2000 | off 72 | render 2000     (patch change while a note sounds)
p%8==4: + on 48..66 step 2 (10 notes: stealing) | render 2000 | all off | render 3000
DEEP=(2,63): full heap dumps kept; RATES: 44100 all 64, 96000 on 2,10,52,63
```

**`jp8/tools/jp8_full_emu.py`** (process A)
- For each patch: `JP8()` → `run_static_init` → `build` → `set_ftz` → `set_sr` → `host_init` (assert (3,0)) → `snap_ramps()` with **no clear_latch**.
- init hash = sha256 of heap [base, jp.heap) + image .data.
- `recall(p)`, then the events.
- `render_words` = `render_both`'s block loop that also keeps the 16 voice words (the scratch `t1_emu.py`).
- Writes `words.bin`, `meta.json` (init/end hashes, heap pointer), and heap dumps for the DEEP patches.

**`jp8/tools/jp8_full_c.py`** (process B, ctypes only)
- Per patch: `jp8_init`. **Control 1:** the sha256 of the same regions, read through `jp8_guest`, must equal the oracle's init hash.
- Then recall and the events.
- **Run A:** chunks = the oracle's 256-splits. Words **and** the end hash must be EXACT.
- **Run B:** seeded random chunks of 1..300. Words must be EXACT (this checks that units do not depend on each other; F2 shows it on one patch).
- It prints the first differing word as (sample, slot).

**`jp8/tools/jp8_full_gate.sh`**
1. (optional) export the template + recall table.
2. Lift the 9 ROOTS with `--dyn` and build `libjp8.so` at -O2.
3. `jp8_full_emu`.
4. Run A.
5. Run B.
6. **Teeth.** Each must fail, and the gate prints its first failing line:
   - (T1) `-DJP8_FULL_TOOTH`: note skewed by one key.
   - (T2) lift `--tooth 0x38633e`: the FINE TUNE +0.0003 becomes −0.0003. It is reached through the recall on every patch.
   - (T3) `-DJP8_SNAP_TOOTH`: Control 1 must bite.
   - (T4) template without the stack region: Control 1 must bite (PORT_LESSONS 12).
7. Print the reach line.

Default patches: 2,63,10,0. For all 64, use `tools/run_job.sh`. Estimated cost: oracle about 20 s/patch, about 25 min for 64; the C side is under 1 min (INFERRED from F7).

Reach closure: a trap names an unlifted indirect target. Add it (`--dyn`), lift again, run again, and log which patch needed it.

**`jp8/tools/jp8_listen_law.py`** (refactor of `jp8_sweep.py`'s key_ok, early/late windows, release rule, 3 s tail rule, and `track_verdict`).

**`jp8/tools/jp8_listen_c.py`** (process B)
- All 64 patches at 44100. Idle 4096, runaway < 0.01 (patch 5's master floor is 1.1e-3 on the oracle).
- Keys 48/60/72: dry = sum of voice main words, plus the master; engine pitch cells at `jp8_unit_state(v)` + 0x16e0/0x16f0; the same law as the sweep.
- NaN census.
- Output: one table of C verdict against the oracle sweep verdict (`SWEEP_44100.md`). Any disagreement is a defect to triage.
- Estimated time: about 5 min for 64 patches (INFERRED).

## 3. The oracle's full-chain drive

**Snap or no snap:** snap, and exactly once, after host_init. Without a snap the drive is PROVEN broken (F1). The walker cannot settle a ramp whose step is NaN.
- Latch: leave it live. It is the plugin's own 960-sample warm-up mute, and the walker settles the recall ramps inside it.
- Recall: no snap after it. It runs live, like a host would.
- The MXCSR order (BUILD before FTZ) does not change the result (F3); use the `jp8_emu.boot` order.

**Steps that exist only in the harness.** The C API must copy each one verbatim:
1. Import stubs and the IAT pointing to 0x600000000 + 8·i. In C: `jp8_import` with the same shims; the template carries the IAT.
2. The ALLOC hook at 0x6F5B04: bump allocator, 16-byte rounding, minimum 16, cap 0x2000000, zero fill.
3. The fake-handle counter `_hc` (hc0 = 0x9020).
4. Page 0 as the gs base → JP8_GS_BASE.
5. The two entry rsp values (0x201FEFFF8 for direct calls, 0x201FEFFB8 for wrapper calls).
6. MXCSR written on every entry: 0x1F80 before `set_ftz`, 0x9FC0 after it.
7. `build()`: HOST = bump(0x8000) zeroed, and the three pointer tables.
8. SETSR with a float in xmm1 and the other lanes zero.
9. `host_init`: the 3 mapped writes.
10. `snap_ramps`. (`clear_latch` is not used.)
11. The recall order: units outer, then ASG_NOTIFY(4).
12. **The voice and master stubs** (§2, `jp8_render`). The lifter never saw them, because they are not in the image.

Not reproduced:
- Unicorn register residue (for example rbp at stub entry). This is INFERRED to be unused; F2 heap EXACT supports it.
- The stray page from the one static-init fault. Layer 3 and F2 run without it.
- Host RENDER 0x445DC0. D1 says it faults on a zero HOST. D3 says 48000 needs its resampler, so 48000 is refused.

## 4. Web shell (step 8): verdict

What the JX needed is listed in §1.

For the JP8:
- **Size is realistic:** about 0.72 MB gz of code + about 1.5 MB gz of template. Memory is about 130 MB (heap arena 112 MB, image 14.6 MB). emcc is not needed: clang wasm32 freestanding works (F5), with about 40 lines of JS glue.
- **Exactness is realistic, with work.** It is PROVEN only over 192 samples. FTZ changes the result by sample 27,370 (F6). So wasm needs `jp8_lift.py --soft-fp`:
  - DAZ on inputs, and FTZ with the hardware's tininess detection. The sibling's vectors in `../fp/hw.txt` show the tininess rule; their T3 case shows that "flush if the IEEE result is denormal" is wrong.
  - Soft MXCSR, plus a census proving every executed `ldmxcsr` keeps rounding at nearest. There are 16 sites, all in CRT math.
  - Prove it on x86 first: a native gate at MXCSR 0x1F80 with soft-fp must be EXACTLY 0 against the oracle. Then a node golden test compares the wasm words against the oracle refs of the full gate.
- **Live real time is not realistic today.** 35–36 µs/sample is 1.5–1.6 cores. With soft-fp it is probably about 2 cores (INFERRED). One AudioWorklet thread would underrun on every 128-frame quantum.
- **Honest scope:** an offline page first (render a phrase, then play it; bit-exact). Live play only after a ≥ 2× speedup. Two ways to get it:
  - lifter dead-flag elimination (gated) — every ALU op now computes all 5 flags;
  - worker threads. The units do not depend on order (F2), but threads need SharedArrayBuffer and cross-origin isolation. Pages and artifacts probably cannot give that (INFERRED).
- Native: 0.92 of one core at -O2, so real time is marginal on one core and good on two threads.
- Artifact: publish `engine.wasm` + `template.gz` through `files`. No base64 inlining is needed.

## 5. Order of work

1. Record F1 in `jp8/docs/S3_STATUS.md`, as PORT_LESSONS 13, and as a playbook entry: "EXACTLY 0 on a drive that fails step 4 is not a boot". Also PORT_LESSONS 14: the lifted `call` does not store the return address.
2. Oracle step 4 on the T1 drive: add `--drive t1` to `jp8_listen2.py`. Run patches 2, 10, 52, 63 and 0 (late window). About 1–3 min each. Do not continue until this is GREEN.
3. Translated runtime + lifter `JP8_HA` + runtime split. Re-run the layer 1/2/3 gates; they must stay EXACTLY 0 (F4 already shows it for layer 1).
4. `jp8_recall_export.py`, then `jp8_template_export.py` with its self-check.
5. `jp8.h` + `jp8_engine.c`. C smoke test: after init, zero ramps with a NaN step.
6. Full gate on 4 patches with all 4 teeth. Then 64 patches through `run_job`, run B, and 96000 on 4 patches. Close the reach on every trap.
7. `jp8_listen_law.py` + `jp8_listen_c.py` on 64 patches, with the agreement table against the oracle sweep.
8. Soft-fp + MXCSR census. Native 0x1F80 gate. FTZ tooth (drop DAZ in one helper; it must fail, or the report must state that no denormal was reached).
9. Web: offline page, node wasm golden test against the oracle refs, artifact.
10. Later: `jp8_param` + a param segment in the gate, multi-instance (move the runtime statics into the engine), lifter speedups, and the host RENDER layer for 48000.

## Scratch evidence (all under `.../scratchpad/design/ship/`)

- `bootdrv.c`, `bootdrv2.c`, `bootdrv3.c`: stage timings, no-snap scream, ramp census.
- `t1_emu.py` + `t1_p5/`: the oracle on the T1 drive.
- `t1_c.c`: T1 on the C twin, modes A and B, snap tooth.
- `vals.txt`: host_init and recall values.
- `wasm/`: `jp8_cpu.h` (translated), `rt_ship.c`, `drv.c`, `bench.mjs`, `lift_rt.c`, `lift_full_t.c`, the `engine_O2.wasm` / `engine_full_O2.wasm` builds, and the native `b_tr_O1` / `b_tr_O2` binaries.

Other agents are also working in the parent `design/` folder (`bench/`, `fp/`, `pass*.json`). I did not change their files.
