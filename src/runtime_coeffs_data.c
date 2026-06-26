/* runtime_coeffs_data.c — parameter-applied coefficients the DSP reads but no
 * static init writes. ORIGIN: memory-captured from the live plugin for preset
 * "PD The Juno Pad", chorus mode II, 96 kHz. This is a CAPTURE and is being
 * eliminated coefficient-by-coefficient (docs/PROVENANCE_CORRECTION.md):
 *   - 98 shared FX filter templates: now applied capture-free from .rdata via
 *     juno_fx_filter_coeffs_apply() (src/juno_fx_filter_coeffs.c). REMOVED here.
 *   - remaining 181 offsets: still capture-sourced (voice LUT params + reverb
 *     tank + switches) pending decompile transcription.
 *
 * Derived rigorously from the full state dump: every offset voice_render/master
 * READS where the live plugin differs from our (chorus_init+engine_init) state AND
 * is stable across the t0/t1 snapshots (so per-sample STATE is excluded -- 160
 * such offsets were dropped). 279 coefficients, all nonzero. With these applied,
 * our initialised state matches the plugin's at ~100% over the DSP read set
 * (see docs/VALIDATION.md). NOTE: 96 kHz -- run the engine at 96000.
 */
#include "juno_engine.h"
#include <string.h>
#include <stddef.h>

typedef struct { int off; uint32_t bits; } juno_coeff;

static const juno_coeff k[] = {
  {4,0x00007ff9u}, {136,0x2832dd50u}, {304,0x40d56419u}, {336,0x40d56419u}, /* ~6.66847 */
  {464,0x40d56419u}, {496,0xbf800000u}, {512,0xbf800000u}, {624,0x3d01499du}, /* ~0.0315643 */
  {704,0x40d56419u}, {720,0x40d56419u}, {752,0x40d56419u}, {1072,0x402eb51bu}, /* ~2.7298 */
  {1088,0x3ebabac0u}, {1136,0x40327be4u}, {1472,0x3f7ec4b7u}, {1504,0x3f7f8c0bu}, /* ~0.998231 */
  {1520,0x3f7f8c0bu}, {1664,0x38327be4u}, {1776,0x3f7ec4b7u}, {1872,0x3f800000u}, /* ~1 */
  {1888,0x3f800000u}, {1920,0x378d4b0du}, {1936,0x3f800000u}, {1952,0x3f800000u}, /* ~1 */
  {2064,0x3ebabac0u}, {2080,0x3f800000u}, {2592,0x0895cffcu}, {2608,0x0895cffcu}, /* ~9.01651e-34 */
  {2672,0x41026666u}, {2688,0x41026666u}, {2704,0x393d0000u}, {2720,0x01e1847eu}, /* ~8.28421e-38 */
  {2736,0x01e1847eu}, {2752,0x0708f8acu}, {2768,0x0708f8acu}, {2784,0x3b42b82au}, /* ~0.00297118 */
  {2800,0x3f31d33cu}, {2816,0x3b9ab62eu}, {2832,0x3b5ab9cau}, {2848,0x3f800000u}, /* ~1 */
  {3072,0x088d10c5u}, {3088,0x088d10c5u}, {3152,0x41026666u}, {3168,0x41026666u}, /* ~8.15 */
  {3184,0x393d0000u}, {3200,0x01d4c794u}, {3216,0x01d4c794u}, {3232,0x0700f964u}, /* ~9.70294e-35 */
  {3248,0x0700f964u}, {3264,0x3a9e72dfu}, {3280,0x3f800000u}, {3296,0x40aaac0bu}, /* ~5.3335 */
  {3312,0x3b684959u}, {3328,0x3f800000u}, {3616,0x40d56419u}, {3632,0x40d56419u}, /* ~6.66847 */
  {3648,0x0708f8acu}, {3664,0x0700f964u}, {3696,0x40d56419u}, {3792,0x3f800000u}, /* ~1 */
  {3824,0x40d56419u}, {3840,0x3f800000u}, {3872,0x3f800000u}, {3888,0x3f800000u}, /* ~1 */
  {4016,0x3f800000u}, {4032,0xbad2f2e5u}, {4048,0x3f800000u}, {4128,0x3e0c8c8du}, /* ~0.137255 */
  {4144,0x3f0a8c22u}, {4192,0x3f5c1a60u}, {4224,0x3ea20000u}, {4240,0x3f5c1a60u}, /* ~0.859777 */
  {4272,0x3ea20000u}, {4736,0x3f5c1a60u}, {4768,0x3ea20000u}, {5456,0x3f800000u}, /* ~1 */
  {5520,0x3ca3d70au}, {6432,0x3f800000u}, {6448,0x3f800000u}, {6464,0x3f800000u}, /* ~1 */
  {6512,0x3f80f154u}, {6528,0x3e340000u}, {6704,0x3ed4158bu}, {6736,0x3ed4d4c0u}, /* ~0.415686 */
  {6864,0x3f57af5fu}, {6880,0x3f57af5fu}, {6896,0x3f57af5fu}, {6912,0x3f57af5fu}, /* ~0.84252 */
  {6976,0x40d56419u}, {6992,0x40d56419u}, {7072,0x0708f8acu}, {7248,0x3f57af5fu}, /* ~0.84252 */
  {7296,0x3f800000u}, {7344,0x3c105872u}, {7392,0x404a2317u}, {7408,0x3f800000u}, /* ~1 */
  {7440,0xbf010204u}, {7472,0x3e48c8c9u}, {7632,0x3f800000u}, {9024,0x3f800000u}, /* ~1 */
  {9056,0x3f800000u}, {9104,0x3f800000u}, {9584,0x3e3162c6u}, {9616,0x3f6e147au}, /* ~0.93 */
  {9632,0x3e3162c6u}, {9664,0x3f6e147au}, {9680,0x3f93c210u}, {9696,0x3f93c210u}, /* ~1.15436 */
  {9712,0x3f93c210u}, {9728,0x3f93c210u}, {9760,0x3f6e147au}, {9776,0x3f6e13eau}, /* ~0.929991 */
  {9792,0x3f6e13eau}, {9824,0x3f800000u}, {9840,0x3f800000u}, {9856,0x3f7fff70u}, /* ~0.999991 */
  {9872,0x3f7fff70u}, {9904,0x039da956u}, {9920,0x039da956u}, {9936,0x039da956u}, /* ~9.26651e-37 */
  {10048,0x0700f964u}, {10080,0x80000000u}, {10208,0x3f800000u}, {10240,0x3b0d8c2eu}, /* ~0.00215984 */
  {10288,0x3f800000u}, {10304,0x3f800000u}, {10320,0x3f800000u}, {10432,0x02800b23u}, /* ~1.88143e-37 */
  {10448,0x02800b23u}, /* ~1 */
  {101072,0x3e863babu}, /* ~0.241843 */
  {4297584,0x3ee0f001u}, /* ~0.439331 */
  {4297760,0x3f800000u}, /* ~1 */
  {6395312,0xc0aa6a6au}, /* ~-5.32549 */
  };

