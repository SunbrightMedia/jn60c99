/* s3_chain_link.h -- CHAIN4 on silicon: the per-hop control + audio ports.
 *
 * Design: docs/engineb/CHAIN4.md (binding). Law: s3_chain.h, proven EXACTLY 0
 * by tools/engineb/chain_gate.sh BEFORE this file existed. Every hop is one
 * instance of the O6 pairwise machinery (announce frames, CRC-proven mix
 * gate, training-pattern lock, slave-TX pacing) -- re-plumbed per PORT
 * instead of per CHIP, because a middle chip is the A-side of one hop and
 * the B-side of the other at the same time.
 *
 * WHAT IS DELIBERATELY CUT from the pairwise code (stated, not slipped):
 *  - the CRC sweep / bit-shift / half-swap fallback lock. The training
 *    pattern is the lock that actually locked on the bench; if a hop's raw
 *    words arrive transformed, pat_disc counts it and LKraw prints it --
 *    diagnosable, and the fallback can be ported then.
 *  - the aged-advert probe. Same reason: diagnostic, not path.
 *
 * PORTS (identical pin map on all four chips; position decides which exist):
 *   UP   (away from the DAC; this chip is the hop's A-side, MASTER RX):
 *        TDM4 BCLK 10  LRCK 11  DATA 12; control TX 13 RX 14
 *        (UART2 on pos 1 -- UART1 there is MIDI; UART1 on pos 2/3)
 *   DOWN (toward the DAC; this chip is the hop's B-side, SLAVE TX):
 *        TDM4 BCLK 15  LRCK 16  DATA 17; control TX 8 RX 9 (UART2)
 *   Hop wiring, N=2,3,4:  N.15<-(N-1).10  N.16<-(N-1).11  N.17->(N-1).12
 *                         N.8->(N-1).14   N.9<-(N-1).13   + ground.
 *
 * THE EVENT CHAIN: only pos 1 has inputs. Every note it accepts is mirrored
 * up the chain as a 9-byte 'J','E' frame; pos 2/3 apply AND re-forward.
 * A sequence gap is COUNTED, printed, and answered with all-notes-off from
 * the local held map -- a desynced allocator resyncs, it does not play a
 * wrong chord forever.
 */
#ifndef JUNO_S3_CHAIN_LINK_H
#define JUNO_S3_CHAIN_LINK_H

#include "s3_chain.h"
#include "s3_link.h"            /* pure: frame codec, pattern, amix, bpace */
#include "driver/uart.h"
#include "driver/i2s_tdm.h"
#include "esp_heap_caps.h"
#include "esp_timer.h"

#ifndef S3_CHAIN_POS
#error "a CHAIN build must say which position it is: -DS3_CHAIN_POS=1..4"
#endif
#if S3_CHAIN_POS < 1 || S3_CHAIN_POS > 4
#error "S3_CHAIN_POS must be 1..4 (1 = the DAC end)"
#endif

#define S3C_HAS_UP   (S3_CHAIN_POS < 4)
#define S3C_HAS_DOWN (S3_CHAIN_POS > 1)

/* ---- pins (see the header comment; identical on all chips) -------------- */
#define S3C_UP_BCLK 10
#define S3C_UP_LRCK 11
#define S3C_UP_DATA 12
#define S3C_UP_TX   13
#define S3C_UP_RX   14
#define S3C_DN_BCLK 15
#define S3C_DN_LRCK 16
#define S3C_DN_DATA 17
#define S3C_DN_TX   8
#define S3C_DN_RX   9
#define LINK_BAUD_CHAIN 115200
#if S3_CHAIN_POS == 1
#define S3C_UP_UART UART_NUM_2      /* UART1 is MIDI on pos 1 */
#else
#define S3C_UP_UART UART_NUM_1      /* no MIDI on pos 2..4    */
#define S3C_DN_UART UART_NUM_2
#endif

