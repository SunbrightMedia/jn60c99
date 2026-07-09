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
 * state[272]==0) to v28 == state[304]. state[4448] = -4.75 (= -57/12) is the fixed
 * DCO tune written by init and shared by every voice/patch (DO NOT touch it). With
 * the pitch spline's poly(0)==1.0 and f_DCO = 220*2^(state[4448]+state[304]+mod):
 *     f = 440*2^((n-69)/12) = 220*2^((n-57)/12)  =>  state[304] = n/12.
 * So the faithful note->pitch is  state[voiceBase+304] = midi_note / 12.0.
 * (The plugin default state[304]=6.668469 = 80/12 + ~0.0018 carries a ~+2.2-cent
 *  analog master tune from a 12-entry table not transcribed here; n/12 is within
 *  ~2 cents. This is the ONLY documented deviation and it is sub-audible.)
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
 * DCO RETRIGGER  ->  aux latch (offset 101504 + voice*32), immediate
 * ---------------------------------------------------------------------------
 * On note-on the plugin sets the per-voice one-shot latch state[101504+voice*32] =
 * 1.0. voice_render consumes it on the next sample (voice_render.c:567-572 forces
 * the gate to 0 for that one sample and clears state[320]; :2146-2149 restores
 * state[320] and clears the latch). This resets DCO phase for a consistent attack.
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

/* Per-voice absolute state offsets (relative to voice base = voice*STRIDE). */
#define VBASE(v)    ((unsigned int)(v) * JUNO_VOICE_MAIN_STRIDE)  /* v*10512 */
#define PITCH_OFF   304    /* M.CV   — per-voice DCO note pitch (= note/12)    */
#define GATE_OFF    320    /* M.Gate — per-voice binary gate conditioner       */
#define TUNE_OFF    4448   /* fixed DCO tune (-4.75), set by init; DO NOT write */
#define AUX_EDGE(v) (JUNO_VOICE_AUX_BASE0 + (unsigned int)(v) * JUNO_VOICE_AUX_STRIDE)

/* Gate is binary in the DSP; any positive magnitude opens it identically. */
#define GATE_OPEN   1.0f

/* MIDI note -> the octave value written to the per-voice pitch slot state[304]. */
float juno_note_pitch(int midi_note)
{
    return (float)midi_note * (1.0f / 12.0f);
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

    /* Aux latch (immediate): one-shot DCO phase retrigger (consumed next sample). */
    JF(st, AUX_EDGE(voice)) = 1.0f;

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
    /* The same gate-notify sets these two to 1.0 (velocity-independent). */
    JF(st, base + 1856) = 1.0f;
    JF(st, base + 9824) = 1.0f;
}

void juno_note_off(unsigned char *st, int voice)
{
    unsigned int base;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    base = VBASE(voice);

    /* M.Gate (immediate): close the gate -> state[560] falls to 0 -> both ADSRs
     * enter release. Written directly, matching the descriptor's en=0 flag. */
    JF(st, base + GATE_OFF) = 0.0f;
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
