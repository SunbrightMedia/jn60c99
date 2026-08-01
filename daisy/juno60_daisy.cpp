/* juno60_daisy.cpp — EXPERIMENT PLATFORM for the JUNO-60 C99 port on an
 * Electrosmith Daisy Seed (STM32H750IBK6, Cortex-M7).
 *
 * THIS WAS AN EXPERIMENT AND IS NOW A PLATFORM. The difference matters, and it
 * is the user's own reason: flashing this board costs them real mental effort,
 * and they expect to do it for a long time. So ONE BOOT MUST RETURN A TABLE,
 * NOT A NUMBER. Every cheap orthogonal question is answered in a single run,
 * and anything that used to need a second image now lives in this one and is
 * selected at run time.
 *
 * What one boot now answers:
 *   PRE-FLIGHT  are the preconditions met? (printed FIRST, so a bad build is
 *               obvious before any table rather than after one)
 *   E0          the SDRAM pool allocator
 *   E1          golden corpus -- is the engine bit-exact on real M7 silicon?
 *   MATRIX      placement {QSPI, voice-ITCM, voice+master-ITCM}
 *               x I-cache {on,off} x D-cache {on,off} x voices {0,1,2,4,8}
 *   E4          SDRAM vs AXI-SRAM, generic walk
 *   E7          SDRAM vs AXI at the ENGINE'S OWN MEASURED access pattern,
 *               16-byte stride (today) vs 4-byte (compacted)
 *   E5          live self-playing audio, then park in DFU
 *
 * THE QUESTION THE MATRIX EXISTS TO SETTLE. The port measures 93,288
 * cyc/sample for 8 voices against an 8,333 budget (SILICON, 400 MHz). Two
 * analyses in docs/trackb/CONFLICT.md disagree about where ~50,742 of those
 * cycles go: scattered SDRAM DATA stalls, or INSTRUCTION FETCH, because
 * APP_TYPE=BOOT_QSPI means we execute XIP from external QSPI flash and the hot
 * .text is ~32.8 KB against a 16 KB L1 I-cache. The old E3 toggled the D-cache
 * only, so it was structurally blind to an I-side cost. The placement and
 * I-cache columns are the instruction side; the D-cache column and E7 are the
 * data side. Both sides now come out of the same run, off the same context,
 * with the same warmup -- which is what makes the rows comparable at all.
 *
 * PLACEMENT IS A RUN-TIME AXIS, NOT A BUILD. The image contains two
 * compilations of voice_render and of master_render: the originals in QSPI and
 * identical copies the linker put in ITCM (daisy/voice_render_itcm.c,
 * daisy/master_render_itcm.c, daisy/juno_itcm.lds). src/juno_driver.c calls
 * both through function pointers, so assigning a pointer switches placement
 * mid-run. That indirection changes NO arithmetic and the host golden corpus
 * stays 8/8; it is the only change src/ was allowed.
 *
 * STATUS: the previous revision RAN ON THIS BOARD. Everything here that is
 * labelled SILICON was measured on it.
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
 *
 * THIS WAS A BUMP ALLOCATOR AND THAT WAS WRONG. Its comment claimed "this
 * firmware allocates during setup and never frees, so reclaiming would be dead
 * code". The first run on silicon disproved it: E1 builds and drops a 12 MB
 * juno_ctx for EACH of its 8 scenarios, and E2/E3/E5 build one more each. With
 * no reclaim, scenario 2 asks for 12 MB of a 13 MB pool, gets nullptr, falls
 * back to the AXI heap (which cannot serve 12 MB either), and juno_gui_create
 * returns NULL -- then the corpus driver dereferences it and the board stops
 * dead after printing exactly one OK line. Free is now real: first fit, split
 * on alloc, full coalescing pass on free. Block count stays in single digits,
 * so a linear scan costs nothing measurable. */
static uint8_t DSY_SDRAM_BSS g_sdram_pool[13u * 1024u * 1024u];

/* 32-byte header keeps every payload cache-line aligned, as the bump version did. */
typedef struct sdblk { uint32_t size; uint32_t used; uint32_t pad[6]; } sdblk;
#define SDBLK_HDR 32u

static int    g_sdram_init;
static size_t g_sdram_hwm;                        /* high-water mark, for the log */

static void sdram_pool_init(void)
{
    sdblk *b = (sdblk *)g_sdram_pool;
    b->size  = (uint32_t)(sizeof g_sdram_pool - SDBLK_HDR);
    b->used  = 0;
    g_sdram_init = 1;
}

/* EVERY entry point must call this first. .sdram_bss is NOLOAD, so before the
 * first init the pool holds whatever the SDRAM powered up with -- and a walk
 * over that garbage reports a full pool. The first silicon run of E0 did
 * exactly that and halted the board. A host test could not reproduce it: the
 * host's pool is ordinary BSS and is therefore already zero. */
static inline void sdram_ensure(void) { if (!g_sdram_init) sdram_pool_init(); }

/* Every walk is bounded. A corrupted header must not turn a diagnostic tool
 * into an infinite loop -- that would look exactly like the hang we just spent
 * an evening chasing. The pool never holds more than a handful of blocks. */
#define SDBLK_MAX 4096

static int g_sdram_corrupt;

/* Walk the block list, checking it is well formed. Returns 0 on damage. */
static int sdram_check(void)
{
    sdram_ensure();
    size_t off = 0;
    int n = 0;
    while (off + SDBLK_HDR <= sizeof g_sdram_pool) {
        sdblk *b = (sdblk *)&g_sdram_pool[off];
        if (b->used > 1) return 0;                       /* flag is 0 or 1     */
        if (b->size == 0) return 0;                      /* zero never happens */
        if (off + SDBLK_HDR + (size_t)b->size > sizeof g_sdram_pool) return 0;
        off += SDBLK_HDR + b->size;
        if (++n > SDBLK_MAX) return 0;
    }
    return off == sizeof g_sdram_pool;                   /* must tile exactly  */
}

/* Merge every run of adjacent free blocks. Called after each free. */
static void sdram_coalesce(void)
{
    sdram_ensure();
    size_t off = 0;
    int guard = 0;
    while (off + SDBLK_HDR < sizeof g_sdram_pool) {
        if (++guard > 2 * SDBLK_MAX) { g_sdram_corrupt = 1; return; }
        sdblk *b = (sdblk *)&g_sdram_pool[off];
        size_t nxt = off + SDBLK_HDR + b->size;
        if (nxt > sizeof g_sdram_pool) { g_sdram_corrupt = 1; return; }
        if (b->used || nxt + SDBLK_HDR >= sizeof g_sdram_pool) { off = nxt; continue; }
        sdblk *n = (sdblk *)&g_sdram_pool[nxt];
        if (!n->used) { b->size += SDBLK_HDR + n->size; continue; }  /* retry same b */
        off = nxt;
    }
}

static size_t sdram_in_use(void)
{
    sdram_ensure();
    size_t off = 0, used = 0;
    int guard = 0;
    while (off + SDBLK_HDR < sizeof g_sdram_pool) {
        if (++guard > SDBLK_MAX) { g_sdram_corrupt = 1; break; }
        sdblk *b = (sdblk *)&g_sdram_pool[off];
        if (b->size == 0) { g_sdram_corrupt = 1; break; }
        if (b->used) used += b->size;
        off += SDBLK_HDR + b->size;
    }
    return used;
}

/* Largest single allocation the pool could still serve. */
static size_t sdram_largest_free(void)
{
    sdram_ensure();
    size_t off = 0, best = 0;
    int guard = 0;
    while (off + SDBLK_HDR < sizeof g_sdram_pool) {
        if (++guard > SDBLK_MAX) break;
        sdblk *b = (sdblk *)&g_sdram_pool[off];
        if (b->size == 0) break;
        if (!b->used && b->size > best) best = b->size;
        off += SDBLK_HDR + b->size;
    }
    return best;
}

