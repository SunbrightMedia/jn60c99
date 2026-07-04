/* juno_note.c — see juno_note.h.
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
 * this engine's DCO scale = -5.4192 (measured from the exact phase increment
 * v398*48000 at 96 kHz). One semitone = 1/12 unit. NOTE: this is the DCO-domain
 * value; it differs from firstnote/note_pitch_table.h (a separate pitch node) by a
 * constant octave offset, which is a DCO-tuning matter beyond the note-on layer. */
#define PITCH_C4     (-5.4192f)

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
