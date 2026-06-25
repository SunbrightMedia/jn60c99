# Parameter registry — the static DB→engine bridge (extracted from sub_180388170)

## The breakthrough

For a long time this port treated the **preset → engine-coefficient** binding as
"runtime-only, not statically reconstructable" (a red-black tree built at load
time), and leaned on live captures for per-patch continuous coefficients. **That
was wrong, and it was an artifact of one tool failure:** the function that builds
the bindings, `sub_180388170` (rva `0x388170`), is ~12.4 K lines of assembly that
**Hex-Rays decompiled to `None`**. So every binding it creates was invisible in the
`.c` decompile — which is exactly why grepping the `.c` files for a writer of, say,
the chorus coefficient `6395312` returned nothing, and why the bridge looked
runtime-only. The code was there the whole time, just in asm.

## What the registry is

`sub_180388170` registers **1121 named engine parameters**. Each registration is a
fixed asm idiom:

```
movdqa xmm0, cs:xmmword_7FF91E5EC030   ; shared descriptor template (range/curve/flags)
lea    rax, aChorusCv ; "Chorus CV"     ; the parameter NAME
mov    [rbp+var_D0], rax
lea    rax, [rdi+6195B0h]               ; the ENGINE COEFFICIENT SLOT (rdi = state base; 0x6195B0 = 6395312)
mov    [rbp+var_B0], rax
...
call   sub_7FF91E00BA00                 ; register: name -> slot, into the param container at [rdi+38h]
```

So each call binds **parameter name → engine state offset**. `rdi` is the state
base, so the offsets are the same absolute coefficient offsets the DSP reads
(verified: `Chorus CV` → 6395312, which `master_render` reads for the chorus LFO
rate). 1118 of 1121 share the descriptor template `xmmword_7FF91E5EC030`, so the
template is a generic CV descriptor, **not** a per-param value — the per-param value
arrives via the apply path (curve table keyed by the registration, indexed in
`refs/param_registry.json` as `idx`).

Full extraction: **`refs/param_registry.json`** (offset, hex, name, idx, descriptor),
produced by parsing `allcode/asm_380000.asm` lines 6153–18565.

## What it immediately settled (the chorus)

The chorus block (the v39 "Delay/Chorus" slot) owns this named parameter set —
note the **real depth control is `LFO Depth` (6396176)**, not the offset `6395328`
(which is `Chrus LFO Sync`) that the raw DSP math had made me call "depth":

| offset | name | PD-capture value |
|--:|---|--:|
| 6395312 | Chorus CV (LFO rate) | −5.32549 |
| 6395328 | Chrus LFO Sync | 1.0 |
| 6396128 | Delay Time | 0.05847 |
| 6396160 | LFO Manual | 0.5 |
| **6396176** | **LFO Depth** | **1.0** |
| 6396368 / 6396384 | Dry / Wet Level | 1.0 / 1.0 |
| 6396496 / 6396512 | Dry / Wet Gain | 0.708 / 1.413 |

The FX-A slot (6429xxx) is likewise named — it is a **Flanger** (`Flanger CV`
6429472, `Flanger LFO Sync` 6429488), confirming the Finding-4 conclusion that the
`v551` slot is a separate System-8 effect, not a second chorus.

## What's still needed (and is now a *data* hunt, not a capture)

The registry gives name→slot for all 1121 params. Two pieces remain to compute a
specific patch's chorus coefficients fully from static data:

1. **The apply curve per param** — the transform from a patch step to the stored
   float. Partially recovered (`refs/param_curves.json`, `refs/param_table_full.json`,
   `sub_356380` in `src/juno_params.c`); needs joining to these `idx` values.
2. **CH1's preset values** — what "JUNO Chorus mode = CH1" sets `Chorus CV` /
   `LFO Depth` / `Wet Level` to. This is factory FX-preset data (the System-8 FX
   algorithm preset for "JUNO Chorus I"), applied through the bindings above. Our
   current chorus values are the **PD-Juno-Pad** capture; whether they equal CH1's
   canonical values (i.e. whether PD-Juno-Pad also used CH1) is the open question
   for the "exaggerated depth". Next step: locate the FX-preset table / mode handler
   that writes these slots when CH1 is selected.

The headline: the bridge is **static and extracted**. No capture is required to know
*which* coefficient each parameter drives — only to (still) confirm the few CH1
preset values, which is now a bounded data hunt in the binary.
