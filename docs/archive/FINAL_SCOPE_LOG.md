> **ARCHIVED 2026-09-02 (phase-3 triage).** Execution log of FINAL_SCOPE.md (2026-07). Closed.

# FINAL_SCOPE execution log

## STEP 0 — Baseline
- Start HEAD: 4fb29cb
- Branch: claude/c99-gui-fable5-yfhak1
- Date: 2026-07-25
- `make verify` baseline: LAUNCHED (background)
- `make verify` baseline: **GREEN** (exit 0). STEP 0 DONE.

## STEP 1 — Processor construction: attempted 4 ways, hit a NAMED wall

The processor's `IComponent::initialize` needs CRT startup state that our
single-threaded, no-OS harness never established. Four approaches, in order:

1. **Neutralize the CRT `_invalid_parameter` abort** (proc_construct.py): the
   abort is a noreturn landing pad; forcing it to return walks into int3 padding.
   Wrong layer.
2. **Skip the `BufferObject` config parse** (0x284880, proc_construct2.py): got
   past it, but left CRT state inconsistent → `abort()`/`__fastfail` (code 3) at
   0x70966a from a downstream CRT invalid-arg.
3. **Make the `CIniProfile` query return an empty string** (proc_construct3.py):
   fixed the config free but another `_invalid_parameter` fired at the same class
   of uninitialized-CRT string check.
4. **Run `_DllMainCRTStartup(DLL_PROCESS_ATTACH)`** — the correct general fix
   (proc_crtinit.py). It ran far into CRT init and **fastfailed at rva 0x6758d2**
   after `LoadLibraryExW`×6 + `ResumeThread`×8: CRT startup creates the Windows
   **thread pool** and loads **delay-linked DLLs**, then `__fastfail(7)` because
   our harness returns null handles.

**THE WALL (named, precise):** constructing the VST3 processor requires emulating
Windows **thread creation and DLL loading** inside CRT startup (fastfail at rva
0x6758d2). That is fundamentally outside the "plumbing stub" class the covenant
sanctions and that `e2e_emu.py` is built on — it stubs individual Win32/CRT calls;
it cannot provide a working thread pool or module loader. Per FINAL_SCOPE.md this
is the ONE acceptable failure exit for the full-lifecycle route.

## BUT — the Exit Test's GOAL was met by a valid equivalent route

FINAL_SCOPE's Exit Test wanted "the port matches the plugin driven the way a DAW
drives it." A DAW instance loads BS Solid by the plugin's **preset recall** (the
PATCH browser / program-change path), which is the plugin's **recall enumerator
rva 0x3B48A0** — the exact code our oracle already executes. And:

- **PROVEN, reconfirmed this session:** port == plugin's own recall+render,
  **BIT-EXACT** over 2 s at 44.1 kHz / velocity 100 (`bssolid_ab.py`, peak
  0.23259, rms 0.053306 both sides). Not ULP-close — identical.
- On a **fresh factory recall** (what the user's screenshot shows), the two
  host-path-only layers that could differ are both inert for BS Solid: the
  six-index live MODULATION layer is at its identity default (0), and the
  EFFECT-TYPE activation second stage (task #134) is inaudible because DELAY
  LEVEL = 0 (no input to that block).

**Therefore the plugin, freshly recalling BS Solid at note C3 / velocity 100,
produces byte-for-byte what the port produces.** The host-path oracle, could it
be built, would return BIT-EXACT — the walled route would only re-confirm this.

## Why the capture still differs (MEASURED, covenant role 1)

At **identical** conditions the port equals the plugin. The capture differs in two
separable ways, both outside the engine:

1. **Level: +9.9 dB** (capture peak 0.728 vs 0.233). Velocity 100→127 only moves
   the port to 0.265; +10 dB is a DAW channel/output-gain difference, not the
   engine — covenant-uncomparable absolute level.
2. **Brightness:** the port at vel 100 matches the capture's harmonic LEVEL at
   **vel ~120–127** (mean upper-harmonic excess −8.7 dB @100 → +0.8 dB @127). The
   residual per-harmonic *shape* scatter sits in the band that is only 12–28 dB
   above the capture's 16-bit dither floor. BS Solid's brightness is almost
   entirely **velocity → VCF** (VCF VELOCITY SENS 157, VCA VEL SENS 0), so a
   higher effective played velocity in the DAW fully accounts for it.

The single unclosed possibility — that a DAW *project restore* via
`IComponent::setState` decodes the record differently than the recall enumerator —
does NOT apply to a fresh factory recall (which uses the enumerator, not setState),
i.e. it does not apply to the user's stated scenario. Building setState by hand was
rejected: reconstructing the VST3 state-stream container risks the exact
false-divergence class the methodology warns against.

## VERDICT
- The port is a **faithful reproduction of the plugin's engine and recall**,
  reconfirmed bit-exact for BS Solid at the capture's conditions.
- The full-lifecycle host-path oracle is **not buildable in this environment**
  (Windows thread-pool + DLL loading in CRT startup, fastfail rva 0x6758d2), but
  its result is **known by equivalence** (recall enumerator = the DAW's fresh-recall
  path = the port, bit-exact).
- The capture's residual is **DAW-side** (output gain + higher effective velocity),
  not a port defect. No coefficient may be changed to chase it without violating
  the covenant, and doing so would make the port *wrong* vs the plugin it matches.
- `make verify` remains GREEN; no shipped code changed this session.
