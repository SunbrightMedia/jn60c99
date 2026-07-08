# Power-on voice-0 baseline: (b) vs (c) resolution

**Question.** Our `juno_prepare.c` writes voice-0 with the ctor+setSampleRate state (b).
Snap-all produces a different state (c) for a set of coefficients. For each, does voice-0
actually render with (b) or with (c) at the first sample of the power-on default patch?

**VERDICT (one line): KEEP (b) for all 9 structural offsets. State (c) is a suspend-time
transient that never reaches the playback render path. `juno_prepare.c` is already correct;
NO baseline change is needed.**

This is proven from the binary's own code + execution of that code under Unicorn, not from
any capture.

---

## Scope (per coordinator's refinement)

The recalled offsets **3984 (Mod Sens DCO), 7360 (Mod Sens VCF), 5520 (Duty Tune)** are
dispatch-written per patch (dispatch 860/861, and 856/CONDITION) — dropped from scope; recall
owns them. See "Recalled offsets" at the bottom.

The TRUE structural set (never recalled, no dispatch writes them) is these 9, all plugin/(c)=0
vs our/(b)=nonzero:

| off | name | (b)=ours | (c)=snap-all | verdict |
|---|---|---|---|---|
| 1952 | LFO Sin Sw | 1.0 | 0.0 | **KEEP (b)=1.0** |
| 2080 | LFO Internal Sw | 1.0 | 0.0 | **KEEP (b)=1.0** |
| 4016 | LFO Gain | 1.0 | 0.0 | **KEEP (b)=1.0** |
| 4048 | LFO Sw | 1.0 | 0.0 | **KEEP (b)=1.0** |
| 6512 | Osc1 Level | 1.00736 (0x3f80f154) | 0.0 | **KEEP (b)** |
| 7440 | Velocity Offset | -0.503937 (0xbf010204) | 0.0 | **KEEP (b)** |
| 9104 | -24dB/oct Tap | 1.0 | 0.0 | **KEEP (b)=1.0** |
| 9616 | AMP FIX VELOCITY | 0.93 (0x3f6e147a) | 0.0 | **KEEP (b)** |
| 10304 | ENV LEVEL | 1.0 | 0.0 | **KEEP (b)=1.0** |

Every one of these 9 values already present in `src/juno_prepare.c` matches (b) exactly →
the file needs no edit.

---

## The mechanism (why (b), not (c)) — the smoother architecture

These offsets are all **smoother output cells**. The engine holds a vector of 40-byte smoother
descriptors (at `ST+88 .. ST+96`, 798 of them; 73 belong to voice-0). Descriptor layout
(recovered from the code below):

```
+0   pointer to the OUTPUT cell in the engine state (the coefficient voice_render reads)
+8   ramp increment (float)
+12  accumulated increment (float)
+16  ramp start value (float)
+20  TARGET (float)
+24  sample rate / steps-scale (=96000)
+28  ACTIVE flag (byte)          <-- gate
+32  interval length (int, =10)
+36  interval counter (int)
```

Three operations touch the output cell. Two are relevant, and they behave differently:

### 1. Per-block advance / tick — the PLAYBACK path (leaves (b) untouched)

`sub_7FF91E0224A0` @ rva 0x3C24A0 is the per-block "advance active smoothers" loop. It walks a
**work-queue of active-smoother indices** (`a1[14]..a1[15]`) and ticks each via
`sub_7FF91E022E00` @ rva 0x3C2E00. The tick's first instruction is the gate:

```c
// sub_7FF91E022E00  (rva 0x3C2E00), decomp_3C0000.c:1821
char sub_7FF91E022E00(a1) {
  if ( *(_BYTE *)(a1 + 28) ) {           // <-- ONLY advances if ACTIVE flag set
     ... ramp *output toward target ...
  }
  return 0;                               // inactive => returns without touching *output
}
```

A smoother is only added to the active queue when its **target is changed** by set-target
`sub_7FF91E022E80` @ rva 0x3C2E80 (which sets `+28 = 1` and enqueues the index, via
`sub_7FF91E022920`). **The 9 cells are never set-targeted by anything** (see next section), so
they are never enqueued, never ticked, and their output cell keeps the value the constructor
wrote — i.e. (b) — for the entire session.

### 2. snap-all — the SUSPEND path (produces (c), never seen at playback)

`sub_7FF91E0229B0` @ rva 0x3C29B0 iterates the WHOLE smoother vector and calls
`sub_7FF91E022E60` @ rva 0x3C2E60 on each:

```c
// sub_7FF91E022E60 (rva 0x3C2E60), decomp_3C0000.c:1857
**(_DWORD **)a1 = *(_DWORD *)(a1 + 20);   // *output = target, UNCONDITIONALLY (ignores +28)
*(a1+36)=0; *(a1+12)=0; *(a1+28)=0;
```

Because it ignores the active flag, snap-all forces `output = target` for the *inactive* 9
smoothers, whose targets are 0 → this is exactly the (c) delta. **This is the only code that
produces (c).**