/* ---- the event frame (fixed 9 bytes, NO padding -- the codec lesson) ---- */
#define S3C_EV_MAGIC1 0x45u         /* 'J','E' */
enum { S3C_EV_OFF = 0, S3C_EV_ON = 1, S3C_EV_ALLOFF = 2 };
typedef struct {
    uint8_t m0, m1, kind, note, vel, seq0, seq1, sum0, sum1;
} s3c_ev;
typedef char s3c_ev_is_9[(sizeof(s3c_ev) == 9) ? 1 : -1];
static uint16_t s3c_ev_sum(const s3c_ev *e)
{
    const uint8_t *p = (const uint8_t *)e;
    uint16_t s = 0; int i;
    for (i = 0; i < 7; ++i) s = (uint16_t)(s + p[i] * 31u + 7u);
    return s;
}

/* ---- one control port --------------------------------------------------- */
typedef struct {
    int started;
    uart_port_t u;
    int a_side;                 /* 1 = this end is the hop's DOWNSTREAM end */
    int my_lo, my_hi;           /* the window this end advertises           */
    s3_peer peer;
    int hs;
    int peer_alock;             /* A-side's lock flag, read by the B-side   */
    uint32_t peer_acrc, peer_ablk;
    int acrc_fresh, said;
    unsigned long sent, got, bad;
    int64_t last_tx_us;
    unsigned char rx[64];
    int rxn;
    /* event chain */
    uint16_t ev_seq_rx;
    int      ev_have_seq;
    unsigned long ev_got, ev_gap;
} s3c_ctl;

#if S3C_HAS_UP
static s3c_ctl C_UP;
#endif
#if S3C_HAS_DOWN
static s3c_ctl C_DN;
#endif
static uint16_t s3c_ev_seq_tx;
static uint32_t s3c_held[4];               /* notes THIS chip was told on */
static unsigned long s3c_ev_sent, s3c_ev_applied;

static int s3c_ctl_start(s3c_ctl *c, uart_port_t u, int tx, int rx,
                         int a_side, int lo, int hi)
{
    uart_config_t cfg = {
        .baud_rate  = LINK_BAUD_CHAIN,
        .data_bits  = UART_DATA_8_BITS,
        .parity     = UART_PARITY_DISABLE,
        .stop_bits  = UART_STOP_BITS_1,
        .flow_ctrl  = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };
    memset(c, 0, sizeof *c);
    c->u = u; c->a_side = a_side; c->my_lo = lo; c->my_hi = hi;
    c->hs = S3_HS_NO_PEER;
    if (uart_driver_install(u, 512, 512, 0, NULL, 0) != ESP_OK) return 0;
    if (uart_param_config(u, &cfg) != ESP_OK) return 0;
    if (uart_set_pin(u, tx, rx, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE)
        != ESP_OK) return 0;
    c->started = 1;
    return 1;
}

/* forward decl: the firmware provides these (they live in juno_s3_listen.c) */
static int  s3c_apply_event(int kind, int note, int vel);
static void s3c_patch_follow(int peer_patch);

static void s3c_ev_send_port(s3c_ctl *c, int kind, int note, int vel,
                             uint16_t seq)
{
    s3c_ev e;
    uint16_t s;
    if (!c || !c->started) return;
    e.m0 = S3_LINK_MAGIC0; e.m1 = S3C_EV_MAGIC1;
    e.kind = (uint8_t)kind; e.note = (uint8_t)note; e.vel = (uint8_t)vel;
    e.seq0 = (uint8_t)(seq & 0xFF); e.seq1 = (uint8_t)(seq >> 8);
    s = s3c_ev_sum(&e);
    e.sum0 = (uint8_t)(s & 0xFF); e.sum1 = (uint8_t)(s >> 8);
    uart_write_bytes(c->u, (const char *)&e, sizeof e);
}

/* pos 1 (and re-forwarders) call this: send one event UP the chain */
static void s3c_ev_send(int kind, int note, int vel)
{
#if S3C_HAS_UP
    s3c_ev_send_port(&C_UP, kind, note, vel, s3c_ev_seq_tx++);
    ++s3c_ev_sent;
#else
    (void)kind; (void)note; (void)vel;
#endif
}

static void s3c_all_off_local(void)
{
    int n;
    for (n = 0; n < 128; ++n)
        if (s3c_held[n >> 5] & (1u << (n & 31)))
            s3c_apply_event((3 << 4) | S3C_EV_OFF, n, 0);   /* src DIN */
    memset(s3c_held, 0, sizeof s3c_held);
}

