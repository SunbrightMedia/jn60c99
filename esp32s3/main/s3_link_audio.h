/* s3_link_audio.h -- O6 STEP 2: the AUDIO LINK on silicon.
 *
 * The decisions live in s3_link.h as pure, host-gated functions (s3_amix,
 * s3_bpace, the tap/injection slots). This file is the plumbing that carries
 * them: two I2S channels, a chunk CRC, and three small entry points the block
 * tail calls. Everything is role-conditional and inert on a lone board.
 *
 * FORMAT: std Philips stereo, 32-bit slots, f32 bits verbatim. One I2S frame
 * per sample: slot 0 = B's voice S3_LA_TAP0, slot 1 = S3_LA_TAP1. At SR with
 * 2x32 slots the link BCLK is 2.8224 MHz -- far inside spec for jumper wire.
 *
 * ⚠ THE INVARIANT GOVERNS EVERY PATH HERE:
 *   - A mixes NOTHING until the control channel has CRC-proven the audio
 *     wire (s3_amix). Unverified DMA content is garbage by assumption.
 *   - B never blocks on a clockless wire: its slave-TX write carries a
 *     timeout, and a timeout drops it back to its own crystal (s3_bpace).
 *   - A's own audio path never depends on the link at all.
 */
#ifndef JUNO_S3_LINK_AUDIO_H
#define JUNO_S3_LINK_AUDIO_H

#include "s3_link.h"
#include "driver/i2s_std.h"
#include "esp_heap_caps.h"

/* the same CRC the recall answer key uses -- one checksum dialect per repo.
 * The bitwise eb_devseq_crc32 costs ~60 cyc/byte; the sweep needs thousands
 * of windows, so a TABLE twin (identical dialect, ~8 cyc/byte) is built at
 * link start and PROVEN equal on a test vector before anything uses it. */
#include "eb_devseq.h"

static void s3_la_lock_task(void *arg);
static uint32_t la_crctab[256];
static int      la_crctab_ok;
static uint32_t la_crc32(const void *p, size_t n)
{
    const unsigned char *q = (const unsigned char *)p;
    uint32_t c = 0xFFFFFFFFu;
    size_t i;
    for (i = 0; i < n; ++i)
        c = (c >> 8) ^ la_crctab[(c ^ q[i]) & 0xFFu];
    return c ^ 0xFFFFFFFFu;
}
static int la_crc_init(void)
{
    uint32_t i, k, c;
    static const unsigned char tv[] = { 49,50,51,52,53,54,55,56,57 };
    for (i = 0; i < 256; ++i) {
        c = i;
        for (k = 0; k < 8; ++k)
            c = (c >> 1) ^ (0xEDB88320u & (uint32_t)(-(int32_t)(c & 1u)));
        la_crctab[i] = c;
    }
    /* the twin is not believed until it MATCHES the dialect it mirrors */
    la_crctab_ok = (la_crc32(tv, 9) == eb_devseq_crc32(tv, 9));
    return la_crctab_ok;
}

typedef struct {
    i2s_chan_handle_t ch;          /* A: master RX.  B: slave TX.           */
    int   up;                      /* channel created and enabled           */
    int   role;
    /* chip B */
    int   pace;                    /* S3_BPACE_*                            */
    uint32_t tx_blk;               /* chunks queued                         */
    uint32_t tx_crc;               /* CRC of the last NON-SILENT chunk      */
    uint32_t tx_crc_blk;           /*   ...and its index                    */
    uint32_t tx_timeouts;
    /* chip A */
    s3_amix  mix;
    uint32_t rx_chunks, rx_short, rx_match, rx_mismatch;
    uint32_t rx_crc[8];            /* CRCs of the last 8 received chunks    */
    int      rx_crc_n;
    /* ---- PHASE LOCK (defect paid on the first real wire, 2026-08-23) ----
     * I2S is a CONTINUOUS stream: A's DMA chunk boundaries sit at a constant
     * but arbitrary slot offset from B's chunk boundaries, so the as-designed
     * chunk-CRC compare can NEVER match on silicon (the host gates fed
     * aligned buffers and could not see this). The offset is constant
     * because one bit clock drives both framings, so it is found ONCE:
     * search the received stream for a 512-slot window whose CRC equals a
     * CRC B advertised, then discard `off` slots so every later chunk read
     * is B-aligned. Search cost is bounded to LOCK_BATCH windows per block
     * and only runs while unlocked (mix is closed then anyway). */
    int      locked;               /* 1 = A's reads are B-chunk-aligned     */
    int      lock_off;             /* slot offset the lock found (report)   */
    int      bit_shift;            /* serial bit-shift the lock found (0-31)*/
    int      half_swap;            /* 16-bit halves exchanged (I2S artifact) */
    uint32_t carry;                /* last RAW word read (bit-shift carry)  */
    uint32_t discard_left;         /* slots still to drop to re-frame       */
    uint32_t search_off;           /* next candidate slot offset (0..511)   */
    int      hist_n;               /* chunks in la_hist (need 2)            */
    uint32_t acrc_hist[8];         /* last 8 advertised CRCs from B         */
    int      acrc_n;
    /* pending adverts: an advert ALWAYS beats its chunk to A (the chunk is
     * still in B's 6-deep DMA when the UART frame lands), so the compare
     * runs chunk-against-recent-adverts, and only an advert no chunk
     * redeems within PEND_MAX chunks counts as a mismatch. */
    uint32_t pend[8];
    uint16_t pend_age[8];
    uint8_t  pend_used[8];
    uint32_t relock_miss;          /* post-lock mismatch streak -> re-lock  */
    uint32_t pat_disc;             /* pattern discontinuities seen (diag)   */
    uint32_t rx_dropped;           /* whole chunks skipped by the drain     */
    int      probe_lag, probe_delta, probe_have; /* last probe result (diag) */
} s3_la;