**snap-all's only reachable caller is the deactivate/suspend routine.** grep proves snap-all
(0x3C29B0) has one wrapper `sub_7FF91E021060` (0x3C1060), whose single caller is
`sub_7FF91E026DC0` (0x3C6DC0). That function *stops and JOINS the 8 worker threads*
(`_InterlockedExchangeAdd(v2, 0x80000000)` + `SetEvent`, then `std::thread::join` — the decomp
even contains the string `"boost thread: trying joining itself"`) before snapping. You join
worker threads on **deactivate/suspend**, never on activate. So snap-all runs when audio
processing STOPS, resetting smoother outputs to a clean state — it does not run before the
first rendered sample.

### 3. The constructor establishes (b) and never snaps

`sub_7FF91E0268D0` (0x3C68D0, "BUILD") sets the output cells directly to their computed DSP
defaults (6512=1.00736, 9616=0.93, 7440=-0.503937, the LFO one-hots/gain=1.0, ENV LEVEL=1.0)
and prepares the smoother container via `sub_7FF91E021040` (per-smoother setSR) +
`sub_7FF91E021050` (finalize) — decomp_3C0000.c:4979-4980. It does **not** call the snap
wrapper `sub_7FF91E021060`. So construction leaves every one of the 9 with:
`output=(b)`, `target=0`, `active(+28)=0` (verified by emulation, below).

---

## Evidence from executing the binary's own code (Unicorn)

Harness: `scratchpad/oracle/emu2.py` (BUILD @0x3C68D0, setSampleRate @0x3C7A20 with
XMM1=float32(96000), snap-all @0x3C29B0, advance @0x3C24A0).

**A. Smoother state after BUILD+setSR (state b)** — all 9 are INACTIVE with target 0
(`scratchpad/active_flags.py`):

```
 off  name             output     target  act+28  cnt+12  steps+32
1952  LFO Sin Sw       1.0        0        0       0       10
2080  LFO Internal Sw  1.0        0        0       0       10
4016  LFO Gain         1.0        0        0       0       10
4048  LFO Sw           1.0        0        0       0       10
6512  Osc1 Level       1.00736    0        0       0       10
7440  Velocity Offset  -0.503937  0        0       0       10
9104  -24dB/oct Tap    1.0        0        0       0       10
9616  AMP FIX VELOCITY 0.93       0        0       0       10
10304 ENV LEVEL        1.0        0        0       0       10
```

**B. Running the plugin's OWN per-block advance `sub_7FF91E0224A0` 2000 times (no snap) leaves
all 9 at (b)** (`scratchpad/advance_test.py`) — i.e. the actual runtime processing loop never
moves them:

```
1952 1.0->1.0  2080 1.0->1.0  4016 1.0->1.0  4048 1.0->1.0
6512 1.00736->1.00736  7440 -0.503937->-0.503937
9104 1.0->1.0  9616 0.93->0.93  10304 1.0->1.0   (all MATCH)
```

**C. No value-tree dispatch writes any of the 9.** Full sweep of every engine-writing dispatch
(census WRITERS) over values {0,1,2,64,128,255} through the plugin's own value-tree dispatch
`sub_7FF91E019A30` (`scratchpad/lfo_dispatch_test.py`): none of 1952/2080/4016/4048 (nor
1968/1984/2000/2016/2032/2048/2096/2112/4000) is ever written. 6512/9104/9616/10304 likewise
have no dispatch writer. Only neighbors that ARE dispatch-driven: 2064 (Noise Mix, disp
752/878), 3984 (disp 860), 4032 LFO Level (disp 753).

**D. No patch recall writes any of the 9.** Ran the recall oracle over all 64 factory patches
(`patch_oracle2.py all` -> `patch_state2/patch_*.json`): union of offsets any patch writes =
61 offsets; **none of the 9 is in it.** (3984/5520/7360 ARE written by all 64 — the recalled
trio.)

**E. voice_render (sub_180369070 / `src/voice_render.c`) only READS the 9** — none appears on
an LHS; grep confirms all 9 are read-only there, and `src/juno_note.c` (note-on) writes none of
them. So nothing on the render/note path rewrites the cell either.

Chain A+B+C+D+E ⇒ these 9 cells are set once by the constructor (=b) and are never modified by
any dispatch, recall, note-on, or the per-block smoother advance. They render at (b). (c) is
only reachable via the suspend-time snap-all.

This matches the coordinator's silence-on-zero experiment: zeroing 6512/9104/9616/10304 kills
the voice precisely because those are the load-bearing gains the constructor set to (b) and the
plugin genuinely renders with. If (c)=0 were the render value the real plugin would be silent
at power-on, which it is not.

---

## Per-offset verdict + reason

- **6512 Osc1 Level = 1.00736 — KEEP (b).** DCO osc-mix gain (voice_render.c:1120,
  `JF(6544)=v199*JF(6528)+v198*JF(6512)`). Inactive smoother, no writer. (c)=0 would mute
  osc1. INVARIANT.
