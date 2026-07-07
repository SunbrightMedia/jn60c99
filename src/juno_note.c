/* juno_note.c — faithful note-on / gate / pitch driver for the JUNO-60 port.
 *
 * This replaces the earlier documented HACK (poke state[320]=0.01 for the gate,
 * host-side calibrated PITCH_C4=-6.4192 for pitch). Both are now recovered from
 * the binary and the live-plugin state, and verified against the ported DSP.
 *
 * ---------------------------------------------------------------------------
 * PITCH  (deliverable #1)
 * ---------------------------------------------------------------------------
 * voice_render feeds the DCO pitch spline with  clamp(state[4448]+state[3776]).
 * state[3776] is the recomputed DCO pitch-modulation sum, and its dominant term
 * is the PORTAMENTO/glide conditioner output v28 (voice_render.c:617):
 *     v28 = state[272]*state[240]*(state[176]-state[304]) + state[304]
 * The gate uses the SAME shared coefficient state[272]*state[240] in the twin
 * conditioner v29 (voice_render.c:618). Neither juno_engine_init nor voice_render
 * ever writes state[240]/[272] (they stay 0 — confirmed in src, in the parameter
 * map: offsets <384 are unregistered internal state, and in the live-plugin dump
 * state_dump/state_t*.bin), so both conditioners are frozen:
 *     v28 == state[304]   (portamento off  -> instant pitch)
 *     v29 == state[320]   (gate)
 * => The per-voice NOTE PITCH lives in state[304] (octave units, 1.0 == +1 oct).
 *    state[4448] = -4.75 is a FIXED DCO tune offset (= -57/12) written by init;
 *    it is the SAME for every voice and every patch (verified for patches 0..7
 *    and a fresh init), so the note path must NOT touch it.
 *
 * The frequency scale is state[5536] = 220/96000 (live dump) and the pitch spline
 * poly() approximates 2^x with poly(0)=1.0 exactly (juno_tables.h), so
 *     f_DCO = 220 * 2^(state[4448] + state[304] + mod) = 220 * 2^(state[304]-4.75).
 * For concert pitch f = 440*2^((n-69)/12) = 220*2^((n-57)/12) we need
 *     state[304] - 4.75 = (n-57)/12  =>  state[304] = n/12.
 * So the faithful note->pitch formula is simply
 *
 *     state[voiceBase+304] = midi_note / 12.0            (octave units)
 *
 * PROOF / cross-checks (all bit-derived, no fitting):
 *   - Fresh juno_engine_init leaves state[304] = 6.668469, and the live-plugin
 *     dump has voice pitches 6.50191 / 6.66847 / 6.75152 = notes 78 / 80 / 81
 *     (n/12 = 6.5 / 6.6667 / 6.75) plus a ~+0.0018-octave (~+2.2 cent) master
 *     tune. The port's init default matches the live plugin to the last digit.
 *   - Rendering the ported voice with state[304]=n/12 and 4448 left at -4.75:
 *     Goertzel power peaks exactly at the note fundamental — note 48 -> 130.8 Hz,
 *     note 60 -> 261.6 Hz (concert C4); relative octaves double exactly (the DSP
 *     scaling was already verified). MIDI 60 lands on a musical pitch. QED.
 *   NOTE: we write the clean n/12 (exact A440, semitone/octave-exact). The
 *   plugin's default carries an extra ~+2.2 cent master tune (state[304] default
 *   = 6.668469 = 80/12 + 0.0018); folding that in exactly would need the 12-entry
 *   analog tuning table (sub_7FF91DFBD180, table[s]=cents_s/1200) and its note-on
 *   apply path, which is not transcribed. n/12 is within ~2 cents of the plugin.
 *
 * ---------------------------------------------------------------------------
 * GATE  (deliverable #2)
 * ---------------------------------------------------------------------------
 * The shared ADSR gate is state[560] (voice_render.c:651):
 *     v29 = state[272]*state[240]*(state[208]-state[320]) + state[320]  (==state[320])
 *     gate = 1  iff  v29 != 0  AND  v29 + state[544] >= 0  (state[544]=1/96)
 * Both ADSRs (filter state[2592], amp state[3072]) run their attack while this
 * gate is 1 (voice_render.c:926 v124=state[560]*v123 ; :981 v146=state[560]*v145).
 * The real note-on (sub_7FF91E021720 / voice-trigger sub_7FF91E022920) drives the
 * gate through the ramp engine (sub_7FF91E022E80, transcribed in juno_ramp.c):
 * it ramps the gate slot from 0 toward a positive const with subdiv 10. Because
 * state[240]*state[272]==0, v29 == state[320], so the ONLY input that can open
 * the gate is state[320] -> the ramp writes state[320]. We reproduce exactly
 * that: ramp state[320] 0 -> positive on note-on, positive -> 0 on note-off.
 * The gate is BINARY: state[480]=v29 is dead downstream (never re-read in
 * voice_render, not a registered param), so state[320]'s magnitude is
 * audio-irrelevant — only its sign/nonzero-ness sets the gate. Hence the exact
 * ramp target does not affect the sound; any positive value yields the identical
 * gate edge that triggers both ADSRs. (The plugin's ramp const happens to be 4.0.)
 *
 * ---------------------------------------------------------------------------
 * ATTACK EDGE
 * ---------------------------------------------------------------------------
 * state[101504+voice*32] = 1.0 is the one-shot DCO retrigger latch: voice_render
 * consumes it on the first sample (zeroes state[320] for that sample, then
 * restores it and clears the latch, voice_render.c:549 / :2128). Set on note-on.
 */