static void s3c_ctl_poll(s3c_ctl *c, int my_patch, unsigned long my_crc,
                         uint32_t my_acrc, uint32_t my_ablk, int my_alock)
{
    int64_t now;
    int n;
    if (!c->started) return;
    now = esp_timer_get_time();
    if (now - c->last_tx_us > 100000) {
        s3_link_frame f;
        memset(&f, 0, sizeof f);
        f.m0 = S3_LINK_MAGIC0; f.m1 = S3_LINK_MAGIC1;
        f.role       = (unsigned char)(c->a_side ? S3_ROLE_A : S3_ROLE_B);
        f.voice_base = (unsigned char)c->my_lo;
        f.voices     = (unsigned char)(c->my_hi - c->my_lo);
        f.pad        = (unsigned char)my_alock;
        f.patch      = (unsigned short)my_patch;
        f.crc        = (uint32_t)my_crc;
        f.acrc       = my_acrc;
        f.ablk       = my_ablk;
        f.sum        = s3_link_sum(&f);
        uart_write_bytes(c->u, (const char *)&f, sizeof f);
        c->last_tx_us = now;
        ++c->sent;
    }
    n = uart_read_bytes(c->u, c->rx + c->rxn,
                        (int)(sizeof c->rx - (size_t)c->rxn), 0);
    if (n > 0) c->rxn += n;
    for (;;) {
        if (c->rxn >= 2 && c->rx[0] == S3_LINK_MAGIC0
            && c->rx[1] == S3C_EV_MAGIC1) {
            s3c_ev e;
            uint16_t s, seq;
            if (c->rxn < (int)sizeof e) break;
            memcpy(&e, c->rx, sizeof e);
            memmove(c->rx, c->rx + sizeof e,
                    (size_t)(c->rxn -= (int)sizeof e));
            s = (uint16_t)(e.sum0 | (e.sum1 << 8));
            if (s != s3c_ev_sum(&e)) { ++c->bad; continue; }
            seq = (uint16_t)(e.seq0 | (e.seq1 << 8));
            ++c->ev_got;
            if (c->ev_have_seq && seq != (uint16_t)(c->ev_seq_rx + 1)) {
                ++c->ev_gap;
                printf("EVCHAIN: *** SEQ GAP (%u -> %u) -- all notes off, "
                       "resync ***\n", c->ev_seq_rx, seq);
                s3c_all_off_local();
            }
            c->ev_seq_rx = seq; c->ev_have_seq = 1;
            if ((e.kind & 0xF) == S3C_EV_ALLOFF) s3c_all_off_local();
            else {
                s3c_apply_event(e.kind, e.note, e.vel);
                if ((e.kind & 0xF) == S3C_EV_ON)
                    s3c_held[e.note >> 5] |=  (1u << (e.note & 31));
                else
                    s3c_held[e.note >> 5] &= ~(1u << (e.note & 31));
            }
            ++s3c_ev_applied;
#if S3C_HAS_UP
            /* re-forward with OUR tx sequence: each hop keeps its own */
            s3c_ev_send(e.kind, e.note, e.vel);
#endif
            continue;
        }
        if (c->rxn >= (int)sizeof(s3_link_frame)
            && c->rx[0] == S3_LINK_MAGIC0 && c->rx[1] == S3_LINK_MAGIC1) {
            s3_link_frame f;
            memcpy(&f, c->rx, sizeof f);
            memmove(c->rx, c->rx + sizeof f,
                    (size_t)(c->rxn -= (int)sizeof f));
            if (f.sum != s3_link_sum(&f)) { ++c->bad; continue; }
            ++c->got;
            c->peer.present    = 1;
            c->peer.role       = f.role;
            c->peer.patch      = f.patch;
            c->peer.voice_base = f.voice_base;
            c->peer.voices     = f.voices;
            c->peer.crc        = f.crc;
            c->peer_alock      = f.pad;
            if (f.acrc != c->peer_acrc || f.ablk != c->peer_ablk) {
                c->peer_acrc = f.acrc; c->peer_ablk = f.ablk;
                c->acrc_fresh = 1;
            }
            /* the hop handshake: role opposite, same build+patch, and the
             * two windows tile -- the s3_chain_hop_check the gate toothed. */
            if ((c->a_side && f.role != S3_ROLE_B) ||
                (!c->a_side && f.role != S3_ROLE_A))
                c->hs = S3_HS_BAD_PAIR;
            else if (f.patch != my_patch)  c->hs = S3_HS_PATCH_DIFFERS;
            else if (f.crc != my_crc)      c->hs = S3_HS_CRC_DIFFERS;
            else if (c->a_side
                     ? s3_chain_hop_check(c->my_lo, c->my_hi,
                                          f.voice_base,
                                          f.voice_base + f.voices)
                     : s3_chain_hop_check(f.voice_base,
                                          f.voice_base + f.voices,
                                          c->my_lo, c->my_hi))
                c->hs = S3_HS_BASE_OVERLAP;
            else                           c->hs = S3_HS_OK;
            if (!c->said) {
                c->said = 1;
                printf("\nCHAIN(%s): PEER ANSWERED (hop %s) -- handshake %s\n",
                       c->a_side ? "up-port A" : "down-port B",
                       c->a_side ? "upstream" : "downstream",
                       s3_handshake_name(c->hs));
            }
            /* PATCH FOLLOW, one rule: the DOWNSTREAM side is truth. Our
             * B-side (down port) follows the peer; the A-side never does. */
            if (!c->a_side && c->peer.present && f.patch != my_patch)
                s3c_patch_follow(f.patch);
            continue;
        }
        if (c->rxn >= 2) {          /* junk byte: resync on the magic */
            memmove(c->rx, c->rx + 1, (size_t)(--c->rxn));
            ++c->bad;
            continue;
        }
        break;
    }
}

