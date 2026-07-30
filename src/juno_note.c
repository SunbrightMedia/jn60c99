/* juno_note.c — faithful note-on / gate / pitch driver for the JUNO-60 port.
 *
 * This is a bit-exact transcription of the plugin's note control surface, derived
 * from the binary's own parameter-descriptor table (docs/param_routing.json, built
 * by RUNNING the plugin's descriptor-build code under the Unicorn oracle) and the
 * transcribed DSP (src/voice_render.c). No captures, no fitted curves.
 *
 * ---------------------------------------------------------------------------
 * THE CONTROL SURFACE (binary-derived)
 * ---------------------------------------------------------------------------
 * The engine exposes 110 parameters per voice; a note event writes three of them,
 * all flagged en=0 in the descriptor table, i.e. IMMEDIATE writes (`*target = v`),
 * NOT smoothed ramps (en=1 params route through the smoother subsystem):
 *
 *   param   1  M.CV     off 304   note pitch   (immediate)
 *   param   2  M.Gate   off 320   ADSR gate    (immediate)
 *   param 927  Voice0 Note Off Notify off 101504 (+voice*32)  DCO retrigger latch
 *
 * (Per-voice: voice v adds v*JUNO_VOICE_MAIN_STRIDE to the M.CV/M.Gate offsets and
 *  v*JUNO_VOICE_AUX_STRIDE to the aux latch.)
 *
 * ---------------------------------------------------------------------------
 * PITCH  ->  M.CV (offset 304), immediate
 * ---------------------------------------------------------------------------
 * voice_render feeds the DCO pitch spline with clamp(state[4448]+state[3776]); the
 * dominant term reduces (portamento off => glide conditioner frozen, state[240]==
 * state[272]==0) to v28 == state[304]. state[4448] = -4.75 is the fixed DCO tune
 * written by init and shared by every voice/patch (DO NOT touch it). Measured
 * ground truth (RUNNING the plugin's own note-on under Unicorn for all 128 notes,
 * scratchpad/oracle/id_feet_mcv_probe.py): the plugin writes
 *     state[304] = (midi_note - 12)/12 + tune_offset(note),
 * NOT midi_note/12. The tune_offset is a small per-note analog stretch (<=~2.5
 * cents). We store the plugin's exact 128 per-note bits (juno_mcv_bits[]) so pitch
 * is bit-identical.
 *   HISTORY: an earlier version wrote midi_note/12 (one octave too high). That was
 *   masked in the web build by a SECOND, compensating bug — the DCO-RANGE recall
 *   spuriously wrote 0.5 into the "feet" cell 3840 (one octave too low), which the
 *   plugin leaves at its prepare default of 1.0. The two octave errors cancelled on
 *   pitch but NOT on amplitude/timbre (the pitch spline is not exactly exponential),
 *   leaving every patch ~1.3x off in level. Both are now fixed; see docs/COLDLOAD_AB.md.
 *
 * ---------------------------------------------------------------------------
 * GATE  ->  M.Gate (offset 320), immediate
 * ---------------------------------------------------------------------------
 * voice_render collapses the gate to a BINARY signal state[560] (voice_render.c:
 * 636 v29==state[320] because state[240]*state[272]==0; :661-669 state[560] = 1.0
 * iff v29>0 else 0.0), and both ADSRs multiply their input by state[560]
 * (:944 v124=state[560]*v123 ; :999 v146=state[560]*v145). So the ONLY thing that
 * opens/closes the gate is the sign of state[320]. The descriptor flags M.Gate
 * en=0 => the plugin writes it IMMEDIATELY (a positive constant on note-on, 0 on
 * note-off), it does NOT ramp it. We do exactly that. Because state[560] is binary,
 * the exact positive magnitude is audio-irrelevant; 1.0 yields the identical gate
 * edge that drives both ADSRs.
 *
 * ---------------------------------------------------------------------------
 * DCO RETRIGGER  ->  aux latch Array A (offset 101504 + voice*32)
 * ---------------------------------------------------------------------------
 * voice_render consumes a per-voice one-shot latch state[101504+voice*32]==1.0 on
 * a sample (voice_render.c:566-572 forces the gate to 0 for that one sample and
 * clears state[320]; :2141-2149 restores state[320] and clears the latch) to reset
 * DCO phase. CORRECTED (measured from the plugin's own code under Unicorn): this
 * latch (call it Array A) is armed to 1.0 for all 8 voices ONCE at engine BUILD
 * (juno_init.c), NOT by note-on. Each voice's first rendered sample consumes its
 * own slot, so a cold first note resets DCO phase; thereafter the DCO free-runs.
 * The plugin's note-on writes a DIFFERENT, DSP-inert cell — aux Array B at
 * 101520+voice*32 — never Array A. An earlier port armed Array A on every note-on;
 * that re-phased the DCO on notes played after rendering had begun (wrong; only
 * masked in the cold single-note A/B because there note-on precedes any render).
 * See scratchpad/oracle/latch_{probe,reads,arm_when}.py.
 *
 * ---------------------------------------------------------------------------
 * WHAT WE DELIBERATELY DO NOT DO
 * ---------------------------------------------------------------------------
 * No parameter in the descriptor table targets the ADSR integrator/level slots
 * (ENV1 2592/2720, ENV2 3072/3200) — verified across all 1121 descriptors. The
 * envelope is pure DSP state: it attacks from the M.Gate rising edge and releases
 * from the falling edge, entirely inside voice_render. So we do NOT hand-reset the
 * envelope (an earlier version zeroed 2592..3248 — that was an approximation the
 * plugin never performs; it caused an onset click and a slow swell). The snappy
 * attack on a replayed note comes from the voice allocator handing the note a voice
 * whose gate has already fallen (note-off -> gate 0), so note-on's gate 0->1 edge
 * re-attacks cleanly. We drive M.Gate immediately; the bit-exact DSP does the rest.
 *
 * Velocity (params 73/98, immediate) IS now written: note-on sets 6864 =
 * juno_curve(56, velocity) (VCF) and 9680 = juno_curve(57, velocity) (VCA), the
 * raw MIDI velocity through the plugin's own gate-notify curves. Proven bit-exact
 * by driving the plugin's dispatch over a full velocity sweep under emulation
 * (see scratchpad/oracle/velocity_coeff_findings.md); no longer capture-sourced.
 */
