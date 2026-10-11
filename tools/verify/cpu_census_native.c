/* cpu_census_native.c -- a plugin's own CPU questions asked of THIS CPU: its CRT inits (__isa_available_init, the
 * FMA3 init) run natively, and the globals they set printed. Driven by tools/verify/cpu_census.py (the answers a
 * real PC gives, beside the ones Unicorn gives and the image's static ones).
 *
 * The PE image is mapped at its preferred base (MAP_FIXED_NOREPLACE: the inits address their globals RIP-relative);
 * each init is called through an ms_abi pointer (the plugin's calling convention); neither calls an import.
 *   cpu_census_native PE INIT[,INIT..] GLOBAL[,GLOBAL..]     prints `addr=value` (addr hex, value decimal u32) */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
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

typedef uint64_t (__attribute__((ms_abi)) *init_t)(void);

int main(int argc, char **argv)
{
    if (argc != 4) { fprintf(stderr, "usage: cpu_census_native PE INIT[,INIT..] GLOBAL[,GLOBAL..]\n"); return 2; }
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