/* ==========================================================================
 * AUDIO: TDM4, one format on every hop (CHAIN4.md §3)
 * ========================================================================== */
#define S3C_SLOTW  (S3_CHAIN_SLOTS)                /* words per sample      */
#define S3C_CHW    (S3C_SLOTW * 256)               /* words per chunk >= CHUNK*4 */

typedef struct {
    i2s_chan_handle_t ch;
    int up;                      /* channel enabled                          */
    /* B-side (down TX) */
    int   pace;
    uint32_t tx_blk, tx_crc, tx_crc_blk, tx_timeouts;
    uint32_t pat_idx;
    /* A-side (up RX) */
    s3_amix mix;
    int locked, lock_off;
    uint32_t discard_left;
    uint32_t rx_chunks, rx_short, rx_match, rx_mismatch, rx_dropped, pat_disc;
    uint32_t pend[8]; uint16_t pend_age[8]; uint8_t pend_used[8];
    uint32_t relock_miss;
    uint32_t crc_last;
} s3c_aud;

#if S3C_HAS_UP
static s3c_aud A_UP;
static int32_t s3c_rxbuf[S3C_CHW];      /* the drained, aligned chunk       */
static int     s3c_rx_fresh;            /* a full audio chunk this block    */
#endif
#if S3C_HAS_DOWN
static s3c_aud A_DN;
static int32_t s3c_txbuf[S3C_CHW];
#endif

static int s3c_aud_start(s3c_aud *a, int master_rx,
                         int bclk, int lrck, int data)
{
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG(
        I2S_NUM_AUTO, master_rx ? I2S_ROLE_MASTER : I2S_ROLE_SLAVE);
    i2s_tdm_config_t tc = {
        .clk_cfg  = I2S_TDM_CLK_DEFAULT_CONFIG(SR),
        .slot_cfg = I2S_TDM_PHILIPS_SLOT_DEFAULT_CONFIG(
                        I2S_DATA_BIT_WIDTH_32BIT, I2S_SLOT_MODE_STEREO,
                        I2S_TDM_SLOT0 | I2S_TDM_SLOT1 |
                        I2S_TDM_SLOT2 | I2S_TDM_SLOT3),
        .gpio_cfg = { .mclk = I2S_GPIO_UNUSED,
                      .bclk = bclk, .ws = lrck,
                      .dout = I2S_GPIO_UNUSED, .din = I2S_GPIO_UNUSED,
                      .invert_flags = {0, 0, 0} },
    };
    memset(a, 0, sizeof *a);
    a->pace = S3_BPACE_FREERUN;
    if (master_rx) tc.gpio_cfg.din  = data;
    else           tc.gpio_cfg.dout = data;
    cc.dma_desc_num  = 6;
    cc.dma_frame_num = CHUNK;
    if (master_rx) {
        if (i2s_new_channel(&cc, NULL, &a->ch) != ESP_OK) return 0;
    } else {
        if (i2s_new_channel(&cc, &a->ch, NULL) != ESP_OK) return 0;
    }
    if (i2s_channel_init_tdm_mode(a->ch, &tc) != ESP_OK) return 0;
    if (i2s_channel_enable(a->ch) != ESP_OK) return 0;
    a->up = 1;
    return 1;
}

