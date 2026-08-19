/* paramclass_gate.c -- O3: THE NARROWED REFRESH IS BIT-IDENTICAL, WITH TEETH.
 *
 * THE DESIGN UNDER TEST. The shipping parameter refresh is:
 *
 *     write the edited record bytes -> warm recall (apply + seeds, legal by
 *     paramwarm.c) -> re-run ONLY the sub-builders the parameter's class
 *     needs -> publish.
 *
 * The sub-builders are the SAME pieces O2's chunked build already ships:
 * eb_coefs_voice(v), eb_render_coefs_build_shared, eb_master_coefs_build.
 * b13 measured the classes: 37 parameters need all voices, 22 need only the
 * shared tail and/or master set, 1 (ASSIGN MODE) needs voices 1-7.
 *
 * THE CLAIM THIS GATE HOLDS: for every parameter, (pre-edit coefficients +
 * only the class's sub-builders re-run) == (full rebuild), BYTE FOR BYTE.
 * C9 names the tooth: "a parameter whose map is short by one field must
 * produce a coefficient set that differs from the full build."
 *
 * ⚠ THE CLASS IS DERIVED HERE, NOT ASSERTED. For each parameter the gate
 * measures which REGIONS moved -- per-voice regions come from OWN[v], the
 * bytes eb_coefs_voice(v) itself writes under two fills; the tail is what
 * remains of eb_render_coefs; the master set is its own struct -- and then
 * re-runs exactly the builders those regions belong to. The emitted table
 * (argv[3]) is therefore a MEASUREMENT the firmware can include, and this
 * gate re-derives it every run, so a table gone stale fails here before it
 * ships a stale coefficient there.
 *
 * ⚠ TEETH, because a gate never seen to fail is not a gate:
 *   --tooth-tail    treat every parameter as voices-only: a tail/master
 *                   parameter's narrowed rebuild must then DIFFER. Must FAIL.
 *   --tooth-voice   treat every parameter as tail+master-only: a per-voice
 *                   parameter must then DIFFER. Must FAIL.
 *   --tooth-one     drop voice 3 from every voice mask: the class is short by
 *                   ONE voice -- the C9 tooth verbatim. Must FAIL.
 *
 * ⚠ ITEM-7. Region ownership is measured from the builders, the classes are
 * measured from the deltas, and the teeth are mask edits. No JUNO name
 * appears; point it at another synth's builders and it asks the same question.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"

#define BANK_HEADER  23
#define BANK_STRIDE  20223
#define NBASE        13

static unsigned char *ST;
static eb_render_coefs RC_PRE, RC_REF, RC_TRY;
static eb_master_coef  MC_PRE, MC_REF, MC_TRY;
static unsigned char  *OWNV[EB_NUM_VOICES];   /* bytes eb_coefs_voice(v) writes */

static void reseed(void)
{
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = 44100.0f;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
}

static void recall_only(unsigned char *bank, int p)
{
    juno_bank_apply(ST, bank, p);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(bank, p));
    juno_apply_condition(ST, juno_bank_condition(bank, p));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(bank, p), 128.0f);
}

static void build_full(eb_render_coefs *rc, eb_master_coef *mc)
{
    eb_render_coefs_build(ST, rc);
    eb_master_coefs_build(ST, mc);
}

/* Which builder owns byte i of eb_render_coefs: voice v, or the tail (-1). */
static int rc_owner(size_t i)
{
    int v;
    for (v = 0; v < EB_NUM_VOICES; ++v)
        if (OWNV[v][i]) return v;
    return -1;
}