- **9104 -24dB/oct Tap = 1.0 — KEEP (b).** VCF slope tap gain
  (voice_render.c:1353/1388/1423/1457). Inactive smoother, no writer. (c)=0 would kill the
  filter output tap. INVARIANT.
- **9616 AMP FIX VELOCITY = 0.93 — KEEP (b).** Amp fixed-velocity level
  (voice_render.c:1491, `JI(9664)=JI(9616)`). Inactive smoother, no writer. (c)=0 silences the
  VCA fixed-velocity path. INVARIANT.
- **10304 ENV LEVEL = 1.0 — KEEP (b).** Final amp/env level gain (voice_render.c:1561,
  `v362=v360*JF(10304)`). Inactive smoother, no writer. (c)=0 mutes the voice. INVARIANT.
- **4016 LFO Gain = 1.0 — KEEP (b).** LFO→DCO multiplier (voice_render.c:1060-1071,
  `v176=v170*JF(4016)`, `v180=v176*JF(4032)`, `v182=v175*(JF(4016)*JF(1808))*JF(4000)`).
  Inactive smoother, no writer. Plugin renders 1.0. INVARIANT.
- **4048 LFO Sw = 1.0 — KEEP (b).** Gate on the LFO→DCO term (`v181=JF(4048)`, `v185 +=
  v181*v180`, voice_render.c:1070,1076). Inactive smoother, no writer. INVARIANT.
- **1952 LFO Sin Sw = 1.0 — KEEP (b).** Sine-shape mix coefficient in the LFO waveform sum
  (voice_render.c:928, `... + v117*JF(1952)`). Inactive smoother, no writer. INVARIANT.
- **2080 LFO Internal Sw = 1.0 — KEEP (b).** Internal-LFO-source gate on the composed LFO
  output (voice_render.c:925,932-934, `JF(1792) = ext.. + v119(2080)*v120*v121`). Inactive
  smoother, no writer. INVARIANT.
- **7440 Velocity Offset = -0.503937 — KEEP (b).** VCF velocity offset term
  (voice_render.c:1187, `(JF(7440)+JF(7248))*JF(7504)*JF(7424)`). Inactive smoother, no writer.
  Reported "inert" in the RMS test only because current test patches/notes don't exercise that
  bias audibly, but the plugin still holds -0.503937, so (b) is the faithful value. INVARIANT.

All 9: KEEP (b). There is no offset where (c) is correct.

---

## LFO-gain-zero risk — resolved

The worry was that copying (c) would zero 4016 and kill LFO→DCO for LFO patches. Resolution:

1. We must NOT zero 4016 — the plugin renders it at **1.0** (constructor value; inactive
   smoother; no dispatch/recall/note writer; per-block advance leaves it at 1.0). Keeping (b)=1.0
   is exactly faithful. So the risk is avoided by keeping (b), which is independently the correct
   answer.
2. The LFO *depth* does not live in 4016 anyway. In voice_render the DCO LFO depth is
   `JF(4032)` "LFO Level" and the VCF LFO depth is `JF(7344)` "LFO Level"; both ARE recalled
   (4032 via dispatch 753). 4016/4048 are unity gates/normalizers around them. This is why the
   coordinator's wobble test showed LFO depth unchanged (0.754 vs 0.757) when 4016 was zeroed —
   the depth is carried by 4032/7344. So neither zeroing nor keeping 4016 changes LFO depth; but
   the plugin's value is 1.0, so keep 1.0.

Net: the LFO is fully functional with the (b) baseline. Zeroing (moving to (c)) would be the
regression, not keeping (b).

---

## Recalled offsets (out of scope, for completeness)

3984 Mod Sens DCO (0.0862745 = 22/255), 7360 Mod Sens VCF (0.862745 = 220/255), 5520 Duty Tune
(0.02) — these ARE the genuine default-patch smoother targets and, unlike the 9, they ARE
dispatch/recall-driven (3984←disp860, 7360←disp861, 5520←CONDITION/disp856; written by all 64
patches). Their smoother targets were set to those default values at construction, so snap-all's
(c) values equal the power-on default. For these three the baseline only affects the UNAPPLIED
(no-patch) sound; any loaded patch overwrites them via recall. If you want the unapplied sound to
match the machine's power-on default, the correct baseline is the (c)/target value
(0.0862745 / 0.862745 / 0.02), not the ctor placeholder — but this is a recall-owned region, so
it does not affect any patch's rendered sound. (Coordinator already handles these via recall.)

---

## Flagged / underivable

- Nothing underivable for the 9. Every verdict is backed by the binary's code (functions cited)
  and by executing that code under Unicorn.
- One reasoned (not byte-fetched) link: that `sub_7FF91E026DC0` is specifically the
  deactivate/suspend virtual slot rests on (i) its thread-stop+join body, (ii) snap-all being
  reachable only through it, and (iii) the empirical fact that the plugin is not silent at
  power-on (so (c) cannot be a pre-render state). I did not resolve its exact VST3 vtable index.
  This does not affect the verdict: even if snap-all were somehow invoked before playback, the 9
  targets are 0 and would zero the voice, which contradicts observed behavior — so the render
  state is (b) regardless.