/* 8 KB threshold: the 12 MB state and the corpus driver's render buffers go to
 * SDRAM; juno_ctx and libDaisy's own small allocations stay on the AXI-SRAM
 * heap, which is where the linker script puts .heap. */
#define SDRAM_MIN 8192u

static void *sdram_alloc(size_t n)
{
    sdram_ensure();
    n = (n + 31u) & ~(size_t)31u;                 /* 32-byte: cache-line safe */

    size_t off = 0;
    while (off + SDBLK_HDR < sizeof g_sdram_pool) {
        sdblk *b = (sdblk *)&g_sdram_pool[off];
        if (!b->used && b->size >= n) {
            /* split only if the remainder can hold a header plus a useful payload */
            if (b->size >= n + SDBLK_HDR + 32u) {
                sdblk *r = (sdblk *)&g_sdram_pool[off + SDBLK_HDR + n];
                r->size  = (uint32_t)(b->size - n - SDBLK_HDR);
                r->used  = 0;
                b->size  = (uint32_t)n;
            }
            b->used = 1;
            size_t u = sdram_in_use();
            if (u > g_sdram_hwm) g_sdram_hwm = u;
            return &g_sdram_pool[off + SDBLK_HDR];
        }
        off += SDBLK_HDR + b->size;
    }
    return nullptr;
}

/* Free by SEARCH, not by pointer arithmetic. Subtracting the header from an
 * arbitrary pointer and trusting what is there would silently corrupt the pool
 * on any interior or double free. Confirm p is the payload of a live block. */
static void sdram_free(void *p)
{
    sdram_ensure();
    size_t want = (size_t)((uint8_t *)p - g_sdram_pool);
    size_t off = 0;
    int guard = 0;
    while (off + SDBLK_HDR < sizeof g_sdram_pool) {
        if (++guard > SDBLK_MAX) { g_sdram_corrupt = 1; return; }
        sdblk *b = (sdblk *)&g_sdram_pool[off];
        if (b->size == 0) { g_sdram_corrupt = 1; return; }
        if (off + SDBLK_HDR == want) {
            if (!b->used) { g_sdram_corrupt = 1; return; }   /* double free */
            b->used = 0;
            sdram_coalesce();
            return;
        }
        off += SDBLK_HDR + b->size;
    }
    g_sdram_corrupt = 1;                                     /* interior pointer */
}

extern "C" {
void *__real_malloc(size_t);
void *__real_calloc(size_t, size_t);
void *__real_realloc(void *, size_t);
void  __real_free(void *);

static int sdram_owns(const void *p)
{
    const uint8_t *b = (const uint8_t *)p;
    return b >= g_sdram_pool && b < g_sdram_pool + sizeof g_sdram_pool;
}

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

/* Pool memory now returns to the pool; anything outside it is real heap. */
void __wrap_free(void *p)
{
    if (!p) return;
    if (sdram_owns(p)) { sdram_free(p); return; }
    __real_free(p);
}

/* realloc was NOT wrapped, which was a latent corruption: handing a pool
 * pointer to the newlib allocator makes it read a heap header that does not
 * exist. Nothing in the engine calls realloc today -- this closes the hole so
 * that adding such a call later cannot silently destroy the pool. The block's
 * own size is not recorded here, so copy the smaller of old and new and let the
 * spare bytes be whatever the caller writes. */
void *__wrap_realloc(void *p, size_t n)
{
    if (!p) return __wrap_malloc(n);
    if (!sdram_owns(p)) return __real_realloc(p, n);
    if (n == 0) { sdram_free(p); return nullptr; }

    sdblk *b = (sdblk *)((uint8_t *)p - SDBLK_HDR);
    size_t old = b->size;
    if (n <= old) return p;                       /* shrink in place */
    void *q = __wrap_malloc(n);
    if (!q) return nullptr;
    memcpy(q, p, old);
    sdram_free(p);
    return q;
}
} /* extern "C" */

/* Print the pool state. Called at every phase boundary so that an exhausted or
 * leaking pool is visible in the log the moment it happens, instead of being
 * inferred hours later from a missing line. */
static void pool_report(const char *tag)
{
    size_t used = sdram_in_use();
    LOG("  [pool] %-16s used %4d KB   largest free %4d KB   peak %4d KB%s",
        tag, (int)(used / 1024), (int)(sdram_largest_free() / 1024),
        (int)(g_sdram_hwm / 1024), g_sdram_corrupt ? "   !! CORRUPT" : "");
}

/* Exercise the allocator before anything depends on it: the exact shape E1
 * uses (bank + 12 MB context + a render buffer, eight times over), plus a
 * deliberate double free and an interior free, which must be REFUSED rather
 * than obeyed. Runs in a few microseconds and turns an allocator regression
 * into one printed line instead of a dead board. */
static int pool_selftest(void)
{
    /* Measure against a BASELINE, not against zero. libDaisy is free to hold a
     * legitimate allocation by the time E0 runs, and demanding an empty pool
     * would reject a healthy board. What must be true is that the pool returns
     * to wherever it started -- that is what proves nothing leaked. */
    if (!sdram_check()) { LOG("  [pool] selftest: block list malformed at start"); return 0; }
    const size_t base = sdram_in_use();
    if (base) LOG("  [pool] baseline in use: %d KB (not a fault)", (int)(base / 1024));

    for (int i = 0; i < 8; ++i) {
        void *bank = sdram_alloc(23 + 20223);
        void *st   = sdram_alloc(12u * 1024u * 1024u);
        void *buf  = sdram_alloc(2u * 16000u * sizeof(float));
        if (!bank || !st || !buf) {
            LOG("  [pool] selftest FAILED on round %d (bank=%d st=%d buf=%d)",
                i, bank != nullptr, st != nullptr, buf != nullptr);
            return 0;
        }
        sdram_free(buf); sdram_free(bank); sdram_free(st);
        if (sdram_in_use() != base) { LOG("  [pool] selftest: leak after round %d", i); return 0; }
    }

    /* Refusals. Both must set the corrupt flag WITHOUT altering the pool. */
    void *p = sdram_alloc(65536);
    sdram_free(p);
    g_sdram_corrupt = 0;
    sdram_free(p);                                   /* double free  */
    int caught_double = g_sdram_corrupt;
    g_sdram_corrupt = 0;
    void *q = sdram_alloc(65536);
    sdram_free((uint8_t *)q + 64);                   /* interior ptr */
    int caught_interior = g_sdram_corrupt;
    g_sdram_corrupt = 0;
    sdram_free(q);

    if (!caught_double || !caught_interior) {
        LOG("  [pool] selftest: bad free NOT refused (double=%d interior=%d)",
            caught_double, caught_interior);
        return 0;
    }
    if (!sdram_check() || sdram_in_use() != base) {
        LOG("  [pool] selftest: pool damaged by the refusal tests");
        return 0;
    }
    g_sdram_hwm = 0;                                 /* do not report the test's peak */
    LOG("  [pool] selftest OK  (8 rounds, leak-free, bad frees refused)");
    return 1;
}

/* ----------------------------------------------------------------- engine API */
extern "C" {
typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float sample_rate, int chorus_mode);
void      juno_gui_destroy(juno_ctx *c);
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

