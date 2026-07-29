/* juno60_daisy.cpp — EXPERIMENTAL bring-up + instrumentation for the JUNO-60
 * C99 port on an Electrosmith Daisy Seed (STM32H750IBK6, Cortex-M7 @ 480 MHz).
 *
 * PURPOSE: find out whether the Daisy can run 8 voices bit-exact in real time,
 * and if not, WHY not and by how much. Every number this prints replaces an
 * ESTIMATE in docs/ARM_MEASURED.md §4. No audio hardware is used or needed --
 * results come out over USB serial.
 *
 * Five experiments, in dependency order:
 *   E1  golden corpus         is the engine bit-exact on real M7 silicon?
 *   E2  cycles/sample         the headline cost, at 0/1/2/4/8 voices
 *   E3  D-cache on vs off     how much of the cost is SDRAM latency?
 *   E4  SDRAM vs AXI-SRAM     what would relocating hot state buy?
 *   E5  verdict               voices that fit the 48 kHz real-time budget
 *
 * WHY E3 AND E4 EXIST. docs/ARM_MEASURED.md §4 estimates cost from instruction
 * counts and assumes memory is free. It is not: the engine's state is a single
 * ~10.5 MB span that must live in SDRAM, its per-sample working set is ~416 KB
 * of random access (docs/ARM_MEASURED.md §2), and the Cortex-M7 L1 D-cache is
 * only 16 KB. That is a >25x oversubscription, so SDRAM latency could plausibly
 * dominate everything the instruction count predicts. E3 and E4 measure it
 * instead of arguing about it.
 *
 * HONEST STATUS: written from the real libDaisy headers (SampleRate enum,
 * AudioHandle typedefs, DSY_SDRAM_BSS, the H750 linker scripts) but NEVER RUN
 * ON HARDWARE. Expect to fix integration details on first flash.
 */

/* The corpus driver's main/printf renames live in daisy/golden_shim.c and are
 * deliberately NOT global -D defines. libDaisy compiles its own
 * startup_stm32h750xx.c with the project's flags, so a global -Dmain= rewrites
 * the startup's own call to main(): Reset_Handler branches into the corpus
 * driver, --gc-sections then deletes this file's main() and everything it
 * references, and the link still reports success. The board would boot with no
 * hw.Init() and die silently. `make verify-entry` asserts against it. */

#include "daisy_seed.h"

#include <cstdint>
#include <cstdarg>
#include <cstdio>
#include <cstring>

using namespace daisy;

static DaisySeed hw;

/* The corpus is 44.1 kHz. That is fine and is NOT a conflict with the Daisy's
 * 48 kHz codec: E1 never touches the audio peripheral, it renders into RAM and
 * hashes. libDaisy's SaiHandle::Config::SampleRate offers 8/16/32/48/96 kHz
 * only -- no 44.1 -- so LIVE audio would run at 48000, which is inside the
 * port's proven rate contract (44100/48000/88200/96000/192000). */
#define E2_RATE       44100.0f    /* match the corpus, so E1 and E2 agree */
#define LIVE_RATE     48000.0f    /* what a real Daisy audio callback would use */
#define BLOCK         48          /* libDaisy's default audio block size */

/* ------------------------------------------------------------------ printf
 * The corpus driver (tests/test_teensy_golden.c) is compiled verbatim with
 * -Dmain=juno_golden_main so the device runs THE SAME code as the host gate.
 * It uses printf. Under --specs=nosys.specs printf goes nowhere, so route it
 * through newlib's vsnprintf (pure formatting, no syscalls) into libDaisy's
 * logger. LOGGER_BUFFER is 128 bytes (src/hid/logger.h), so emit in chunks. */
