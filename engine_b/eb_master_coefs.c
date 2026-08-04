/* eb_master_coefs.c -- GENERATED. Builds engine B's master-chain
 * coefficients and seeds its state from the PORT's recalled cells.
 *
 * This is HARNESS PLUMBING for the 1b-2 gate, exactly as
 * eb_render_coefs_build is for the voice chain: it lets the standalone
 * engine be gated before eb_patch (engine B's own recall) exists. The
 * instrument's own recall path is a separate, separately gated task.
 *
 * Every cell list here is the one the corresponding MODULE was generated
 * from, so the two cannot drift apart by hand-editing.
 */
#include "eb_master_coefs.h"
#include "eb_chorus_shim.h"
#include <string.h>

#define CF(p, off)  (*(const float *)((const unsigned char *)(p) + (off)))
#define CI(p, off)  (*(const int32_t *)((const unsigned char *)(p) + (off)))

void eb_master_coefs_build(const unsigned char *base, eb_master_coef *c)
{
    memset(c, 0, sizeof *c);
    c->delay_type  = CI(base, 11022056);   /* JUNO_PROG_DLY */
    c->effect_type = CI(base, 11022052);   /* JUNO_PROG_EFX */
    c->k101744     = CF(base, 101744);     /* delay-core output gain */

    c->in.k84448 = CF(base, 84448);
    c->in.k84464 = CF(base, 84464);
    c->in.k84480 = CF(base, 84480);
    c->in.k84496 = CF(base, 84496);
    c->in.k84512 = CF(base, 84512);
    c->in.k84544 = CF(base, 84544);
    c->in.k84560 = CF(base, 84560);
    c->in.k84640 = CF(base, 84640);
    c->in.k84656 = CF(base, 84656);
    c->in.k84800 = CF(base, 84800);
    c->in.k84816 = CF(base, 84816);
    c->in.k101072 = CF(base, 101072);

    c->out.k101136 = CF(base, 101136);
    c->out.k101152 = CF(base, 101152);
    c->out.k101296 = CF(base, 101296);
    c->out.k101312 = CF(base, 101312);
    c->out.k101328 = CF(base, 101328);
    c->out.k101344 = CF(base, 101344);
    c->out.k101360 = CF(base, 101360);
    c->out.k101376 = CF(base, 101376);
    c->out.k101392 = CF(base, 101392);
    c->out.k101408 = CF(base, 101408);
    c->out.k101424 = CF(base, 101424);
    c->out.k101440 = CF(base, 101440);
    c->out.k101456 = CF(base, 101456);
    c->out.k101472 = CF(base, 101472);

    c->d1.k101744 = CF(base, 101744);
    c->d1.k4297584 = CF(base, 4297584);
    c->d1.k4297600 = CF(base, 4297600);
    c->d1.k4297616 = CF(base, 4297616);
    c->d1.k4297632 = CF(base, 4297632);
    c->d1.k4297648 = CF(base, 4297648);
    c->d1.k4297664 = CF(base, 4297664);
    c->d1.k4297680 = CF(base, 4297680);
    c->d1.k4297696 = CF(base, 4297696);
    c->d1.k4297712 = CF(base, 4297712);
    c->d1.k4297728 = CF(base, 4297728);
    c->d1.k4297744 = CF(base, 4297744);
    c->d1.k4297760 = CF(base, 4297760);
    c->d1.k4297792 = CF(base, 4297792);
    c->d1.k4297808 = CF(base, 4297808);
    c->d1.k4297824 = CF(base, 4297824);
    c->d1.k4297840 = CF(base, 4297840);
    c->d1.k4297856 = CF(base, 4297856);
    c->d1.k4297872 = CF(base, 4297872);
    c->d1.k4297888 = CF(base, 4297888);
    c->d1.k4297904 = CF(base, 4297904);
    c->d1.k4297920 = CF(base, 4297920);
    c->d1.k4297936 = CF(base, 4297936);
    c->d1.k4297952 = CF(base, 4297952);
    c->d1.k4297968 = CF(base, 4297968);
    c->d1.k4297984 = CF(base, 4297984);
    c->d1.k4298000 = CF(base, 4298000);
    c->d1.k4298016 = CF(base, 4298016);
    c->d1.k4298032 = CF(base, 4298032);
    c->d1.k4298048 = CF(base, 4298048);
    c->d1.k4298064 = CF(base, 4298064);
    c->d1.k4298080 = CF(base, 4298080);
    c->d1.k6395252 = CI(base, 6395252);

    c->d23.k101744 = CF(base, 101744);
    c->d23.k6395312 = CF(base, 6395312);
    c->d23.k6395328 = CF(base, 6395328);
    c->d23.k6395408 = CF(base, 6395408);
    c->d23.k6395648 = CF(base, 6395648);
    c->d23.k6395664 = CF(base, 6395664);
    c->d23.k6395696 = CF(base, 6395696);
    c->d23.k6395712 = CF(base, 6395712);
    c->d23.k6396128 = CF(base, 6396128);
    c->d23.k6396144 = CF(base, 6396144);
    c->d23.k6396160 = CF(base, 6396160);
    c->d23.k6396176 = CF(base, 6396176);
    c->d23.k6396192 = CF(base, 6396192);
    c->d23.k6396208 = CF(base, 6396208);
    c->d23.k6396224 = CF(base, 6396224);
    c->d23.k6396240 = CF(base, 6396240);
    c->d23.k6396256 = CF(base, 6396256);
    c->d23.k6396272 = CF(base, 6396272);
    c->d23.k6396288 = CF(base, 6396288);
    c->d23.k6396304 = CF(base, 6396304);
    c->d23.k6396320 = CF(base, 6396320);
    c->d23.k6396336 = CF(base, 6396336);
    c->d23.k6396352 = CF(base, 6396352);
    c->d23.k6396368 = CF(base, 6396368);
    c->d23.k6396384 = CF(base, 6396384);
    c->d23.k6396400 = CF(base, 6396400);
    c->d23.k6396416 = CF(base, 6396416);
    c->d23.k6396432 = CF(base, 6396432);
    c->d23.k6396448 = CF(base, 6396448);
    c->d23.k6396464 = CF(base, 6396464);
    c->d23.k6396480 = CF(base, 6396480);
    c->d23.k6396496 = CF(base, 6396496);
    c->d23.k6396512 = CF(base, 6396512);
    c->d23.k6396528 = CF(base, 6396528);
    c->d23.k6396544 = CF(base, 6396544);
    c->d23.k6396560 = CF(base, 6396560);
    c->d23.k6396576 = CF(base, 6396576);
    c->d23.k6396592 = CF(base, 6396592);
    c->d23.k6396608 = CF(base, 6396608);
    c->d23.k6396624 = CF(base, 6396624);
    c->d23.k6429412 = CI(base, 6429412);

    c->d5.k101744 = CF(base, 101744);
    c->d5.k6497168 = CF(base, 6497168);
    c->d5.k6497184 = CF(base, 6497184);
    c->d5.k6497200 = CF(base, 6497200);
    c->d5.k6497216 = CF(base, 6497216);
    c->d5.k6497232 = CF(base, 6497232);
    c->d5.k6497248 = CF(base, 6497248);
    c->d5.k6497264 = CF(base, 6497264);
    c->d5.k6497280 = CF(base, 6497280);
    c->d5.k6497296 = CF(base, 6497296);
    c->d5.k6497312 = CF(base, 6497312);
    c->d5.k6497328 = CF(base, 6497328);
    c->d5.k6497344 = CF(base, 6497344);
    c->d5.k6497376 = CF(base, 6497376);
    c->d5.k6497392 = CF(base, 6497392);
    c->d5.k6497408 = CF(base, 6497408);
    c->d5.k6497424 = CF(base, 6497424);
    c->d5.k6497440 = CF(base, 6497440);
    c->d5.k6497456 = CF(base, 6497456);
    c->d5.k6497472 = CF(base, 6497472);
    c->d5.k6497488 = CF(base, 6497488);
    c->d5.k6497504 = CF(base, 6497504);
    c->d5.k6497520 = CF(base, 6497520);
    c->d5.k6497536 = CF(base, 6497536);
    c->d5.k6497568 = CF(base, 6497568);
    c->d5.k6497584 = CF(base, 6497584);
    c->d5.k6497600 = CF(base, 6497600);
    c->d5.k8594772 = CI(base, 8594772);
    c->d5.k10691940 = CI(base, 10691940);
    c->d5.k10692016 = CF(base, 10692016);
    c->d5.k10692032 = CF(base, 10692032);
    c->d5.k10692112 = CF(base, 10692112);
    c->d5.k10692352 = CF(base, 10692352);
    c->d5.k10692368 = CF(base, 10692368);
    c->d5.k10692400 = CF(base, 10692400);
    c->d5.k10692416 = CF(base, 10692416);
    c->d5.k10693008 = CF(base, 10693008);
    c->d5.k10693024 = CF(base, 10693024);
    c->d5.k10693040 = CF(base, 10693040);
    c->d5.k10693056 = CF(base, 10693056);
    c->d5.k10693072 = CF(base, 10693072);
    c->d5.k10693088 = CF(base, 10693088);
    c->d5.k10693104 = CF(base, 10693104);
    c->d5.k10693120 = CF(base, 10693120);
    c->d5.k10693136 = CF(base, 10693136);
    c->d5.k10693152 = CF(base, 10693152);
    c->d5.k10693168 = CF(base, 10693168);
    c->d5.k10693184 = CF(base, 10693184);
    c->d5.k10693200 = CF(base, 10693200);
    c->d5.k10693216 = CF(base, 10693216);
    c->d5.k10693232 = CF(base, 10693232);
    c->d5.k10693248 = CF(base, 10693248);
    c->d5.k10693264 = CF(base, 10693264);
    c->d5.k10693280 = CF(base, 10693280);
    c->d5.k10693296 = CF(base, 10693296);
    c->d5.k10693312 = CF(base, 10693312);
    c->d5.k10693328 = CF(base, 10693328);
    c->d5.k10693344 = CF(base, 10693344);
    c->d5.k10693360 = CF(base, 10693360);
    c->d5.k10693376 = CF(base, 10693376);
    c->d5.k10693392 = CF(base, 10693392);
    c->d5.k10693408 = CF(base, 10693408);
    c->d5.k10693424 = CF(base, 10693424);
    c->d5.k10693440 = CF(base, 10693440);
    c->d5.k10693456 = CF(base, 10693456);
    c->d5.k10693472 = CF(base, 10693472);
    c->d5.k10726260 = CI(base, 10726260);
    c->d5.k10759044 = CI(base, 10759044);

    c->e1.k86288 = CF(base, 86288);
    c->e1.k86304 = CF(base, 86304);
    c->e1.k86320 = CF(base, 86320);
    c->e1.k86352 = CF(base, 86352);
    c->e1.k86368 = CF(base, 86368);
    c->e1.k86384 = CF(base, 86384);
    c->e1.k86400 = CF(base, 86400);
    c->e1.k86416 = CF(base, 86416);
    c->e1.k86432 = CF(base, 86432);
    c->e1.k86448 = CF(base, 86448);
    c->e1.k86464 = CF(base, 86464);
    c->e1.k86480 = CF(base, 86480);
    c->e1.k86496 = CF(base, 86496);
    c->e1.k86512 = CF(base, 86512);
    c->e1.k86528 = CF(base, 86528);
    c->e1.k86544 = CF(base, 86544);
    c->e1.k86560 = CF(base, 86560);
    c->e1.k86576 = CF(base, 86576);
    c->e1.k86592 = CF(base, 86592);
    c->e1.k86608 = CF(base, 86608);
    c->e1.k86624 = CF(base, 86624);
    c->e1.k86640 = CF(base, 86640);
    c->e1.k86816 = CF(base, 86816);
    c->e1.k86832 = CF(base, 86832);
    c->e1.k86848 = CF(base, 86848);
    c->e1.k86864 = CF(base, 86864);
    c->e1.k86880 = CF(base, 86880);
    c->e1.k86896 = CF(base, 86896);
    c->e1.k86912 = CF(base, 86912);
    c->e1.k86928 = CF(base, 86928);
    c->e1.k86944 = CF(base, 86944);
    c->e1.k86960 = CF(base, 86960);
    c->e1.k87056 = CF(base, 87056);
    c->e1.k87072 = CF(base, 87072);
    c->e1.k87088 = CF(base, 87088);
    c->e1.k87104 = CF(base, 87104);
    c->e1.k87120 = CF(base, 87120);
    c->e1.k87136 = CF(base, 87136);
    c->e1.k87152 = CF(base, 87152);

    c->e5.k96336 = CF(base, 96336);
    c->e5.k96352 = CF(base, 96352);
    c->e5.k96368 = CF(base, 96368);
    c->e5.k96384 = CF(base, 96384);
    c->e5.k96400 = CF(base, 96400);
    c->e5.k96416 = CF(base, 96416);
    c->e5.k96432 = CF(base, 96432);
    c->e5.k96448 = CF(base, 96448);
    c->e5.k96464 = CF(base, 96464);
    c->e5.k96480 = CF(base, 96480);
    c->e5.k96496 = CF(base, 96496);
    c->e5.k96512 = CF(base, 96512);
    c->e5.k96528 = CF(base, 96528);
    c->e5.k96544 = CF(base, 96544);
    c->e5.k96560 = CF(base, 96560);
    c->e5.k96576 = CF(base, 96576);
    c->e5.k96592 = CF(base, 96592);
    c->e5.k96608 = CF(base, 96608);
    c->e5.k96624 = CF(base, 96624);
    c->e5.k96640 = CF(base, 96640);
    c->e5.k96656 = CF(base, 96656);
    c->e5.k96672 = CF(base, 96672);
    c->e5.k96688 = CF(base, 96688);
    c->e5.k96704 = CF(base, 96704);
    c->e5.k96720 = CF(base, 96720);
    c->e5.k96736 = CF(base, 96736);
    c->e5.k96752 = CF(base, 96752);
    c->e5.k96768 = CF(base, 96768);
    c->e5.k96784 = CF(base, 96784);
    c->e5.k96800 = CF(base, 96800);
    c->e5.k96816 = CF(base, 96816);
    c->e5.k96832 = CF(base, 96832);
    c->e5.k96848 = CF(base, 96848);
    c->e5.k96864 = CF(base, 96864);
    c->e5.k96880 = CF(base, 96880);
    c->e5.k96896 = CF(base, 96896);
    c->e5.k96912 = CF(base, 96912);
    c->e5.k101028 = CI(base, 101028);

    /* FX: the same gathers eb_coefs.c uses, which are the FX shims' own. */
    ebsh_load_coef(&c->cho, base);
    {   eb_delay_cfg *k = &c->dcore;
        k->b0 = CF(base, 102368); k->b1 = CF(base, 102384);
        k->b2 = CF(base, 102400); k->a1 = CF(base, 102416);
        k->a2 = CF(base, 102432); k->mixA = CF(base, 102448);
        k->svf_g = CF(base, 102464); k->svf_r = CF(base, 102480);
        k->mixB = CF(base, 102496); k->dry = CF(base, 102512);
        k->wet = CF(base, 102528); k->fb = CF(base, 102560);
        k->on = CF(base, 102576); k->mute = CF(base, 102592);
        k->lp_g = CF(base, 102608); k->k624 = CF(base, 102624);
        k->lf_damp = CF(base, 102640); k->hp_g = CF(base, 102656);
        k->hf_damp = CF(base, 102672); k->k688 = CF(base, 102688);
        k->dc_g = CF(base, 102704); k->fade_k = CF(base, 102720);
        k->fade_up = CF(base, 102752); k->fade_dn = CF(base, 102768);
        k->slew = CF(base, 102784); k->time_target = CF(base, 102352);
        k->fade_gain = CF(base, 84496); }
    {   eb_reverb_cfg *k = &c->rev; int rk;
        k->send = CF(base, 10759408); k->gate = CF(base, 10759376);
        k->dry  = CF(base, 10759424); k->wet  = CF(base, 10759440);
        k->ap   = CF(base, 10759392);
        for (rk = 0; rk < 8; ++rk) k->f_in[rk] = CF(base, 10759520 + 16*rk);
        for (rk = 0; rk < 4; ++rk) {
            k->damp[rk][0] = CF(base, 10759648 + 48*rk);
            k->damp[rk][1] = CF(base, 10759664 + 48*rk);
            k->damp[rk][2] = CF(base, 10759680 + 48*rk); }
        k->lfo_inc = CF(base, 10759504);
        k->lfo_depth = CF(base, 10759488); }
}