/* ------------------------------------------------- WRAP-SAFE BLOCK TIMING
 * DWT->CYCCNT is 32 bits and has no overflow flag. At the MEASURED SysClk of
 * 400 MHz it wraps every 2^32/400e6 = 10.74 s.
 *
 * THE FIRST SILICON RUN WAS BITTEN BY EXACTLY THIS. E2 timed a whole
 * half-second-of-audio loop with one cyc()-t0 pair. At the real cost (~288k
 * cyc/sample) 22080 samples take 15.9 s -- PAST the wrap -- so the uint32
 * subtraction silently returned (true - 2^32) and E2 under-reported every row
 * by 2^32/N = 194,783 cyc/sample. E3 escaped only because its N was half as
 * large: 7.9 s, just inside the wrap. That, and nothing else, is the "3x E2/E3
 * discrepancy": 287,075 / 93,288 = 3.077, and (93,288 + 2^32/22050) / 93,288 =
 * 3.088.
 *
 * THE ORIGINAL PRINTS DO NOT PIN THE ABSOLUTE LEVEL. E2 rendered exactly twice
 * E3's samples, so E2_true = 2*E3_true and the wrap counts satisfy
 * k_E2 = 2*k_E3 + 1 for EVERY k_E3 >= 0. Both (k_E2,k_E3) = (1,0) -> 287,680
 * cyc/sample and (3,1) -> 676,717 cyc/sample reproduce both printed numbers to
 * within 0.4%. A 32-bit counter compared only against itself cannot settle
 * this, so the fix carries an INDEPENDENT time base (System::GetNow(), a
 * millisecond tick that does not wrap for 49 days) alongside the DWT and prints
 * both. If they disagree, the DWT wrapped and by how many turns is then
 * arithmetic, not inference.
 *
 * Fix: time ONE BLOCK at a time (~13.8M cycles, 300x inside the wrap period)
 * and accumulate in 64 bits. Also carry a canary: a single block whose delta
 * exceeds half the counter means the counter wrapped inside even one block, at
 * which point DWT alone can no longer measure this workload. */
static int g_wrap_suspect;

/* Cycles AND milliseconds for the same interval, from two independent clocks. */
typedef struct { uint64_t cyc; uint32_t ms; uint32_t worst; } span;

static span timed_render(juno_ctx *c, float *buf, int nblocks)
{
    span s = {0, 0, 0};
    uint32_t m0 = System::GetNow();
    for (int b = 0; b < nblocks; ++b) {
        uint32_t t0 = cyc();
        juno_gui_render(c, buf, BLOCK);
        uint32_t d = cyc() - t0;
        if (d > 0x80000000u) g_wrap_suspect = 1;   /* wrapped inside one block */
        if (d > s.worst) s.worst = d;
        s.cyc += d;
    }
    s.ms = System::GetNow() - m0;
    return s;
}

/* ======================= E6: is the cost INSTRUCTION FETCH? ===============
 * Two analyses disagreed about where 50,742 of the 93,288 cyc/sample go. One
 * says scattered SDRAM DATA stalls; the other says INSTRUCTION FETCH, because
 * APP_TYPE=BOOT_QSPI means we execute XIP from external QSPI flash and the hot
 * .text is ~32.8 KB against a 16 KB L1 I-cache -- every byte touched every
 * sample. E3 toggled the D-cache ONLY, so an I-side cost is exactly what it is
 * structurally unable to see.
 *
 * E6a toggles the I-CACHE around the E2 workload.
 * E6b is the linker script: with ITCM_HOT=1 the hot render objects are linked
 *     to ITCM (load address stays in QSPI) and copied there by itcm_install()
 *     below, so E2 in THIS image measures ITCM-resident code. Compare it against
 *     the QSPI-resident SILICON baseline of 93,288 already measured on this
 *     board. Build the baseline with: make ITCM_HOT=0 */
extern uint32_t _sitcm, _eitcm, _siitcm;
extern uint32_t _svoice_itcm, _evoice_itcm, _smaster_itcm, _emaster_itcm;

/* MUST run before anything calls the relocated code. The linker gave those
 * functions ITCM addresses; until the bytes are actually there, calling one
 * executes whatever ITCM powered up holding. */
static uint32_t itcm_install(void)
{
    uint32_t *dst = &_sitcm, *src = &_siitcm;
    uint32_t  n   = (uint32_t)((uint8_t *)&_eitcm - (uint8_t *)&_sitcm);
    while (dst < &_eitcm) *dst++ = *src++;
    /* The code was just written as DATA. Without this the I-side can fetch
     * stale bytes for addresses it has already cached. */
    SCB_CleanDCache();
    SCB_InvalidateICache();
    __DSB();
    __ISB();
    return n;
}

/* ------------------------------------------------- the placement axis itself
 * The engine calls its two hot functions through pointers (src/juno_driver.c).
 * The image holds two compilations of each: the original in QSPI and an
 * identical ITCM copy. Selecting between them changes NOTHING but the address
 * the instructions are fetched from -- no operand, no rounding, no ordering --
 * so the arms remain bit-exact with respect to one another and the whole
 * placement question is answered inside ONE boot. */
extern "C" {
uint32_t juno_voice_render(unsigned char *, int, float *, float *);
uint32_t juno_voice_render_itcm(unsigned char *, int, float *, float *);
float   *juno_master_render(unsigned char *, float **, float **);
float   *juno_master_render_itcm(unsigned char *, float **, float **);
extern uint32_t (*juno_voice_render_fn)(unsigned char *, int, float *, float *);
extern float   *(*juno_master_render_fn)(unsigned char *, float **, float **);
}

enum Placement { PL_QSPI = 0, PL_VOICE_ITCM = 1, PL_BOTH_ITCM = 2 };
static const char *PL_NAME[3] = { "QSPI", "V-ITCM", "VM-ITCM" };

static void set_placement(Placement p)
{
    juno_voice_render_fn  = (p == PL_QSPI) ? juno_voice_render
                                           : juno_voice_render_itcm;
    juno_master_render_fn = (p == PL_BOTH_ITCM) ? juno_master_render_itcm
                                                : juno_master_render;
    /* The I-side may hold lines fetched through the OTHER copy's addresses.
     * Invalidating is not strictly required (the addresses differ, so there is
     * no aliasing) but it makes each point start from the same I-cache state,
     * which is the whole reason the matrix is trustworthy. */
    SCB_InvalidateICache();
    __DSB();
    __ISB();
}

/* ------------------------------------------------------------------ reporting */
static float    g_budget_live;    /* cycles/sample available at LIVE_RATE */
static uint32_t g_sysclk_hz = 1;  /* for the elapsed-seconds column         */

/* The old per-row `report()` helper is gone. Every timing row now comes out of
 * ONE table printer in the matrix, so no two rows can be formatted -- or
 * normalised -- by different code. Each row still carries its own independent
 * millisecond-tick cross-check, which is the thing that would have caught the
 * DWT wrap that invalidated the first silicon run.
 */

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

/* ==================== THE MATRIX: one flash, one table ====================
 *
 * WHY THIS REPLACED E2, E3 AND E6a. Those were three separate experiments, each
 * with its own context, its own warmup and its own block count. Two of them
 * disagreed by 3x about the SAME nominal workload, and reconciling that cost a
 * flash. Every cheap orthogonal question now runs as one point of one sweep,
 * off one context, with one warmup and one timing helper -- so the rows are
 * comparable BY CONSTRUCTION, not by inspection of three sets of constants.
 *
 * The cross product:
 *     placement { QSPI, voice in ITCM, voice+master in ITCM }
 *     I-cache   { on, off }
 *     D-cache   { on, off }
 *     voices    { 0, 1, 2, 4, 8 }
 *
 * The first two placements run the FULL 2x2x5 = 20 points each. The third runs
 * only its 8-voice, caches-on point: its job is to report the TOTAL that code
 * placement can ever buy, which is the number that decides whether placement
 * alone gets meaningfully toward the budget. 41 points.
 *
 * READING IT. The disagreement in docs/trackb/CONFLICT.md is between an
 * INSTRUCTION-FETCH hypothesis (we execute XIP from QSPI, hot .text ~32.8 KB
 * against a 16 KB L1 I-cache) and a DATA-STALL hypothesis (scattered SDRAM
 * cells). The placement and I-cache columns are the instruction side; the
 * D-cache column and E7 are the data side. One table, both sides.
 */
#define WARMUP_N ((int)E2_RATE)      /* 1 s of DSP, ONCE, at context setup */

/* Per point: an equal short re-warm then an equal measurement. The re-warm runs
 * with the point's OWN cache and placement configuration already applied, so
 * each point is measured in its own steady state rather than through the tail
 * of the previous point's. An UNEQUAL warmup is precisely the defect that made
 * the old E3 not a replicate of the old E2, so this length is one constant used
 * by every point, deliberately. */
