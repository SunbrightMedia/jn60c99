# master_render (sub_180363380) — transcription map & dropped-arg resolutions

`sub_180363380` is the **master process**: 8-voice mix → stereo BBD chorus
(multi-mode) → true-stereo output. Source: `sub_180363380` in the full decompile
(`refs/allcode_decomp.tgz`, file `decomp_360000.c`; 2875-line Hex-Rays body). Ported to
`src/master_render.c` by `tools/translate_master.py`.

## Method
The body is kept **verbatim** — IDA's `_DWORD/_QWORD/_WORD/__int16` types and
`LODWORD` are provided as typedefs/macros, and `a1` is an `unsigned char *`, so
every `*(float *)(a1 + N)` cast, circular-buffer index expression, `goto`/label,
and the host-params pointer chase compiles directly as C. Verbatim = safest:
the whole algorithm is preserved bit-for-bit; only the lines Hex-Rays mangled are
rewritten. Those rewrites are the table below, each pinned to the disassembly
(`master_deps/master_sub_180363380_180363380.asm`) — none guessed.

## Signature / I/O
`float *juno_master_render(unsigned char *a1, float **a2, float **a3)`
- `a2[0,2,4,…,14]` = the 8 voice current-sample pointers (read at decompile
  785–808). Odd indices unused.
- Output (decompile 2892–2894): `*a3[0] = 2*JF(101264)`, `*a3[1] = 2*JF(101280)`.
- Chorus mode selectors are read through a **host-params object**:
  `v39  = **(int**)(*(void**)(a1+136) + 136)` (line 844) and
  `v551 = **(int**)(*(void**)(a1+136) + 112)` (line 2329). The driver must store a
  valid pointer at `a1+136`; mode `0` selects the dry/bypass path.

## Dropped-XMM-argument resolutions (from the .asm)

The three chorus **LFO stages** are structurally identical; Hex-Rays fully
rendered stage 1 but **dropped the entire phase-increment block** (and the helper
args) in stages 2 and 3. Each was reconstructed from the asm, which is unambiguous.

| decompile | helper | asm addr | recovered argument |
|-----------|--------|----------|--------------------|
| 1239 (stage1) | `juno_pitch_poly` | 0x180365139 | `(double)(JF(6395312)+JF(6395408))` |
| 1242 (stage1) | phase load | 0x18036516E | `v256 = JF(6395600)` (float carrier) |
| 1260 (stage1) | `juno_triangle` | 0x1803651E9 | `v256` (wrapped phase) |
| 1622 (stage2) | `juno_pitch_poly` | 0x1803647E4 | `(double)(JF(10692016)+JF(10692112))` |
| 1626 (stage2) | `juno_wrap_hi` + incr | 0x18036485F | incr=`JF(10692080)*JF(10692352)`, ±2/±4 wrap, `==0→JF(10692368)`; arg=`JF(10692304)+incr` |
| 1628 (stage2) | `juno_triangle` | 0x180364867 | `v102` |
| 1835 (stage3) | `juno_pitch_poly` | 0x180365139-twin 0x180364... | `(double)(JF(6429472)+JF(6429568))` |
| 1839 (stage3) | `juno_wrap_hi` + incr | 0x18036... | incr=`JF(6429536)*JF(6429808)`, ±2/±4 wrap, `==0→JF(6429824)`; arg=`JF(6429760)+incr` |
| 1841 (stage3) | `juno_triangle` | — | `v181` |

Stereo-output BBD LFOs (`juno_wrap_unit`, arg dropped):

| decompile | asm addr | recovered argument |
|-----------|----------|--------------------|
| 2603 | 0x1803674C3 | `JF(96176)+JF(96144)+JF(96352)` |
| 2734 | 0x180367A9C | `JF(90672)+JF(90640)+JF(91152)` |
| 2771 | 0x180367C71 | `fabs(wrap_unit(JF(90656)+JF(91168)))` |

`juno_wrap24` at 2743/2746 (`-v597`, `-v599`) kept the args in the decompile —
only the name was swapped. The four float-carrier temporaries Hex-Rays typed
`double` (v102, v181, v256, v553) are retyped `float` (they only ever hold the
low 32 bits used by the surrounding `*(float*)&` reads).

The `±2/±4` wrap in the increment block is exactly stage 1's (decompile 1246–1254):
`if (i<4){ if(i>=2) i-=2; } else i-=4;  if(i==0) i=fallback;` — confirmed identical
in the asm for all three stages.

## Missing data (not a transcription gap)
The ~250 chorus/output coefficients are written by `sub_180388170`, on which
Hex-Rays returns None. Run `tools/extract_chorus_coeffs.py` in IDA to capture its
disassembly. Until then those fields are zero: the chorus is inert and the output
saturator (decompile 2305–2326) collapses toward silence. The algorithm in
`master_render.c` is complete and exact regardless.
