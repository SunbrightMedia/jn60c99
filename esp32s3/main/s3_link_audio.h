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

/* the same CRC the recall answer key uses -- one checksum dialect per repo */
#include "eb_devseq.h"

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
} s3_la;

static s3_la LA;

/* one chunk of link frames, assembled/disassembled off the DMA */
static int32_t la_buf[2 /*slots*/ * 256 /*>=CHUNK*/];

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
    LA.up = 1;
    return 1;
}

/* ---- chip B: queue this chunk's two tapped voices; returns 1 if the
 * slave write TIMED OUT (A's clock is gone) so the caller can re-pace. ---- */
static int s3_la_tx(float vb[][EB_NUM_VOICES], int n, int hs_ok)
{
    size_t want, wrote = 0;
    int i, silent = 1, tmo;
    if (!LA.up || LA.role != S3_ROLE_B) return 0;
    if (n > CHUNK) n = CHUNK;
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
    if (i2s_channel_read(LA.ch, la_buf,
                         (size_t)n * 2u * sizeof(int32_t), &got, 0) == ESP_OK
        && got == (size_t)n * 2u * sizeof(int32_t)) {
        got_chunk = 1;
        ++LA.rx_chunks;
        LA.rx_crc[LA.rx_crc_n++ & 7] =
            eb_devseq_crc32(la_buf, got);
    } else if (got) {
        ++LA.rx_short;   /* partial chunks are dropped, never injected      */
    }
    /* compare B's advertised CRC against the last 8 chunks A actually
     * received -- the two counters share no epoch, so the match is windowed */
    if (fresh_acrc && peer_acrc) {
        int k, hit = 0, lim = LA.rx_crc_n < 8 ? LA.rx_crc_n : 8;
        for (k = 0; k < lim; ++k) if (LA.rx_crc[k] == peer_acrc) hit = 1;
        if (hit) { match = 1; ++LA.rx_match; }
        else     { mismatch = 1; ++LA.rx_mismatch; }
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

static void s3_la_report(void)
{
    if (!LA.up) return;
    if (LA.role == S3_ROLE_A)
        printf("LKA: mix=%s rx=%lu short=%lu crc ok=%lu bad=%lu\n",
               LA.mix.st == S3_AMIX_OPEN ? "OPEN" : "closed",
               (unsigned long)LA.rx_chunks, (unsigned long)LA.rx_short,
               (unsigned long)LA.rx_match, (unsigned long)LA.rx_mismatch);
    else
        printf("LKA: pace=%s tx=%lu timeouts=%lu\n",
               LA.pace == S3_BPACE_LINKED ? "LINKED(A's clock)" : "freerun",
               (unsigned long)LA.tx_blk, (unsigned long)LA.tx_timeouts);
}

#endif /* JUNO_S3_LINK_AUDIO_H */