#define MTX_WARM_BLK  (((int)E2_RATE / 16) / BLOCK)
#define MTX_MEAS_BLK  (((int)E2_RATE /  8) / BLOCK)

typedef struct {
    Placement pl;
    int       ic, dc, voices;
    uint32_t  per;          /* cycles per sample                        */
    uint32_t  worst;        /* worst single block                       */
    uint32_t  ms;           /* wall time, from the independent ms tick   */
    uint32_t  per_ms;       /* cyc/sample derived from that tick         */
    int       valid;
} mrow;

#define MTX_MAX 48
static mrow g_mtx[MTX_MAX];
static int  g_mtx_n;

/* Cache control, written once so no point can configure itself differently.
 *
 * The D-cache sequence is load-bearing and must not be simplified. CMSIS's
 * SCB_EnableDCache() EARLY-RETURNS when CCR.DC is already set (cachel1_armv7.h);
 * without that guard the call would invalidate by set/way and DISCARD the dirty
 * engine state the warmup just wrote. So: clean-invalidate BEFORE disabling
 * (dirty lines reach SDRAM), and on re-enable let CMSIS invalidate a cache that
 * is already clean and empty. Never disable without cleaning first. */
static void caches_set(int ic, int dc)
{
    if (dc) { SCB_EnableDCache(); }
    else    { SCB_CleanInvalidateDCache(); SCB_DisableDCache(); }
    if (ic) { SCB_EnableICache(); SCB_InvalidateICache(); }
    else    { SCB_DisableICache(); }
    __DSB(); __ISB();
}

/* Every point ends here, whatever it measured, so the next point starts from
 * the same machine state. A point that left the D-cache off would corrupt every
 * row after it and the table would look plausible while being wrong. */
static void caches_restore(void)
{
    caches_set(1, 1);
}

static void matrix_point(juno_ctx *c, float *buf, Placement pl,
                         int ic, int dc, int voices)
{
    if (g_mtx_n >= MTX_MAX) return;
    mrow *r = &g_mtx[g_mtx_n++];
    r->pl = pl; r->ic = ic; r->dc = dc; r->voices = voices; r->valid = 0;

    /* Notes first, while the machine is in its normal configuration: a recall
     * or note event is not what we are timing. */
    for (int v = 0; v < 8; ++v) juno_gui_note_off(c, 36 + v * 5);
    juno_gui_render(c, buf, BLOCK);
    for (int v = 0; v < voices; ++v) juno_gui_note_on(c, 36 + v * 5, 100);

    set_placement(pl);
    caches_set(ic, dc);

    (void)timed_render(c, buf, MTX_WARM_BLK);          /* equal warm, discarded */
    span s = timed_render(c, buf, MTX_MEAS_BLK);

    caches_restore();

    uint32_t n = (uint32_t)(MTX_MEAS_BLK * BLOCK);
    r->per    = (uint32_t)(s.cyc / n);
    r->worst  = s.worst;
    r->ms     = s.ms;
    r->per_ms = (uint32_t)((uint64_t)s.ms * g_sysclk_hz / (1000ull * n));
    r->valid  = 1;
}

/* Find a row by its coordinates; 0 if that point was not run. */
static const mrow *mtx_find(Placement pl, int ic, int dc, int voices)
{
    for (int i = 0; i < g_mtx_n; ++i) {
        const mrow *r = &g_mtx[i];
        if (r->valid && r->pl == pl && r->ic == ic && r->dc == dc
            && r->voices == voices) return r;
    }
    return nullptr;
}

/* Ratio of two rows as an integer percentage, so no float formatting is needed
 * and a missing row cannot print as a confident 0.00x. */
static void ratio_line(const char *what, const mrow *num, const mrow *den)
{
    if (!num || !den || !den->per) { LOG("  %-38s (not measured)", what); return; }
    uint32_t r100 = (uint32_t)(((uint64_t)num->per * 100u) / den->per);
    LOG("  %-38s %d.%02dx", what, (int)(r100 / 100), (int)(r100 % 100));
}

