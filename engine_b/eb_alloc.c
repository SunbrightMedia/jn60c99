/* eb_alloc.c — see eb_alloc.h. A transcription of gui/juno_bridge.c's
 * allocator, which is the plugin's CAssignJu60 and is proven 34/34 against it.
 * Structure and scan directions are preserved exactly; only the cell writes
 * become emitted events.
 */
#include "eb_alloc.h"

#define NV EB_ALLOC_VOICES

static void emit(eb_alloc_ev *ev, int *n, int kind, int voice, int a, int b)
{
    if (*n >= EB_ALLOC_MAX_EV) return;
    ev[*n].kind  = (uint8_t)kind;
    ev[*n].voice = (int8_t)voice;
    ev[*n].a     = (int16_t)a;
    ev[*n].b     = (int16_t)b;
    ++*n;
}

void eb_alloc_init(eb_alloc *a)
{
    int v;
    for (v = 0; v < NV; ++v) {
        a->voice_note[v]  = -1;
        a->voice_gated[v] = 0;
        a->voice_age[v]   = 0;
    }
    a->age_counter = 0;
    a->held_notes[0] = a->held_notes[1] = a->held_notes[2] = a->held_notes[3] = 0;
    a->legato_mask = 0;
    a->assign_mode = 0;
    a->legato = 0;
    a->portamento_on = 0;
}

static void held_set(eb_alloc *a, int n)   { if (n>=0 && n<128) a->held_notes[n>>5] |=  (1u<<(n&31)); }
static void held_clear(eb_alloc *a, int n) { if (n>=0 && n<128) a->held_notes[n>>5] &= ~(1u<<(n&31)); }

static int held_lowest(const eb_alloc *a)
{
    int w, b;
    for (w = 0; w < 4; ++w)
        if (a->held_notes[w])
            for (b = 0; b < 32; ++b)
                if (a->held_notes[w] & (1u << b)) return (w << 5) | b;
    return -1;
}

static int pick_oldest(const eb_alloc *a, int want_assigned, int want_gated)
{
    int v, pick = -1; uint32_t oldest = 0;
    for (v = 0; v < NV; ++v) {
        int assigned = a->voice_note[v] >= 0;
        if (assigned != want_assigned) continue;
        if (assigned && (int)a->voice_gated[v] != want_gated) continue;
        if (pick < 0 || a->voice_age[v] < oldest) { oldest = a->voice_age[v]; pick = v; }
    }
    return pick;
}

static int pick_newest(const eb_alloc *a, int want_assigned, int want_gated)
{
    int v, pick = -1; uint32_t newest = 0;
    for (v = 0; v < NV; ++v) {
        int assigned = a->voice_note[v] >= 0;
        if (assigned != want_assigned) continue;
        if (assigned && (int)a->voice_gated[v] != want_gated) continue;
        if (pick < 0 || a->voice_age[v] > newest) { newest = a->voice_age[v]; pick = v; }
    }
    return pick;
}

static void voice_trigger(eb_alloc *a, int v, int midi_note, int velocity,
                          eb_alloc_ev *ev, int *n)
{
    a->voice_note[v]  = midi_note;
    a->voice_gated[v] = 1;
    a->voice_age[v]   = ++a->age_counter;
    emit(ev, n, EB_EV_TRIGGER, v, midi_note, velocity);
}

/* MODE 0 POLY + MODE 3 variant. See eb_alloc.h rule 1 for the 7->0 scan. */
static void poly_note_on(eb_alloc *a, int midi_note, int velocity, int variant,
                         eb_alloc_ev *ev, int *n)
{
    int v, pick = -1;
    if (!variant) {
        pick = pick_newest(a, 1, 1);
        if (pick >= 0 && a->voice_note[pick] != midi_note) pick = -1;
        if (pick < 0) {
            int best = -1, w; uint32_t age = 0;
            for (w = 0; w < NV; ++w)
                if (a->voice_note[w] == midi_note && (best < 0 || a->voice_age[w] > age))
                    { age = a->voice_age[w]; best = w; }
            pick = best;
        }
        if (pick < 0) {
            int w; uint32_t oldest = 0;
            for (w = NV - 1; w >= 0; --w)          /* TOP-DOWN -- load-bearing */
                if (!a->voice_gated[w] && (pick < 0 || a->voice_age[w] < oldest))
                    { oldest = a->voice_age[w]; pick = w; }
        }
    } else {
        for (v = NV - 1; v >= 0; --v)
            if (a->voice_note[v] < 0 || !a->voice_gated[v]) { pick = v; break; }
    }
    if (pick < 0)
        pick = a->portamento_on ? pick_newest(a, 1, 1) : pick_oldest(a, 1, 1);
    if (pick < 0) pick = 0;

    if (!variant && a->legato && a->portamento_on) {
        int silent = 1, i;
        for (v = 0; v < NV; ++v)
            if (a->voice_gated[v]) { silent = 0; break; }
        for (v = 0; v < NV; ++v)
            emit(ev, n, EB_EV_PORTA_GATE, v, silent, 0);
        if (silent) a->legato_mask = (1u << NV) - 1u;
        for (i = 0; i < NV; ++i)
            if (i != pick && ((a->legato_mask >> i) & 1u)) {
                if (a->voice_note[i] != midi_note)
                    emit(ev, n, EB_EV_GLIDE, i, midi_note, 0);
                a->voice_note[i] = midi_note;
            }
    }
    voice_trigger(a, pick, midi_note, velocity, ev, n);
    a->legato_mask &= ~(1u << pick);
}