static s3_la LA;

#define PEND_MAX 32   /* chunks an advert may wait for its audio */
/* one chunk of link frames, assembled/disassembled off the DMA */
static int32_t la_buf[2 /*slots*/ * 256 /*>=CHUNK*/];
/* chip A only: the last TWO received chunks, for the phase-lock search */
static int32_t la_hist[2 * 2 * 256];
/* ---- THE SEARCH RUNS OFF THE AUDIO PATH (second bench defect, same day) --
 * The first cut CRC'd 8 candidate windows in the block tail: ~800k cyc/block,
 * quiet blocks 6.2 -> 9.3 ms against the 5.8 ms period -- the INVARIANT
 * broken by its own diagnostic. Worse, the overruns overflow A's RX DMA,
 * the stream SLIPS, and the just-found offset is invalid: lock, 32 misses,
 * unlock, forever. So the audio side only SNAPSHOTS (one 4 KB copy) and the
 * full 512-window sweep runs in the console task, which has no deadline.
 * snap_state: 0 = audio may fill, 1 = filled (search owns it), 2 = result. */
static int32_t  la_snap[2 * 2 * 256];
static uint32_t la_snap_acrc[8];
static int      la_snap_nacrc;
static volatile int la_snap_state;
static volatile int la_snap_off;
static volatile int la_snap_shift;
static volatile int la_snap_swap;
/* the WHY probe: when an advert ages out unredeemed, the lock task searches
 * the raw received stream (last 4 chunks) at chunk lags 0..3 and word deltas
 * -32..+32 for a window matching that CRC, and reports where the advertised
 * chunk ACTUALLY lives. One line that ends the guessing. */
static int32_t *la_rawhist;            /* 4 chunks, PSRAM                   */
static volatile uint32_t la_probe_crc; /* aged-out advert awaiting a probe  */
static volatile int      la_probe_req;
/* console-task scratch for the bit-shift-recovered candidate stream.
 * PSRAM: it is touched only by the deadline-free sweep, and internal DRAM
 * is 224 bytes from full -- allocated at link start, chip A only. */
static int32_t *la_swp;
static int32_t *la_swp2;