extern "C" int jd_printf(const char *fmt, ...)
{
    char buf[512];
    va_list ap;
    int n;
    va_start(ap, fmt);
    n = vsnprintf(buf, sizeof buf, fmt, ap);
    va_end(ap);
    if (n < 0) return n;

    /* strip a single trailing newline; PrintLine adds its own */
    size_t len = strlen(buf);
    if (len && buf[len - 1] == '\n') buf[--len] = '\0';

    for (size_t off = 0; off <= len; off += 100) {
        char chunk[104];
        size_t k = len - off; if (k > 100) k = 100;
        memcpy(chunk, buf + off, k);
        chunk[k] = '\0';
        hw.PrintLine("%s", chunk);
        if (k < 100) break;
    }
    return n;
}
#define LOG(...)  jd_printf(__VA_ARGS__)

/* ------------------------------------------------------------------- memory
 * The engine does exactly one large calloc (gui/juno_bridge.c:147, 12 MB) plus
 * a handful of small ones. --wrap lets us serve the large ones from SDRAM
 * without touching a line of engine source.
 *
 * .sdram_bss is declared NOLOAD in the linker script, so it is NOT zeroed by
 * startup -- the explicit memset below is load-bearing, not defensive.
 * A bump allocator is correct here: this firmware allocates during setup and
 * never frees, so reclaiming would be dead code. */
static uint8_t DSY_SDRAM_BSS g_sdram_pool[13u * 1024u * 1024u];
static size_t  g_sdram_used;

/* 8 KB threshold: the 12 MB state and the corpus driver's render buffers go to
 * SDRAM; juno_ctx and libDaisy's own small allocations stay on the AXI-SRAM
 * heap, which is where the linker script puts .heap. */
#define SDRAM_MIN 8192u

static void *sdram_alloc(size_t n)
{
    n = (n + 31u) & ~(size_t)31u;                 /* 32-byte: cache-line safe */
    if (g_sdram_used + n > sizeof g_sdram_pool) return nullptr;
    void *p = &g_sdram_pool[g_sdram_used];
    g_sdram_used += n;
    return p;
}

extern "C" {
void *__real_malloc(size_t);
void *__real_calloc(size_t, size_t);
void  __real_free(void *);

void *__wrap_malloc(size_t n)
{
    if (n < SDRAM_MIN) return __real_malloc(n);
    void *p = sdram_alloc(n);
    return p ? p : __real_malloc(n);
}

void *__wrap_calloc(size_t n, size_t sz)
{
    size_t bytes = n * sz;
    if (bytes < SDRAM_MIN) return __real_calloc(n, sz);
    void *p = sdram_alloc(bytes);
    if (!p) return __real_calloc(n, sz);
    memset(p, 0, bytes);              /* .sdram_bss is NOLOAD -- must zero */
    return p;
}

/* Pool memory is never individually freed; anything outside it is real heap. */
void __wrap_free(void *p)
{
    uint8_t *b = (uint8_t *)p;
    if (b >= g_sdram_pool && b < g_sdram_pool + sizeof g_sdram_pool) return;
    __real_free(p);
}
} /* extern "C" */

/* ----------------------------------------------------------------- engine API */
extern "C" {
typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float sample_rate, int chorus_mode);
int  juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx);
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity);
void juno_gui_note_off(juno_ctx *c, int midi_note);
void juno_gui_warmup(juno_ctx *c, int n);
int  juno_gui_render(juno_ctx *c, float *out, int nframes);
int  juno_golden_main(void);           /* tests/test_teensy_golden.c, renamed  */
}

#include "teensy_golden.h"             /* tg_scenarios[], for E2's patch blob  */

/* ------------------------------------------------------- hardware FTZ (FPSCR)
 * The port's bit-exactness is defined against x86 SSE2 with FTZ/DAZ set;
 * src/juno_ftz.c mirrors that in software. FPv5 has the same behaviour in
 * silicon at FPSCR bit 24 (FZ). Setting it makes the hardware AGREE with the
 * software scan -- it does not replace it (that is a later, measured cut).
 * RMode (bits 23:22) is left 00 = round-to-nearest-even, matching the
 * reference. */
static void enable_hw_ftz(void)
{
    uint32_t fpscr;
    __asm__ volatile("vmrs %0, fpscr" : "=r"(fpscr));
    fpscr |= (1u << 24);
    __asm__ volatile("vmsr fpscr, %0" : : "r"(fpscr));
}

