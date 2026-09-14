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
 * PORTS (identical pin map on all four chips; position decides which exist;
 * the CARRIER map 2026-09-08 -- see the pin block below for the why):
 *   UP   (away from the DAC; this chip is the hop's A-side, MASTER RX):
 *        TDM4 BCLK 9  LRCK 10  DATA 11; control TX 46 RX 47
 *        (UART2 on pos 1 -- UART1 there is MIDI; UART1 on pos 2/3)
 *   DOWN (toward the DAC; this chip is the hop's B-side, SLAVE TX):
 *        TDM4 BCLK 15  LRCK 16  DATA 17; control TX 5 RX 6 (UART2)
 *   Hop wiring, N=2,3,4:  N.15<-(N-1).9   N.16<-(N-1).10  N.17->(N-1).11
 *                         N.5->(N-1).47   N.6<-(N-1).46   + ground.
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
#include "esp_rom_crc.h"        /* the CRCBENCH's third candidate */
#include "esp_timer.h"

#ifndef S3_CHAIN_POS
#error "a CHAIN build must say which position it is: -DS3_CHAIN_POS=1..4"
#endif
#if S3_CHAIN_POS < 1 || S3_CHAIN_POS > 4
#error "S3_CHAIN_POS must be 1..4 (1 = the DAC end)"
#endif

#define S3C_HAS_UP   (S3_CHAIN_POS < 4)
#define S3C_HAS_DOWN (S3_CHAIN_POS > 1)

/* ---- pins (identical on all chips) --------------------------------------
 * CARRIER MAP (2026-09-08, net-level audit of the drawn MasterAudio board):
 * UP audio RX follows the board's LINK nets (IO9/10/11, socket rows
 * L15-L17), NOT the old bench map's 10/11/12. Control moved to the four
 * pins the carrier leaves unconnected on every slot: DOWN ctl TX/RX =
 * IO5/IO6 (rows L5/L6, DAC-only on slot 1, which has no DOWN port) and
 * UP ctl TX/RX = IO46/IO47 (rows L14/R17, NC everywhere). IO46 is a
 * strapping pin but only OUR OUTPUT drives it, and the peer's RX is
 * high-impedance at boot; the RX side (IO47) is not a strapping pin.
 * The EXT breakout pins (IO4,12,13,14,1,40,39,38) stay untouched. */
#define S3C_UP_BCLK 9
#define S3C_UP_LRCK 10
#define S3C_UP_DATA 11
#define S3C_UP_TX   46
#define S3C_UP_RX   47
#define S3C_DN_BCLK 15
#define S3C_DN_LRCK 16
#define S3C_DN_DATA 17
#define S3C_DN_TX   5
#define S3C_DN_RX   6
#define LINK_BAUD_CHAIN 115200
#if S3_CHAIN_POS == 1
#define S3C_UP_UART UART_NUM_2      /* UART1 is MIDI on pos 1 */
#else
#define S3C_UP_UART UART_NUM_1      /* no MIDI on pos 2..4    */
#define S3C_DN_UART UART_NUM_2
#endif

/* ---- the event frame (fixed 9 bytes, NO padding -- the codec lesson) ----
 * S3C_EV_PARAM reuses the note/vel bytes as pid/val: a knob on chip 1 must
 * move ALL SIX voices, and before this kind existed a chip-1 parameter edit
 * rebuilt chip 1's record only -- five voices kept the old cutoff. The pid
 * is the portable EB_PARAM_CLASS index (0..58, fits the byte) and val is
 * already 0..255. A mixed-build chain would misread kind 3 as a note-off,
 * so the four images must always be flashed AS A SET. */
#define S3C_EV_MAGIC1 0x45u         /* 'J','E' */
enum { S3C_EV_OFF = 0, S3C_EV_ON = 1, S3C_EV_ALLOFF = 2, S3C_EV_PARAM = 3 };
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
                /* the held map tracks NOTES only: a PARAM event's pid rides
                 * the note byte and must never clear a held bit there. */
                if ((e.kind & 0xF) == S3C_EV_ON)
                    s3c_held[e.note >> 5] |=  (1u << (e.note & 31));
                else if ((e.kind & 0xF) == S3C_EV_OFF)
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

/* THE TABLE CRC TWIN (the pairwise link's own lesson, re-paid on the first
 * chain flash 2026-09-03: the bitwise eb_devseq_crc32 is ~60 cyc/byte, and
 * running it over a 4 KB chunk on the block tail cost ~960 cyc/sample --
 * cyc read 6,343 against the 5,442 budget and the DAC starved. Same dialect,
 * ~8 cyc/byte, PROVEN equal on a test vector before anything trusts it. */
static uint32_t s3c_crctab[256];
static int      s3c_crctab_ok;
/* ⚠ SLICING-BY-4 REFUTED ON SILICON (2026-09-14, one flash after it
 * landed): the b45u log's POS2 -- whose ONLY change was the CRC swap --
 * read +177 cyc/sample; the dependency-chained four-table walk stalls
 * this in-order core worse than the byte loop it replaced, and the
 * predicted ~3x never existed outside the cycle model. The pure fast
 * law stays in s3_chain.h with its host equivalence gate as the record;
 * the DEVICE walks the byte table again. s3c_crc_bench() below prints
 * all three candidates (byte / slice / ROM) so the next choice is a
 * MEASUREMENT (playbook 46: a number quoted is not thereby measured). */
/* the byte-table reference twin, kept as the on-chip oracle the ROM
 * implementation is proven against at every boot */
static uint32_t s3c_crc32_byte(const void *p, size_t n)
{
    const unsigned char *q = (const unsigned char *)p;
    uint32_t c = 0xFFFFFFFFu;
    size_t i;
    for (i = 0; i < n; ++i)
        c = (c >> 8) ^ s3c_crctab[(c ^ q[i]) & 0xFFu];
    return c ^ 0xFFFFFFFFu;
}
/* THE STREAMING CRC IS THE ROM'S (2026-09-14, CROWNED BY CRCBENCH ON ALL
 * FOUR CHIPS: rom 10,125 cyc/KB vs byte 12,821-16,400 vs slice4
 * 16,913-18,210, values identical on every chip). The slicing lesson
 * (refuted +177 one flash earlier) is why this swap arrives MEASURED:
 * the bench ran on silicon first, and s3c_crc_init refuses to stream
 * unless rom == byte == eb_devseq_crc32 over the corpus, every boot. */
static uint32_t s3c_crc32(const void *p, size_t n)
{
    return esp_rom_crc32_le(0, (const uint8_t *)p, (uint32_t)n);
}
static int s3c_crc_init(void)
{
    static const unsigned char tv[] = { 49,50,51,52,53,54,55,56,57 };
    static uint32_t corpus[1024];
    uint32_t i, k, c;
    int ok;
    if (s3c_crctab_ok) return 1;
    for (i = 0; i < 256; ++i) {
        c = i;
        for (k = 0; k < 8; ++k)
            c = (c >> 1) ^ (0xEDB88320u & (uint32_t)(-(int32_t)(c & 1u)));
        s3c_crctab[i] = c;
    }
    s3_chain_crc_fast_init();
    for (i = 0; i < 1024; ++i)
        corpus[i] = 0x3f000000u + i * 2654435761u;
    for (i = 0; i < 256; ++i)
        corpus[4 * i + 3] = s3_chain_mark(7, i);
    ok = (s3c_crc32(tv, 9) == eb_devseq_crc32(tv, 9))
      && (s3c_crc32(corpus, sizeof corpus)
          == eb_devseq_crc32(corpus, sizeof corpus))
      && (s3c_crc32_byte(corpus, sizeof corpus)
          == eb_devseq_crc32(corpus, sizeof corpus))
      && (s3_chain_crc32_fast(corpus, sizeof corpus)
          == eb_devseq_crc32(corpus, sizeof corpus))
      && (s3c_crc32((const unsigned char *)corpus + 1, 4093)
          == eb_devseq_crc32((const unsigned char *)corpus + 1, 4093))
      && (s3c_crc32(corpus, 7) == eb_devseq_crc32(corpus, 7));
    s3c_crctab_ok = ok;
    return s3c_crctab_ok;
}

/* boot-time CRC bench: cyc/KB for the three same-value candidates over the
 * marked-chunk corpus. PRINT ONLY -- the streaming path uses the byte
 * table until a log crowns a faster one AND its value equality is gated. */
static void s3c_crc_bench(void)
{
    static uint32_t corpus[1024];
    uint32_t i, r;
    unsigned long t0, tb, ts, tr;
    volatile uint32_t sink = 0;
    for (i = 0; i < 1024; ++i)
        corpus[i] = 0x3f000000u + i * 2654435761u;
    t0 = (unsigned long)esp_cpu_get_cycle_count();
    for (r = 0; r < 64; ++r) sink ^= s3c_crc32_byte(corpus, sizeof corpus);
    tb = ((unsigned long)esp_cpu_get_cycle_count() - t0) / 256u;
    t0 = (unsigned long)esp_cpu_get_cycle_count();
    for (r = 0; r < 64; ++r) sink ^= s3_chain_crc32_fast(corpus, sizeof corpus);
    ts = ((unsigned long)esp_cpu_get_cycle_count() - t0) / 256u;
    t0 = (unsigned long)esp_cpu_get_cycle_count();
    for (r = 0; r < 64; ++r) sink ^= esp_rom_crc32_le(0, (const uint8_t *)corpus,
                                                      sizeof corpus);
    tr = ((unsigned long)esp_cpu_get_cycle_count() - t0) / 256u;
    printf("CRCBENCH: byte=%lu slice4=%lu rom=%lu cyc/KB (rom==byte values: "
           "%s)\n", tb, ts, tr,
           esp_rom_crc32_le(0, (const uint8_t *)corpus, sizeof corpus)
               == s3c_crc32_byte(corpus, sizeof corpus) ? "YES" : "NO");
}

typedef struct {
    i2s_chan_handle_t ch;
    int up;                      /* channel enabled                          */
    /* B-side (down TX) */
    int   pace;
    int   tx_marked;             /* the built chunk carries markers          */
    uint32_t tx_blk, tx_crc, tx_crc_blk, tx_timeouts;
    uint32_t pat_idx;
    /* A-side (up RX) */
    s3_amix mix;
    int locked, lock_off;
    uint32_t discard_left;
    uint32_t rx_chunks, rx_short, rx_match, rx_mismatch, rx_dropped, pat_disc;
    size_t   rx_off, tx_off;     /* bytes of a PART-moved chunk, carried over */
    int      tx_silent;          /* the carried chunk is all zeros            */
    /* the SEQ PROBE: every audio chunk carries a counter in spare slot 3,
     * frame 0. A gap at the receiver = the wire stream slipped; zero gaps
     * with zero redemptions = the advert plumbing is the defect. */
    uint32_t tx_seq;
    uint32_t rx_seq_last, rx_seq_ok, rx_seq_slips; int rx_seq_have;
    uint32_t rx_realigns;
    /* RATE PROBE (2026-09-13, pure counters, zero behavior change): total
     * BYTES moved through this port since boot, and the longest single
     * i2s_channel_write/read wait in us. The report prints them; the bench
     * diffs two reports to get the true wire rate -- board 2's loop ran at
     * engine speed while every clock read as correct in the code, and that
     * contradiction is settled by measuring, not arguing (playbook 46). */
    uint64_t io_bytes;
    uint32_t io_wait_max_us;
    uint32_t mm_w[4], mm_crc, mm_pend; int mm_have;
    /* SEAM PROBE: slot-3 markers at fixed frames of the first mismatched
     * chunk each report. The seq field changing mid-chunk PROVES composite
     * and shows WHERE the seam falls: always on 128-frame descriptor
     * boundaries = DMA-quantized inserts; random = byte-time cuts. */
    uint32_t mm_f[6];
    /* THE FULL BATTERY (one flash, many answers -- the bench's gift):
     * ci_last = last 4 realign rotations raw; ci_h buckets: [mult of 128 |
     * <16 | other | =0 never counted]. seam_last = last 4 seam frame
     * indexes found by scanning a bad chunk's markers; seam_h buckets:
     * [on 128 | on 64 | other | NO seam found (single-seq bad chunk =
     * content corruption, a different disease)]. z_chunks = chunks whose
     * frame-0 slot 3 carries NO tag and are not pattern (raw underrun
     * output, previously invisible). */
    uint32_t ci_last[4], ci_h[3];
    uint32_t seam_last[4], seam_h[4];
    uint32_t z_chunks;
    uint8_t  ci_i, seam_i;
    /* B-side write-size split: full chunk in one call / partial / zero. */
    uint32_t wr_full, wr_part, wr_zero;
    /* HEAL VERIFY: the chunk that completes right after a memmove heal
     * must read ci=0. ok = it did; fail = it rotated AGAIN at once --
     * the heal itself would then be the suspect. */
    uint32_t heal_ok, heal_fail; int heal_pending;
    uint32_t pend[8]; uint16_t pend_age[8]; uint8_t pend_used[8];
    uint32_t relock_miss;
    uint32_t crc_last;
    int alock_prev;              /* B-side: last peer_alock, for the cushion */
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
    if (!s3c_crc_init()) {
        printf("CHAIN: crc table twin DIVERGES from eb_devseq_crc32 -- "
               "no audio port\n");
        return 0;
    }
    {   static int benched;
        if (!benched) { benched = 1; s3c_crc_bench(); }
    }
    if (master_rx) tc.gpio_cfg.din  = data;
    else           tc.gpio_cfg.dout = data;
    /* The driver caps a descriptor at 4092 B. TDM4 x 32 bit = 16 B a frame,
     * so CHUNK=256 frames (4096 B) is clamped to 255 and NO single descriptor
     * can ever hold one chunk. Ask for a frame count that DIVIDES the chunk:
     * the reads and writes below then land on descriptor boundaries. */
    /* 16 descriptors = 8 chunks = 46 ms of armor per direction. The mm
     * forensics showed COMPOSITE chunks (one seq, varying crc): seams cut
     * by slave-TX underrun and RX overflow during churn. RAM cost 32 KB
     * per port; the middle chips keep >55 KB internal free. */
    cc.dma_desc_num  = 16;
    cc.dma_frame_num = (CHUNK > 128) ? (CHUNK / 2) : CHUNK;
    /* AUTO-CLEAR (battery run 2026-09-13): without it, a TX underrun
     * REPLAYS the last descriptor -- old markers, old seq, invisible to
     * every counter, and exactly the constant per-hop rotation the seam
     * histogram measured (128 = one descriptor on hop 3<-4). With it, an
     * underrun transmits ZEROS: the receiver counts them (z=) and the
     * realign is not fed forged markers. Truth over comfort. */
    cc.auto_clear_after_cb = true;
    if (master_rx) {
        if (i2s_new_channel(&cc, NULL, &a->ch) != ESP_OK) return 0;
    } else {
        if (i2s_new_channel(&cc, &a->ch, NULL) != ESP_OK) return 0;
    }
    if (i2s_channel_init_tdm_mode(a->ch, &tc) != ESP_OK) return 0;
#if S3C_HAS_DOWN   /* s3c_txbuf exists only on chips with a DOWN port */
    if (!master_rx) {
        /* Pre-fill the slave-TX DMA ring BEFORE enable. The rate probe
         * showed the ring running near-EMPTY (write waits 42-677 us): a
         * just-in-time writer has no cushion, so every loop stall became
         * an underrun, every underrun a fresh rotation downstream. A ring
         * that starts FULL makes the blocking write the true pacer (it
         * must now wait one descriptor per chunk -- SEEN TO BLOCK) and
         * absorbs a stall up to the whole ring depth. Playbook 92. */
        size_t pl = 1;
        memset(s3c_txbuf, 0, sizeof s3c_txbuf);
        while (pl)
            if (i2s_channel_preload_data(a->ch, s3c_txbuf, sizeof s3c_txbuf,
                                         &pl) != ESP_OK)
                break;
    }
#endif
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
    want = (size_t)n * S3C_SLOTW * sizeof(int32_t);
    /* CUSHION AT THE MOMENT IT MATTERS: when the downstream peer first
     * locks (alock 0->1), stuff the ring with sealed SILENT marked chunks
     * BEFORE the first audio chunk. The boot preload drains away during
     * the 8 s recall; this one lands exactly when marked streaming starts,
     * so the first sealed chunks ride a 4-chunk cushion instead of a
     * near-empty ring. Silence is free here: the mix gate is still closed
     * (it opens only after these very chunks redeem). */
    if (peer_alock && !A_DN.alock_prev && !A_DN.tx_off) {
        int j;
        for (j = 0; j < 4; ++j) {
            size_t w2 = 0;
            uint32_t sq = ++A_DN.tx_seq;
            memset(s3c_txbuf, 0, want);
            for (i = 0; i < n; ++i)
                s3c_txbuf[S3C_SLOTW * i + 3] =
                    (int32_t)s3_chain_mark(sq, (uint32_t)i);
            A_DN.tx_crc = s3_chain_crc_seal((uint32_t *)s3c_txbuf,
                                            (uint32_t)(S3C_SLOTW * n),
                                            S3C_SLOTW, s3c_crc32);
            i2s_channel_write(A_DN.ch, s3c_txbuf, want, &w2, 20);
            A_DN.io_bytes += (uint64_t)w2;
            if (w2 < want) {
                /* FIX: a part-written cushion chunk left UNTRACKED bytes in
                 * the ring -- a permanent rotation seeded at every lock
                 * transition. Hand the remainder to the normal completion
                 * path (tx_off), exactly like any partial chunk. */
                A_DN.tx_off = w2;
                break;
            }
            ++A_DN.tx_blk;
        }
        A_DN.tx_marked = 1;
        A_DN.tx_silent = 0;
    }
    A_DN.alock_prev = peer_alock;
    /* A part-written chunk MUST be finished before a new one is built, or the
     * slot stream loses its alignment. Only fill the buffer when it is free. */
    if (!A_DN.tx_off) {
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
        A_DN.tx_silent = silent;
        /* Spare slot 3 of EVERY frame carries a tagged marker: the frame's
         * own index plus a chunk sequence. The receiver reads frame 0's
         * marker and knows instantly whether the stream is frame-rotated
         * (a slave-TX underrun inserts whole frames) and by how much -- the
         * probe proved exactly that rotation. Markers also make every audio
         * chunk non-silent, so an advert goes out for each one.
         * The marker LAW (tag, layout, realign bound) is pure in s3_chain.h
         * and gated by chain_gate.c -- review 2026-09-06. */
        if (peer_alock) {
            uint32_t sq = ++A_DN.tx_seq;
            for (i = 0; i < n; ++i)
                s3c_txbuf[S3C_SLOTW * i + 3] =
                    (int32_t)s3_chain_mark(sq, (uint32_t)i);
            A_DN.tx_silent = 0;
            A_DN.tx_marked = 1;
            /* IN-BAND CRC (s3_chain.h law): frame 1's redundant marker word
             * becomes the chunk's own CRC. The advert now carries the same
             * value (diagnostic only -- redemption is in the chunk). */
            A_DN.tx_crc = s3_chain_crc_seal((uint32_t *)s3c_txbuf,
                                            (uint32_t)(S3C_SLOTW * n),
                                            S3C_SLOTW, s3c_crc32);
        } else {
            A_DN.tx_seq = 0;
            A_DN.tx_marked = 0;
        }
    }
    /* i2s_channel_write takes MILLISECONDS and converts internally
     * (pdMS_TO_TICKS(timeout_ms) in i2s_common.c). Passing pdMS_TO_TICKS(20)
     * handed it 2 "ms" -> 0 ticks at the 100 Hz tick rate: the LINKED pacer
     * NEVER BLOCKED on silicon (rate probe: wmax=39us, 634880 of 705600 B/s
     * fed, perpetual slave underrun = the realign churn). Playbook 92. */
    tmo = (A_DN.pace == S3_BPACE_LINKED) ? 20 : 0;
    {   int64_t tw0 = esp_timer_get_time();
        i2s_channel_write(A_DN.ch, (const char *)s3c_txbuf + A_DN.tx_off,
                          want - A_DN.tx_off, &wrote, tmo);
        {   uint32_t wus = (uint32_t)(esp_timer_get_time() - tw0);
            if (wus > A_DN.io_wait_max_us) A_DN.io_wait_max_us = wus;
        }
        A_DN.io_bytes += (uint64_t)wrote;
        if (!wrote)                              ++A_DN.wr_zero;
        else if (wrote == want - A_DN.tx_off)    ++A_DN.wr_full;
        else                                     ++A_DN.wr_part;
    }
    A_DN.tx_off += wrote;
    if (A_DN.tx_off >= want) {
        A_DN.tx_off = 0;
        ++A_DN.tx_blk;
        /* advertise MARKED (audio) chunks only. tx_crc is the in-band seal
         * computed at fill time (the merge guard keeps txbuf frozen between
         * fill and completion, so the value still matches the bytes). */
        if (!A_DN.tx_silent && A_DN.tx_marked)
            A_DN.tx_crc_blk = A_DN.tx_blk;
        tmo = 0;
    } else {
        tmo = (A_DN.pace == S3_BPACE_LINKED);
    }
    if (tmo) ++A_DN.tx_timeouts;
    A_DN.pace = s3_bpace_step(A_DN.pace, S3_ROLE_B, hs_ok, tmo);
    return tmo;
}
#endif

#if S3C_HAS_DOWN
/* the block-tail merge must NOT refill s3c_txbuf while a part-written chunk
 * is still leaving -- the splice would carry a CRC no advert ever matches.
 * The caller skips one merge instead (freerun only; LINKED completes). */
#define s3c_tx_busy() (A_DN.tx_off != 0)
#endif

#if S3C_HAS_UP
/* A-side: drain to latest, pattern-lock, redeem adverts, step the mix gate.
 * Leaves the latest aligned AUDIO chunk in s3c_rxbuf and returns 1 when the
 * mix gate is OPEN for it. */
static int s3c_rx_one(int n, int hs_ok);

static int s3c_rx(int n, int peer_present, int hs_ok,
                  uint32_t peer_acrc, int fresh_acrc)
{
    if (!A_UP.up) return 0;
    if (n > CHUNK) n = CHUNK;
    s3c_rx_fresh = 0;
    /* Adverts no longer drive redemption (in-band CRC does). */
    (void)fresh_acrc; (void)peer_acrc;
    /* NO PEER: the master clock still fills the DMA with garbage, so DRAIN
     * it (cheap memcpys) -- but pay for nothing else. The first chain flash
     * scanned and CRC'd a floating wire every block; that work belongs
     * behind a peer that answered. */
    if (!peer_present) {
        size_t g;
        int d = 0;
        do {
            g = 0;
            if (i2s_channel_read(A_UP.ch, s3c_rxbuf,
                                 (size_t)n * S3C_SLOTW * sizeof(int32_t),
                                 &g, 0) != ESP_OK || !g)
                break;
            A_UP.io_bytes += (uint64_t)g;
        } while (++d < 4);
        A_UP.locked = 0;
        A_UP.rx_seq_have = 0;    /* a returning peer restarts its sequence */
        (void)s3_amix_step(&A_UP.mix, 0, 0, 0, 0);
        return 0;
    }
    if (A_UP.discard_left) {
        /* Drain the WHOLE discard now (bounded like the no-peer drain).
         * The old single read per block STARVED the port during recovery
         * -- the rate probe measured 543459 of 705600 lawful B/s read, so
         * the RX ring overflowed behind every rotation and one slip
         * snowballed into permanent churn. Playbook 92. */
        int d_ = 0;
        while (A_UP.discard_left && d_++ < 4) {
            size_t g = 0;
            uint32_t w = A_UP.discard_left;
            if (w > (uint32_t)S3C_CHW) w = (uint32_t)S3C_CHW;
            if (i2s_channel_read(A_UP.ch, s3c_rxbuf, w * sizeof(int32_t),
                                 &g, 0) != ESP_OK || !g)
                break;
            A_UP.io_bytes += (uint64_t)g;
            A_UP.discard_left -= (uint32_t)(g / sizeof(int32_t));
        }
        if (A_UP.discard_left) return 0;
    }
    /* A zero-timeout read returns only what the ready descriptors hold, so a
     * chunk can arrive in PIECES. Carry the part across blocks (rx_off).
     * ⚑ THE TORN-CHUNK DEFECT (mf forensics 2026-09-13): drain-to-latest
     * kept READING INTO THE SAME BUFFER after completing a chunk, then the
     * judge ran on bytes that were [next chunk's head][old chunk's tail],
     * cut at the boot-constant arrival phase (measured: seam 97/98 frames,
     * seq S then S-1). THE JUDGE TORE ITS OWN EVIDENCE. Now every completed
     * chunk is judged IMMEDIATELY, before any further read can touch the
     * buffer; up to 4 chunks judge per block (catch-up), and the LAST good
     * one stays in s3c_rxbuf for the mix. */
    {   int drained = 0, res = 0;
        size_t want = (size_t)n * S3C_SLOTW * sizeof(int32_t), g;
        char  *base = (char *)s3c_rxbuf;
        for (;;) {
            g = 0;
            if (i2s_channel_read(A_UP.ch, base + A_UP.rx_off,
                                 want - A_UP.rx_off, &g, 0) != ESP_OK || !g)
                break;
            A_UP.io_bytes += (uint64_t)g;
            A_UP.rx_off += g;
            if (A_UP.rx_off < want) { ++A_UP.rx_short; break; }
            A_UP.rx_off = 0;
            res = s3c_rx_one(n, hs_ok);
            if (++drained >= 4) break;
        }
        if (drained > 1) A_UP.rx_dropped += (uint32_t)(drained - 1);
        return res;
    }
}

/* Judge ONE completed chunk in s3c_rxbuf: realign-or-lock, pattern filter,
 * in-band verify, step the mix gate. Runs the moment a chunk completes and
 * BEFORE any further read touches the buffer. A realign heal leaves rx_off
 * set, so the caller's loop completes the healed chunk -- possibly in this
 * same block. A block that completes no chunk holds the mix state. */
static int s3c_rx_one(int n, int hs_ok)
{
    int match = 0, mismatch = 0, got_chunk = 1;
    {
        ++A_UP.rx_chunks;
        /* the marker in frame 0 slot 3 heals frame rotation on the spot: a
         * slave-TX underrun inserts whole frames, and before this check ONE
         * slip broke the CRC forever (the probe measured it). The decision
         * is s3_chain_realign_ci -- pure, BOUNDED, tag distinct from the
         * training pattern, gated in chain_gate.c (review 2026-09-06). */
        if (A_UP.locked) {
            uint32_t ci = s3_chain_realign_ci((uint32_t)s3c_rxbuf[3],
                                              (uint32_t)n);
            if (ci) {
                /* Heal by KEEPING what was read, not by discarding. The
                 * buffer's tail (ci frames) is the START of the next chunk:
                 * move it to the front and let rx_off complete that chunk.
                 * The old path discarded a further (n-ci) frames with extra
                 * reads -- during churn that starved the port to 90% of the
                 * wire rate and the RX ring overflowed behind every slip,
                 * which re-created the rotation it was healing (measured;
                 * playbook 92). */
                size_t tail = (size_t)ci * S3C_SLOTW * sizeof(int32_t);
                memmove(s3c_rxbuf,
                        (const char *)s3c_rxbuf
                            + ((size_t)n - ci) * S3C_SLOTW * sizeof(int32_t),
                        tail);
                A_UP.rx_off = tail;
                A_UP.ci_last[A_UP.ci_i++ & 3u] = ci;
                ++A_UP.ci_h[(ci % 128u == 0u) ? 0 : (ci < 16u) ? 1 : 2];
                if (A_UP.heal_pending) ++A_UP.heal_fail;
                A_UP.heal_pending = 1;
                ++A_UP.rx_realigns;
                A_UP.rx_seq_have = 0;
                got_chunk = 0;
            }
        }
        if (!A_UP.locked) {
            uint32_t idx0; int disc;
            if (s3_pat_scan((const uint32_t *)s3c_rxbuf, S3C_SLOTW * n,
                            &idx0, &disc)) {
                uint32_t m = idx0 & ((uint32_t)S3C_SLOTW * CHUNK - 1u);
                A_UP.locked = 1;
                A_UP.lock_off = (int)m;
                A_UP.discard_left = ((uint32_t)S3C_SLOTW * CHUNK - m)
                                    & ((uint32_t)S3C_SLOTW * CHUNK - 1u);
                /* a FRESH lock starts clean: pre-lock pends can never
                 * match audio, and stale seq state fakes a slip. The
                 * RE-lock path below already clears these. */
                memset(A_UP.pend_used, 0, sizeof A_UP.pend_used);
                A_UP.relock_miss = 0;
                A_UP.rx_seq_have = 0;
            } else {
                A_UP.pat_disc += (uint32_t)disc;
            }
        }
    }
    /* a PATTERN chunk must never redeem an advert or feed the mix gate.
     * THREE slots checked (review 2026-09-06): a decaying audio tail passes
     * floats with top byte 0xA5 (about -1e-16); two coincidences dropped a
     * good chunk, three make the false positive negligible. A real pattern
     * chunk tags EVERY word, so this stays a certain hit. */
    if (got_chunk &&
        ((uint32_t)s3c_rxbuf[0] & S3_PAT_MASK) == S3_PAT_TAG &&
        ((uint32_t)s3c_rxbuf[1] & S3_PAT_MASK) == S3_PAT_TAG &&
        ((uint32_t)s3c_rxbuf[2] & S3_PAT_MASK) == S3_PAT_TAG)
        got_chunk = 0;
    if (got_chunk && A_UP.locked) {
        if (A_UP.heal_pending) { ++A_UP.heal_ok; A_UP.heal_pending = 0; }
        /* chunk-sequence continuity, read from the marker (8-bit wrap) */
        {   uint32_t mk = (uint32_t)s3c_rxbuf[3];
            if ((mk & S3_CHAIN_MARK_MASK) == S3_CHAIN_MARK_TAG) {
                uint32_t s = (mk >> 9) & 0xFFu;
                if (A_UP.rx_seq_have) {
                    if (s == ((A_UP.rx_seq_last + 1u) & 0xFFu))
                        ++A_UP.rx_seq_ok;
                    else
                        ++A_UP.rx_seq_slips;
                }
                A_UP.rx_seq_last = s; A_UP.rx_seq_have = 1;
            } else {
                ++A_UP.z_chunks;   /* no tag at frame 0: raw underrun output */
            }
        }
        /* IN-BAND redemption (s3_chain.h law): the chunk carries its own
         * CRC in frame 1 slot 3; check leaves that word zeroed (spare). */
        {   uint32_t inb = (uint32_t)s3c_rxbuf[S3_CHAIN_CRCW(S3C_SLOTW)];
            if (s3_chain_crc_check((uint32_t *)s3c_rxbuf,
                                   (uint32_t)(S3C_SLOTW * n), S3C_SLOTW,
                                   s3c_crc32)) {
                match = 1; ++A_UP.rx_match; A_UP.relock_miss = 0;
            } else {
                if (!A_UP.mm_have) {
                    static const int mf_[6] = { 2, 32, 64, 128, 192, 255 };
                    int q;
                    A_UP.mm_have = 1;
                    A_UP.mm_w[0] = (uint32_t)s3c_rxbuf[0];
                    A_UP.mm_w[1] = (uint32_t)s3c_rxbuf[1];
                    A_UP.mm_w[2] = (uint32_t)s3c_rxbuf[2];
                    A_UP.mm_w[3] = (uint32_t)s3c_rxbuf[3];
                    for (q = 0; q < 6; ++q)
                        A_UP.mm_f[q] = (mf_[q] < n)
                            ? (uint32_t)s3c_rxbuf[S3C_SLOTW * mf_[q] + 3]
                            : 0u;
                    A_UP.mm_crc  = s3c_crc32(s3c_rxbuf,
                                             (size_t)n * S3C_SLOTW
                                                 * sizeof(int32_t));
                    A_UP.mm_pend = inb;
                }
                /* seam scan: the first frame whose marker disagrees with
                 * frame 0 (frame 1 is the crc word -- skipped). No seam on
                 * a bad chunk = single-seq content corruption: a DIFFERENT
                 * disease, counted apart. ~256 reads, mismatch path only. */
                {   uint32_t s0_ = ((uint32_t)s3c_rxbuf[3] >> 9) & 0xFFu;
                    int kk_, seam_ = -1;
                    for (kk_ = 2; kk_ < n; ++kk_) {
                        uint32_t wm_ =
                            (uint32_t)s3c_rxbuf[S3C_SLOTW * kk_ + 3];
                        if ((wm_ & S3_CHAIN_MARK_MASK) != S3_CHAIN_MARK_TAG
                            || ((wm_ >> 9) & 0xFFu) != s0_) {
                            seam_ = kk_;
                            break;
                        }
                    }
                    if (seam_ < 0) ++A_UP.seam_h[3];
                    else {
                        A_UP.seam_last[A_UP.seam_i++ & 3u] = (uint32_t)seam_;
                        ++A_UP.seam_h[(seam_ % 128 == 0) ? 0
                                      : (seam_ % 64 == 0) ? 1 : 2];
                    }
                }
                mismatch = 1; ++A_UP.rx_mismatch;
                /* Under IN-BAND CRC a miss convicts ONE chunk (a seam), not
                 * the lock: alignment is maintained per chunk by the marker
                 * realign, so re-training buys nothing and costs the storm
                 * -- the 8-miss trigger fed the churn cascade (unlock ->
                 * pattern flip -> scan load -> stalls -> more seams on the
                 * hop below). The lock now survives seams; it drops only
                 * when the stream is DEAD for ~1.5 s (256 chunks with no
                 * single clean one), which is a rebooted or unwired peer,
                 * not a bad moment. */
                if (++A_UP.relock_miss >= 256) {
                    A_UP.locked = 0; A_UP.relock_miss = 0;
                    A_UP.rx_seq_have = 0;
                }
            }
        }
    }
    s3c_rx_fresh = got_chunk;
    if (match || mismatch)
        return s3_amix_step(&A_UP.mix, hs_ok, got_chunk, match, mismatch)
               && got_chunk;
    /* A HEALED or pattern chunk is not a verdict: under the in-band law a
     * heal just completes the chunk a moment later, and closing the gate
     * on it reset the 3-match streak forever (judge-fix log: ok:bad 10:1
     * yet one transient OPEN). Hold the gate; only judged chunks move it. */
    return (A_UP.mix.st == S3_AMIX_OPEN) && got_chunk;
}
#endif

static void s3c_report(void)
{
#if S3C_HAS_UP
    if (C_UP.started)
        printf("CHAINup: %s hs=%s rx=%lu ok=%lu bad=%lu drop=%lu %s%s "
               "part=%lu pat_disc=%lu\n",
               A_UP.mix.st == S3_AMIX_OPEN ? "mix=OPEN" : "mix=closed",
               C_UP.peer.present ? s3_handshake_name(C_UP.hs) : "no peer yet",
               (unsigned long)A_UP.rx_chunks, (unsigned long)A_UP.rx_match,
               (unsigned long)A_UP.rx_mismatch, (unsigned long)A_UP.rx_dropped,
               A_UP.locked ? "lock=YES" : "lock=searching",
               "", (unsigned long)A_UP.rx_short,
               (unsigned long)A_UP.pat_disc);
    if (C_UP.started) {
        printf("CHAINseq: ok=%lu slips=%lu realign=%lu last=%lu\n",
               (unsigned long)A_UP.rx_seq_ok,
               (unsigned long)A_UP.rx_seq_slips,
               (unsigned long)A_UP.rx_realigns,
               (unsigned long)A_UP.rx_seq_last);
        if (A_UP.mm_have) {
            printf("CHAINmm: w=%08lx %08lx %08lx %08lx crc=%08lx pend=%08lx\n",
                   (unsigned long)A_UP.mm_w[0], (unsigned long)A_UP.mm_w[1],
                   (unsigned long)A_UP.mm_w[2], (unsigned long)A_UP.mm_w[3],
                   (unsigned long)A_UP.mm_crc, (unsigned long)A_UP.mm_pend);
            printf("CHAINmf: f2=%08lx f32=%08lx f64=%08lx f128=%08lx "
                   "f192=%08lx f255=%08lx\n",
                   (unsigned long)A_UP.mm_f[0], (unsigned long)A_UP.mm_f[1],
                   (unsigned long)A_UP.mm_f[2], (unsigned long)A_UP.mm_f[3],
                   (unsigned long)A_UP.mm_f[4], (unsigned long)A_UP.mm_f[5]);
            A_UP.mm_have = 0;
        }
    }
    /* RATE PROBE: cumulative since boot -- the bench diffs two reports.
     * 44100 frames/s x 16 B = 705600 B/s is the lawful wire rate. */
    printf("CHAINrateUP: rxB=%llu\n", (unsigned long long)A_UP.io_bytes);
    printf("CHAINdx: ci=[%lu %lu %lu %lu] cih=[%lu %lu %lu] "
           "seam=[%lu %lu %lu %lu] sh=[%lu %lu %lu %lu] z=%lu\n",
           (unsigned long)A_UP.ci_last[0], (unsigned long)A_UP.ci_last[1],
           (unsigned long)A_UP.ci_last[2], (unsigned long)A_UP.ci_last[3],
           (unsigned long)A_UP.ci_h[0], (unsigned long)A_UP.ci_h[1],
           (unsigned long)A_UP.ci_h[2],
           (unsigned long)A_UP.seam_last[0], (unsigned long)A_UP.seam_last[1],
           (unsigned long)A_UP.seam_last[2], (unsigned long)A_UP.seam_last[3],
           (unsigned long)A_UP.seam_h[0], (unsigned long)A_UP.seam_h[1],
           (unsigned long)A_UP.seam_h[2], (unsigned long)A_UP.seam_h[3],
           (unsigned long)A_UP.z_chunks);
    printf("CHAINhv: ok=%lu fail=%lu\n",
           (unsigned long)A_UP.heal_ok, (unsigned long)A_UP.heal_fail);
#endif
#if S3C_HAS_DOWN
    if (C_DN.started)
        printf("CHAINdn: pace=%s hs=%s tx=%lu timeouts=%lu ev_gap=%lu "
               "txseq=%lu\n",
               A_DN.pace == S3_BPACE_LINKED ? "LINKED" : "freerun",
               C_DN.peer.present ? s3_handshake_name(C_DN.hs) : "no peer yet",
               (unsigned long)A_DN.tx_blk, (unsigned long)A_DN.tx_timeouts,
               (unsigned long)C_DN.ev_gap, (unsigned long)A_DN.tx_seq);
    printf("CHAINrateDN: txB=%llu wmax=%luus wr=[%lu %lu %lu]\n",
           (unsigned long long)A_DN.io_bytes,
           (unsigned long)A_DN.io_wait_max_us,
           (unsigned long)A_DN.wr_full, (unsigned long)A_DN.wr_part,
           (unsigned long)A_DN.wr_zero);
#endif
    printf("CHAINev: sent=%lu applied=%lu\n", s3c_ev_sent, s3c_ev_applied);
}

#endif /* JUNO_S3_CHAIN_LINK_H */