#include "juno_engine.h"
#include "juno_note.h"
#include "juno_curve.h"
#include <string.h>

/* Per-voice absolute state offsets (relative to voice base = voice*STRIDE). */
#define VBASE(v)    ((unsigned int)(v) * JUNO_VOICE_MAIN_STRIDE)  /* v*10512 */
#define PITCH_OFF   304    /* M.CV   — per-voice DCO note pitch (= note/12)    */
#define GATE_OFF    320    /* M.Gate — per-voice binary gate conditioner       */
#define TUNE_OFF    4448   /* fixed DCO tune (-4.75), set by init; DO NOT write */
#define AUX_EDGE(v) (JUNO_VOICE_AUX_BASE0 + (unsigned int)(v) * JUNO_VOICE_AUX_STRIDE)

/* Gate is binary in the DSP; any positive magnitude opens it identically. */
#define GATE_OPEN   1.0f

/* juno_mcv_bits[128]: MIDI note -> M.CV(304) pitch CV, captured from the plugin's
 * OWN note-on under Unicorn (parameter 1, immediate write). The base is exactly
 * (note-12)/12; the small per-note residual is the analog stretch-tune offset the
 * plugin applies (<=~2.5 cents). Stored as exact IEEE-754 bits so note pitch is
 * bit-identical to the plugin. Generated by scratchpad/oracle/id_feet_mcv_probe.py. */