int main(int argc, char **argv)
{
    unsigned char *bank, *wb, *base[NBASE];
    int bpat[NBASE];
    static unsigned char want[4096];
    long bl;
    FILE *f, *tf = NULL;
    int b, i, k, v, nparam = 0, nfail = 0;
    unsigned s = 7u;
    int tooth_tail = 0, tooth_voice = 0, tooth_one = 0;
    const size_t NRC = sizeof(eb_render_coefs);
    const size_t NMC = sizeof(eb_master_coef);

    for (i = 4; i < argc; ++i) {
        if (!strcmp(argv[i], "--tooth-tail"))  tooth_tail = 1;
        if (!strcmp(argv[i], "--tooth-voice")) tooth_voice = 1;
        if (!strcmp(argv[i], "--tooth-one"))   tooth_one = 1;
    }
    if (argc < 4) {
        fprintf(stderr, "usage: paramclass_gate <bank> <positions.txt> "
                        "<table.h out> [--tooth-*]\n");
        return 2;
    }

    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)bl);
    if (fread(bank, 1, (size_t)bl, f) != (size_t)bl) { fclose(f); return 2; }
    fclose(f);

    f = fopen(argv[2], "r");
    if (!f) { perror(argv[2]); return 2; }
    while (fscanf(f, "%d", &i) == 1)
        if (i >= 0 && i < 4096) want[i] = 1u;
    fclose(f);

    ST = (unsigned char *)malloc(JUNO_STATE_BYTES);
    wb = (unsigned char *)malloc((size_t)bl);
    memcpy(wb, bank, (size_t)bl);
    for (b = 0; b < NBASE; ++b) {
        static const int RPAT[3] = { 3, 10, 17 };
        int pat = (b < 10) ? (b * 7) : RPAT[b - 10];
        bpat[b] = pat;
        base[b] = wb + BANK_HEADER + (long)pat * BANK_STRIDE;
        if (b >= 10)
            for (i = 16; i < BANK_STRIDE; ++i) {
                s = s * 1103515245u + 12345u;
                base[b][i] = (unsigned char)((s >> 16) & 0xFF);
            }
    }

    /* OWN[v] by two fills -- the same construction parammap.c proved out. */
    reseed(); recall_only(wb, 0);
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        static eb_render_coefs probe;
        int fill;
        OWNV[v] = (unsigned char *)calloc(NRC, 1);
        for (fill = 0; fill < 2; ++fill) {
            unsigned char fv = fill ? 0xFFu : 0x00u;
            const unsigned char *pp = (const unsigned char *)&probe;
            memset(&probe, fv, sizeof probe);
            eb_coefs_voice(ST, &probe, v);
            for (k = 0; (size_t)k < NRC; ++k)
                if (pp[k] != fv) OWNV[v][k] = 1u;
        }
    }

    tf = fopen(argv[3], "w");
    fprintf(tf, "/* GENERATED by paramclass_gate.c -- DO NOT EDIT.\n"
                " * record pair -> which sub-builders a parameter edit must\n"
                " * re-run. vmask = voices, tail/master = 0 or 1. The gate\n"
                " * that derives this also HOLDS it, with teeth. */\n"
                "typedef struct { short rec; unsigned char vmask8;\n"
                "                 unsigned char tail, master; } eb_param_class;\n"
                "static const eb_param_class EB_PARAM_CLASS[] = {\n");

    printf("%-6s %-10s %-5s %-6s  %s\n",
           "rec", "vmask", "tail", "master", "narrowed == full ?");

    for (i = 16; i + 1 < 4096; i += 2) {
        unsigned vmask = 0u;
        int need_tail = 0, need_master = 0, ok = 1, touched = 0;

        if (!want[i] && !want[i + 1]) continue;

        for (b = 0; b < NBASE && ok; ++b) {
            unsigned char o0 = base[b][i], o1 = base[b][i + 1];
            static const unsigned char PV[6] = { 0x00, 0x02, 0x03, 0x40,
                                                 0x7F, 0xFF };
            for (k = 0; k < 6 && ok; ++k) {
                unsigned char hi = (unsigned char)((PV[k] >> 4) & 0xFu);
                unsigned char lo = (unsigned char)(PV[k] & 0xFu);
                const unsigned char *pa, *pb;
                size_t j;
                if (hi == (o0 & 0xFu) && lo == (o1 & 0xFu)) continue;

                /* PRE: the live instrument on patch P */
                reseed(); recall_only(wb, bpat[b]);
                build_full(&RC_PRE, &MC_PRE);

                /* the edit lands warm, as it will on the device */
                base[b][i] = hi; base[b][i + 1] = lo;
                recall_only(wb, bpat[b]);
                build_full(&RC_REF, &MC_REF);            /* the oracle */

                /* grow this parameter's class from what actually moved */
                pa = (const unsigned char *)&RC_PRE;
                pb = (const unsigned char *)&RC_REF;
                for (j = 0; j < NRC; ++j)
                    if (pa[j] != pb[j]) {
                        int own = rc_owner(j);
                        if (own < 0) need_tail = 1;
                        else vmask |= (1u << own);
                    }
                if (memcmp(&MC_PRE, &MC_REF, NMC)) need_master = 1;

                /* THE NARROWED REBUILD, from the PRE structs, teeth applied */
                {
                    unsigned use_v = vmask;
                    int use_t = need_tail, use_m = need_master;
                    if (tooth_tail)  { use_t = 0; use_m = 0; }
                    if (tooth_voice) { use_v = 0; }
                    if (tooth_one)   { use_v &= ~(1u << 3); }

                    memcpy(&RC_TRY, &RC_PRE, NRC);
                    memcpy(&MC_TRY, &MC_PRE, NMC);
                    for (v = 0; v < EB_NUM_VOICES; ++v)
                        if ((use_v >> v) & 1u)
                            eb_coefs_voice(ST, &RC_TRY, v);
                    if (use_t) eb_render_coefs_build_shared(ST, &RC_TRY);
                    if (use_m) eb_master_coefs_build(ST, &MC_TRY);
                }
                if (memcmp(&RC_TRY, &RC_REF, NRC) ||
                    memcmp(&MC_TRY, &MC_REF, NMC)) ok = 0;
                if (memcmp(&RC_PRE, &RC_REF, NRC) ||
                    memcmp(&MC_PRE, &MC_REF, NMC)) touched = 1;

                base[b][i] = o0; base[b][i + 1] = o1;
            }
        }
        if (!touched) continue;
        ++nparam;
        if (!ok) ++nfail;
        printf("%-6d 0x%02x       %-5d %-6d  %s\n",
               i, vmask, need_tail, need_master, ok ? "IDENTICAL" : "*** DIFFERS ***");
        fprintf(tf, "    { %d, 0x%02xu, %d, %d },\n",
                i, vmask, need_tail, need_master);
    }
    fprintf(tf, "};\n");
    fclose(tf);

    printf("\n%d parameters, %d narrowed rebuilds differ\n", nparam, nfail);
    if (tooth_tail || tooth_voice || tooth_one)
        return nfail ? 0 : 1;      /* a tooth run must FAIL to pass */
    return nfail ? 1 : 0;
}
