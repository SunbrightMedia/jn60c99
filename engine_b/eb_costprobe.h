/* eb_costprobe.h -- WRITE-ONLY branch-rate counters for the PATCH-DEPENDENCE
 * question, and nothing else.
 *
 * WHY. The board's 0xd0 verdict (5,395 against a 5,442 budget, a margin of
 * 47 cycles) was measured on ONE patch and ONE fixed chord. Two branches in
 * the voice path are PATCH- and PITCH-dependent and could move that margin:
 *   * eb_vcf_res's LUT can MISS and fall back to the exact tail;
 *   * eb_dco_wt schedules a 16-iteration residual per oscillator edge, so its
 *     cost rises with pitch.
 * A margin of 0.9 % measured on one patch is not a margin until the WORST
 * patch is known. These counters answer that over the whole gated battery.
 *
 * Off in every shipping build; nothing here is read by the DSP. */
#ifndef ENGINEB_EB_COSTPROBE_H
#define ENGINEB_EB_COSTPROBE_H
#ifndef EB_COSTPROBE
#define EB_COSTPROBE 0
#endif
#if EB_COSTPROBE
extern unsigned long ebcp_vsamp, ebcp_lut_hit, ebcp_lut_miss, ebcp_wtadd;
#define EBCP(x) (++ebcp_##x)
#else
#define EBCP(x) ((void)0)
#endif
#endif
