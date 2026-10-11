/* cpu_census_native.c -- a plugin's own CPU questions asked of THIS CPU: its CRT inits (__isa_available_init, the
 * FMA3 init) run natively, and the globals they set printed. Driven by tools/verify/cpu_census.py (the answers a
 * real PC gives, beside the ones Unicorn gives and the image's static ones).
 *
 * The PE image is mapped at its preferred base (MAP_FIXED_NOREPLACE: the inits address their globals RIP-relative);
 * each init is called through an ms_abi pointer (the plugin's calling convention); neither calls an import.
 *   cpu_census_native PE INIT[,INIT..] GLOBAL[,GLOBAL..]     prints `addr=value` (addr hex, value decimal u32)
 *   cpu_census_native PE --path KIND FN GLOBAL A B N SEED [TRAP]
 *       a CRT routine's two paths: N random inputs of KIND (strnlen, wcslen, wcsnlen) through FN with the answer
 *       *GLOBAL = A and = B, results compared (`inputs N differ D`); with TRAP, an int3 at TRAP (the first instruction
 *       of the path one answer selects) shows which answer enters it (`trap A yes|no` and `trap B yes|no`) */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/mman.h>
#include <setjmp.h>
#include <signal.h>

static uint8_t *pe_map(const char *path)
{
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); exit(2); }
    fseek(f, 0, SEEK_END);
    long n = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t *file = malloc((size_t)n);
    if (!file || fread(file, 1, (size_t)n, f) != (size_t)n) { fprintf(stderr, "read %s failed\n", path); exit(2); }
    fclose(f);
    uint32_t pe = *(uint32_t *)(file + 0x3c);
    uint16_t nsec = *(uint16_t *)(file + pe + 6), optsz = *(uint16_t *)(file + pe + 20);
    uint8_t *opt = file + pe + 24;
    uint64_t base = *(uint64_t *)(opt + 24);
    uint32_t imgsz = *(uint32_t *)(opt + 56), hdrsz = *(uint32_t *)(opt + 60);
    uint8_t *img = mmap((void *)base, imgsz, PROT_READ | PROT_WRITE | PROT_EXEC,
                        MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    if (img == MAP_FAILED || (uint64_t)img != base) { fprintf(stderr, "cannot map the image at %llx\n", (unsigned long long)base); exit(2); }
    memcpy(img, file, hdrsz);
    uint8_t *sec = opt + optsz;
    for (int i = 0; i < nsec; i++, sec += 40) {
        uint32_t vsz = *(uint32_t *)(sec + 8), va = *(uint32_t *)(sec + 12);
        uint32_t rawsz = *(uint32_t *)(sec + 16), raw = *(uint32_t *)(sec + 20);
        memcpy(img + va, file + raw, (rawsz < vsz || !vsz) ? rawsz : vsz);
    }
    free(file);
    return img;
}

typedef uint64_t (__attribute__((ms_abi)) *init_t)(void);
typedef uint64_t (__attribute__((ms_abi)) *f2_t)(uint64_t, uint64_t);

static sigjmp_buf jb;
static void on_trap(int sig) { (void)sig; siglongjmp(jb, 1); }
static uint64_t rs;
static uint32_t rnd(void) { rs = rs * 6364136223846793005ULL + 1442695040888963407ULL; return (uint32_t)(rs >> 33); }

/* one input: a string of `len` units (bytes, or 16-bit units for the wide kinds) at offset `off`, no unit 0 inside,
 * a 0 after it and zeros to the end of the buffer; returns the pointer */
static uint8_t *make(uint8_t *buf, size_t cap, int wide, size_t len, size_t off)
{
    memset(buf, 0, cap);
    uint8_t *p = buf + off;
    for (size_t i = 0; i < len; i++) {
        if (wide) { uint16_t v = (uint16_t)(1 + rnd() % 0xFFFE); memcpy(p + 2 * i, &v, 2); }
        else p[i] = (uint8_t)(1 + rnd() % 255);
    }
    return p;
}

static int path(uint8_t *img, int argc, char **argv)
{
    const char *kind = argv[3];
    uint32_t fn = (uint32_t)strtoul(argv[4], 0, 0), g = (uint32_t)strtoul(argv[5], 0, 0);
    uint32_t A = (uint32_t)strtoul(argv[6], 0, 0), B = (uint32_t)strtoul(argv[7], 0, 0);
    int n = atoi(argv[8]), wide = strcmp(kind, "strnlen") != 0, bounded = strcmp(kind, "wcslen") != 0;
    uint32_t trap = argc > 10 ? (uint32_t)strtoul(argv[10], 0, 0) : 0;
    size_t cap = 1 << 18;
    uint8_t *buf = aligned_alloc(4096, cap);
    volatile uint32_t *ans = (volatile uint32_t *)(img + g);
    f2_t f = (f2_t)(img + fn);
    rs = strtoull(argv[9], 0, 0);
    if (!buf) return 2;
    if (trap) {
        struct sigaction sa;
        memset(&sa, 0, sizeof sa);
        sa.sa_handler = on_trap;
        sigaction(SIGTRAP, &sa, 0);
        uint8_t keep = img[trap];
        uint32_t vals[2] = { A, B };
        for (int k = 0; k < 2; k++) {
            uint8_t *p = make(buf, cap, wide, 1000, 3);
            *ans = vals[k];
            img[trap] = 0xCC;
            if (!sigsetjmp(jb, 1)) { f((uint64_t)p, 5000); printf("trap %u no\n", vals[k]); }
            else printf("trap %u yes\n", vals[k]);
            img[trap] = keep;
        }
    }
    int d = 0;
    for (int i = 0; i < n; i++) {
        size_t len = rnd() % (i % 7 == 0 ? 60000 : 300), off = rnd() % 64, mx = rnd() % 3 ? len + rnd() % 100 : rnd() % (len + 1);
        uint8_t *p = make(buf, cap, wide, len, off);
        *ans = A;
        uint64_t r1 = f((uint64_t)p, bounded ? mx : 0);
        *ans = B;
        uint64_t r2 = f((uint64_t)p, bounded ? mx : 0);
        if (r1 != r2) { if (d < 8) printf("diff len %zu off %zu max %zu: %llu %llu\n", len, off, mx, (unsigned long long)r1, (unsigned long long)r2); d++; }
    }
    printf("inputs %d differ %d\n", n, d);
    return 0;
}

int main(int argc, char **argv)
{
    if (argc >= 10 && !strcmp(argv[2], "--path")) return path(pe_map(argv[1]), argc, argv);
    if (argc != 4) { fprintf(stderr, "usage: see the file header\n"); return 2; }
    uint8_t *img = pe_map(argv[1]);
    for (char *s = argv[2]; *s;) {
        uint32_t fn = (uint32_t)strtoul(s, &s, 0);
        ((init_t)(img + fn))();
        if (*s == ',') s++;
    }
    for (char *s = argv[3]; *s;) {
        uint32_t g = (uint32_t)strtoul(s, &s, 0);
        printf("%x=%u\n", g, *(uint32_t *)(img + g));
        if (*s == ',') s++;
    }
    return 0;
}
