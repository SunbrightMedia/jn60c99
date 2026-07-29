/* state_footprint.c — measure how much of the 12 MB engine state is ACTUALLY
 * touched (read or written) during real use.
 *
 * Why: docs/DAISY_FEASIBILITY.md asserts "12 MB of state, needs SDRAM". That is
 * the ALLOCATION size (gui/juno_bridge.c: calloc(1, JUNO_STATE_BYTES)), not the
 * working set. If the live set is small enough, the whole SDRAM/PSRAM argument
 * against Teensy 4.1 (1 MB internal RAM) collapses.
 *
 * Method (measurement, not estimate): link with -Wl,--wrap=calloc so the
 * engine's one big allocation is served by an mmap(PROT_NONE) region. Every
 * first touch of a page faults; the SIGSEGV handler records the page and
 * mprotects it R/W so execution continues. After a hard workout the recorded
 * bitmap IS the touched set — reads included, which a poison-scan would miss.
 *
 * Page granularity is 4 KiB (an over-estimate of the true byte footprint, which
 * is the safe direction for a memory-budget claim).
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/mman.h>
#include <unistd.h>

typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float sr, int chorus_mode);
int  juno_gui_apply_bank(juno_ctx *c, const unsigned char *bank, int len, int idx);
void juno_gui_note_on(juno_ctx *c, int midi_note, int velocity);
void juno_gui_note_off(juno_ctx *c, int midi_note);
void juno_gui_warmup(juno_ctx *c, int n);
int  juno_gui_render(juno_ctx *c, float *out, int nframes);

void *__real_calloc(size_t n, size_t sz);

#define PGSZ 4096u

static unsigned char *g_base;      /* the intercepted state region        */
static size_t         g_len;
static unsigned char *g_hit;       /* one byte per page: 1 == touched     */
static size_t         g_pages;
static int            g_armed;

static void segv(int sig, siginfo_t *si, void *uc)
{
    unsigned char *a = (unsigned char *)si->si_addr;
    size_t pg;
    (void)sig; (void)uc;
    if (!g_armed || a < g_base || a >= g_base + g_len) _exit(139);
    pg = (size_t)(a - g_base) / PGSZ;
    g_hit[pg] = 1;
    if (mprotect(g_base + pg * PGSZ, PGSZ, PROT_READ | PROT_WRITE) != 0) _exit(140);
}

/* The engine's single big allocation is redirected here. Everything else falls
 * through to the real calloc untouched. */
void *__wrap_calloc(size_t n, size_t sz)
{
    size_t bytes = n * sz;
    void *p;
    if (g_armed || bytes < 4u * 1024u * 1024u) return __real_calloc(n, sz);

    g_len   = (bytes + PGSZ - 1) & ~(size_t)(PGSZ - 1);
    g_pages = g_len / PGSZ;
    p = mmap(NULL, g_len, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (p == MAP_FAILED) { perror("mmap"); exit(2); }
    g_base = (unsigned char *)p;
    g_hit  = (unsigned char *)__real_calloc(g_pages, 1);
    g_armed = 1;
    fprintf(stderr, "[footprint] intercepted %zu byte allocation (%zu pages)\n",
            bytes, g_pages);
    return p;
}

static void report(const char *tag)
{
    size_t i, hit = 0, hi = 0;
    for (i = 0; i < g_pages; ++i)
        if (g_hit[i]) { hit++; hi = i; }
    printf("%-26s touched %6zu / %6zu pages = %8.1f KiB   (highest page ends at %.2f MiB)\n",
           tag, hit, g_pages, hit * 4.0, (hi + 1) * PGSZ / 1048576.0);
    fflush(stdout);
}

/* Re-arm: forget the touched set and re-protect everything, so the NEXT phase
 * measures its own working set rather than the union with init. Page contents
 * survive mprotect, so the engine state is untouched by this. */
static void rearm(void)
{
    memset(g_hit, 0, g_pages);
    if (mprotect(g_base, g_len, PROT_NONE) != 0) { perror("mprotect"); exit(2); }
}

/* Print the touched pages as coalesced [start,end) byte ranges: this is the map
 * an embedded port would use to lay the state out in real RAM. */
static void ranges(void)
{
    size_t i = 0, total = 0, nr = 0;
    printf("\ntouched address ranges (byte offsets into the state):\n");
    while (i < g_pages) {
        size_t s;
        if (!g_hit[i]) { i++; continue; }
        s = i;
        while (i < g_pages && g_hit[i]) i++;
        printf("  [%9zu .. %9zu)  %8.1f KiB\n",
               s * PGSZ, i * PGSZ, (i - s) * 4.0);
        total += (i - s) * PGSZ;
        nr++;
    }
    printf("  %zu ranges, %.1f KiB total\n", nr, total / 1024.0);
}

int main(int argc, char **argv)
{
    struct sigaction sa;
    unsigned char *bank;
    long n;
    FILE *f;
    float buf[2 * 128];
    int p, v, i;
    double sr = (argc > 1) ? atof(argv[1]) : 44100.0;

    memset(&sa, 0, sizeof sa);
    sa.sa_sigaction = segv;
    sa.sa_flags = SA_SIGINFO;
    sigaction(SIGSEGV, &sa, NULL);

    f = fopen("truth/presetbankog1.bin", "rb");
    if (!f) { fprintf(stderr, "run me from the repo root\n"); return 2; }
    fseek(f, 0, SEEK_END); n = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)n);
    if (fread(bank, 1, (size_t)n, f) != (size_t)n) return 2;
    fclose(f);

    juno_ctx *c = juno_gui_create((float)sr, 0);
    report("A. create (init constants)");
    juno_gui_apply_bank(c, bank, (int)n, 0);
    report("A. + apply patch 0");

    /* ---- phase B: the HOT set. What does a steady-state audio callback touch?
     * This is the number that decides fast-RAM placement: pages only written by
     * init can live in slow external memory and never be read again. */
    rearm();
    for (v = 0; v < 8; ++v) juno_gui_note_on(c, 36 + v * 5, 100);
    for (i = 0; i < (int)(sr * 2.0); i += 128) juno_gui_render(c, buf, 128);
    report("B. HOT: 8 voices, 2 s");
    ranges();

    /* ---- phase C: everything, all 64 patches: every FX type, every line. */
    rearm();
    for (p = 0; p < 64; ++p) {
        juno_gui_apply_bank(c, bank, (int)n, p);
        for (v = 0; v < 8; ++v) juno_gui_note_on(c, 36 + v * 5, 100);
        for (i = 0; i < (int)(sr * 1.5); i += 128) juno_gui_render(c, buf, 128);
        for (v = 0; v < 8; ++v) juno_gui_note_off(c, 36 + v * 5);
        for (i = 0; i < (int)(sr * 1.0); i += 128) juno_gui_render(c, buf, 128);
    }
    report("C. all 64 patches (recall+render)");
    ranges();
    return 0;
}