static int s3_la_start(int role)
{
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG(
        I2S_NUM_AUTO, (role == S3_ROLE_A) ? I2S_ROLE_MASTER : I2S_ROLE_SLAVE);
    i2s_std_config_t sc = {
        .clk_cfg  = I2S_STD_CLK_DEFAULT_CONFIG(SR),
        .slot_cfg = I2S_STD_PHILIPS_SLOT_DEFAULT_CONFIG(
                        I2S_DATA_BIT_WIDTH_32BIT, I2S_SLOT_MODE_STEREO),
        .gpio_cfg = { .mclk = I2S_GPIO_UNUSED,
                      .bclk = S3_LINK_BCLK, .ws = S3_LINK_LRCK,
                      .dout = I2S_GPIO_UNUSED, .din = I2S_GPIO_UNUSED,
                      .invert_flags = {0, 0, 0} },
    };
    memset(&LA, 0, sizeof LA);
    LA.role = role;
    LA.pace = S3_BPACE_FREERUN;
    /* the DIRECTION table (d1_link_gate: every wire exactly one driver):
     * A clocks the link and RECEIVES; B is a slave that TRANSMITS. */
    if (role == S3_ROLE_A) sc.gpio_cfg.din  = S3_LINK_DATA;
    else                   sc.gpio_cfg.dout = S3_LINK_DATA;
    cc.dma_desc_num  = 6;
    cc.dma_frame_num = CHUNK;
    if (role == S3_ROLE_A) {
        if (i2s_new_channel(&cc, NULL, &LA.ch) != ESP_OK) return 0;
    } else {
        if (i2s_new_channel(&cc, &LA.ch, NULL) != ESP_OK) return 0;
    }
    if (i2s_channel_init_std_mode(LA.ch, &sc) != ESP_OK) return 0;
    if (i2s_channel_enable(LA.ch) != ESP_OK) return 0;
    if (role == S3_ROLE_A && !la_crc_init()) {
        printf("LKA: crc table twin DIVERGES from eb_devseq_crc32 -- no link\n");
        return 0;
    }
    if (role == S3_ROLE_A && !la_swp) {
        la_swp  = (int32_t *)heap_caps_malloc(2 * 2 * 256 * sizeof(int32_t),
                                              MALLOC_CAP_SPIRAM);
        la_swp2 = (int32_t *)heap_caps_malloc(2 * 2 * 256 * sizeof(int32_t),
                                              MALLOC_CAP_SPIRAM);
        la_rawhist = (int32_t *)heap_caps_malloc(8 * 2 * 256 * sizeof(int32_t),
                                                 MALLOC_CAP_SPIRAM);
        if (!la_swp || !la_swp2 || !la_rawhist) return 0;
    }
    if (role == S3_ROLE_A)
        xTaskCreate(s3_la_lock_task, "lalock", 4096, NULL, 1, NULL);
    LA.up = 1;
    return 1;
}

/* ---- chip B: queue this chunk's two tapped voices; returns 1 if the
 * slave write TIMED OUT (A's clock is gone) so the caller can re-pace. ---- */
static uint32_t lb_pat_idx;      /* B's pattern stream counter (words)     */

static int s3_la_tx(float vb[][EB_NUM_VOICES], int n, int hs_ok)
{
    size_t want, wrote = 0;
    int i, silent = 1, tmo;
    if (!LA.up || LA.role != S3_ROLE_B) return 0;
    if (n > CHUNK) n = CHUNK;
    if (!LINK.peer_alock) {
        /* A is unlocked: send the self-describing TRAINING PATTERN instead
         * of audio (B has no DAC; A's mix is closed -- zero audible cost).
         * Chunk-aligned counter so A's alignment math is exact. */
        lb_pat_idx = (lb_pat_idx + 2u * (uint32_t)CHUNK - 1u)
                     & ~(2u * (uint32_t)CHUNK - 1u);
        for (i = 0; i < 2 * n; ++i)
            la_buf[i] = (int32_t)s3_pat_word(lb_pat_idx++);
        silent = 0;
    } else
    for (i = 0; i < n; ++i) {
        memcpy(&la_buf[2 * i],     &vb[i][S3_LA_TAP0], 4);
        memcpy(&la_buf[2 * i + 1], &vb[i][S3_LA_TAP1], 4);
        if (la_buf[2 * i] | la_buf[2 * i + 1]) silent = 0;
    }
    want = (size_t)n * 2u * sizeof(int32_t);
    /* LINKED paces here (A's clock drains it); FREERUN must not block on a
     * wire that may have no clock at all -- 0 ticks, drop what will not fit */
    tmo = (LA.pace == S3_BPACE_LINKED) ? pdMS_TO_TICKS(20) : 0;
    i2s_channel_write(LA.ch, la_buf, want, &wrote, tmo);
    ++LA.tx_blk;
    if (!silent && wrote == want) {
        /* only a NON-SILENT chunk may verify the wire: a grounded line also
         * reads all-zero, so a silent CRC would "prove" a dead wire good */
        LA.tx_crc     = eb_devseq_crc32(la_buf, want);
        LA.tx_crc_blk = LA.tx_blk;
    }
    tmo = (LA.pace == S3_BPACE_LINKED && wrote < want);
    if (tmo) ++LA.tx_timeouts;
    LA.pace = s3_bpace_step(LA.pace, LA.role, hs_ok, tmo);
    return tmo;
}

/* ---- chip A: drain one chunk if available; inject ONLY through the mix
 * gate. vb is the chunk core 0 just finished -- slots INJ0/INJ1 are free. -- */