static void run_matrix(void)
{
    static float buf[2 * BLOCK];
    const tg_scenario *s = &tg_scenarios[0];
    unsigned char *bank = build_bank(s);
    juno_ctx *c = juno_gui_create(E2_RATE, 0);
    if (!c || !bank) {
        LOG("!! MATRIX: allocation FAILED (ctx=%d bank=%d) -- NO TABLE.",
            c != nullptr, bank != nullptr);
        pool_report("matrix alloc fail");
        if (c) juno_gui_destroy(c);
        if (bank) sdram_free(bank);
        return;
    }
    juno_gui_apply_bank(c, bank, BK_HEADER + BK_STRIDE, 0);
    juno_gui_warmup(c, WARMUP_N);          /* past the cold-start transient */

    const int NV[5] = {0, 1, 2, 4, 8};
    for (int p = 0; p <= 1; ++p)
        for (int ic = 1; ic >= 0; --ic)
            for (int dc = 1; dc >= 0; --dc)
                for (int k = 0; k < 5; ++k)
                    matrix_point(c, buf, (Placement)p, ic, dc, NV[k]);

    /* Third placement arm: the 8-voice, caches-on point only. That single row
     * is the TOTAL placement ceiling; the full cross product for it would add
     * minutes for questions the first two arms already answer. */
    matrix_point(c, buf, PL_BOTH_ITCM, 1, 1, 8);

    /* --------------------------------------------------------- the table */
    LOG("");
    LOG("place    ic dc  vox   cyc/sample   x-budget   worst-block   tick-check");
    LOG("-------  -- --  ---   ----------   --------   -----------   ----------");
    for (int i = 0; i < g_mtx_n; ++i) {
        const mrow *r = &g_mtx[i];
        if (!r->valid) continue;
        uint32_t x100 = (uint32_t)(r->per * 100.0f / g_budget_live + 0.5f);
        /* The millisecond tick is an INDEPENDENT clock. If it disagrees with the
         * DWT the DWT wrapped, and the row is not to be believed -- that is the
         * exact failure that invalidated the first silicon E2. */
        int bad = (r->per_ms > r->per + r->per / 10u)
               || (r->per_ms + r->per / 10u < r->per);
        LOG("%-7s  %-2s %-2s  %3d   %10d   %4d.%02dx   %11d   %s",
            PL_NAME[r->pl], r->ic ? "on" : "OFF", r->dc ? "on" : "OFF",
            r->voices, (int)r->per, (int)(x100 / 100), (int)(x100 % 100),
            (int)r->worst, bad ? "!! WRAPPED" : "ok");
    }
    if (g_wrap_suspect)
        LOG("!! a single block exceeded 2^31 cycles -- DWT cannot time this.");

    /* --------------------------------------------------------- derived */
    const mrow *base = mtx_find(PL_QSPI,       1, 1, 8);
    const mrow *vit  = mtx_find(PL_VOICE_ITCM, 1, 1, 8);
    const mrow *both = mtx_find(PL_BOTH_ITCM,  1, 1, 8);
    const mrow *noi  = mtx_find(PL_QSPI,       0, 1, 8);
    const mrow *nod  = mtx_find(PL_QSPI,       1, 0, 8);
    const mrow *idle = mtx_find(PL_QSPI,       1, 1, 0);

    LOG("");
    LOG("--- DERIVED (all at 8 voices, QSPI/caches-on as the reference) ---");
    ratio_line("voice_render QSPI -> ITCM",        vit,  base);
    ratio_line("voice+master QSPI -> ITCM",        both, base);
    ratio_line("cost of disabling the I-cache",    noi,  base);
    ratio_line("cost of disabling the D-cache",    nod,  base);
    ratio_line("idle floor as a fraction of 8v",   idle, base);

    if (base && vit && both) {
        LOG("");
        LOG("VERDICT (SILICON, this board, this boot):");
        /* State the rule BEFORE the numbers decide it, so the reading is not
         * fitted to whatever came out. */
        uint32_t iratio = noi ? (uint32_t)(((uint64_t)noi->per * 100u) / base->per) : 0;
        uint32_t bratio = (uint32_t)(((uint64_t)both->per * 100u) / base->per);
        if (bratio <= 80u || iratio >= 150u) {
            LOG("  INSTRUCTION FETCH is a major term: moving the hot text off");
            LOG("  QSPI changed the cost materially. COST_ATTRIBUTION.md's side");
            LOG("  of docs/trackb/CONFLICT.md is supported, and placement -- a");
            LOG("  linker script, zero arithmetic, still bit-exact -- is real.");
        } else {
            LOG("  INSTRUCTION FETCH is NOT the dominant term: the hot text in");
            LOG("  ITCM barely moved the cost, and disabling the I-cache barely");
            LOG("  hurt. That refutes COST_ATTRIBUTION.md's residual and points");
            LOG("  at the DATA side -- read E7 below, which replays the engine's");
            LOG("  own measured access pattern rather than a generic walk.");
        }
        if (both->per > (uint32_t)g_budget_live)
            LOG("  Placement alone still leaves %d.%02dx over budget.",
                (int)(both->per / (uint32_t)g_budget_live),
                (int)((uint32_t)(both->per * 100.0f / g_budget_live) % 100));
    }

    /* Leave the machine in the reference configuration and RELEASE THE 12 MB.
     * Every phase must give the pool back or later phases starve; that defect
     * has already cost this project a dead board and two flashes. */
    set_placement(PL_QSPI);
    caches_restore();
    juno_gui_destroy(c);
    sdram_free(bank);
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


/* ============ E7: REPLAY THE ENGINE'S OWN ACCESS PATTERN ================
 *
 * E4 above walks 256 KB sequentially and with a coprime stride. That is a
 * generic proxy for "scattered", and a proxy is exactly what the two analyses
 * in docs/trackb/CONFLICT.md have been arguing over. We no longer need a proxy:
 * docs/trackb/MEMORY_LEVER.md MEASURED the real thing on the host --
 *
 *   1,155 accesses per voice per sample (817 loads, 338 stores)
 *   620 DISTINCT 4-byte cells per voice
 *   and the finding that matters: EVERY touched cell sits on its own 16-BYTE
 *   boundary. That is the plugin's SSE layout carried over verbatim. A 32-byte
 *   Cortex-M7 line therefore holds at most 2 useful cells, and 75.6% of every
 *   line fill is thrown away.
 *
 * E7 replays THAT, in four arms with an identical access count:
 *
 *   16 B stride, SDRAM     <- what the engine does today
 *   16 B stride, AXI SRAM
 *    4 B stride, SDRAM     <- what COMPACTING the cell layout would give
 *    4 B stride, AXI SRAM
 *
 * It therefore answers two questions off one flash. First: how much of the cost
 * is data stall UNDER THE REAL PATTERN (the data side of CONFLICT.md, which E3's
 * D-cache toggle measures only indirectly). Second, and this is the one that can
 * change the plan: what compaction would buy BEFORE anyone attempts the invasive
 * offset remap that compaction requires. If 4-byte stride in SDRAM lands near
 * 16-byte stride in AXI, then compaction is a much cheaper route to the same win
 * than relocating the state, and the whole memory plan changes.
 *
 * ORDER MATTERS AND IS NOT ASCENDING. The measured pattern is ~70% jumps. A
 * purely ascending sweep would let the M7's automatic linefill prefetcher hide
 * precisely the cost we are trying to measure, and the arms would converge on a
 * comfortable, wrong answer. The index list below is a fixed pseudo-random
 * permutation-ish walk, built once at run time and REUSED BY ALL FOUR ARMS, so
 * the arms differ in stride and memory only.
 *
 * ANTI-FOLDING. An earlier version of E4 used a plain array filled by memset:
 * GCC proved every word constant, deleted the loads, garbage-collected the
 * buffer, and the benchmark printed a plausible number while measuring nothing.
 * It was caught by inspecting the symbol table, not the build log. So: the
 * buffers are volatile, they are filled from a run-time-seeded PRNG whose values
 * cannot be known at compile time, the accumulator is stored to a volatile sink,
 * and E7 PRINTS THE ACTUAL ADDRESSES it walked. AXI SRAM must read 0x24xxxxxx
 * and SDRAM must read 0xC0xxxxxx. If they do not, the arms are not in the
 * memories their labels claim and every ratio below is meaningless. */

#define E7_CELLS   (620 * 8)          /* 620 cells x 8 voices, the real set  */
#define E7_STRIDE16 4                 /* 16 B, expressed in 4-byte words     */
#define E7_WORDS16 (E7_CELLS * E7_STRIDE16)   /* 19,840 words = 79.4 KB      */
#define E7_ACCESS  200000             /* identical in every arm              */

/* Two buffers, each big enough for the 16-byte-stride arm. The 4-byte arm uses
 * the first E7_CELLS words of the same buffer, so the two strides differ in
 * FOOTPRINT exactly as the real layouts would: 79.4 KB scattered versus 19.8 KB
 * compact. That difference IS the effect being measured -- it is not a flaw in
 * the comparison, it is the point of it. */
static volatile uint32_t g_e7_axi[E7_WORDS16];
static volatile uint32_t DSY_SDRAM_BSS g_e7_sdr[E7_WORDS16];
static uint32_t g_e7_idx[4096];       /* the shared jumpy visit order */

__attribute__((noinline))
static uint32_t e7_walk(volatile uint32_t *p, uint32_t stride_words, int iters)
{
    uint32_t acc = 0;
    uint32_t k = 0;
    uint32_t t0 = cyc();
    for (int i = 0; i < iters; ++i) {
        uint32_t cell = g_e7_idx[k];
        k = (k + 1u) & 4095u;
        /* ~70% of the measured accesses are loads and the rest stores; mirror
         * that rather than reading only, because a store miss on a write-back
         * cache costs a line fill too. */
        if ((i & 3) == 3) p[cell * stride_words] = acc;
        else              acc += p[cell * stride_words];
    }
    uint32_t d = cyc() - t0;
    g_sink = acc;
    return d;
}

static void measure_real_pattern(void)
{
    uint32_t seed = cyc() | 1u;

    /* Runtime-derived contents: unknowable at compile time, so unfoldable. */
    for (uint32_t i = 0; i < E7_WORDS16; ++i) {
        seed = seed * 1664525u + 1013904223u;
        g_e7_axi[i] = seed;
        g_e7_sdr[i] = seed;
    }
    /* The jumpy visit order, built once and shared by all four arms. */
    for (uint32_t i = 0; i < 4096u; ++i) {
        seed = seed * 1664525u + 1013904223u;
        g_e7_idx[i] = (seed >> 8) % (uint32_t)E7_CELLS;
    }

    /* PROVE THE PLACEMENT. A label is not evidence; an address is. */
    LOG("  buffers: AXI at 0x%08lx   SDRAM at 0x%08lx   (%d KB each)",
        (unsigned long)(uintptr_t)g_e7_axi, (unsigned long)(uintptr_t)g_e7_sdr,
        (int)(sizeof g_e7_axi / 1024u));
    int axi_ok = (((uintptr_t)g_e7_axi >> 24) == 0x24u);
    int sdr_ok = (((uintptr_t)g_e7_sdr >> 24) == 0xC0u);
    if (!axi_ok || !sdr_ok) {
        LOG("  !! WRONG MEMORY: AXI must be 0x24xxxxxx (%s), SDRAM 0xC0xxxxxx (%s).",
            axi_ok ? "ok" : "NOT", sdr_ok ? "ok" : "NOT");
        LOG("  !! The arms below are NOT in the memories they are labelled with.");
        LOG("  !! Do not quote any ratio from this table.");
    }

    struct { const char *name; volatile uint32_t *buf; uint32_t stride; }
    ARM[4] = {
        {"16B SDRAM (today)", g_e7_sdr, E7_STRIDE16},
        {"16B AXI",           g_e7_axi, E7_STRIDE16},
        {"4B  SDRAM (compact)", g_e7_sdr, 1},
        {"4B  AXI  (compact)", g_e7_axi, 1},
    };
    uint32_t cyc100[4];

    LOG("");
    LOG("  arm                   cyc/access");
    LOG("  --------------------  ----------");
    for (int i = 0; i < 4; ++i) {
        /* Start every arm from the same cache state, or the arm that happens to
         * run second inherits the first one's residency and reads faster for a
         * reason that has nothing to do with stride. */
        SCB_CleanInvalidateDCache();
        uint32_t d = e7_walk(ARM[i].buf, ARM[i].stride, E7_ACCESS);
        cyc100[i] = (uint32_t)((uint64_t)d * 100u / (uint32_t)E7_ACCESS);
        LOG("  %-20s  %5d.%02d", ARM[i].name,
            (int)(cyc100[i] / 100), (int)(cyc100[i] % 100));
    }

    LOG("");
    LOG("  DERIVED:");
    if (cyc100[1]) LOG("    SDRAM penalty at the real 16B stride   %d.%02dx",
                       (int)(cyc100[0] * 100u / cyc100[1] / 100u),
                       (int)((cyc100[0] * 100u / cyc100[1]) % 100u));
    if (cyc100[2]) LOG("    compaction 16B->4B, in SDRAM           %d.%02dx",
                       (int)(cyc100[0] * 100u / cyc100[2] / 100u),
                       (int)((cyc100[0] * 100u / cyc100[2]) % 100u));
    if (cyc100[3]) LOG("    compaction 16B->4B, in AXI             %d.%02dx",
                       (int)(cyc100[1] * 100u / cyc100[3] / 100u),
                       (int)((cyc100[1] * 100u / cyc100[3]) % 100u));
    /* THE DECISION LINE. Compaction is a pure offset remap of the port's own
     * layout; relocation needs 21 KB of the hot set moved into internal SRAM and
     * the rest left behind. If compacted SDRAM is already near scattered AXI,
     * compaction is the cheaper route to the same win. */
    if (cyc100[1] && cyc100[2]) {
        uint32_t r = cyc100[2] * 100u / cyc100[1];
        LOG("    compacted-SDRAM vs scattered-AXI       %d.%02dx",
            (int)(r / 100u), (int)(r % 100u));
        if (r <= 130u)
            LOG("    -> COMPACTION alone gets close to relocation. It is a pure");
        else
            LOG("    -> Relocation still beats compaction here. Compaction is a");
        LOG("       offset remap of our own layout and needs no new memory.");
    }
    LOG("  NOTE: this measures the MEMORY SYSTEM under the engine's measured");
    LOG("  pattern. It does not by itself say what fraction of the engine's");
    LOG("  93,288 cyc/sample is data stall -- read it with the matrix's");
    LOG("  D-cache column, which is the same question asked from the other end.");
}

/* ========================= E5: PLAY IT (live audio) ======================
 * Everything above runs without touching the codec. This part actually makes
 * sound, so you can hear the engine and hear whether it keeps up.
 *
 * It is self-playing: no MIDI hardware, no keyboard, no extra wiring. Plug in
 * audio out and it cycles the 8 factory patches embedded in teensy_golden.h,
 * playing an 8-note chord (all eight voices at once) then an arpeggio.
 *
 * The real-time verdict comes out two ways at once: by ear (dropouts are
 * audible) and by number (worst-case block cycles vs the budget, printed from
 * the main loop -- never from the callback, which runs at interrupt priority
 * where PrintLine is unsafe). */

static juno_ctx *g_play;
static unsigned char *g_play_bank;

/* Delivery-only output trim. The engine's master stage ends in 2*(sat*1.0) and
 * can legitimately exceed +-1.0, which a codec would clip. This is the same role
 * the webapp's MONITOR fader plays -- it is NOT part of the engine and does not
 * touch a single coefficient. */
#define OUT_TRIM 0.45f

static volatile uint32_t g_worst_cyc, g_last_cyc, g_blocks, g_overruns;
static volatile int      g_cur_patch, g_want_patch = -1;
static float             g_budget_block;

/* Self-playing sequencer state, advanced from the callback. */
static uint32_t g_seq_frames;
static int      g_seq_step = -1;
static const int CHORD[8] = {36, 43, 48, 55, 60, 64, 67, 72};

static void seq_advance(void)
{
    /* 0: 8-note chord on   1: release   2..9: arpeggio   10: next patch */
    g_seq_step = (g_seq_step + 1) % 11;
    if (g_seq_step == 0) {
        for (int v = 0; v < 8; ++v) juno_gui_note_on(g_play, CHORD[v], 100);
    } else if (g_seq_step == 1) {
        for (int v = 0; v < 8; ++v) juno_gui_note_off(g_play, CHORD[v]);
    } else if (g_seq_step >= 2 && g_seq_step <= 9) {
        int prev = CHORD[(g_seq_step - 3) & 7];
        if (g_seq_step > 2) juno_gui_note_off(g_play, prev);
        juno_gui_note_on(g_play, CHORD[g_seq_step - 2], 100);
    } else {
        juno_gui_note_off(g_play, CHORD[7]);
        g_want_patch = (g_cur_patch + 1) % TG_NSCEN;
    }
}

/* Frames each step lasts: long for the chord, short for the arp steps. */
static uint32_t seq_len(int step)
{
    if (step == 0) return (uint32_t)(LIVE_RATE * 2.0f);   /* chord held  */
    if (step == 1) return (uint32_t)(LIVE_RATE * 1.0f);   /* tail        */
    if (step == 10) return (uint32_t)(LIVE_RATE * 1.0f);  /* gap         */
    return (uint32_t)(LIVE_RATE * 0.16f);                 /* arp step    */
}

static void AudioCB(AudioHandle::InterleavingInputBuffer  in,
                    AudioHandle::InterleavingOutputBuffer out,
                    size_t                                size)
{
    /* libDaisy's interleaved `size` is the TOTAL sample count (L and R counted
     * separately -- see AudioHandle::Impl::InternalCallback, which steps i += 2).
     * juno_gui_render takes FRAMES. Passing `size` would render twice the buffer
     * and corrupt memory past the end. */
    const int frames = (int)(size / 2u);
    uint32_t t0 = cyc();
    (void)in;

    /* Patch changes happen here, at a block boundary, so the engine state is
     * never torn by a concurrent recall. A full recall costs far more than one
     * block, so it deliberately produces ONE dropout -- audible as a click, the
     * same as switching patches on the real thing. */
    if (g_want_patch >= 0) {
        int p = g_want_patch;
        g_want_patch = -1;
        memcpy(g_play_bank + BK_HEADER + BK_BLOB, tg_scenarios[p].blob, TG_BLOB_LEN);
        juno_gui_apply_bank(g_play, g_play_bank, BK_HEADER + BK_STRIDE, 0);
        g_cur_patch = p;
    }

    if (g_seq_step < 0 || g_seq_frames >= seq_len(g_seq_step)) {
        g_seq_frames = 0;
        seq_advance();
    }
    g_seq_frames += (uint32_t)frames;

    juno_gui_render(g_play, out, frames);
    for (size_t i = 0; i < size; ++i) {
        float s = out[i] * OUT_TRIM;
        out[i] = s > 1.0f ? 1.0f : (s < -1.0f ? -1.0f : s);
    }

    uint32_t d = cyc() - t0;
    g_last_cyc = d;
    if (d > g_worst_cyc) g_worst_cyc = d;
    if ((float)d > g_budget_block) g_overruns++;
    g_blocks++;
}

static void start_playing(void)
{
    g_play_bank = (unsigned char *)sdram_alloc(BK_HEADER + BK_STRIDE);
    g_play = juno_gui_create(LIVE_RATE, 0);
    if (!g_play || !g_play_bank) {
        hw.PrintLine("  E5: allocation FAILED (ctx=%d bank=%d) -- NO AUDIO.",
                     g_play != nullptr, g_play_bank != nullptr);
        hw.PrintLine("  This means an earlier phase did not release its 12 MB.");
        pool_report("E5 alloc fail");
        if (g_play) { juno_gui_destroy(g_play); g_play = nullptr; }
        if (g_play_bank) { sdram_free(g_play_bank); g_play_bank = nullptr; }
        return;
    }
    memset(g_play_bank, 0, BK_HEADER + BK_STRIDE);
    memcpy(g_play_bank + BK_HEADER + BK_BLOB, tg_scenarios[0].blob, TG_BLOB_LEN);
    juno_gui_apply_bank(g_play, g_play_bank, BK_HEADER + BK_STRIDE, 0);
    g_cur_patch = 0;

    /* Cold-start warm-up. All 8 DCOs boot phase-aligned, which makes the first
     * note of a UNISON patch peak roughly 2x hot and read several times darker
     * until the per-voice CONDITION scatter decorrelates them. Measured on x86:
     * ~4 s is where it settles (docs/COLDSTART_UNISON_FINDING.md). This is not
     * instant on the Daisy -- it is 4 s of DSP, possibly slower than real time. */
    pool_report("E5 running");
    hw.PrintLine("  warming up 4 s of DSP (cold DCO phase alignment)...");
    hw.PrintLine("  (this is real DSP and may take longer than 4 s -- wait for");
    hw.PrintLine("   the 'budget' line below, THEN expect sound.)");
    juno_gui_warmup(g_play, (int)(LIVE_RATE * 4.0f));

    g_budget_block = (float)System::GetSysClkFreq() / LIVE_RATE * (float)BLOCK;
    hw.PrintLine("  budget %d cycles per %d-frame block",
                 (int)(g_budget_block + 0.5f), BLOCK);
    hw.StartAudio(AudioCB);
}

/* ======================= PRE-FLIGHT SELF-CHECK ===========================
 * DO NOT WASTE A FLASH ON A BAD BUILD. Every number below this point depends on
 * a handful of preconditions that can silently fail: the ITCM copy may be empty
 * (a linker glob that matched nothing still links cleanly), the DWT may not
 * tick, the counter may wrap inside a measurement. When one of those fails the
 * firmware still prints a full, plausible, WRONG table -- which is how this
 * project lost a flash before.
 *
 * So the verdict is printed HERE, at the TOP, before any measurement, and it is
 * loud. A reader who sees FAIL on this block can stop reading immediately. */
static int preflight(uint32_t itcm_bytes, bool dwt_ok)
{
    int ok = 1;
    uint32_t vsz = (uint32_t)((uint8_t *)&_evoice_itcm - (uint8_t *)&_svoice_itcm);
    uint32_t msz = (uint32_t)((uint8_t *)&_emaster_itcm - (uint8_t *)&_smaster_itcm);

    hw.PrintLine("");
    hw.PrintLine("--- PRE-FLIGHT (every row below is a precondition) ---");
    hw.PrintLine("  ITCM copied            %6d B from 0x%08lx to 0x%08lx",
                 (int)itcm_bytes, (unsigned long)(uintptr_t)&_siitcm,
                 (unsigned long)(uintptr_t)&_sitcm);
    hw.PrintLine("    voice_render_itcm    %6d B   %s", (int)vsz,
                 vsz ? "ok" : "!! EMPTY -- the ITCM arm is not real");
    hw.PrintLine("    master_render_itcm   %6d B   %s", (int)msz,
                 msz ? "ok" : "!! EMPTY -- the ITCM arm is not real");
    if (!vsz || !msz || !itcm_bytes) ok = 0;
    if (itcm_bytes > 64u * 1024u) {
        hw.PrintLine("  !! ITCM section is %d B but ITCMRAM is only 65536 B.",
                     (int)itcm_bytes);
        ok = 0;
    }
    /* Prove the pointers really select DIFFERENT code. If both arms resolved to
     * the same address the sweep would compare a thing with itself and report a
     * confident 1.00x -- the most misleading result this firmware could give. */
    hw.PrintLine("  voice_render  QSPI 0x%08lx   ITCM 0x%08lx   %s",
                 (unsigned long)(uintptr_t)juno_voice_render,
                 (unsigned long)(uintptr_t)juno_voice_render_itcm,
                 (uintptr_t)juno_voice_render != (uintptr_t)juno_voice_render_itcm
                     ? "distinct" : "!! SAME -- no A/B is possible");
    hw.PrintLine("  master_render QSPI 0x%08lx   ITCM 0x%08lx   %s",
                 (unsigned long)(uintptr_t)juno_master_render,
                 (unsigned long)(uintptr_t)juno_master_render_itcm,
                 (uintptr_t)juno_master_render != (uintptr_t)juno_master_render_itcm
                     ? "distinct" : "!! SAME -- no A/B is possible");
    if ((uintptr_t)juno_voice_render == (uintptr_t)juno_voice_render_itcm) ok = 0;
    if ((uintptr_t)juno_master_render == (uintptr_t)juno_master_render_itcm) ok = 0;
    /* The ITCM copies must actually be AT ITCM addresses (0x0000xxxx). A glob
     * that missed would leave them in QSPI and the "ITCM" rows would be a
     * second QSPI measurement wearing an ITCM label. */
    int in_itcm = ((uintptr_t)juno_voice_render_itcm < 0x10000u)
               && ((uintptr_t)juno_master_render_itcm < 0x10000u);
    hw.PrintLine("  ITCM copies are at ITCM addresses          %s",
                 in_itcm ? "ok" : "!! NO -- they are still in flash");
    if (!in_itcm) ok = 0;

    hw.PrintLine("  DWT cycle counter ticking                  %s",
                 dwt_ok ? "ok" : "!! NO -- every cycle number is invalid");
    if (!dwt_ok) ok = 0;
    hw.PrintLine("  wrap canary (set if a block exceeded 2^31) %s",
                 g_wrap_suspect ? "!! FIRED" : "clear");
    if (g_wrap_suspect) ok = 0;
    hw.PrintLine("  SysClk %d Hz   budget %d cyc/sample at %d Hz",
                 (int)g_sysclk_hz, (int)(g_budget_live + 0.5f), (int)LIVE_RATE);
    hw.PrintLine("  SDRAM pool %d KB   corpus rate %d Hz",
                 (int)(sizeof g_sdram_pool / 1024u), (int)E2_RATE);

    hw.PrintLine("  ==> PRE-FLIGHT %s", ok ? "PASS" : "*** FAIL ***");
    if (!ok) {
        hw.PrintLine("  *** ONE OR MORE PRECONDITIONS FAILED. The table below");
        hw.PrintLine("  *** would be nonsense. Fix the build; do not read it.");
    }
    return ok;
}

/* ===================== PARK IN DFU WHEN THE RUN IS DONE ==================
 * Flashing costs the user real effort, and the button dance (BOOT + RESET,
 * timed) is the worst part of it. When everything above has run and the audio
 * has played for a while, put the board into DFU with an INFINITE timeout: it
 * then sits there waiting for dfu-util with no buttons touched at all.
 *
 * GUARDED, because parking is destructive to the thing a listener may still
 * want: the audio. A power cycle re-runs the firmware from the top and plays
 * again, so nothing is lost permanently -- and the countdown below announces
 * the park well in advance instead of cutting the sound off as a surprise. */
#define PARK_AFTER_S 90

static void park_in_dfu(void)
{
    hw.PrintLine("");
    hw.PrintLine("=== parking in DFU (infinite timeout) -- run dfu-util when");
    hw.PrintLine("=== ready, no buttons needed. Power-cycle to hear audio again.");
    System::Delay(300);            /* let the last line reach the terminal */
    System::ResetToBootloader(System::BootloaderMode::DAISY_INFINITE_TIMEOUT);
    while (1) { }                  /* not reached */
}

/* ================================= main ================================== */
int main(void)
{
    /* FIRST: nothing may call the relocated code until the bytes are in ITCM.
     * The linker gave those functions ITCM addresses; until this copy runs,
     * calling one executes whatever ITCM powered up holding. */
    uint32_t itcm_bytes = itcm_install();

    hw.Init();                       /* also brings up the 64 MB SDRAM        */
    hw.SetAudioSampleRate(SaiHandle::Config::SampleRate::SAI_48KHZ);
    hw.SetAudioBlockSize(BLOCK);
    hw.StartLog(true);               /* wait for a serial monitor             */

    enable_hw_ftz();
    bool dwt_ok = dwt_init();

    g_sysclk_hz   = System::GetSysClkFreq();
    g_budget_live = (float)g_sysclk_hz / LIVE_RATE;

    hw.PrintLine("=== JUNO-60 C99 port : Daisy Seed EXPERIMENT PLATFORM ===");
    hw.PrintLine("One boot returns a TABLE, not a number. Placement x I-cache x");
    hw.PrintLine("D-cache x voices, plus a replay of the engine's real access");
    hw.PrintLine("pattern. Every arm is in THIS image; no second flash is needed.");
    /* Print the wrap period every run. It is the number that invalidated the
     * first E2 and it is not derivable from any other line in this log. */
    hw.PrintLine("DWT CYCCNT is 32-bit: wraps every %d ms. No single timed",
                 (int)(4294967296.0f / (float)g_sysclk_hz * 1000.0f));
    hw.PrintLine("interval below may exceed that (each point times one block).");
    /* The cost rows are measured at E2_RATE but scored against the LIVE_RATE
     * budget. That is deliberate (per-sample cost is rate-independent to within
     * the rate-armed coefficient branches) but it must be stated, not assumed. */
    hw.PrintLine("Cost rows: MEASURED at %d Hz, scored against the %d Hz budget.",
                 (int)E2_RATE, (int)LIVE_RATE);
    hw.PrintLine("All timing below is SILICON -- measured on this board.");

    /* HARD GUARD: on an old bootloader our SDRAM does not exist.
     *
     * DaisySeed::Init (src/daisy_seed.cpp:113-131) skips BOTH sdram_handle.Init()
     * and -- via syscfg.skip_clocks -- System::ConfigureClocks()/ConfigureMpu()
     * (src/sys/system.cpp:220-224) when the bootloader predates v6.0 AND the app
     * does not run from internal flash. This firmware is APP_TYPE=BOOT_QSPI, so
     * it always runs from QSPI and always trips that condition on an old
     * bootloader. The 13 MB DSY_SDRAM_BSS pool would then be un-clocked memory:
     * the memset in __wrap_calloc faults or silently writes garbage, and with no
     * MPU programming 0xC0000000 falls back to non-cacheable Device memory, which
     * would make the cache columns measure nonsense even if it did not crash.
     *
     * Detect it and refuse, rather than fail in a way that looks like a port bug. */
    {
        auto bv = System::GetBootloaderVersion();
        auto mr = System::GetProgramMemoryRegion();
        hw.PrintLine("bootloader v%s   program memory region %d",
                     bv == System::BootInfo::Version::LT_v6_0 ? "<6.0" : ">=6.0",
                     (int)mr);
        if (bv == System::BootInfo::Version::LT_v6_0
            && mr != System::MemoryRegion::INTERNAL_FLASH) {
            hw.PrintLine("!! FATAL: bootloader is older than v6.0 and we run from");
            hw.PrintLine("!! QSPI, so libDaisy SKIPPED SDRAM init and MPU config.");
            hw.PrintLine("!! The 10.5 MB engine state has nowhere to live.");
            hw.PrintLine("!! Fix: reflash the Daisy bootloader (make program-boot),");
            hw.PrintLine("!! then flash this app again. Halting -- this is NOT a");
            hw.PrintLine("!! port defect.");
            while (1) { System::Delay(1000); }
        }
    }

    /* --- pre-flight: say it LOUDLY and say it FIRST --------------------- */
    int pf = preflight(itcm_bytes, dwt_ok);

    /* --- E0: prove the allocator before anything relies on it ------------ */
    hw.PrintLine("");
    hw.PrintLine("--- E0: SDRAM pool self-test ---");
    if (!pool_selftest()) {
        hw.PrintLine("!! The pool cannot serve the pattern E1-E7 need. Every");
        hw.PrintLine("!! result below would be meaningless. Halting.");
        while (1) { System::Delay(1000); }
    }
    pool_report("after E0");

    /* --- E1 ------------------------------------------------------------- */
    hw.PrintLine("");
    hw.PrintLine("--- E1: golden corpus (bit-exactness on real M7) ---");
    int rc = juno_golden_main();
    pool_report("after E1");
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

    /* E1 runs the corpus through the DEFAULT (QSPI) pointers. Re-run one
     * scenario's worth of the corpus through the ITCM copies as well? No: the
     * two copies are the same source compiled with the same flags, and E1's own
     * 8/8 already proves the source. What must be checked, and is checked in
     * pre-flight, is that they are DISTINCT ADDRESSES -- a placement question,
     * not an arithmetic one. */

    /* --- THE MATRIX ----------------------------------------------------- */
    hw.PrintLine("");
    hw.PrintLine("--- MATRIX: placement x I-cache x D-cache x voices (SILICON) ---");
    run_matrix();
    pool_report("after matrix");

    /* --- E4 / E7: the memory system ------------------------------------- */
    hw.PrintLine("");
    hw.PrintLine("--- E4: SDRAM vs internal AXI-SRAM (generic walk) ---");
    measure_memory();
    pool_report("after E4");

    hw.PrintLine("");
    hw.PrintLine("--- E7: the ENGINE'S OWN measured access pattern ---");
    measure_real_pattern();
    pool_report("after E7");

    hw.PrintLine("");
    if (!pf) {
        hw.PrintLine("*** REMINDER: PRE-FLIGHT FAILED. Everything above is suspect.");
    }
    hw.PrintLine("=== The matrix's QSPI/on/on/8 row against the budget IS the");
    hw.PrintLine("=== answer to 'can the Daisy do 8 voices bit-exact'. The");
    hw.PrintLine("=== placement and I-cache columns are the instruction side of");
    hw.PrintLine("=== docs/trackb/CONFLICT.md; the D-cache column and E7 are the");
    hw.PrintLine("=== data side. Both sides, one flash.");

    /* --- E5: make sound ------------------------------------------------- */
    hw.PrintLine("");
    hw.PrintLine("--- E5: LIVE AUDIO (self-playing, no MIDI needed) ---");
    start_playing();

    /* Live real-time verdict, once a second, from the main loop, then park in
     * DFU so the next flash needs no buttons. */
    uint32_t last_blocks = 0;
    for (uint32_t sec = 0; ; ++sec) {
        System::Delay(1000);
        uint32_t blocks = g_blocks, worst = g_worst_cyc, over = g_overruns;
        if (blocks == last_blocks) {
            hw.PrintLine("audio callback STALLED");
        } else {
            last_blocks = blocks;
            hw.PrintLine("patch %d/%d '%s'  worst %d cyc/block (%d%% of budget)"
                         "  overruns %d/%d",
                         g_cur_patch + 1, TG_NSCEN, tg_scenarios[g_cur_patch].name,
                         (int)worst, (int)(100.0f * worst / g_budget_block),
                         (int)over, (int)blocks);
            /* Reset the peak so a single patch-change dropout does not dominate
             * the reading forever -- that one block is expected to overrun. */
            g_worst_cyc = 0;
        }
        /* Announced, not sprung. The listener gets the whole countdown. */
        if (sec + 10 >= PARK_AFTER_S && sec < PARK_AFTER_S)
            hw.PrintLine("  ... parking in DFU in %d s (power-cycle to keep playing)",
                         (int)(PARK_AFTER_S - sec));
        if (sec >= PARK_AFTER_S) {
            hw.StopAudio();
            park_in_dfu();
        }
    }
}
