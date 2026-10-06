/* host_edit.h -- the plugin's HOST-ROLE parameter edits (CLAIMS B7).
 *
 * A DAW that automates a panel parameter calls the plugin's host parameter
 * entry (rva 0x3C7AE0): the setter runs with flag 0, and in that role it RAMPS
 * most cells (ramped set rva 0x3C10D0 -> 0x3C2920 -> ramp start 0x3C2E80,
 * 4..96 ms) instead of writing them, and writes the rest immediately or
 * directly. Which sets it makes, in which order, with which time and where
 * each value comes from, is the plugin's executed census (src/
 * host_ramp_table.h, tools/verify/gen_host_ramps.py); the VALUES are the
 * port's settled recall of the edited record (computed on a scratch copy of
 * the state) except where the census shows a constant or a kept value.
 *
 * juno_host_edit() applies one edit's set list to the live state: ramped sets
 * through the ramp records (src/recall_ramp.c, whose stored targets decide
 * whether a ramp starts at all), immediate sets and direct writes in place.
 * Compiled out under EB_DEVCELLS (the device edits through a settled recall).
 */
#ifndef JUNO_HOST_EDIT_H
#define JUNO_HOST_EDIT_H

#ifdef __cplusplus
extern "C" {
#endif

/* What a set list depends on (the key features of src/host_ramp_table.h). */
typedef struct {
    int et, dt;      /* EFFECT TYPE / DELAY TYPE in force before the edit       */
    int from, to;    /* the parameter's value before / after (its host range)  */
    int don1;        /* DELAY LEVEL on-flag after the edit (hysteresis)         */
    int ron0, ron1;  /* REVERB LEVEL on before / after (level >= 3)             */
    int pl;          /* ASSIGN MODE 0 with LEGATO 1 (processor +0x548 / +0x544) */
    int arpon;       /* the processor's arp on (juno_rr_arp_on), before the edit */
    int cutbyte;     /* the stored VCF CUTOFF FREQ (the arp refresh re-sends it)  */
} juno_host_feat;

/* 1 when host parameter hp (src/juno_hostparams.c index) has a set list */
int juno_host_edit_known(int hp);
/* 1 when the features land on a key the census covered */
int juno_host_edit_covered(int hp, const juno_host_feat *f);
/* Apply host parameter hp's set list to `st`, values from `settled` (the
 * settled recall of the edited record on a copy of st). Returns the number of
 * sets made, -1 when the key is not covered (nothing applied). */
int juno_host_edit(unsigned char *st, const unsigned char *settled, int hp, const juno_host_feat *f);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_HOST_EDIT_H */