static void s3_la_rx_inject(float vb[][EB_NUM_VOICES], int n,
                            int hs_ok, uint32_t peer_acrc, int fresh_acrc)
{
    size_t got = 0;
    int i, match = 0, mismatch = 0, got_chunk = 0;
    if (!LA.up || LA.role != S3_ROLE_A) return;
    if (n > CHUNK) n = CHUNK;
    /* phase re-frame: drop the slots between A's DMA framing and B's chunk
     * framing (found by the lock search below). Must complete before the
     * next full-chunk read; a partial drop just resumes next block. */
    if (LA.discard_left) {
        size_t g = 0;
        i2s_channel_read(LA.ch, la_buf,
                         LA.discard_left * sizeof(int32_t), &g, 0);
        if (g >= sizeof(int32_t))            /* bit-shift carry follows the */
            LA.carry = (uint32_t)la_buf[g / sizeof(int32_t) - 1];  /* stream */
        LA.discard_left -= (uint32_t)(g / sizeof(int32_t));
        if (LA.discard_left) return;         /* not re-framed yet */
    }
    /* DRAIN TO LATEST: when A ran late, more than one chunk waits in the
     * DMA. Reading only one lets the queue overflow and drop WORDS, which
     * destroys the framing (the slip behind the mix flap). Draining drops
     * whole CHUNKS instead: framing preserved, one block of B's voices
     * gracefully skipped, the mix stays open. */
    {
        int drained = 0;
        size_t g;
        do {
            g = 0;
            if (i2s_channel_read(LA.ch, la_buf,
                                 (size_t)n * 2u * sizeof(int32_t), &g, 0) != ESP_OK
                || g != (size_t)n * 2u * sizeof(int32_t))
                break;
            got = g; ++drained;
        } while (drained < 4);
        if (drained > 1) LA.rx_dropped += (uint32_t)(drained - 1);
    }
    if (got == (size_t)n * 2u * sizeof(int32_t)) {
        got_chunk = 1;
        ++LA.rx_chunks;
        memmove(la_rawhist, la_rawhist + 2 * CHUNK,
                7 * 2 * CHUNK * sizeof(int32_t));
        memcpy(la_rawhist + 7 * 2 * CHUNK, la_buf,
               2 * CHUNK * sizeof(int32_t));
        /* bit-shift recovery (locked, shift != 0): rebuild the sender's
         * words in place from the raw stream + the carry word, THEN CRC.
         * The raw last word becomes the next chunk's carry. */
        if (LA.locked && LA.half_swap)
            s3_halfswap((uint32_t *)la_buf, (const uint32_t *)la_buf, 2 * n);
        if (LA.locked && LA.bit_shift) {
            /* carry is kept in the SWAPPED domain, matching the sweep */
            uint32_t rawlast = (uint32_t)la_buf[2 * n - 1];
            s3_bitshift_recover((uint32_t *)la_buf, (const uint32_t *)la_buf,
                                2 * n, LA.bit_shift, LA.carry);
            LA.carry = rawlast;
        } else {
            LA.carry = (uint32_t)la_buf[2 * n - 1];
        }
        LA.rx_crc[LA.rx_crc_n++ & 7] =
            la_crc32(la_buf, got);
        /* THE PATTERN LOCK: while unlocked, B sends tagged counter words.
         * One clean chunk gives the alignment with no search at all. */
        if (!LA.locked) {
            uint32_t idx0; int disc;
            if (s3_pat_scan((const uint32_t *)la_buf, 2 * n, &idx0, &disc)) {
                uint32_t m = idx0 & (2u * (uint32_t)CHUNK - 1u);
                LA.locked = 1;
                LA.lock_off = (int)m;
                LA.bit_shift = 0; LA.half_swap = 0;
                LA.discard_left = (2u * (uint32_t)CHUNK - m)
                                  & (2u * (uint32_t)CHUNK - 1u);
                LA.rx_crc_n = 0;      /* pattern CRCs must not seed audio */
            } else {
                LA.pat_disc += (uint32_t)disc;
            }
        }
    } else if (got) {
        ++LA.rx_short;   /* partial chunks are dropped, never injected      */
    }
    if (fresh_acrc && peer_acrc) {
        int k, free_k = -1;
        LA.acrc_hist[LA.acrc_n++ & 7] = peer_acrc;
        for (k = 0; k < 8; ++k) if (!LA.pend_used[k]) { free_k = k; break; }
        if (free_k < 0) {                    /* evict the oldest, count it bad */
            int old_k = 0;
            for (k = 1; k < 8; ++k)
                if (LA.pend_age[k] > LA.pend_age[old_k]) old_k = k;
            LA.pend_used[old_k] = 0; ++LA.rx_mismatch; free_k = old_k;
        }
        LA.pend[free_k] = peer_acrc; LA.pend_age[free_k] = 0;
        LA.pend_used[free_k] = 1;
    }
    /* every received AUDIO chunk tries to redeem a pending advert; adverts
     * that age out unredeemed are the mismatches. Pattern chunks and the
     * unlocked state leave the pending set untouched. */
    s3_link_alock = LA.locked;       /* B reads this and switches to audio */
    /* a PATTERN chunk must never redeem an advert or feed the mix gate --
     * B also advertises pattern-chunk CRCs, and a pattern match would open
     * the mix onto the training signal itself. */
    if (got_chunk &&
        ((uint32_t)la_buf[0] & S3_PAT_MASK) == S3_PAT_TAG &&
        ((uint32_t)la_buf[1] & S3_PAT_MASK) == S3_PAT_TAG)
        got_chunk = 0;
    if (got_chunk && LA.locked) {
        uint32_t c = LA.rx_crc[(LA.rx_crc_n - 1) & 7];
        int k;
        for (k = 0; k < 8; ++k)
            if (LA.pend_used[k] && LA.pend[k] == c) {
                LA.pend_used[k] = 0;
                match = 1; ++LA.rx_match; LA.relock_miss = 0;
                break;
            }
        for (k = 0; k < 8; ++k)
            if (LA.pend_used[k] && LA.pend_age[k] == 10 && !la_probe_req) {
                la_probe_crc = LA.pend[k]; la_probe_req = 1;
            }
        for (k = 0; k < 8; ++k)
            if (LA.pend_used[k] && ++LA.pend_age[k] > PEND_MAX) {
                LA.pend_used[k] = 0;
                mismatch = 1; ++LA.rx_mismatch;
                /* a lock that stops redeeming adverts is stale (a word
                 * slipped): drop it and retrain -- one pattern chunk. */
                if (++LA.relock_miss >= 8) {
                    LA.locked = 0; LA.relock_miss = 0;
                    LA.rx_crc_n = 0;
                    memset(LA.pend_used, 0, sizeof LA.pend_used);
                }
            }
    }
    if (s3_amix_step(&LA.mix, hs_ok, got_chunk, match, mismatch) && got_chunk) {
        for (i = 0; i < n; ++i) {
            memcpy(&vb[i][S3_LA_INJ0], &la_buf[2 * i],     4);
            memcpy(&vb[i][S3_LA_INJ1], &la_buf[2 * i + 1], 4);
        }
    } else if (got_chunk) {
        /* the gate is CLOSED: the received bytes are dropped and the slots
         * stay exactly what A rendered -- silence on a 2-voice build */
        for (i = 0; i < n; ++i) {
            vb[i][S3_LA_INJ0] = 0.0f;
            vb[i][S3_LA_INJ1] = 0.0f;
        }
    }
}