/* ------------------------------------------------------------ DWT cycle count */
static bool dwt_init(void)
{
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    /* DWT Lock Access Register at 0xE0001FB0. CMSIS's DWT_Type has no LAR
     * member, and the M7 does not normally require the unlock, but writing it
     * is harmless and saves a silent zero-counter on parts that do. */
    *(volatile uint32_t *)0xE0001FB0u = 0xC5ACCE55u;
    DWT->CYCCNT       = 0;
    DWT->CTRL        |= DWT_CTRL_CYCCNTENA_Msk;
    /* Verify it actually ticks rather than trusting the sequence. */
    uint32_t a = DWT->CYCCNT;
    for (volatile int i = 0; i < 100; ++i) { }
    return DWT->CYCCNT != a;
}
static inline uint32_t cyc(void) { return DWT->CYCCNT; }

/* ------------------------------------------------------------------ reporting */
static float g_budget_live;    /* cycles/sample available at LIVE_RATE */

static void report(const char *tag, uint32_t cycles, uint32_t samples)
{
    float per = (float)cycles / (float)samples;
    /* libDaisy's logger has limited float formatting; print scaled integers so
     * the numbers are always readable regardless of %f support. */
    LOG("  %-24s %6d cyc/sample   budget %5d   %d.%02dx %s",
        tag, (int)(per + 0.5f), (int)(g_budget_live + 0.5f),
        (int)(per / g_budget_live), (int)(per / g_budget_live * 100.0f) % 100,
        per <= g_budget_live ? "OK" : "OVER");
}

/* Rebuild the 1-patch bank the corpus embeds, so E2 profiles a real patch
 * rather than power-on defaults. Layout from tools/verify/e2e_emu.py. */
#define BK_HEADER 23
#define BK_STRIDE 20223
#define BK_BLOB   16

static unsigned char *build_bank(const tg_scenario *s)
{
    unsigned char *bank = (unsigned char *)sdram_alloc(BK_HEADER + BK_STRIDE);
    if (!bank) return nullptr;
    memset(bank, 0, BK_HEADER + BK_STRIDE);
    memcpy(bank + BK_HEADER + BK_BLOB, s->blob, TG_BLOB_LEN);
    return bank;
}

/* ============================ E2: cycles/sample ========================== */
static void measure_cost(void)
{
    static float buf[2 * BLOCK];
    const tg_scenario *s = &tg_scenarios[0];
    unsigned char *bank = build_bank(s);
    juno_ctx *c = juno_gui_create(E2_RATE, 0);
    if (!c || !bank) { LOG("  E2: allocation FAILED"); return; }

    juno_gui_apply_bank(c, bank, BK_HEADER + BK_STRIDE, 0);
    juno_gui_warmup(c, (int)E2_RATE);         /* past the cold-start transient */

    const int N = (int)E2_RATE / 2;           /* half a second per point      */

    /* Idle first. All 8 voices free-run even with nothing held -- this fixed
     * floor is ~84% of the cost on x86 and is the thing to attack. */
    uint32_t t0 = cyc();
    for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
    report("0 voices (idle)", cyc() - t0, (uint32_t)N);

    const int NV[] = {1, 2, 4, 8};
    for (int k = 0; k < 4; ++k) {
        for (int v = 0; v < NV[k]; ++v) juno_gui_note_on(c, 36 + v * 5, 100);
        t0 = cyc();
        for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
        uint32_t d = cyc() - t0;
        char tag[32]; snprintf(tag, sizeof tag, "%d voice%s sounding",
                               NV[k], NV[k] > 1 ? "s" : "");
        report(tag, d, (uint32_t)N);
        for (int v = 0; v < NV[k]; ++v) juno_gui_note_off(c, 36 + v * 5);
        for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
    }
}

/* ===================== E3: how much of it is SDRAM latency? ==============
 * Same workload, D-cache enabled then disabled. The ratio is a direct,
 * assumption-free measure of how much the 16 KB D-cache is saving us against
 * a ~416 KB working set -- and therefore an upper bound on what relocating
 * hot state into internal SRAM could recover. */
