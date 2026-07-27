/* test_voice_alloc.c — regression guard for voice ALLOCATION + KEY ASSIGN mode.
 *
 * 1. POLY: a fresh single note is allocated to the HIGHEST slot (voice 7), and
 *    successive new notes descend 7,6,5,... (the plugin's priority list is [0..7]
 *    scanned top-down — NOT 0,1,2,..). Proven by running-code diff vs CAssignJu60.
 *
 * 2. KEY ASSIGN (blob 56) selects the allocator: 0 = POLY, 1 = MONO
 *    (sub_7FF91DFB38F0, one fixed voice 0), 2 = UNISON (sub_7FF91DFB3B60, the whole
 *    stack on one note), 3 = POLY-variant — the 4-way switch on the assigner's
 *    cached mode field in sub_7FF91DFB5820.
 *
 * HISTORY — this file previously asserted the OPPOSITE of 2: "there is NO mono",
 * "assign=2 is polyphonic, NOT unison". That came from an A/B against an oracle in
 * which the plugin's allocator had never been told the mode (the engine's host
 * parameter entry follows every dispatch with assigner->slot+8(4), which our recall
 * skipped, so the plugin's own allocator sat in POLY for every patch). The test then
 * froze the wrong conclusion in place. See docs/ASSIGNER_MODE_FINDING.md; the live
 * check is tools/verify/assigner_ab.py, which drives note SEQUENCES through the
 * plugin's own allocator and the port's and requires bit-exact audio (28/28).
 * A single note cannot tell POLY from MONO, which is exactly how the old A/B — and
 * this test — got it backwards.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float sr, int chorus_mode);
int  juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx);
void juno_gui_note_on(juno_ctx *c, int note, int vel);
int  juno_gui_debug_voices(juno_ctx *c, int *notes, unsigned char *gated);

#define HDR 23
#define STRIDE 20223

static void put_pair(unsigned char *rec, int off, int v)
{ rec[off] = (v >> 4) & 0xF; rec[off + 1] = v & 0xF; }
static void put_blob(unsigned char *rec, int bp, int v) { put_pair(rec, 16 + 2 * bp, v); }

static int ngated(const unsigned char *g)
{ int v, n = 0; for (v = 0; v < 8; ++v) if (g[v]) ++n; return n; }

int main(void)
{
    int fails = 0, notes[8]; unsigned char g[8];
    unsigned char *bank = calloc(1, HDR + STRIDE);
    bank[0] = 'K';
    unsigned char *rec = bank + HDR;
    /* give the voice a sounding level so allocation is observable (DCO saw + VCA) */
    put_blob(rec, 27, 200);          /* DCO SAW LEVEL */
    put_blob(rec, 66, 200);          /* VCA LEVEL     */

    /* --- assign = 0 (POLY): first note voice 7, chord descends 7,6,5 --------- */
    put_blob(rec, 56, 0);
    juno_ctx *c0 = juno_gui_create(48000.0f, 2);
    juno_gui_apply_bank(c0, bank, HDR + STRIDE, 0);
    juno_gui_note_on(c0, 60, 100);
    juno_gui_debug_voices(c0, notes, g);
    if (!(g[7] && notes[7] == 60)) {
        printf("FAIL: assign=0 single note not on voice 7 (");
        for (int v = 0; v < 8; ++v) if (g[v]) printf("v%d=n%d ", v, notes[v]);
        printf(")\n"); ++fails;
    }
    juno_gui_note_on(c0, 64, 100); juno_gui_note_on(c0, 67, 100);
    juno_gui_debug_voices(c0, notes, g);
    if (ngated(g) < 3) { printf("FAIL: assign=0 chord collapsed to %d voice(s)\n", ngated(g)); ++fails; }
    if (!(g[7] && g[6] && g[5])) { printf("FAIL: assign=0 chord not on voices 7/6/5\n"); ++fails; }

    /* --- assign = 1 (MONO): one fixed voice, voice 0, last-note priority ------ */
    put_blob(rec, 56, 1);
    juno_ctx *c1 = juno_gui_create(48000.0f, 2);
    juno_gui_apply_bank(c1, bank, HDR + STRIDE, 0);
    juno_gui_note_on(c1, 60, 100);
    juno_gui_debug_voices(c1, notes, g);
    if (!(ngated(g) == 1 && g[0] && notes[0] == 60)) {
        printf("FAIL: assign=1 single note not MONO on voice 0 (%d voices lit)\n", ngated(g));
        ++fails;
    }
    juno_gui_note_on(c1, 64, 100); juno_gui_note_on(c1, 67, 100);
    juno_gui_debug_voices(c1, notes, g);
    if (ngated(g) != 1) { printf("FAIL: assign=1 chord lit %d voices — want 1 (MONO)\n", ngated(g)); ++fails; }
    if (!(g[0] && notes[0] == 67)) { printf("FAIL: assign=1 not following last note on voice 0\n"); ++fails; }

    /* --- assign = 2 (UNISON): the whole 8-voice stack on the held note -------- */
    put_blob(rec, 56, 2);
    juno_ctx *c2 = juno_gui_create(48000.0f, 2);
    juno_gui_apply_bank(c2, bank, HDR + STRIDE, 0);
    juno_gui_note_on(c2, 60, 100);
    juno_gui_debug_voices(c2, notes, g);
    if (ngated(g) != 8) { printf("FAIL: assign=2 single note lit %d voices — want 8 (UNISON)\n", ngated(g)); ++fails; }
    for (int v = 0; v < 8; ++v)
        if (notes[v] != 60) { printf("FAIL: assign=2 voice %d on note %d, want 60\n", v, notes[v]); ++fails; break; }
    juno_gui_note_on(c2, 67, 100);
    juno_gui_debug_voices(c2, notes, g);
    if (ngated(g) != 8) { printf("FAIL: assign=2 second note lit %d voices — want 8\n", ngated(g)); ++fails; }
    for (int v = 0; v < 8; ++v)
        if (notes[v] != 67) { printf("FAIL: assign=2 stack did not follow to 67 (voice %d = %d)\n", v, notes[v]); ++fails; break; }

    free(bank);
    if (fails) { printf("FAIL: %d voice-alloc check(s)\n", fails); return 1; }
    printf("OK: voice allocation 7->0 + KEY ASSIGN POLY/MONO/UNISON verified\n");
    return 0;
}
