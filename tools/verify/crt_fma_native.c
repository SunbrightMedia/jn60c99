/* crt_fma_native.c -- a plugin's OWN statically linked CRT math function, run NATIVELY on this CPU, once with
 * the CRT's FMA3 flag clear (the SSE2 code Unicorn runs) and once with it set (the FMA3 code the plugin runs on
 * a CPU with FMA3 + AVX: its CRT init sets the flag at load). Driven by tools/verify/crt_fma_gate.py.
 *
 * The PE image is mapped at its preferred base (no relocation: the math code addresses its constants and
 * tables RIP-relative); each error-handler address given is replaced by `ret` (the error path returns its
 * xmm0 -- both paths call it for the same inputs, so the compare still holds). The function is called through
 * an ms_abi pointer (the plugin's calling convention).
 *
 *   crt_fma_native PE ff FN FLAG HANDLERS LO HI    float -> float, every input bit pattern in [LO, HI]
 *   crt_fma_native PE df FN FLAG HANDLERS LO HI    (double)float -> double, every float bit pattern in [LO, HI]
 *   crt_fma_native PE dl FN FLAG HANDLERS D1 [D2 ..]  double -> double, the listed double bit patterns
 * prints `inputs N differ D` (ff: the first 64 differing inputs as `diff X SSE2 FMA3`; df / dl: `maxabs M`),
 * or `flag-dead` when setting the flag does not change the path (the function never read it). */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <sys/mman.h>

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

typedef float (__attribute__((ms_abi)) *ff_t)(float);
typedef double (__attribute__((ms_abi)) *dd_t)(double);

int main(int argc, char **argv)
{
    if (argc < 7) { fprintf(stderr, "usage: see the file header\n"); return 2; }
    uint8_t *img = pe_map(argv[1]);
    const char *mode = argv[2];
    uint32_t fn = (uint32_t)strtoul(argv[3], 0, 0), flag = (uint32_t)strtoul(argv[4], 0, 0);
    char *h = argv[5];
    while (h && *h) { img[strtoul(h, &h, 0)] = 0xC3; if (*h == ',') h++; }
    volatile uint32_t *fl = (volatile uint32_t *)(img + flag);
    uint64_t n = 0, nd = 0;
    double maxabs = 0;
    if (!strcmp(mode, "ff")) {
        ff_t f = (ff_t)(img + fn);
        uint64_t lo = strtoull(argv[6], 0, 0), hi = strtoull(argv[7], 0, 0);
        for (uint64_t u = lo; u <= hi; u++) {
            uint32_t b = (uint32_t)u, ua, uc;
            float x, a, c;
            memcpy(&x, &b, 4);
            *fl = 0; a = f(x);
            *fl = 1; c = f(x);
            memcpy(&ua, &a, 4); memcpy(&uc, &c, 4);
            n++;
            if (ua != uc) { if (nd < 64) printf("diff %08X %08X %08X\n", b, ua, uc); nd++; }
        }
    } else if (!strcmp(mode, "df") || !strcmp(mode, "dl")) {
        dd_t f = (dd_t)(img + fn);
        uint64_t lo = 0, hi = 0;
        int list = !strcmp(mode, "dl");
        if (!list) { lo = strtoull(argv[6], 0, 0); hi = strtoull(argv[7], 0, 0); }
        for (uint64_t k = list ? 6 : lo; list ? k < (uint64_t)argc : k <= hi; k++) {
            double x, a, c;
            if (list) { uint64_t b = strtoull(argv[k], 0, 16); memcpy(&x, &b, 8); }
            else { uint32_t b = (uint32_t)k; float xf; memcpy(&xf, &b, 4); x = xf; }
            *fl = 0; a = f(x);
            *fl = 1; c = f(x);
            n++;
            if (memcmp(&a, &c, 8)) { nd++; if (fabs(a - c) > maxabs) maxabs = fabs(a - c); }
        }
        printf("maxabs %.17g\n", maxabs);
    } else { fprintf(stderr, "unknown mode %s\n", mode); return 2; }
    printf("inputs %llu differ %llu\n", (unsigned long long)n, (unsigned long long)nd);
    return 0;
}
