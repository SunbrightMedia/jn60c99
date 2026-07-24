/* juno_mod.c -- the plugin's LIVE MODULATION layer (#112). See juno_mod.h.
 *
 * Transcribed from the plugin's own setters sub_7FF91E010600 (idx 313) and its
 * five siblings 0x3B9990 / 0x3B0650 / 0x3B06A0 / 0x3B06F0 / 0x3B0740, and PROVEN
 * against them by execution: tools/verify/hostmod_gate.py drives the plugin's own
 * modulation setter and the plugin's own base-parameter setter under Unicorn and
 * requires the two resulting engine states to be bit-identical.
 *
 * The plugin's code is:
 *     v5 = base;                                     // proc value cache
 *     if (off) { v6 = (off > 0) ? 255 - base : base;
 *                v5 = (int)(off * v6) / 100 + v5; }
 *     baseSetter(this, 0, v5);
 */
#include "juno_mod.h"

int juno_mod_byte(int base, int off)
{
    long span, prod;

    if (base < 0) base = 0;
    else if (base > 255) base = 255;
    /* the plugin's own paramDB range for indices 312..317 */
    if (off < -100) off = -100;
    else if (off > 100) off = 100;
    if (off == 0) return base;

    span = (off > 0) ? (255L - (long)base) : (long)base;
    prod = (long)off * span;
    /* C89/C99 integer division truncates toward zero -- the same rounding the
     * plugin's idiv performs for both signs. */
    return base + (int)(prod / 100L);
}

static const struct { const char *base_name; int mod_idx; int base_idx; }
MODS[JUNO_MOD_COUNT] = {
    { "VCF CUTOFF FREQ", 312, 779 },
    { "HPF CUTOFF FREQ", 313, 782 },
    { "VCF RESONANCE",   314, 781 },
    { "DCO PWM DEPTH",   315, 758 },
    { "PORTAMENTO",      316, 798 },
    { "EFFECT DEPTH",    317, 794 }
};

const char *juno_mod_base_name(int slot)
{
    return (slot >= 0 && slot < JUNO_MOD_COUNT) ? MODS[slot].base_name : "";
}

int juno_mod_dispatch_index(int slot)
{
    return (slot >= 0 && slot < JUNO_MOD_COUNT) ? MODS[slot].mod_idx : -1;
}

int juno_mod_base_dispatch_index(int slot)
{
    return (slot >= 0 && slot < JUNO_MOD_COUNT) ? MODS[slot].base_idx : -1;
}