static void measure_dcache(void)
{
    static float buf[2 * BLOCK];
    const tg_scenario *s = &tg_scenarios[0];
    unsigned char *bank = build_bank(s);
    juno_ctx *c = juno_gui_create(E2_RATE, 0);
    if (!c || !bank) { LOG("  E3: allocation FAILED"); return; }
    juno_gui_apply_bank(c, bank, BK_HEADER + BK_STRIDE, 0);
    juno_gui_warmup(c, (int)E2_RATE / 4);
    for (int v = 0; v < 8; ++v) juno_gui_note_on(c, 36 + v * 5, 100);

    const int N = (int)E2_RATE / 4;

    SCB_EnableDCache();
    SCB_CleanInvalidateDCache();
    uint32_t t0 = cyc();
    for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
    uint32_t on = cyc() - t0;
    report("8 voices, D-cache ON", on, (uint32_t)N);

    SCB_CleanInvalidateDCache();
    SCB_DisableDCache();
    t0 = cyc();
    for (int i = 0; i < N; i += BLOCK) juno_gui_render(c, buf, BLOCK);
    uint32_t off = cyc() - t0;
    report("8 voices, D-cache OFF", off, (uint32_t)N);
    SCB_EnableDCache();

    if (on)
        LOG("  -> D-cache is worth %d.%02dx here. A large ratio means SDRAM",
            (int)((float)off / on), (int)((float)off / on * 100.0f) % 100);
    LOG("     latency dominates and moving hot state to internal RAM pays.");
}

/* ============ E4: SDRAM vs AXI-SRAM, sequential and random ==============
 * A cache-busting walk over 256 KB in each memory, so the SDRAM penalty is
 * quantified independently of the engine. Random order is the case that
 * matters: the engine's per-sample access pattern is scattered, not streamed.
 * (256 KB fits the 512 KB AXI SRAM alongside code+heap; the engine's real
 * random-access set is ~416 KB, so scale the result accordingly.) */
#define WALK_BYTES (256u * 1024u)
#define WALK_WORDS (WALK_BYTES / 4u)

/* volatile is load-bearing, not decoration. A first version of this test used a
 * plain array filled by memset(,1,): GCC then knew every word was 0x01010101,
 * constant-folded the entire accumulation, dropped the loads, and garbage-
 * collected g_axi_buf out of the binary -- the benchmark measured nothing while
 * still printing a plausible number. Caught by checking the symbol table for the
 * array's address, not by reading the build log. volatile forces a real load per
 * access (exactly what a memory-latency benchmark wants), the fill below is
 * runtime-derived so the contents are unknowable at compile time, and the result
 * is stored to a volatile sink so the whole chain is observably live. */
static volatile uint32_t g_axi_buf[WALK_WORDS];                 /* AXI SRAM */
static volatile uint32_t DSY_SDRAM_BSS g_sdr_buf[WALK_WORDS];   /* SDRAM    */
static volatile uint32_t g_sink;

__attribute__((noinline))
static uint32_t walk(volatile uint32_t *p, int stride_words, int iters)
{
    uint32_t acc = 0;
    uint32_t idx = 0;
    uint32_t t0 = cyc();
    for (int i = 0; i < iters; ++i) {
        acc += p[idx];
        idx = (idx + (uint32_t)stride_words) & (WALK_WORDS - 1u);
    }
    uint32_t d = cyc() - t0;
    g_sink = acc;                  /* observable: the loads cannot be dropped */
    return d;
}

