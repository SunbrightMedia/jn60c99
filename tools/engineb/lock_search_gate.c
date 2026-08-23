/* lock_search_gate.c -- gate for s3_lock_search (the audio-link phase lock).
 *
 * THE DEFECT IT GUARDS (paid on the first real wire, 2026-08-23): A's DMA
 * chunk framing sits at a constant arbitrary slot offset from B's, so the
 * as-designed aligned chunk-CRC compare can never match on silicon. This
 * gate simulates exactly that: B emits chunks of a pseudo-random stream and
 * advertises their CRCs; A receives the SAME stream shifted by a constant
 * offset. PASS requires, for every offset 0..511:
 *   1. the OLD aligned compare finds zero matches for any nonzero offset
 *      (the defect is real and reproducible), and a match at offset 0;
 *   2. s3_lock_search finds the exact offset within one full sweep;
 *   3. after re-framing by the found offset, the aligned compare matches
 *      every subsequent chunk (the fix completes the original design).
 * TOOTH (compile with LOCK_TOOTH_OFFBYONE): the re-frame discards off+1
 * slots -- step 3 must then fail, proving the gate can see a wrong lock.
 *
 * usage: cc -std=c99 -O1 -I esp32s3/main lock_search_gate.c && ./a.out
 */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
/* the pure function under test, exactly as the firmware compiles it */
#include "s3_link.h"

/* s3_lock_search is CHECKSUM-AGNOSTIC by construction (the crc arrives as a
 * function pointer), so this gate supplies its own CRC32 rather than pulling
 * in the device-recall build (eb_devseq.c requires -DEB_DEVCELLS and the full
 * engine headers). The property gated -- framing alignment -- is independent
 * of the dialect; the firmware passes gate_crc32 at the same seam. */
static uint32_t gate_crc32(const void *p, size_t n)
{
    const unsigned char *b = (const unsigned char *)p;
    uint32_t c = 0xFFFFFFFFu; size_t i; int k;
    for (i = 0; i < n; ++i) {
        c ^= b[i];
        for (k = 0; k < 8; ++k) c = (c >> 1) ^ (0xEDB88320u & (0u - (c & 1u)));
    }
    return ~c;
}

#define WIN   512                    /* slots per chunk (2 * CHUNK frames)  */
#define NCH   64                     /* chunks of stream simulated         */

static int32_t stream[(NCH + 2) * WIN];

static uint32_t rng = 0x2A2B2CD1u;
static int32_t prand(void) { rng = rng * 1664525u + 1013904223u; return (int32_t)rng; }

static int run_offset(int off)
{
    uint32_t acrc[NCH];
    int32_t hist[2 * WIN];
    uint32_t search = 0;
    int c, k, found = -1, old_matches = 0;

    for (c = 0; c < (NCH + 2) * WIN; ++c) stream[c] = prand();
    /* B's truth: CRC of each of ITS chunks */
    for (c = 0; c < NCH; ++c)
        acrc[c] = gate_crc32(stream + c * WIN, WIN * sizeof(int32_t));

    /* A receives the same stream but its framing starts `off` slots late */
    /* 1. OLD aligned compare: A's chunk c is stream[off + c*WIN ...) */
    for (c = 0; c < NCH; ++c) {
        uint32_t rc = gate_crc32(stream + off + c * WIN, WIN * sizeof(int32_t));
        for (k = 0; k < NCH; ++k) if (acrc[k] == rc) { ++old_matches; break; }
    }
    if (off == 0 && old_matches != NCH) {
        printf("off 0: OLD compare should match aligned, got %d/%d\n", old_matches, NCH);
        return 1;
    }
    if (off != 0 && old_matches != 0) {
        printf("off %d: OLD compare matched %d chunks on a SHIFTED stream\n", off, old_matches);
        return 1;
    }

    /* 2. the search: feed A's received chunks pairwise into hist */
    for (c = 0; c + 1 < NCH && found < 0; ++c) {
        memcpy(hist,       stream + off + c * WIN,       WIN * sizeof(int32_t));
        memcpy(hist + WIN, stream + off + (c + 1) * WIN, WIN * sizeof(int32_t));
        /* hist[0..WIN) is A-chunk c; B chunk c starts `WIN-off` in... search
         * the full candidate space in batches of 8 as the firmware does */
        int b;
        for (b = 0; b < WIN / 8 && found < 0; ++b)
            found = s3_lock_search(hist, WIN, acrc, NCH, &search, 8,
                                   gate_crc32);
    }
    if (found < 0) { printf("off %d: search never locked\n", off); return 1; }

    /* 3. re-frame by the FOUND offset and re-run the aligned compare */
    {
#ifdef LOCK_TOOTH_OFFBYONE
        int drop = found + 1;
#else
        int drop = found;
#endif
        /* compare only windows that are among B's NCH advertised chunks:
         * base + (c+1)*WIN <= NCH*WIN */
        int base = off + drop, ok = 0, total = 0;
        for (c = 0; base + (c + 1) * WIN <= NCH * WIN; ++c) {
            uint32_t rc = gate_crc32(stream + base + c * WIN,
                                          WIN * sizeof(int32_t));
            ++total;
            for (k = 0; k < NCH; ++k) if (acrc[k] == rc) { ++ok; break; }
        }
        if (ok != total) {
            printf("off %d: post-lock aligned compare %d/%d (found=%d)\n",
                   off, ok, total, found);
            return 1;
        }
    }
    return 0;
}

int main(void)
{
    int off, fails = 0;
    for (off = 0; off < WIN; ++off) fails += run_offset(off);
    printf("lock_search gate: %d/%d offsets PASS\n", WIN - fails, WIN);
    if (fails) { printf("LOCK GATE: RED\n"); return 1; }
    printf("LOCK GATE: GREEN\n");
    return 0;
}