void eb_master_state_seed(const unsigned char *base, eb_master_state *s)
{
    int i;
    memset(s, 0, sizeof *s);
    s->route_change = CI(base, 11022348);
    s->fb84672 = CF(base, 84672);
    s->fb84704 = CF(base, 84704);
    s->in.s84768 = CF(base, 84768);

    s->d1.s4297200 = CF(base, 4297200);
    s->d1.s4297216 = CF(base, 4297216);
    s->d1.s4297232 = CF(base, 4297232);
    s->d1.s4297248 = CF(base, 4297248);
    s->d1.s4297264 = CF(base, 4297264);
    s->d1.s4297280 = CF(base, 4297280);
    s->d1.s4297296 = CF(base, 4297296);
    s->d1.s4297312 = CF(base, 4297312);
    s->d1.s4297328 = CF(base, 4297328);
    s->d1.s4297344 = CF(base, 4297344);
    s->d1.s4297360 = CF(base, 4297360);
    s->d1.s4297376 = CF(base, 4297376);
    s->d1.s4297392 = CF(base, 4297392);
    s->d1.s4297408 = CF(base, 4297408);
    s->d1.s4297424 = CF(base, 4297424);
    s->d1.s4297440 = CF(base, 4297440);
    s->d1.s4297456 = CF(base, 4297456);
    s->d1.s4297472 = CF(base, 4297472);
    s->d1.s4297488 = CF(base, 4297488);
    s->d1.s4297504 = CF(base, 4297504);
    s->d1.s4297520 = CF(base, 4297520);
    s->d1.s4297536 = CF(base, 4297536);
    s->d1.s4297552 = CF(base, 4297552);
    s->d1.s4297568 = CF(base, 4297568);
    s->d1.s6395264 = CF(base, 6395264);
    s->d1.s6395280 = CF(base, 6395280);
    s->d1.s6395284 = CF(base, 6395284);
    s->d1.s6395288 = CF(base, 6395288);
    s->d1.s6395296 = CF(base, 6395296);
    s->d1.s6395300 = CF(base, 6395300);
    s->d1.s6395304 = CF(base, 6395304);
    s->d1.s6395248 = CI(base, 6395248);
    s->d1.s11022348 = CI(base, 11022348);

    s->d23.s6395344 = CF(base, 6395344);
    s->d23.s6395360 = CF(base, 6395360);
    s->d23.s6395376 = CF(base, 6395376);
    s->d23.s6395600 = CF(base, 6395600);
    s->d23.s6395616 = CF(base, 6395616);
    s->d23.s6395632 = CF(base, 6395632);
    s->d23.s6395680 = CF(base, 6395680);
    s->d23.s6395728 = CF(base, 6395728);
    s->d23.s6395744 = CF(base, 6395744);
    s->d23.s6395760 = CF(base, 6395760);
    s->d23.s6395776 = CF(base, 6395776);
    s->d23.s6395792 = CF(base, 6395792);
    s->d23.s6395808 = CF(base, 6395808);
    s->d23.s6395824 = CF(base, 6395824);
    s->d23.s6395840 = CF(base, 6395840);
    s->d23.s6395856 = CF(base, 6395856);
    s->d23.s6395872 = CF(base, 6395872);
    s->d23.s6395888 = CF(base, 6395888);
    s->d23.s6395904 = CF(base, 6395904);
    s->d23.s6395920 = CF(base, 6395920);
    s->d23.s6395936 = CF(base, 6395936);
    s->d23.s6395952 = CF(base, 6395952);
    s->d23.s6395968 = CF(base, 6395968);
    s->d23.s6395984 = CF(base, 6395984);
    s->d23.s6396000 = CF(base, 6396000);
    s->d23.s6396016 = CF(base, 6396016);
    s->d23.s6396032 = CF(base, 6396032);
    s->d23.s6396048 = CF(base, 6396048);
    s->d23.s6396064 = CF(base, 6396064);
    s->d23.s6396080 = CF(base, 6396080);
    s->d23.s6396096 = CF(base, 6396096);
    s->d23.s6396112 = CF(base, 6396112);
    s->d23.s6429424 = CF(base, 6429424);
    s->d23.s6429440 = CF(base, 6429440);
    s->d23.s6429444 = CF(base, 6429444);
    s->d23.s6429448 = CF(base, 6429448);
    s->d23.s6429456 = CF(base, 6429456);
    s->d23.s6429460 = CF(base, 6429460);
    s->d23.s6429464 = CF(base, 6429464);
    s->d23.s6429408 = CI(base, 6429408);
    s->d23.s11022348 = CI(base, 11022348);

    s->d5.s6496576 = CF(base, 6496576);
    s->d5.s6496592 = CF(base, 6496592);
    s->d5.s6496608 = CF(base, 6496608);
    s->d5.s6496624 = CF(base, 6496624);
    s->d5.s6496640 = CF(base, 6496640);
    s->d5.s6496656 = CF(base, 6496656);
    s->d5.s6496672 = CF(base, 6496672);
    s->d5.s6496688 = CF(base, 6496688);
    s->d5.s6496704 = CF(base, 6496704);
    s->d5.s6496720 = CF(base, 6496720);
    s->d5.s6496736 = CF(base, 6496736);
    s->d5.s6496752 = CF(base, 6496752);
    s->d5.s6496768 = CF(base, 6496768);
    s->d5.s6496784 = CF(base, 6496784);
    s->d5.s6496800 = CF(base, 6496800);
    s->d5.s6496816 = CF(base, 6496816);
    s->d5.s6496832 = CF(base, 6496832);
    s->d5.s6496848 = CF(base, 6496848);
    s->d5.s6496864 = CF(base, 6496864);
    s->d5.s6496880 = CF(base, 6496880);
    s->d5.s6496896 = CF(base, 6496896);
    s->d5.s6496912 = CF(base, 6496912);
    s->d5.s6496928 = CF(base, 6496928);
    s->d5.s6496944 = CF(base, 6496944);
    s->d5.s6496960 = CF(base, 6496960);
    s->d5.s6496976 = CF(base, 6496976);
    s->d5.s6496992 = CF(base, 6496992);
    s->d5.s6497008 = CF(base, 6497008);
    s->d5.s6497024 = CF(base, 6497024);
    s->d5.s6497040 = CF(base, 6497040);
    s->d5.s6497056 = CF(base, 6497056);
    s->d5.s6497072 = CF(base, 6497072);
    s->d5.s6497088 = CF(base, 6497088);
    s->d5.s6497104 = CF(base, 6497104);
    s->d5.s6497120 = CF(base, 6497120);
    s->d5.s6497136 = CF(base, 6497136);
    s->d5.s6497152 = CF(base, 6497152);
    s->d5.s10691952 = CF(base, 10691952);
    s->d5.s10691968 = CF(base, 10691968);
    s->d5.s10691972 = CF(base, 10691972);
    s->d5.s10691976 = CF(base, 10691976);
    s->d5.s10691984 = CF(base, 10691984);
    s->d5.s10692000 = CF(base, 10692000);
    s->d5.s10692004 = CF(base, 10692004);
    s->d5.s10692008 = CF(base, 10692008);
    s->d5.s10692048 = CF(base, 10692048);
    s->d5.s10692064 = CF(base, 10692064);
    s->d5.s10692080 = CF(base, 10692080);
    s->d5.s10692304 = CF(base, 10692304);
    s->d5.s10692320 = CF(base, 10692320);
    s->d5.s10692336 = CF(base, 10692336);
    s->d5.s10692384 = CF(base, 10692384);
    s->d5.s10692432 = CF(base, 10692432);
    s->d5.s10692448 = CF(base, 10692448);
    s->d5.s10692464 = CF(base, 10692464);
    s->d5.s10692480 = CF(base, 10692480);
    s->d5.s10692496 = CF(base, 10692496);
    s->d5.s10692512 = CF(base, 10692512);
    s->d5.s10692528 = CF(base, 10692528);
    s->d5.s10692544 = CF(base, 10692544);
    s->d5.s10692560 = CF(base, 10692560);
    s->d5.s10692576 = CF(base, 10692576);
    s->d5.s10692592 = CF(base, 10692592);
    s->d5.s10692608 = CF(base, 10692608);
    s->d5.s10692624 = CF(base, 10692624);
    s->d5.s10692640 = CF(base, 10692640);
    s->d5.s10692656 = CF(base, 10692656);
    s->d5.s10692672 = CF(base, 10692672);
    s->d5.s10692688 = CF(base, 10692688);
    s->d5.s10692704 = CF(base, 10692704);
    s->d5.s10692720 = CF(base, 10692720);
    s->d5.s10692736 = CF(base, 10692736);
    s->d5.s10692752 = CF(base, 10692752);
    s->d5.s10692768 = CF(base, 10692768);
    s->d5.s10692784 = CF(base, 10692784);
    s->d5.s10692800 = CF(base, 10692800);
    s->d5.s10692816 = CF(base, 10692816);
    s->d5.s10692832 = CF(base, 10692832);
    s->d5.s10692848 = CF(base, 10692848);
    s->d5.s10692864 = CF(base, 10692864);
    s->d5.s10692880 = CF(base, 10692880);
    s->d5.s10692896 = CF(base, 10692896);
    s->d5.s10692912 = CF(base, 10692912);
    s->d5.s10692928 = CF(base, 10692928);
    s->d5.s10692944 = CF(base, 10692944);
    s->d5.s10692960 = CF(base, 10692960);
    s->d5.s10692976 = CF(base, 10692976);
    s->d5.s10692992 = CF(base, 10692992);
    s->d5.s10759056 = CF(base, 10759056);
    s->d5.s10759072 = CF(base, 10759072);
    s->d5.s10759076 = CF(base, 10759076);
    s->d5.s10759080 = CF(base, 10759080);
    s->d5.s10759088 = CF(base, 10759088);
    s->d5.s10759104 = CF(base, 10759104);
    s->d5.s10759108 = CF(base, 10759108);
    s->d5.s10759112 = CF(base, 10759112);
    s->d5.s8594768 = CI(base, 8594768);
    s->d5.s10691936 = CI(base, 10691936);
    s->d5.s10726256 = CI(base, 10726256);
    s->d5.s10759040 = CI(base, 10759040);
    s->d5.s11022348 = CI(base, 11022348);

    s->e1.s84672 = CF(base, 84672);
    s->e1.s86096 = CF(base, 86096);
    s->e1.s86112 = CF(base, 86112);
    s->e1.s86128 = CF(base, 86128);
    s->e1.s86144 = CF(base, 86144);
    s->e1.s86160 = CF(base, 86160);
    s->e1.s86176 = CF(base, 86176);
    s->e1.s86192 = CF(base, 86192);
    s->e1.s86208 = CF(base, 86208);
    s->e1.s86224 = CF(base, 86224);
    s->e1.s86240 = CF(base, 86240);
    s->e1.s86256 = CF(base, 86256);
    s->e1.s86272 = CF(base, 86272);
    s->e1.s86656 = CF(base, 86656);
    s->e1.s86672 = CF(base, 86672);
    s->e1.s86688 = CF(base, 86688);
    s->e1.s86704 = CF(base, 86704);
    s->e1.s86720 = CF(base, 86720);
    s->e1.s86736 = CF(base, 86736);
    s->e1.s86752 = CF(base, 86752);
    s->e1.s86768 = CF(base, 86768);
    s->e1.s86784 = CF(base, 86784);
    s->e1.s86800 = CF(base, 86800);
    s->e1.s86976 = CF(base, 86976);
    s->e1.s86992 = CF(base, 86992);
    s->e1.s87008 = CF(base, 87008);
    s->e1.s87024 = CF(base, 87024);
    s->e1.s87040 = CF(base, 87040);

    s->e5.s84672 = CF(base, 84672);
    s->e5.s95888 = CF(base, 95888);
    s->e5.s95904 = CF(base, 95904);
    s->e5.s95920 = CF(base, 95920);
    s->e5.s95936 = CF(base, 95936);
    s->e5.s95952 = CF(base, 95952);
    s->e5.s95968 = CF(base, 95968);
    s->e5.s95984 = CF(base, 95984);
    s->e5.s96000 = CF(base, 96000);
    s->e5.s96016 = CF(base, 96016);
    s->e5.s96032 = CF(base, 96032);
    s->e5.s96048 = CF(base, 96048);
    s->e5.s96064 = CF(base, 96064);
    s->e5.s96080 = CF(base, 96080);
    s->e5.s96096 = CF(base, 96096);
    s->e5.s96112 = CF(base, 96112);
    s->e5.s96128 = CF(base, 96128);
    s->e5.s96144 = CF(base, 96144);
    s->e5.s96160 = CF(base, 96160);
    s->e5.s96176 = CF(base, 96176);
    s->e5.s96192 = CF(base, 96192);
    s->e5.s96208 = CF(base, 96208);
    s->e5.s96224 = CF(base, 96224);
    s->e5.s96240 = CF(base, 96240);
    s->e5.s96256 = CF(base, 96256);
    s->e5.s96272 = CF(base, 96272);
    s->e5.s96288 = CF(base, 96288);
    s->e5.s96304 = CF(base, 96304);
    s->e5.s96320 = CF(base, 96320);
    s->e5.s101040 = CF(base, 101040);
    s->e5.s101056 = CF(base, 101056);
    s->e5.s101060 = CF(base, 101060);
    s->e5.s101064 = CF(base, 101064);
    s->e5.s101024 = CI(base, 101024);

    /* THE FX STATES. The port's FX lines are ZERO at power-on and the
     * standalone engine seeds ONCE at context start, so a memset is the
     * faithful seed for the delay; the reverb and chorus have their own
     * proven seeders and are used rather than second-guessed. */
    for (i = 0; i < EB_REV_NTAP; ++i)
        s->rev_pending[i] = CI(base, 11022208 + 4*i);
    s->rev_wipe = CI(base, 10759872);
    /* The mute seed is cell 11022032 -- the reverb shim's own argument.
     * An earlier revision passed 10759456, a cell invented by pattern
     * rather than read off the shim, and the result was subtle enough to
     * be instructive: v36, v38, v176, v177 and v529 all stayed EXACT and
     * only v530 -- the reverb's B output -- drifted in the last bits.
     * Finding it needed the port's own intermediates exported and
     * compared stage by stage; no amount of staring at the chain would
     * have said which of five stages was first. */
    eb_reverb_seed(&s->rev, (const int32_t *)(base + 11022064),
                   CF(base, 11022032), s->rev_wipe);
    ebsh_snapshot(&s->cho, base);

    /* THE DELAY CORE NEEDS A REAL SEED, not a memset. The delay shim
     * seeds eb_delay_state from these prepared port cells at first use,
     * and juno_engine_prepare leaves most of them NON-ZERO. Seeding the
     * core to zero made every DELAY-TYPE-0 patch fail at about 0 dB in the
     * first standalone run -- the whole output uncorrelated -- while the
     * type-5 patches, which do not use the core, drifted only in the last
     * bits. Two failure magnitudes in one gate meant two distinct causes,
     * and that split is what located this one. */
    s->dcore.s1[0] = CF(base, 101792);
    s->dcore.s2[0] = CF(base, 101808);
    s->dcore.s1[1] = CF(base, 101920);
    s->dcore.s2[1] = CF(base, 101936);
    s->dcore.lp[0] = CF(base, 101840);
    s->dcore.hp[0] = CF(base, 101856);
    s->dcore.dc[0] = CF(base, 101888);
    s->dcore.fbtap[0] = CF(base, 101872);
    s->dcore.lp[1] = CF(base, 101968);
    s->dcore.hp[1] = CF(base, 101984);
    s->dcore.dc[1] = CF(base, 102016);
    s->dcore.fbtap[1] = CF(base, 102000);
    s->dcore.bx1[0] = CF(base, 102048);
    s->dcore.bx2[0] = CF(base, 102064);
    s->dcore.by1[0] = CF(base, 102080);
    s->dcore.by2[0] = CF(base, 102096);
    s->dcore.bx1[1] = CF(base, 102128);
    s->dcore.bx2[1] = CF(base, 102144);
    s->dcore.by1[1] = CF(base, 102160);
    s->dcore.by2[1] = CF(base, 102176);
    s->dcore.t_last = CF(base, 102208);
    s->dcore.t_step = CF(base, 102224);
    s->dcore.t_smooth = CF(base, 102240);
    s->dcore.fade = CF(base, 102288);
    s->dcore.fadesum = CF(base, 102272);
    /* THE RING WRITE INDICES. Missed on the first pass because the
     * extraction regex only recognised bare cell loads and these are
     * MASKED loads. MEASURED consequence: the LEFT channel stayed exact
     * and the RIGHT drifted in the last bits, starting at sample ~7,430 --
     * which is the delay tap depth, i.e. the first sample that reads back
     * far enough for a wrong write index to matter. A seed defect can wait
     * a sixth of a second before it shows. */
    s->dcore.w[0] = CI(base, 2199952) & (EB_DELAY_LEN - 1);
    s->dcore.w[1] = CI(base, 4297120) & (EB_DELAY_LEN - 1);
    s->dcore.overrun = 0;
}

