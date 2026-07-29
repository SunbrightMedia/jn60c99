/* juno60_teensy.cpp — first-hardware bring-up for the JUNO-60 C99 port on a
 * Teensy 4.1 (i.MX RT1062, Cortex-M7).
 *
 * WHAT THIS IS FOR. It answers the two questions that cannot be answered off the
 * device, and nothing else:
 *
 *   1. Is the engine bit-exact on real Cortex-M7 hardware?
 *      -> replays tests/teensy_golden.h and prints the 8 FNV-1a-64 hashes.
 *   2. What does a sample actually cost?
 *      -> DWT cycle counter around juno_gui_render, reported as cycles/sample
 *         against the budget for the configured clock.
 *
 * NO AUDIO HARDWARE IS REQUIRED. No codec, no DAC, no shield, no audio library.
 * A bare Teensy 4.1 and a USB cable are enough, because both answers come out
 * over Serial. Sound comes later; correctness and cost come first.
 *
 * HARD REQUIREMENT: the engine's state is a single ~10.5 MB span, so BOTH PSRAM
 * pads on the underside of the Teensy 4.1 must be populated (2 x 8 MB = 16 MB).
 * One chip is 8 MB and is NOT enough. Measured, not assumed: see
 * docs/ARM_MEASURED.md §2 (highest touched offset 11,026,432).
 *
 * BUILD: see teensy/README.md. The one non-obvious flag is
 * -Wl,--wrap=calloc, which routes the engine's single big allocation into PSRAM
 * without changing a line of engine source.
 */

#include <Arduino.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern "C" {

/* ---------------------------------------------------------------- allocation
 * gui/juno_bridge.c does exactly one large calloc (12 MB) plus a few small
 * ones. Route only the large one to PSRAM; everything else goes to the normal
 * heap. --wrap gives us this without touching the engine. */
void *__real_calloc(size_t n, size_t sz);
void  __real_free(void *p);

static void *g_psram_block;

void *__wrap_calloc(size_t n, size_t sz)
{
    size_t bytes = n * sz;
    if (bytes < 4u * 1024u * 1024u) return __real_calloc(n, sz);

    /* extmem_malloc is Teensyduino's PSRAM allocator. It does not zero. */
    void *p = extmem_malloc(bytes);
    if (!p) return nullptr;
    memset(p, 0, bytes);              /* calloc contract; also faults in PSRAM */
    g_psram_block = p;
    return p;
}

void __wrap_free(void *p)
{
    if (p && p == g_psram_block) { extmem_free(p); g_psram_block = nullptr; return; }
    __real_free(p);
}

/* -------------------------------------------------------------- hardware FTZ
 * The engine's bit-exactness is defined against x86 SSE2 running with FTZ/DAZ
 * set (src/juno_ftz.c mirrors that in software). FPv5 has the same behaviour in
 * silicon via FPSCR.FZ, so setting the bit gives the plugin's own semantics for
 * free. This does NOT replace juno_flush_denormals yet -- that is a measured
 * optimisation for later (docs/ARM_MEASURED.md §5). Setting FZ here only makes
 * the hardware agree with the software scan.
 *
 * Bit 24 = FZ (flush-to-zero). Bits 23:22 = RMode, left at 00 = round-to-
 * nearest-even, which is what the reference uses. */
static void enable_hw_ftz(void)
{
    uint32_t fpscr;
    __asm__ volatile("vmrs %0, fpscr" : "=r"(fpscr));
    fpscr |= (1u << 24);
    __asm__ volatile("vmsr fpscr, %0" : : "r"(fpscr));
}

/* ------------------------------------------------------------- DWT profiling */
static inline void dwt_start(void)
{
    ARM_DEMCR      |= ARM_DEMCR_TRCENA;
    ARM_DWT_CTRL   |= ARM_DWT_CTRL_CYCCNTENA;
    ARM_DWT_CYCCNT  = 0;
}
static inline uint32_t dwt_now(void) { return ARM_DWT_CYCCNT; }

/* The golden-corpus driver, compiled from tests/test_teensy_golden.c with
 * -Dmain=juno_golden_main so the device runs the SAME code as the host gate --
 * no reimplementation to drift out of sync. */
int juno_golden_main(void);

/* Engine API (gui/juno_bridge.c). */
typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float sample_rate, int chorus_mode);
int  juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx);
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity);
void juno_gui_note_off(juno_ctx *c, int midi_note);
void juno_gui_warmup(juno_ctx *c, int n);
int  juno_gui_render(juno_ctx *c, float *out, int nframes);

} /* extern "C" */

#include "teensy_golden.h"        /* for the embedded patch blob used by §2 */

/* ------------------------------------------------------------------ config */
static const float  SR    = 44100.0f;   /* inside the port's proven rate contract */
static const int    BLOCK = 128;        /* typical Teensy audio block            */

static float g_buf[2 * BLOCK];

/* Reconstruct the 1-patch bank the corpus driver uses, so §2 profiles a real
 * patch rather than power-on defaults. Layout from tools/verify/e2e_emu.py. */
