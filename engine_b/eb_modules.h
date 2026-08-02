/* eb_modules.h — the module table, and the invariant that keeps the skeleton
 * honest.
 *
 * Engine B is built module by module. Until EVERY module is written, engine B
 * cannot produce the output: a partial engine is not a quiet approximation, it
 * is silence with a plausible shape. So this file declares one flag per module,
 * all zero at the skeleton commit, and eb_engine_process() REFUSES to claim the
 * output while any of them is zero. The refusal is structural — a module cannot
 * be forgotten, and no run of tools/engineb/null_b.py can accidentally score a
 * green on an engine that is not finished.
 *
 * A module is promoted by
 *   1. writing engine_b/eb_<mod>.c,
 *   2. defining EB_HAVE_<MOD> to 1 here,
 *   3. and adding engine_b/shim/<mod>/ so the null harness can put THAT MODULE
 *      ONLY into the port and null it against the oracle
 *      (engine_b/shim/README.md).
 * Step 3 is not optional: docs/engineb/SCOPE.md, "no module gets written before
 * its gate can see it".
 */
#ifndef ENGINEB_EB_MODULES_H
#define ENGINEB_EB_MODULES_H

/* order = the order the signal takes, not the order of the work */
#define EB_HAVE_PARAM   0   /* patch bytes -> coefficients (laws per module)  */
#define EB_HAVE_ALLOC   0   /* voice allocator: POLY / MONO / UNISON, LEGATO  */
#define EB_HAVE_LFO     0   /* global LFO + delay envelope                    */
#define EB_HAVE_NOISE   1   /* shared LFSR: PROVEN bit-identical, 200k samples */
#define EB_HAVE_DCO     0   /* saw + pulse + sub + noise mix, PWM             */
#define EB_HAVE_VCF     0   /* 4-pole low pass, resonance, key follow         */
#define EB_HAVE_HPF     0   /* the JUNO's high pass, 4 TYPEs                  */
#define EB_HAVE_ENV     0   /* ENV1 (filter) + ENV2 (amp)                     */
#define EB_HAVE_VCA     0   /* amp, incl. the GATE / ENV1 / ENV2 mode switch  */
#define EB_HAVE_CHORUS  0   /* the signature BBD chorus                       */
#define EB_HAVE_DELAY   0
#define EB_HAVE_REVERB  0

#define EB_MODULES_COMPLETE                                                   \
    (EB_HAVE_PARAM && EB_HAVE_ALLOC && EB_HAVE_LFO && EB_HAVE_NOISE &&        \
     EB_HAVE_DCO && EB_HAVE_VCF && EB_HAVE_HPF && EB_HAVE_ENV &&              \
     EB_HAVE_VCA && EB_HAVE_CHORUS && EB_HAVE_DELAY && EB_HAVE_REVERB)

#endif /* ENGINEB_EB_MODULES_H */
