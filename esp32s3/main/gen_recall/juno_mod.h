/* juno_mod.h -- the plugin's LIVE MODULATION layer (#112).
 *
 * The plugin's value tree carries six dispatch indices (312..317) that a patch
 * RECALL never applies (they are no-ops in the recall role) but that a real VST3
 * host's parameter changes DO drive. Each applies a signed percentage offset on
 * top of a front-panel parameter's recalled base byte, then re-drives that
 * parameter's own setter with the offset byte.
 *
 * Law -- PROVEN by executing the plugin's own setters under Unicorn
 * (tools/verify/hostmod_gate.py; derived from sub_7FF91E010600 and siblings):
 *
 *     out = base + (off * (off > 0 ? 255 - base : base)) / 100
 *
 * with C integer division (truncating toward zero, matching the plugin's idiv),
 * base in [0,255] and off in [-100,100] (the plugin's own paramDB range for
 * indices 312..317, read from the descriptor table at rva 0x98c040 + 16*idx).
 * At off == 0 the law is the identity, which is why no recall/render gate ever
 * saw these: no factory patch and no default host state drives them.
 *
 * See docs/P112_FINDINGS.md sections 3 and 4.
 */
#ifndef JUNO_MOD_H
#define JUNO_MOD_H

#define JUNO_MOD_COUNT 6

/* Modulation slots, in the plugin's dispatch-index order 312..317. */
enum {
    JUNO_MOD_VCF_CUTOFF = 0,   /* idx 312 -> VCF CUTOFF FREQ (779) */
    JUNO_MOD_HPF_CUTOFF = 1,   /* idx 313 -> HPF CUTOFF FREQ (782) */
    JUNO_MOD_VCF_RESONANCE = 2,/* idx 314 -> VCF RESONANCE   (781) */
    JUNO_MOD_PWM_DEPTH = 3,    /* idx 315 -> DCO PWM DEPTH   (758) */
    JUNO_MOD_PORTAMENTO = 4,   /* idx 316 -> PORTAMENTO      (798) */
    JUNO_MOD_EFFECT_DEPTH = 5  /* idx 317 -> EFFECT DEPTH    (794) */
};

/* The proven law. base is clamped to 0..255, off to -100..100. */
int juno_mod_byte(int base, int off);

/* Slot metadata. juno_mod_base_name(slot) is the exact juno_apply.c BINDINGS name
 * of the front-panel parameter the slot modulates ("" if slot is out of range);
 * juno_mod_dispatch_index(slot) is the plugin's own dispatch index (312..317, or
 * -1); juno_mod_base_dispatch_index(slot) is the base parameter's (779/782/781/
 * 758/798/794, or -1). */
const char *juno_mod_base_name(int slot);
int         juno_mod_dispatch_index(int slot);
int         juno_mod_base_dispatch_index(int slot);

#endif /* JUNO_MOD_H */