static const unsigned int juno_mcv_bits[128] = {
    0xbf7fffa8u, 0xbf6aa7e8u, 0xbf555228u, 0xbf3ffcd0u, 0xbf2aa760u, 0xbf1551b8u,
    0xbefff830u, 0xbed54dc0u, 0xbeaaa2e0u, 0xbe7fef00u, 0xbe2a98e0u, 0xbdaa8540u,
    0x38a80000u, 0x3daad540u, 0x3e2ac260u, 0x3e800d30u, 0x3eaab860u, 0x3ed56430u,
    0x3f0007f0u, 0x3f155d60u, 0x3f2ab318u, 0x3f400850u, 0x3f555edcu, 0x3f6ab3f0u,
    0x3f800d2eu, 0x3f8ab8f2u, 0x3f956426u, 0x3fa01054u, 0x3faabbeau, 0x3fb567aeu,
    0x3fc012ecu, 0x3fcabe86u, 0x3fd56af4u, 0x3fe0169eu, 0x3feac2fcu, 0x3ff56de8u,
    0x400004f7u, 0x40055ac1u, 0x400ab041u, 0x4010063cu, 0x40155be9u, 0x401ab1acu,
    0x40200729u, 0x40255d70u, 0x402ab38cu, 0x40300892u, 0x40355e98u, 0x403ab3e3u,
    0x404001b8u, 0x4045582cu, 0x404aac9au, 0x40500356u, 0x405557d0u, 0x405aad55u,
    0x406003b6u, 0x40655890u, 0x406aae62u, 0x4070031bu, 0x40755a40u, 0x407aaf48u,
    0x407ffcd7u, 0x4082aa5du, 0x4085547au, 0x4087ffbcu, 0x408aa9dcu, 0x408d547fu,
    0x408fff8fu, 0x4092a8a1u, 0x4095549du, 0x4097fed2u, 0x409aaa3au, 0x409d5493u,
    0x40a001acu, 0x40a2ac16u, 0x40a55820u, 0x40a8039au, 0x40aaabe8u, 0x40ad56aau,
    0x40b001dbu, 0x40b2ab10u, 0x40b559c6u, 0x40b8018eu, 0x40bab006u, 0x40bd57a4u,
    0x40c0082cu, 0x40c2b2fau, 0x40c56314u, 0x40c80f34u, 0x40cab41au, 0x40cd5f59u,
    0x40d00fa8u, 0x40d2b9afu, 0x40d56419u, 0x40d80c7eu, 0x40dabb9du, 0x40dd63ecu,
    0x40e001acu, 0x40e2ac16u, 0x40e56314u, 0x40e80778u, 0x40eab41au, 0x40ed56aau,
    0x40f00fa8u, 0x40f2b9aeu, 0x40f56419u, 0x40f80c7eu, 0x40fab006u, 0x40fd63ecu,
    0x41000757u, 0x4101560bu, 0x4102b8d9u, 0x410403bcu, 0x41056240u, 0x4106b404u,
    0x410807d4u, 0x41095cd7u, 0x410ab20cu, 0x410c063fu, 0x410d5803u, 0x410ebe42u,
    0x41100757u, 0x411163d6u, 0x4112b8d9u, 0x411403bcu, 0x41156240u, 0x4116b404u,
    0x41181a44u, 0x41197060u,
};

/* MIDI note -> the pitch CV written to the per-voice M.CV slot state[304].
 * The plugin's note-on writes (note-12)/12 plus a small analog tune offset (NOT
 * note/12 — that was one octave too high, previously masked by a compensating
 * DCO-RANGE recall bug; see docs/COLDLOAD_AB.md). We use the plugin's exact
 * per-note bits so pitch matches bit-for-bit. */
float juno_note_pitch(int midi_note)
{
    unsigned int bits;
    float v;
    if (midi_note < 0)   midi_note = 0;
    if (midi_note > 127) midi_note = 127;
    bits = juno_mcv_bits[midi_note];
    memcpy(&v, &bits, sizeof v);
    return v;
}

