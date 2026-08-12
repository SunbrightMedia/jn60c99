/* eb_chorus_shim.c — the glue that lets tools/engineb/null_b.py put module
 * M-CHORUS, and only module M-CHORUS, inside the sealed port.
 *
 * THIS IS NOT THE ENGINE. Engine B proper will own its coefficients and call
 * eb_chorus_tick() directly; here the surrounding code is still the port, whose
 * recall writes coefficients into the 11 MB flat block. So each sample this
 * file LOADS the 40 coefficient cells out of that block and hands them to
 * eb_chorus_tick_x(). That load is what a recall does once in engine B, so it
 * is NOT part of the module's cost and is not measured as such
 * (tools/engineb/fx_chorus_cost.c measures eb_chorus_tick alone).
 *
 * STATE. The module's state lives in this file, not in the port's cells: it is
 * snapshotted out of them the first time a given engine instance renders the
 * chorus arm, and is authoritative from then on. That is the point — if the
 * module kept the port's cells the null would prove nothing about a compact
 * state layout. The block outputs (91088 / 91104 / 84672) ARE written back, so
 * every consumer downstream sees what it always saw.
 *
 * LIMIT, stated rather than hidden: the snapshot happens once per engine
 * pointer. A re-prepare (host sample-rate change) re-zeroes the port's chorus
 * cells and this file would not notice. No gate in this repo changes sample
 * rate on a live engine, and engine B will not have a snapshot at all, so the
 * limit is confined to the shim. It is asserted rather than assumed:
 * ebsh_chorus refuses a ring length it did not compile for.
 */
#include "eb_chorus.h"
#include "eb_chorus_shim.h"
#ifdef EB_DEVCELLS
#include "ebdev.h"
#define EBSH_CELL(b, off)  ((const unsigned char *)ebdev_at((unsigned long)(off)))
#else
#define EBSH_CELL(b, off)  ((const unsigned char *)(b) + (off))
#endif
#include <string.h>
#include <stdlib.h>

/* HOW MANY HOST CONTEXTS THIS TRANSLATION UNIT KEEPS.
 *
 * 16 is the HOST harness's number: the null gate renders many contexts in one
 * process. `ebsh_st` is sizeof(eb_chorus_state) per slot -- MEASURED at 63,720
 * BYTES of internal .bss on the S3 at 16 slots -- and A DEVICE HAS ONE
 * CONTEXT. Nothing on the firmware calls ebsh_chorus(); the firmware reaches
 * this file only through eb_master_coefs_build's coefficient reads.
 *
 * So the device sets EBSH_MAX_CTX=1 and gets ~60 KB of internal SRAM back,
 * which is more than device recall's entire new cost. It is a #ifndef and not
 * a silent change because the host harness genuinely needs 16, and a host gate
 * that quietly ran at 1 would abort() -- loudly, see below -- rather than
 * mis-measure. */
#ifndef EBSH_MAX_CTX
#define EBSH_MAX_CTX 16
#endif

static const unsigned char *ebsh_base[EBSH_MAX_CTX];
static eb_chorus_state ebsh_st[EBSH_MAX_CTX];
static int             ebsh_n;

static float ld(const unsigned char *b, int off)
{
    float f; memcpy(&f, EBSH_CELL(b, off), 4); return f;
}
static int32_t ldi(const unsigned char *b, int off)
{
    int32_t i; memcpy(&i, EBSH_CELL(b, off), 4); return i;
}

/* Copy the port's power-on chorus state into the module's struct. Every line
 * here is one cell of src/master_render.c's chorus arm; the names are the cell
 * offset minus 90000, so this function greps against that block. */