#if S3C_HAS_DOWN
/* B-side: queue this block's merged slots (already in s3c_txbuf), or the
 * training pattern while the downstream A is unlocked. Returns tx timeout. */
static int s3c_tx(int n, int hs_ok, int peer_alock)
{
    size_t want, wrote = 0;
    int i, silent = 1, tmo;
    if (!A_DN.up) return 0;
    if (n > CHUNK) n = CHUNK;
    if (!peer_alock) {
        A_DN.pat_idx = (A_DN.pat_idx + (uint32_t)S3C_SLOTW * CHUNK - 1u)
                       & ~((uint32_t)S3C_SLOTW * CHUNK - 1u);
        for (i = 0; i < S3C_SLOTW * n; ++i)
            s3c_txbuf[i] = (int32_t)s3_pat_word(A_DN.pat_idx++);
        silent = 0;
    } else {
        for (i = 0; i < S3C_SLOTW * n; ++i)
            if (s3c_txbuf[i]) { silent = 0; break; }
    }
    want = (size_t)n * S3C_SLOTW * sizeof(int32_t);
    tmo = (A_DN.pace == S3_BPACE_LINKED) ? pdMS_TO_TICKS(20) : 0;
    i2s_channel_write(A_DN.ch, s3c_txbuf, want, &wrote, tmo);
    ++A_DN.tx_blk;
    if (!silent && wrote == want) {
        A_DN.tx_crc     = eb_devseq_crc32(s3c_txbuf, want);
        A_DN.tx_crc_blk = A_DN.tx_blk;
    }
    tmo = (A_DN.pace == S3_BPACE_LINKED && wrote < want);
    if (tmo) ++A_DN.tx_timeouts;
    A_DN.pace = s3_bpace_step(A_DN.pace, S3_ROLE_B, hs_ok, tmo);
    return tmo;
}
#endif

#if S3C_HAS_UP
/* A-side: drain to latest, pattern-lock, redeem adverts, step the mix gate.
 * Leaves the latest aligned AUDIO chunk in s3c_rxbuf and returns 1 when the
 * mix gate is OPEN for it. */
