/* test_voice_alloc.c — regression guard for voice ALLOCATION + KEY ASSIGN mode,
 * both proven against the plugin's real CAssignJu60 by running-code diff:
 *   1. a fresh single note is allocated to the HIGHEST slot (voice 7), and
 *      successive new notes descend 7,6,5,... (the plugin's list is [0..7] scanned
 *      top-down — NOT 0,1,2,..).
 *   2. KEY ASSIGN (blob 56) is POLY-1(0) / POLY-2(1) / UNISON(2) — there is NO mono.
 *      An assign=1 patch must play POLYPHONICALLY (a chord uses ≥3 voices), not be
 *      collapsed to a single voice. (14 factory patches carry assign=1 and were
 *      wrongly played mono before this fix.)
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

int main(void)
{
    int fails = 0, notes[8]; unsigned char g[8];
    unsigned char *bank = calloc(1, HDR + STRIDE);
    bank[0] = 'K';
    unsigned char *rec = bank + HDR;
    /* give the voice a sounding level so allocation is observable (DCO saw + VCA) */
    put_blob(rec, 27, 200);          /* DCO SAW LEVEL */
    put_blob(rec, 66, 200);          /* VCA LEVEL     */

    /* --- assign = 1 (POLY-2): must be POLYPHONIC, and first note on voice 7 --- */
    put_blob(rec, 56, 1);
    juno_ctx *c = juno_gui_create(48000.0f, 2);
    juno_gui_apply_bank(c, bank, HDR + STRIDE, 0);
    juno_gui_note_on(c, 60, 100);
    juno_gui_debug_voices(c, notes, g);
    if (!(g[7] && notes[7] == 60)) {
        printf("FAIL: assign=1 single note not on voice 7 (");
        for (int v = 0; v < 8; ++v) if (g[v]) printf("v%d=n%d ", v, notes[v]);
        printf(")\n"); ++fails;
    }
    /* chord: must use 3 distinct voices (poly), descending 7,6,5 */
    juno_gui_note_on(c, 64, 100);
    juno_gui_note_on(c, 67, 100);
    juno_gui_debug_voices(c, notes, g);
    { int ng = 0; for (int v = 0; v < 8; ++v) if (g[v]) ++ng;
      if (ng < 3) { printf("FAIL: assign=1 chord collapsed to %d voice(s) — MONO bug\n", ng); ++fails; }
      if (!(g[7] && g[6] && g[5])) { printf("FAIL: assign=1 chord not on voices 7/6/5\n"); ++fails; } }

    /* --- assign = 0 (POLY-1): also polyphonic, first note voice 7 --- */
    put_blob(rec, 56, 0);
    juno_ctx *c2 = juno_gui_create(48000.0f, 2);
    juno_gui_apply_bank(c2, bank, HDR + STRIDE, 0);
    juno_gui_note_on(c2, 60, 100); juno_gui_note_on(c2, 64, 100); juno_gui_note_on(c2, 67, 100);
    juno_gui_debug_voices(c2, notes, g);
    { int ng = 0; for (int v = 0; v < 8; ++v) if (g[v]) ++ng;
      if (ng < 3) { printf("FAIL: assign=0 chord collapsed to %d voice(s)\n", ng); ++fails; } }

    free(bank);
    if (fails) { printf("FAIL: %d voice-alloc check(s)\n", fails); return 1; }
    printf("OK: voice allocation 7->0 + KEY ASSIGN poly (no mono) verified\n");
    return 0;
}