void ebsh_snapshot(eb_chorus_state *s, const unsigned char *b)
{
    int i;
    for (i = 0; i < EB_CHORUS_RING; ++i) s->line[i] = ld(b, 91728 + 4 * i);
    s->w = ldi(b, 95824);
    s->c400 = ld(b, 90400); s->c416 = ld(b, 90416); s->c432 = ld(b, 90432);
    s->c448 = ld(b, 90448); s->c464 = ld(b, 90464); s->c480 = ld(b, 90480);
    s->c496 = ld(b, 90496); s->c512 = ld(b, 90512);
    s->c528 = ld(b, 90528); s->c544 = ld(b, 90544); s->c560 = ld(b, 90560);
    s->c576 = ld(b, 90576); s->c592 = ld(b, 90592); s->c608 = ld(b, 90608);
    s->c624 = ld(b, 90624); s->c640 = ld(b, 90640); s->c656 = ld(b, 90656);
    s->c672 = ld(b, 90672);
    s->c688 = ld(b, 90688); s->c704 = ld(b, 90704); s->c720 = ld(b, 90720);
    s->c736 = ld(b, 90736); s->c752 = ld(b, 90752);
    s->c832 = ld(b, 90832); s->c848 = ld(b, 90848);
    s->c864 = ld(b, 90864); s->c880 = ld(b, 90880); s->c896 = ld(b, 90896);
    s->c912 = ld(b, 90912); s->c928 = ld(b, 90928); s->c944 = ld(b, 90944);
    s->c960 = ld(b, 90960); s->c976 = ld(b, 90976); s->c992 = ld(b, 90992);
    s->c1008 = ld(b, 91008); s->c1024 = ld(b, 91024); s->c1040 = ld(b, 91040);
    /* 90368/90384, 90768..90816, 91056/91072, 91088/91104, 95840 and
     * 95856..95880 are NOT snapshotted: they are per-sample scratch in the
     * module (eb_chorus.h), so there is nothing to carry. */
}

void ebsh_load_coef(eb_chorus_coef *k, const unsigned char *b)
{
    int i;
    k->dtime = ld(b, 91120); k->depth_r = ld(b, 91136);
    k->rate = ld(b, 91152);  k->phase_off = ld(b, 91168);
    k->depth = ld(b, 91184); k->noise = ld(b, 91200);
    k->dry = ld(b, 91216);   k->wet = ld(b, 91232);
    k->smco = ld(b, 91248);  k->onoff = ld(b, 91264);
    k->mute = ld(b, 91280);
    k->b0 = ld(b, 91296); k->b1 = ld(b, 91312); k->b2 = ld(b, 91328);
    k->a1 = ld(b, 91344); k->a2 = ld(b, 91360);
    k->hb0 = ld(b, 91376); k->hb1 = ld(b, 91392); k->ha1 = ld(b, 91408);
    k->svf_f = ld(b, 91424); k->svf_d = ld(b, 91440);
    k->eps = ld(b, 91456);
    k->mod_scale = ld(b, 91472); k->mod_off = ld(b, 91488);
    k->ramp_inc = ld(b, 91504); k->ramp_max = ld(b, 91520);
    k->slew_up = ld(b, 91536);  k->slew_dn = ld(b, 91552);
    k->n_gain = ld(b, 91568);   k->n_off = ld(b, 91584);
    for (i = 0; i < 8; ++i) k->nf[i] = ld(b, 91600 + 16 * i);
    k->ring_len = ldi(b, 95828);
}

/* Drop a base pointer's state. Called from the shim's chorus_init fork: an
 * engine that is (re-)initialised must not inherit a previous instance's LFO
 * phase or delay line through a recycled malloc address. */
void ebsh_forget(const unsigned char *base)
{
    int i, j;
    for (i = 0; i < ebsh_n; ++i)
        if (ebsh_base[i] == base) {
            for (j = i + 1; j < ebsh_n; ++j) {
                ebsh_base[j - 1] = ebsh_base[j];
                ebsh_st[j - 1] = ebsh_st[j];
            }
            ebsh_n--;
            return;
        }
}

void ebsh_chorus(unsigned char *base, float in, float *outL, float *outR,
                 float v56, float v58)
{
    eb_chorus_coef k;
    int i;
    for (i = 0; i < ebsh_n; ++i)
        if (ebsh_base[i] == base) break;
    if (i == ebsh_n) {
        if (ebsh_n == EBSH_MAX_CTX) abort();   /* loud, never silent */
        ebsh_base[i] = base;
        ebsh_snapshot(&ebsh_st[i], base);
        ebsh_n++;
    }
    ebsh_load_coef(&k, base);
    /* The ring length is a COMPILE-TIME budget. If the port ever prepares a
     * different one, fail loudly instead of indexing with the wrong mask. */
    if (k.ring_len != EB_CHORUS_RING) abort();
    eb_chorus_tick_x(&ebsh_st[i], &k, in, outL, outR, v56, v58);
}
