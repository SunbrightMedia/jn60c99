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

/* ---- bit-shift algebra: serialize MSB-first, sample s bits late, recover
 * with s3_bitshift_recover, and require the recovered stream to byte-match
 * the sender's for every s in 1..31 (with the correct one-word carry). */
static int run_shift(int s)
{
    enum { NW = 4096 };
    static uint32_t src[NW], late[NW], rec[NW];
    int i;
    for (i = 0; i < NW; ++i) src[i] = (uint32_t)prand();
    for (i = 0; i < NW - 1; ++i)                 /* A samples s bits late */
        late[i] = (src[i] << s) | (src[i + 1] >> (32 - s));
    late[NW - 1] = src[NW - 1] << s;
    s3_bitshift_recover(rec + 1, late + 1, NW - 2, s, late[0]);
    for (i = 1; i < NW - 1; ++i)
        if (rec[i] != src[i]) {
            printf("shift %d: word %d recovered 0x%08x want 0x%08x\n",
                   s, i, rec[i], src[i]);
            return 1;
        }
    return 0;
}

static int run_halfswap(void)
{
    enum { NW = 1024 };
    static uint32_t src[NW], sw[NW], back[NW];
    int i;
    for (i = 0; i < NW; ++i) src[i] = (uint32_t)prand();
    s3_halfswap(sw, src, NW);
    s3_halfswap(back, sw, NW);       /* self-inverse */
    for (i = 0; i < NW; ++i) {
        if (back[i] != src[i]) { printf("halfswap not self-inverse @%d\n", i); return 1; }
        if (sw[i] != ((src[i] << 16) | (src[i] >> 16))) { printf("halfswap wrong @%d\n", i); return 1; }
    }
    return 0;
}

/* ---- the training pattern: any window of a pattern stream yields the
 * exact alignment; one corrupted word is seen (tooth inside). */
static int run_pattern(void)
{
    enum { NW = 4096, W = 512 };
    static uint32_t stream[NW], win[W];
    uint32_t idx0; int disc, off, i;
    for (i = 0; i < NW; ++i) stream[i] = s3_pat_word((uint32_t)i + 7u * W);
    for (off = 0; off < W; ++off) {
        memcpy(win, stream + off, W * sizeof(uint32_t));
        if (!s3_pat_scan(win, W, &idx0, &disc) || disc != 0) {
            printf("pattern off %d: clean scan FAILED\n", off); return 1;
        }
        if ((int)(idx0 % W) != (off % W)) {
            printf("pattern off %d: alignment %u wrong\n", off, idx0 % W); return 1;
        }
    }
    /* tooth: one corrupt word must fail the scan and count a break */
    memcpy(win, stream + 100, W * sizeof(uint32_t));
    win[W / 2] ^= 0x00010000u;
    if (s3_pat_scan(win, W, &idx0, &disc) || disc < 1) {
        printf("pattern tooth NOT CAUGHT\n"); return 1;
    }
    return 0;
}

int main(void)
{
    int off, s, fails = 0;
    for (off = 0; off < WIN; ++off) fails += run_offset(off);
    printf("lock_search gate: %d/%d offsets PASS\n", WIN - fails, WIN);
    for (s = 1; s < 32; ++s) fails += run_shift(s);
    printf("bitshift recover: 31 shifts checked\n");
    fails += run_halfswap();
    printf("halfswap: self-inverse + exact\n");
    fails += run_pattern();
    printf("pattern: 512 alignments exact, corrupt-word tooth caught\n");
    if (fails) { printf("LOCK GATE: RED\n"); return 1; }
    printf("LOCK GATE: GREEN\n");
    return 0;
}
