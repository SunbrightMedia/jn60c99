/* juno_note.c — see juno_note.h.
 *
 * STATUS: WORKING PLACEHOLDER, NOT a faithful port of the note-on write. It
 * makes the ADSR envelope open (the DSP is fine — see below), but the way it
 * opens the gate is a HACK, not the plugin's mechanism. Honest accounting:
 *   - The DSP layer is correct. voice_render's DCO frequency scaling is exact
 *     (state[4416] doubles per octave of state[4448], measured); the shared ADSR
 *     gate state[560] and its fixed thresholds (state[2864]/[3344]=-0.5) are
 *     read exactly. The DSP plays whatever inputs it is given, correctly.
 *   - What is NOT ported (control layer) and is faked here:
 *     (1) The gate. state[560] = conditioner(v29 = s272·s240·(s208-s320)+s320).
 *         The REAL note-on loads pitch-derived DCO coefficients into
 *         208/240/272/320 so v29>0 opens the gate as a side effect. We instead
 *         poke state[320] — which is the DCO PHASE ACCUMULATOR (reset on the
 *         note edge at voice_render line 553) — to a small value so v29>0. This
 *         works empirically but is the wrong mechanism; the faithful write needs
 *         the descriptor-1090 ramp out-pointer binding (unresolved init gap).
 *     (2) The pitch VALUE. state[4448] is the DCO pitch input; the DSP is exact.
 *         The plugin's own integer-note -> octave-value formula is not traced, so
 *         PITCH_C4 below is a host-side CALIBRATION (not derived) — but it is now
 *         measured so standard MIDI notes play at concert pitch (MIDI 60 -> C4
 *         261.6 Hz, autocorrelation-verified; relative semitones are exact since
 *         the DSP doubles per octave unit). Was one octave high before.
 * So: this is enough to demonstrate the ADSR/gate path end-to-end, but the two
 * un-ported control-layer inputs above must be traced for a faithful note-on.
 *
 * Reconstructed from the control-layer traces (sub_1803C1720 gate-on,
 * sub_1803C17A0 gate-off, sub_1803C2920 voice-trigger -> ramp start toward the
 * gate target, sub_1803C24A0 per-sample pruner -> ramp step) and from a direct
 * reading of juno_voice_render's envelope + DCO-gate-conditioner blocks.
 *
 * What each note-on write does, and why:
 *   1. state[4448] (pitch, octave units): the DCO frequency is
 *      v391 = poly(clamp(state[4448]+state[3776])) and the phase increment is
 *      v391*state[5536]; nothing else. So pitch lives here and here only.
 *   2. gate ramp on state[base+0] (state[320] for voice 0): the envelope gate
 *      state[base+240] (=state[560]) = 1 iff the conditioner output
 *      v29 = state[272]*state[240]*(state[208]-state[320]) + state[320]
 *      is nonzero and v29 >= -state[544]. With the DCO-coefficient slots
 *      (208/240/272) left at their patch value 0, v29 == state[320], so ramping
 *      state[320] from 0 to a small positive GATE_LEVEL opens the gate cleanly
 *      (this slot does NOT feed the oscillator frequency, so pitch is unaffected;
 *      a large value here would DC-offset the DCO waveform and be filtered away,
 *      hence a small level). Both ADSRs then attack.
 *   3. state[101504+voice*32] = 1.0: the one-shot attack edge voice_render latches
 *      (state[base+0] is reset for that first sample and restored at the end).
 *
 * Note-off ramps state[base+0] back to 0 -> v29 -> 0 -> state[560]=0 -> both
 * ADSRs release.
 */
#include "juno_engine.h"
#include "juno_ramp.h"
#include "juno_note.h"

/* Per-voice state layout (juno_engine.h). */
#define VBASE(v)   (JUNO_VOICE_MAIN_BASE0 + (v) * JUNO_VOICE_MAIN_STRIDE) /* 320  + v*10512 */
#define GATE_OFF   0        /* state[base+0]   = state[320]  : DCO gate-conditioner base */
#define PITCH_OFF  4128     /* state[base+4128]= state[4448] : DCO pitch (octave units)  */
#define AUX_EDGE(v) (JUNO_VOICE_AUX_BASE0 + (v) * JUNO_VOICE_AUX_STRIDE)  /* 101504 + v*32 */

/* Gate ramp target. Any positive value opens state[560]; kept small so the DCO
 * waveform is not DC-offset. Matches the control-layer ramp (subdiv 10). */
#define GATE_LEVEL   0.01f
#define GATE_TIME_MS 2.0f    /* gate edge time; the ADSR times come from the patch */
#define GATE_SUBDIV  10

/* DCO pitch calibration. state[4448] is in octave units (one unit == one octave;
 * verified: +1.0 doubles the oscillator frequency). C4 (MIDI 60, 261.63 Hz) is at
 * this engine's DCO scale = -6.4192, RE-MEASURED at 96 kHz by rendering the note
 * and autocorrelating the output fundamental (state[4448]=-6.42 -> 261.6 Hz).
 * One semitone = 1/12 unit. (The earlier -5.4192 was one octave too high — it
 * produced C5=523 Hz for MIDI 60; corrected here so standard MIDI notes play at
 * concert pitch. This is a host-side calibration of the offline note driver, not
 * the plugin's own note path; DCO RANGE / fine-tune are separate per-patch params
 * in the unported reflection path.) */
#define PITCH_C4     (-6.4192f)

/* Module-static ramp objects (offline host-side control state). */
static juno_ramp g_gate[JUNO_NUM_VOICES];
static int       g_active[JUNO_NUM_VOICES];

float juno_note_pitch(int midi_note)
{
    return PITCH_C4 + (float)(midi_note - 60) * (1.0f / 12.0f);
}

void juno_note_on(unsigned char *st, int voice, int midi_note, int velocity)
{
    unsigned int base;
    float rate;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    if (velocity <= 0) { juno_note_off(st, voice); return; }

    base = VBASE(voice);
    rate = JF(st, 16);                       /* session sample rate (engine+16) */
    if (rate <= 0.0f) rate = 96000.0f;

    /* 1. DCO pitch. */
    JF(st, base + PITCH_OFF) = juno_note_pitch(midi_note);

    /* 2. gate ramp 0 -> GATE_LEVEL on the conditioner base slot. */
    juno_ramp_init(&g_gate[voice], &JF(st, base + GATE_OFF), rate);
    juno_ramp_start(&g_gate[voice], GATE_LEVEL, GATE_TIME_MS, GATE_SUBDIV);
    g_active[voice] = 1;

    /* 3. one-shot attack edge (consumed on the next voice_render sample). */
    JF(st, AUX_EDGE(voice)) = 1.0f;

    (void)velocity; /* the amp level comes from the ADSR; velocity->gain path TBD */
}

void juno_note_off(unsigned char *st, int voice)
{
    unsigned int base;
    float rate;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    base = VBASE(voice);
    rate = JF(st, 16);
    if (rate <= 0.0f) rate = 96000.0f;

    /* ramp the gate slot back to 0 -> state[560]=0 -> both ADSRs release. */
    if (!g_active[voice])                       /* ensure the ramp is bound      */
        juno_ramp_init(&g_gate[voice], &JF(st, base + GATE_OFF), rate);
    g_gate[voice].out = &JF(st, base + GATE_OFF);
    juno_ramp_start(&g_gate[voice], 0.0f, GATE_TIME_MS, GATE_SUBDIV);
    g_active[voice] = 1;
}

void juno_note_tick(unsigned char *st)
{
    int v;
    (void)st;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if (g_active[v])
            juno_ramp_step(&g_gate[v]);
}