#define BK_HEADER 23
#define BK_STRIDE 20223
#define BK_BLOB   16

static unsigned char *build_bank(const tg_scenario *s)
{
    unsigned char *bank = (unsigned char *)extmem_malloc(BK_HEADER + BK_STRIDE);
    if (!bank) return nullptr;
    memset(bank, 0, BK_HEADER + BK_STRIDE);
    memcpy(bank + BK_HEADER + BK_BLOB, s->blob, s->blob_len);
    return bank;
}

static void report_cost(const char *tag, uint32_t cyc, uint32_t samples)
{
    float per = (float)cyc / (float)samples;
    float budget = (float)F_CPU_ACTUAL / SR;
    Serial.printf("  %-22s %8.0f cycles/sample   budget %7.0f   %s%.2fx\n",
                  tag, per, budget,
                  per <= budget ? "OK  " : "OVER ", per / budget);
}

void setup(void)
{
    Serial.begin(115200);
    while (!Serial && millis() < 4000) { /* wait briefly for the host */ }

    enable_hw_ftz();
    dwt_start();

    Serial.println("=== JUNO-60 C99 port : Teensy 4.1 bring-up ===");
    Serial.printf("F_CPU_ACTUAL %lu Hz   sample rate %.0f Hz   budget %.0f cycles/sample\n",
                  (unsigned long)F_CPU_ACTUAL, SR, (float)F_CPU_ACTUAL / SR);
    Serial.printf("external PSRAM: %u bytes\n", (unsigned)(external_psram_size * 1048576u));
    if (external_psram_size < 16) {
        Serial.println("!! FATAL: need 16 MB PSRAM (BOTH pads populated).");
        Serial.println("!! The engine state spans 10.5 MB; one 8 MB chip cannot hold it.");
        return;
    }

    /* ---- 1. bit-exactness: the whole point of this firmware --------------- */
    Serial.println("\n--- 1. golden corpus (bit-exactness on real M7) ---");
    uint32_t t0 = dwt_now();
    int rc = juno_golden_main();
    uint32_t t1 = dwt_now();
    Serial.printf("corpus verdict: %s   (%lu cycles total)\n",
                  rc == 0 ? "ALL 8/8 BIT-EXACT" : "MISMATCH -- see above",
                  (unsigned long)(t1 - t0));
    if (rc != 0) {
        Serial.println("Do not tune anything. Root-cause in this order:");
        Serial.println("  a) -ffp-contract=off actually applied? (check the FMA canary)");
        Serial.println("  b) FPSCR.FZ set before the first render?");
        Serial.println("  c) libm: expf/fmodf. Both were proven bit-identical");
        Serial.println("     glibc-vs-newlib off-device (tools/embed/libm_expf_ab.sh),");
        Serial.println("     so this is unlikely -- but confirm the multilib.");
    }

    /* ---- 2. real cycles/sample: replaces every off-device ESTIMATE -------- */
    Serial.println("\n--- 2. cost (DWT cycle counter) ---");
    const tg_scenario *s = &tg_scenarios[0];
    unsigned char *bank = build_bank(s);
    juno_ctx *c = juno_gui_create(SR, 0);
    if (!c || !bank) { Serial.println("allocation failed"); return; }
    juno_gui_apply_bank(c, bank, BK_HEADER + BK_STRIDE, 0);
    juno_gui_warmup(c, (int)SR);      /* past the cold-start transient */

    /* Idle: all 8 voices free-run even with nothing held -- this is the fixed
     * floor that dominates the budget (docs/ARM_MEASURED.md §5). */
    uint32_t a = dwt_now();
    for (int i = 0; i < (int)SR; i += BLOCK) juno_gui_render(c, g_buf, BLOCK);
    uint32_t b = dwt_now();
    report_cost("0 voices (idle)", b - a, (uint32_t)SR);

    for (int nv = 1; nv <= 8; nv <<= 1) {
        for (int v = 0; v < nv; ++v) juno_gui_note_on(c, 36 + v * 5, 100);
        a = dwt_now();
        for (int i = 0; i < (int)SR; i += BLOCK) juno_gui_render(c, g_buf, BLOCK);
        b = dwt_now();
        char tag[32]; snprintf(tag, sizeof tag, "%d voice%s sounding", nv, nv > 1 ? "s" : "");
        report_cost(tag, b - a, (uint32_t)SR);
        for (int v = 0; v < nv; ++v) juno_gui_note_off(c, 36 + v * 5);
        for (int i = 0; i < (int)SR; i += BLOCK) juno_gui_render(c, g_buf, BLOCK);
    }

    Serial.println("\nExpect the cost to be nearly FLAT in polyphony: the plugin");
    Serial.println("renders all 8 voices every sample by design. That is the");
    Serial.println("finding the optimisation work has to attack, and these are");
    Serial.println("the numbers that replace the off-device estimates.");
    Serial.println("\n=== done ===");
}

void loop(void) { }