/* the console-task half of the phase lock: the full 512-window sweep over the
 * frozen snapshot. ~40 ms of CPU with no deadline anywhere near it. Called
 * wherever s3_la_report is (the status task); a miss just re-arms -- the
 * advertised chunk was not one of the two snapshotted, try the next pair. */
static void s3_la_lock_sweep(void)
{
    int sw, sh, off = -1, hit_shift = 0, hit_swap = 0;
    if (LA.role != S3_ROLE_A || la_snap_state != 1) return;
    for (sw = 0; sw < 2 && off < 0; ++sw) {
        const int32_t *base = la_snap;
        if (sw) {
            s3_halfswap((uint32_t *)la_swp, (const uint32_t *)la_snap,
                        2 * 2 * CHUNK);
            base = la_swp;
        }
        for (sh = 0; sh < 32 && off < 0; ++sh) {
            uint32_t search = 0;
            if (sh == 0) {
                off = s3_lock_search(base, 2 * CHUNK,
                                     la_snap_acrc, la_snap_nacrc,
                                     &search, 2 * CHUNK, la_crc32);
            } else {
                s3_bitshift_recover((uint32_t *)la_swp2, (const uint32_t *)base,
                                    2 * 2 * CHUNK, sh, 0);
                off = s3_lock_search(la_swp2 + 1, 2 * CHUNK,
                                     la_snap_acrc, la_snap_nacrc,
                                     &search, 2 * CHUNK, la_crc32);
                if (off >= 0) off = (off + 1) & (2 * CHUNK - 1);
            }
            if (off >= 0) { hit_shift = sh; hit_swap = sw; }
            vTaskDelay(1);        /* console task: stay off any watchdog */
        }
    }
    la_snap_off   = off;
    la_snap_shift = hit_shift;
    la_snap_swap  = hit_swap;
    la_snap_state = 2;
}