void juno_note_on(unsigned char *st, int voice, int midi_note, int velocity)
{
    unsigned int base;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    if (velocity <= 0) { juno_note_off(st, voice); return; }

    base = VBASE(voice);

    /* M.CV  (immediate): DCO note pitch. Fixed tune at state[4448] left as init. */
    JF(st, base + PITCH_OFF) = juno_note_pitch(midi_note);

    /* M.Gate (immediate): open the gate -> state[560] rises 0->1 -> both ADSRs
     * attack. The plugin writes this directly (descriptor en=0), no ramp. */
    JF(st, base + GATE_OFF) = GATE_OPEN;

    /* DCO retrigger latch (aux Array A, 101504 + v*32): NOT armed here.
     *
     * The arming rule is MODE-DEPENDENT, which is why two earlier measurements
     * appeared to contradict each other. Measured against the plugin on a WARM
     * engine (probes/assigner/mono_stack_ref.py: 747 idle frames, then notes,
     * reading BOTH arrays from the unit that renders each voice):
     *
     *   patch 0  ASSIGN=0 POLY : on 64/29 -> v4[g1 A0 B1]   Array B, A untouched
     *   patch 15 ASSIGN=1 MONO : on 69/36 -> v0[g1 A1 B0]   Array A armed
     *
     * So POLY note-on writes only the DSP-inert Array B (101520 + v*32) — the old
     * comment here was right about POLY — while a MONO retrigger arms Array A,
     * which voice_render consumes to reset DCO phase. Arming unconditionally is
     * measurably wrong: it takes fuzz_diff from 1 diverged seed to 18 and
     * assigner_ab from 28/28 to 20/28, because it re-phases every POLY note.
     *
     * The MONO arm therefore lives in the allocator (gui/juno_bridge.c
     * mono_note_on), which is the only place that knows the mode and can tell a
     * retrigger from a legato slide. See juno_note_retrig(). */


    /* Velocity coefficients (immediate). The plugin's note-on fires the per-voice
     * "gate notify" (poly allocator sub_7FF91DFB3150 -> dispatch case 450 ->
     * FltVoice/AmpVoice velocity setters sub_7FF91DFB9F30 / sub_7FF91DFB7160),
     * which write the RAW MIDI velocity through curve 56 (VCF) / curve 57 (VCA)
     * into these two DSP-read smoother targets. voice_render reads 6864 (VCF) at
     * line 1142 and 9680 (VCA) at 1492. Proven bit-for-bit over a full velocity
     * sweep by driving the plugin's own dispatch under emulation (velocity 107 ->
     * 0.842520 / 1.154360, matching the earlier capture). Without these the voice
     * output is scaled by 0 -> silent. See scratchpad/oracle/velocity_coeff_findings.md. */
    JF(st, base + 6864) = juno_curve(56, velocity);   /* VCF velocity (param 73) */
    JF(st, base + 9680) = juno_curve(57, velocity);   /* VCA velocity (param 98) */
    /* The same gate-notify sets these two to 1.0 (velocity-independent). 1856 is
     * ALSO maintained globally across all voices — see juno_note_broadcast_held. */
    JF(st, base + 1856) = 1.0f;
    JF(st, base + 9824) = 1.0f;
}

/* Global "any key held" flag — cell 1856 on EVERY voice, not just the allocated
 * one. Measured from the plugin's own note event handling under Unicorn
 * (scratchpad/b2_bcast2.py / b2_bcast3.py, zero render between snapshots):
 *   - note-on writes 1856 = 1.0 to ALL 8 voices (the allocated voice additionally
 *     gets pitch/gate/velocity);
 *   - note-off writes 1856 = 0.0 to ALL 8 voices ONLY when no key remains held
 *     (releasing one note of a chord leaves it at 1.0 everywhere);
 * i.e. 1856 = (held-note count > 0), broadcast on every transition. voice_render
 * reads it every sample (voice_render.c:794, summed into a modulation CV, previous
 * value shadowed at 1840) and never clears it, so a missed broadcast permanently
 * diverges a free-running voice's state. The port originally set it only on the
 * allocated voice: invisible for non-arp play (a never-gated voice is enveloped
 * to silence) but the arp gating a previously-idle voice inherited the divergent
 * seed — the proven root cause of the arp render A/B failures on patches 1/33/41
 * (tools/verify/arp_render_ab.py). Caller = the assigner-level note paths in
 * gui/juno_bridge.c, which own the held-note mask this flag reflects. */
void juno_note_broadcast_held(unsigned char *st, int any_held)
{
    int v;
    float f = any_held ? 1.0f : 0.0f;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        JF(st, VBASE(v) + 1856) = f;
}

/* Arm the DCO retrigger latch (aux Array A) for one voice.
 *
 * voice_render consumes it as a one-shot on the next rendered sample: it forces
 * that sample's gate to 0 and clears state[320], which resets DCO phase. The
 * plugin does this for a MONO retrigger and NOT for a POLY note-on (measured —
 * see the note in juno_note_on), so the caller must know the assign mode. Only
 * gui/juno_bridge.c's mono_note_on calls it. */
void juno_note_retrig(unsigned char *st, int voice)
{
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    JF(st, AUX_EDGE(voice)) = 1.0f;
}