static void measure_memory(void)
{
    const int ITERS = 200000;
    /* Runtime-derived fill: the compiler cannot know these values, so it cannot
     * fold the reads even if volatile were ever relaxed. */
    uint32_t seed = cyc() | 1u;
    for (uint32_t i = 0; i < WALK_WORDS; ++i) {
        seed = seed * 1664525u + 1013904223u;
        g_axi_buf[i] = seed;
        g_sdr_buf[i] = seed;
    }

    /* stride 1 word  = sequential (cache lines fully used)
     * stride 33 words = 132 B, coprime with the line size -> every access a
     *                   fresh line, i.e. worst-case scattered */
    struct { const char *name; int stride; } K[] = {
        {"sequential", 1}, {"scattered", 33},
    };
    for (int i = 0; i < 2; ++i) {
        uint32_t a = walk(g_axi_buf, K[i].stride, ITERS);
        uint32_t s = walk(g_sdr_buf, K[i].stride, ITERS);
        LOG("  %-11s  AXI-SRAM %d.%02d cyc/access   SDRAM %d.%02d cyc/access"
            "   penalty %d.%02dx",
            K[i].name,
            (int)(a / ITERS), (int)((float)a / ITERS * 100.0f) % 100,
            (int)(s / ITERS), (int)((float)s / ITERS * 100.0f) % 100,
            a ? (int)((float)s / a) : 0,
            a ? (int)((float)s / a * 100.0f) % 100 : 0);
    }
}

/* ================================= main ================================== */
int main(void)
{
    hw.Init();                       /* also brings up the 64 MB SDRAM        */
    hw.SetAudioSampleRate(SaiHandle::Config::SampleRate::SAI_48KHZ);
    hw.SetAudioBlockSize(BLOCK);
    hw.StartLog(true);               /* wait for a serial monitor             */

    enable_hw_ftz();
    bool dwt_ok = dwt_init();

    g_budget_live = (float)System::GetSysClkFreq() / LIVE_RATE;

    hw.PrintLine("=== JUNO-60 C99 port : Daisy Seed EXPERIMENT ===");
    hw.PrintLine("SysClk %d Hz   live rate %d Hz   budget %d cyc/sample",
                 (int)System::GetSysClkFreq(), (int)LIVE_RATE,
                 (int)(g_budget_live + 0.5f));
    hw.PrintLine("SDRAM pool %d KB   corpus rate %d Hz",
                 (int)(sizeof g_sdram_pool / 1024u), (int)E2_RATE);
    if (!dwt_ok) {
        hw.PrintLine("!! DWT cycle counter is NOT ticking. E2-E4 are invalid.");
        hw.PrintLine("!! Fix that before believing any timing below.");
    }

    /* --- E1 ------------------------------------------------------------- */
    hw.PrintLine("");
    hw.PrintLine("--- E1: golden corpus (bit-exactness on real M7) ---");
    int rc = juno_golden_main();
    hw.PrintLine("E1 verdict: %s", rc == 0 ? "ALL 8/8 BIT-EXACT"
                                           : "MISMATCH (see above)");
    if (rc != 0) {
        hw.PrintLine("Do NOT tune anything. Check in this order:");
        hw.PrintLine(" a) -ffp-contract=off actually reached the compiler.");
        hw.PrintLine("    libDaisy sets NO fp-contract flag, so GCC defaults to");
        hw.PrintLine("    'fast' and WILL emit FMA. This is the likeliest cause.");
        hw.PrintLine(" b) FPSCR.FZ set before the first render.");
        hw.PrintLine(" c) libm: expf/fmodf. Proven bit-identical glibc-vs-newlib");
        hw.PrintLine("    over 32,000,423 inputs, so unlikely -- but confirm.");
    }

    /* --- E2..E4 --------------------------------------------------------- */
    hw.PrintLine("");
    hw.PrintLine("--- E2: cost (DWT cycles/sample) ---");
    measure_cost();
    hw.PrintLine("  Expect near-FLAT scaling: the plugin renders all 8 voices");
    hw.PrintLine("  every sample by design. Flatness is the finding, not a bug.");

    hw.PrintLine("");
    hw.PrintLine("--- E3: is the cost CPU or SDRAM? ---");
    measure_dcache();

    hw.PrintLine("");
    hw.PrintLine("--- E4: SDRAM vs internal AXI-SRAM ---");
    measure_memory();

    hw.PrintLine("");
    hw.PrintLine("=== done. E2's 8-voice row against the budget IS the answer");
    hw.PrintLine("=== to 'can the Daisy do 8 voices bit-exact'. E3/E4 say");
    hw.PrintLine("=== whether memory placement can close any gap.");

    while (1) { System::Delay(1000); }
}