/* Sweep task: priority 1, runs whenever a snapshot is armed. The first cut
 * ran the sweep in the CONSOLE task with the bitwise CRC -- ~14 s per pass,
 * which STARVED every status print (chip A went mute after boot: third
 * bench defect of the day). Its own task + the table CRC (~10 ms/pass)
 * ends both. */
static void s3_la_probe(void)
{
    int lag, d;
    uint32_t want;
    if (!la_probe_req) return;
    want = la_probe_crc;
    for (lag = 0; lag < 7; ++lag)
        for (d = -32; d <= 32; ++d) {
            int base = (7 - lag) * 2 * CHUNK - 2 * CHUNK + d;
            if (base < 0 || base + 2 * CHUNK > 8 * 2 * CHUNK) continue;
            if (la_crc32(la_rawhist + base, 2u * CHUNK * sizeof(int32_t)) == want) {
                LA.probe_lag = lag; LA.probe_delta = d; LA.probe_have = 1;
                la_probe_req = 0;
                return;
            }
        }
    LA.probe_lag = -1; LA.probe_delta = 0; LA.probe_have = 1;
    la_probe_req = 0;
}

static void s3_la_lock_task(void *arg)
{
    (void)arg;
    for (;;) {
        s3_la_lock_sweep();
        s3_la_probe();
        vTaskDelay(pdMS_TO_TICKS(50));
    }
}

static void s3_la_lock_bg(void)
{
    /* kept for the console call site; the dedicated task does the work */
}

static void s3_la_report(void)
{
    if (!LA.up) return;
    if (LA.role == S3_ROLE_A)
        printf("LKA: drop=%lu\n", (unsigned long)LA.rx_dropped),
        printf("LKA: mix=%s rx=%lu short=%lu crc ok=%lu bad=%lu lock=%s off=%d\n",
               LA.mix.st == S3_AMIX_OPEN ? "OPEN" : "closed",
               (unsigned long)LA.rx_chunks, (unsigned long)LA.rx_short,
               (unsigned long)LA.rx_match, (unsigned long)LA.rx_mismatch,
               LA.locked ? "YES" : "searching", LA.lock_off);
    if (LA.role == S3_ROLE_A && LA.locked && (LA.bit_shift || LA.half_swap))
        printf("LKA: corrected in software: bit-shift %d half-swap %d\n",
               LA.bit_shift, LA.half_swap);
    if (LA.role == S3_ROLE_A && LA.probe_have)
        printf(LA.probe_lag >= 0
               ? "LKAprobe: advert found at lag=%d delta=%+d words\n"
               : "LKAprobe: advert NOT in stream (lag=%d d=%d) -- content differs\n",
               LA.probe_lag, LA.probe_delta);
    if (LA.role == S3_ROLE_A && !LA.locked)
        printf("LKA: pattern discontinuities %lu\n", (unsigned long)LA.pat_disc);
    if (LA.role == S3_ROLE_A && !LA.locked)
        printf("LKAraw: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",
               (unsigned long)la_snap[0], (unsigned long)la_snap[1],
               (unsigned long)la_snap[2], (unsigned long)la_snap[3],
               (unsigned long)la_snap[4], (unsigned long)la_snap[5],
               (unsigned long)la_snap[6], (unsigned long)la_snap[7]);
    if (LA.role == S3_ROLE_B)
        printf("LKBraw: %08lx %08lx %08lx %08lx  crc %08lx blk %lu\n",
               (unsigned long)la_buf[0], (unsigned long)la_buf[1],
               (unsigned long)la_buf[2], (unsigned long)la_buf[3],
               (unsigned long)LA.tx_crc, (unsigned long)LA.tx_crc_blk);
    else
        printf("LKA: pace=%s tx=%lu timeouts=%lu\n",
               LA.pace == S3_BPACE_LINKED ? "LINKED(A's clock)" : "freerun",
               (unsigned long)LA.tx_blk, (unsigned long)LA.tx_timeouts);
}

#endif /* JUNO_S3_LINK_AUDIO_H */