void juno_note_off(unsigned char *st, int voice)
{
    unsigned int base;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    base = VBASE(voice);

    /* M.Gate (immediate): close the gate -> state[560] falls to 0 -> both ADSRs
     * enter release. Written directly, matching the descriptor's en=0 flag. */
    JF(st, base + GATE_OFF) = 0.0f;

    /* Arm the per-voice DCO retrigger latch (aux Array A) — the descriptor's
     * param 927 "Voice0 Note Off Notify" (documented in this file's header since
     * the descriptor transcription, but previously unimplemented). Measured from
     * the plugin's own note-off under emulation (Phase-3 fuzz triage, seeds 1/2:
     * each note-off arms the released voice's 101504+32v to 1.0; causally proven
     * by poke-and-render bit-exactness). Inert when the voice stays released —
     * voice_render consumes the latch on the next sample while the gate is
     * already 0 (voice_render.c:566-572 masks a gate that is already closed) —
     * which is why every release/retrigger-after-render scenario passed without
     * it. It changes audio exactly when a released voice is RE-GATED with no
     * render in between: the plugin's new attack then starts one sample later. */
    JF(st, AUX_EDGE(voice)) = 1.0f;
}

void juno_note_glide(unsigned char *st, int voice, int midi_note)
{
    unsigned int base;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    base = VBASE(voice);
    /* M.CV only — leave M.Gate and the aux DCO latch untouched so the envelopes
     * keep running and the DCO does not re-phase: the pitch slews (with portamento
     * on, the DCO glide conditioner smooths it; off, it steps). Mirrors the
     * assigner's `setparam(433+v, key)` with no gate edge. */
    JF(st, base + PITCH_OFF) = juno_note_pitch(midi_note);
}

/* Per-voice PORTAMENTO GATE — the note-bus leaf 467+v that the POLY allocator's
 * LEGATO arm writes (sub_7FF91DFB3150 LABEL_21). PROVEN by dispatching the
 * plugin's own setter over indices 467/468/474 on a recalled engine and diffing
 * the full 9-unit state (probes/assigner/laneX_legato_bus.py + _restore.py):
 *
 *     467+v touches exactly two cells, voice v's  592 + v*10512  and  9824 + v*10512
 *     value 1 -> BOTH forced to 0
 *     value 0 -> 592 back to the recalled PORTAMENTO on/off; 9824 NOT WRITTEN
 *
 * The asymmetry is real and was measured, not inferred — the decompiler dropped
 * the value argument of the else-branch call, so the whole-sequence trace
 * probes/assigner/laneX_p55_trace.py settled it: across note-on 60 (silent, all
 * 592 and 9824 -> 0 except the triggered voice's 9824, which its gate leaf sets
 * back to 1), note-on 67 (all 592 -> 1, every 9824 unchanged), note-off and a
 * third note, cell 9824 only ever moves via the gate leaf 450+v (1 on note-on
 * with velocity, 0 on an explicit gate-off) and via the `off` arm here.
 *
 * Cell 592 is the DCO glide gate (voice_render.c:674 `v45 = (v43+1)*JF(a1,592)`;
 * v45 == 0 bypasses the glide conditioner entirely); 9824 feeds the second
 * smoother at voice_render.c:1517 and is juno_note_on's gate twin.
 *
 * `porta_base` is the recalled 592 value, which the caller reads back from the
 * engine after recall — exactly the value the plugin's own param store holds. */
void juno_note_porta_gate(unsigned char *st, int voice, int off, float porta_base)
{
    unsigned int base;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    base = VBASE(voice);
    JF(st, base + 592) = off ? 0.0f : porta_base;
    if (off) JF(st, base + 9824) = 0.0f;
}

/* Refresh the velocity coefficients (VCF 6864 / VCA 9680) WITHOUT a gate edge —
 * used by MONO legato / UNISON glide overlaps. Verified by executing the plugin's
 * CAssignJu60 (RVA 0x353150) under Unicorn: a legato/glide note arriving with a
 * different velocity refreshes GATE(v, newvel) (velocity coeffs only, no gate-off,
 * no DCO re-latch); an identical velocity is a no-op (same curves as note-on). */
void juno_note_velocity(unsigned char *st, int voice, int velocity)
{
    unsigned int base;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    if (velocity <= 0) return;
    base = VBASE(voice);
    JF(st, base + 6864) = juno_curve(56, velocity);   /* VCF velocity (param 73) */
    JF(st, base + 9680) = juno_curve(57, velocity);   /* VCA velocity (param 98) */
}

/* The gate is now an immediate write (no host-side ramp to advance), so the
 * per-sample tick is a no-op. Kept for API/source compatibility. */
void juno_note_tick(unsigned char *st)
{
    (void)st;
}