static int s3c_rx(int n, int hs_ok, uint32_t peer_acrc, int fresh_acrc)
{
    size_t got = 0;
    int match = 0, mismatch = 0, got_chunk = 0, k;
    if (!A_UP.up) return 0;
    if (n > CHUNK) n = CHUNK;
    s3c_rx_fresh = 0;
    if (A_UP.discard_left) {
        size_t g = 0;
        uint32_t w = A_UP.discard_left;
        if (w > (uint32_t)S3C_CHW) w = (uint32_t)S3C_CHW;
        i2s_channel_read(A_UP.ch, s3c_rxbuf, w * sizeof(int32_t), &g, 0);
        A_UP.discard_left -= (uint32_t)(g / sizeof(int32_t));
        if (A_UP.discard_left) return 0;
    }
    {   int drained = 0;
        size_t g;
        do {
            g = 0;
            if (i2s_channel_read(A_UP.ch, s3c_rxbuf,
                                 (size_t)n * S3C_SLOTW * sizeof(int32_t),
                                 &g, 0) != ESP_OK
                || g != (size_t)n * S3C_SLOTW * sizeof(int32_t))
                break;
            got = g; ++drained;
        } while (drained < 4);
        if (drained > 1) A_UP.rx_dropped += (uint32_t)(drained - 1);
    }
    if (got == (size_t)n * S3C_SLOTW * sizeof(int32_t)) {
        got_chunk = 1;
        ++A_UP.rx_chunks;
        A_UP.crc_last = eb_devseq_crc32(s3c_rxbuf, got);
        if (!A_UP.locked) {
            uint32_t idx0; int disc;
            if (s3_pat_scan((const uint32_t *)s3c_rxbuf, S3C_SLOTW * n,
                            &idx0, &disc)) {
                uint32_t m = idx0 & ((uint32_t)S3C_SLOTW * CHUNK - 1u);
                A_UP.locked = 1;
                A_UP.lock_off = (int)m;
                A_UP.discard_left = ((uint32_t)S3C_SLOTW * CHUNK - m)
                                    & ((uint32_t)S3C_SLOTW * CHUNK - 1u);
            } else {
                A_UP.pat_disc += (uint32_t)disc;
            }
        }
    } else if (got) {
        ++A_UP.rx_short;
    }
    if (fresh_acrc && peer_acrc) {
        int free_k = -1;
        for (k = 0; k < 8; ++k) if (!A_UP.pend_used[k]) { free_k = k; break; }
        if (free_k < 0) {
            int old_k = 0;
            for (k = 1; k < 8; ++k)
                if (A_UP.pend_age[k] > A_UP.pend_age[old_k]) old_k = k;
            A_UP.pend_used[old_k] = 0; ++A_UP.rx_mismatch; free_k = old_k;
        }
        A_UP.pend[free_k] = peer_acrc; A_UP.pend_age[free_k] = 0;
        A_UP.pend_used[free_k] = 1;
    }
    /* a PATTERN chunk must never redeem an advert or feed the mix gate */
    if (got_chunk &&
        ((uint32_t)s3c_rxbuf[0] & S3_PAT_MASK) == S3_PAT_TAG &&
        ((uint32_t)s3c_rxbuf[1] & S3_PAT_MASK) == S3_PAT_TAG)
        got_chunk = 0;
    if (got_chunk && A_UP.locked) {
        uint32_t c = A_UP.crc_last;
        for (k = 0; k < 8; ++k)
            if (A_UP.pend_used[k] && A_UP.pend[k] == c) {
                A_UP.pend_used[k] = 0;
                match = 1; ++A_UP.rx_match; A_UP.relock_miss = 0;
                break;
            }
        for (k = 0; k < 8; ++k)
            if (A_UP.pend_used[k] && ++A_UP.pend_age[k] > 32) {
                A_UP.pend_used[k] = 0;
                mismatch = 1; ++A_UP.rx_mismatch;
                if (++A_UP.relock_miss >= 8) {
                    A_UP.locked = 0; A_UP.relock_miss = 0;
                    memset(A_UP.pend_used, 0, sizeof A_UP.pend_used);
                }
            }
    }
    s3c_rx_fresh = got_chunk;
    return s3_amix_step(&A_UP.mix, hs_ok, got_chunk, match, mismatch)
           && got_chunk;
}
#endif

static void s3c_report(void)
{
#if S3C_HAS_UP
    if (C_UP.started)
        printf("CHAINup: %s hs=%s rx=%lu ok=%lu bad=%lu drop=%lu %s%s "
               "pat_disc=%lu\n",
               A_UP.mix.st == S3_AMIX_OPEN ? "mix=OPEN" : "mix=closed",
               C_UP.peer.present ? s3_handshake_name(C_UP.hs) : "no peer yet",
               (unsigned long)A_UP.rx_chunks, (unsigned long)A_UP.rx_match,
               (unsigned long)A_UP.rx_mismatch, (unsigned long)A_UP.rx_dropped,
               A_UP.locked ? "lock=YES" : "lock=searching",
               "", (unsigned long)A_UP.pat_disc);
#endif
#if S3C_HAS_DOWN
    if (C_DN.started)
        printf("CHAINdn: pace=%s hs=%s tx=%lu timeouts=%lu ev_gap=%lu\n",
               A_DN.pace == S3_BPACE_LINKED ? "LINKED" : "freerun",
               C_DN.peer.present ? s3_handshake_name(C_DN.hs) : "no peer yet",
               (unsigned long)A_DN.tx_blk, (unsigned long)A_DN.tx_timeouts,
               (unsigned long)C_DN.ev_gap);
#endif
    printf("CHAINev: sent=%lu applied=%lu\n", s3c_ev_sent, s3c_ev_applied);
}

#endif /* JUNO_S3_CHAIN_LINK_H */