#include "juno_engine.h"
#include "juno_ramp.h"
#include "juno_note.h"

/* Per-voice absolute state offsets. voice_render is called with a1 = state +
 * voice*STRIDE, so all of its offsets are relative to this voice base. */
#define VBASE(v)    ((unsigned int)(v) * JUNO_VOICE_MAIN_STRIDE)  /* v*10512 */
#define PITCH_OFF   304    /* per-voice DCO note pitch  (v28 input, = note/12) */
#define GATE_OFF    320    /* per-voice gate conditioner (v29 input)          */
#define TUNE_OFF    4448   /* fixed DCO tune (-4.75), set by init; DO NOT write */
#define AUX_EDGE(v) (JUNO_VOICE_AUX_BASE0 + (unsigned int)(v) * JUNO_VOICE_AUX_STRIDE)

/* Gate ramp. Target is any positive value (the gate is binary; state[320]'s
 * magnitude is audio-irrelevant). subdiv 10 mirrors the plugin's gate ramp. */
#define GATE_LEVEL   1.0f
#define GATE_TIME_MS 1.0f
#define GATE_SUBDIV  10

/* Module-static ramp objects (offline host-side control state, one per voice). */
static juno_ramp g_gate[JUNO_NUM_VOICES];
static int       g_active[JUNO_NUM_VOICES];

/* MIDI note -> the octave value written to the per-voice pitch slot state[304].
 * One octave per unit, one semitone = 1/12; combined with the engine's fixed
 * -4.75 tune this yields 220*2^((note-57)/12) = concert pitch (A440). */
float juno_note_pitch(int midi_note)
{
    return (float)midi_note * (1.0f / 12.0f);
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

    /* 1. DCO note pitch -> state[304] (portamento-off => instant, matching the
     *    frozen glide conditioner). The fixed tune at state[4448] is left as
     *    init wrote it (-4.75); the DCO sums the two. */
    JF(st, base + PITCH_OFF) = juno_note_pitch(midi_note);

    /* 2. Gate: ramp state[320] 0 -> GATE_LEVEL so v29>0 => gate opens => both
     *    ADSRs attack. */
    juno_ramp_init(&g_gate[voice], &JF(st, base + GATE_OFF), rate);
    juno_ramp_start(&g_gate[voice], GATE_LEVEL, GATE_TIME_MS, GATE_SUBDIV);
    g_active[voice] = 1;

    /* 3. one-shot DCO retrigger edge (consumed on the next voice_render sample). */
    JF(st, AUX_EDGE(voice)) = 1.0f;

    /* 4. RETRIGGER the ADSRs. On the real synth the voice-trigger restarts each
     *    voice's envelopes from zero when it is (re)assigned to a note — so a
     *    replayed note, a stolen/reused voice, or an arp step all "speak" with a
     *    fresh attack. Without this the port re-attacks from wherever the voice's
     *    envelope was left (sustain / mid-release), so held or reused voices don't
     *    re-strike — the "attack isn't snappy" / arp "just clicks" reports.
     *    Zero the ENV1 (filter, 2592..2768) and ENV2 (amp, 3072..3248) STATE
     *    blocks — the run-time level/integrator/shift-register history. The A/D/S/R
     *    coefficients live at 2784+/3264+ and are deliberately left untouched. */
    {
        unsigned o;
        for (o = 2592; o <= 2768; o += 16) JF(st, base + o) = 0.0f;
        for (o = 3072; o <= 3248; o += 16) JF(st, base + o) = 0.0f;
    }

    (void)velocity; /* velocity->amp level (gate-on param 1090) not yet traced;
                     * the note sounds at the patch's ADSR level. */
}

void juno_note_off(unsigned char *st, int voice)
{
    unsigned int base;
    float rate;
    if (voice < 0 || voice >= JUNO_NUM_VOICES) return;
    base = VBASE(voice);
    rate = JF(st, 16);
    if (rate <= 0.0f) rate = 96000.0f;

    /* ramp the gate slot back to 0 -> v29 -> 0 -> state[560]=0 -> both ADSRs
     * enter release. */
    if (!g_active[voice])                       /* ensure the ramp is bound */
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