void juno_runtime_coeffs_apply(unsigned char *st)
{
    size_t i, n = sizeof(k) / sizeof(k[0]);
    for (i = 0; i < n; ++i) {
        float f; memcpy(&f, &k[i].bits, sizeof f);
        JF(st, k[i].off) = f;
        /* These coefficients were captured from voice 0's region. The plugin's
         * parameter system broadcasts each per-voice patch value to ALL 8 voices,
         * so replicate the per-voice main-block fields (verified range [176,10672])
         * into voices 1..7 at +10512*v. Global/master/chorus coeffs (outside that
         * range) are written once. Without this, only voice 0 sounds. */
        if (k[i].off >= 176 && k[i].off <= 10672) {
            int v;
            for (v = 1; v < JUNO_NUM_VOICES; ++v)
                JF(st, k[i].off + v * JUNO_VOICE_MAIN_STRIDE) = f;
        }
    }
    /* The 98 shared FX filter-coefficient templates (chorus/delay/FX-A/effect)
     * and the 48 HALL2 reverb coefficients are no longer in k[] — they are now
     * applied capture-free from the binary's .rdata via these calls, preserving
     * identical engine state. */
    juno_fx_filter_coeffs_apply(st);
    juno_reverb_coeffs_apply(st);
}

int juno_runtime_coeffs_loaded(void)
{
    size_t i, n = sizeof(k) / sizeof(k[0]);
    for (i = 0; i < n; ++i) if (k[i].bits != 0u) return 1;
    return 0;
}