/* MODE 1 MONO: one fixed voice (0). See eb_alloc.h rule 3 for the retrig arm. */
static void mono_note_on(eb_alloc *a, int midi_note, int velocity,
                         eb_alloc_ev *ev, int *n)
{
    int v;
    if (!a->voice_gated[0]) {
        emit(ev, n, EB_EV_RETRIG, 0, 0, 0);
        voice_trigger(a, 0, midi_note, velocity, ev, n);
    } else {
        emit(ev, n, EB_EV_GLIDE, 0, midi_note, 0);
        emit(ev, n, EB_EV_VELOCITY, 0, velocity, 0);
        a->voice_note[0] = midi_note;
        a->voice_age[0]  = ++a->age_counter;
    }
    for (v = 1; v < NV; ++v)
        if (a->voice_note[v] >= 0) {
            emit(ev, n, EB_EV_NOTE_OFF, v, 0, 0);
            a->voice_gated[v] = 0;
        }
}

/* MODE 2 UNISON: all 8 on the same note; the retrig arm is was-idle ONLY. */
static void unison_note_on(eb_alloc *a, int midi_note, int velocity,
                           eb_alloc_ev *ev, int *n)
{
    int v, was_idle = !a->voice_gated[0];
    for (v = 0; v < NV; ++v) {
        if (was_idle) {
            emit(ev, n, EB_EV_RETRIG, v, 0, 0);
            voice_trigger(a, v, midi_note, velocity, ev, n);
        } else {
            emit(ev, n, EB_EV_GLIDE, v, midi_note, 0);
            emit(ev, n, EB_EV_VELOCITY, v, velocity, 0);
            a->voice_note[v] = midi_note;
            a->voice_age[v]  = ++a->age_counter;
        }
    }
}

int eb_alloc_note_on(eb_alloc *a, int midi_note, int velocity, eb_alloc_ev *ev)
{
    int n = 0;
    held_set(a, midi_note);
    switch (a->assign_mode) {
        case 1:  mono_note_on(a, midi_note, velocity, ev, &n);      break;
        case 2:  unison_note_on(a, midi_note, velocity, ev, &n);    break;
        case 3:  poly_note_on(a, midi_note, velocity, 1, ev, &n);   break;
        default: poly_note_on(a, midi_note, velocity, 0, ev, &n);   break;
    }
    emit(ev, &n, EB_EV_HELD, -1, 1, 0);
    return n;
}

static void poly_release_key(eb_alloc *a, int key, eb_alloc_ev *ev, int *n)
{
    int v;
    for (v = 0; v < NV; ++v)
        if ((a->voice_note[v] == key && a->voice_gated[v]) ||
            (key < 0 && a->voice_note[v] >= 0)) {
            emit(ev, n, EB_EV_NOTE_OFF, v, 0, 0);
            a->voice_gated[v] = 0;      /* stays ASSIGNED -- rule 2 */
        }
}

/* MONO/UNISON note-off: lowest-held fallback. Rule 4. */
static void mono_note_off(eb_alloc *a, int key, int all, eb_alloc_ev *ev, int *n)
{
    int lo, v, last = all ? NV : 1;
    if (key >= 0 && a->voice_note[0] != key) return;    /* stale key */
    lo = held_lowest(a);
    if (lo >= 0) {
        for (v = 0; v < last; ++v)
            if (a->voice_note[v] >= 0) {
                emit(ev, n, EB_EV_GLIDE, v, lo, 0);
                a->voice_note[v] = lo;
            }
    } else {
        for (v = 0; v < last; ++v)
            if (a->voice_note[v] >= 0) {
                emit(ev, n, EB_EV_NOTE_OFF, v, 0, 0);
                a->voice_gated[v] = 0;
            }
    }
}

int eb_alloc_note_off(eb_alloc *a, int midi_note, eb_alloc_ev *ev)
{
    int n = 0;
    held_clear(a, midi_note);
    if (midi_note < 0)
        a->held_notes[0] = a->held_notes[1] = a->held_notes[2] = a->held_notes[3] = 0;
    switch (a->assign_mode) {
        case 1:  mono_note_off(a, midi_note, 0, ev, &n);  break;
        case 2:  mono_note_off(a, midi_note, 1, ev, &n);  break;
        default: poly_release_key(a, midi_note, ev, &n);  break;
    }
    emit(ev, &n, EB_EV_HELD, -1,
         (a->held_notes[0] | a->held_notes[1] |
          a->held_notes[2] | a->held_notes[3]) != 0, 0);
    return n;
}
