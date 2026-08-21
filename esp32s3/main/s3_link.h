/* s3_link.h -- O6/D1+D2: THE TWO-CHIP LINK, as pin maps and pure functions.
 *
 * D1 IS ALREADY DECIDED (user, 2026-08-12): ONE DAC, chip A is the only clock.
 * Nothing here re-opens that. This file writes it down as something a gate can
 * execute, because the alternative is that it first executes on two boards
 * that have never been wired -- and this session has twice paid for logic
 * whose first run was on silicon (playbook 67, 72).
 *
 * ==========================================================================
 * THE WIRING, and it is the whole design in six lines
 * ==========================================================================
 *
 *   AUDIO OUT   chip A  I2S0 MASTER TX  --> the ONE audio board  (5/6/7)
 *   LINK        chip A  I2S1 MASTER RX  <-- chip B  I2S1 SLAVE TX
 *
 *       A GPIO 15  BCLK  ---------------->  B GPIO 15   (A drives, B listens)
 *       A GPIO 16  LRCK  ---------------->  B GPIO 16   (A drives, B listens)
 *       A GPIO 17  DIN   <----------------  B GPIO 17   (B drives, A listens)
 *       A GND            <--------------->  B GND
 *
 *   CONTROL     chip A  UART2 TX/RX     <-> chip B  UART2 RX/TX
 *
 *       A GPIO  8  TX    ---------------->  B GPIO  9  RX
 *       A GPIO  9  RX    <----------------  B GPIO  8  TX
 *
 * ⚠ THE CONTROL PAIR IS TWO WIRES THE D1 DECISION DID NOT COVER, and it is
 * flagged rather than slipped in. D1 settled the AUDIO path at "three wires
 * plus ground, no MCLK". D2 -- patch bytes, apply-at-index, CRC handshake --
 * needs a path from A to B, and the audio link carries data only B->A. The
 * I2S frame could hide control bits in its low bits, but that would put a
 * silent, unprovable coupling between the audio format and the control
 * protocol, and this project has spent the whole session paying for silent
 * couplings. Two more wires and a UART is the honest cost. SIX WIRES PLUS
 * GROUND in total. If the user refuses the extra pair, the fallback is
 * spelled out in docs/engineb/TWO_CHIP_WIRING.md and it is worse.
 *
 * ==========================================================================
 * WHY B GETS ITS SAMPLE TICK FOR FREE
 * ==========================================================================
 * B's I2S is a SLAVE, clocked by A's BCLK/LRCK. Its render loop is driven by
 * the DMA those clocks advance, so the two chips cannot drift: there is one
 * oscillator in the instrument. Chip B's audio arrives one block late, which
 * is the same trade the FX pipeline already pays and which THE INVARIANT
 * permits (audio never breaks; changes may land late).
 */
#ifndef JUNO_S3_LINK_H
#define JUNO_S3_LINK_H

#include "s3_role.h"

/* ---- the link pins. IDENTICAL on both chips: one image, and the DIRECTION
 * is what the role changes, never the number. A pin map that differed by role
 * would be two boards' worth of wiring to keep in step. -------------------- */
#ifndef S3_LINK_BCLK
#define S3_LINK_BCLK 15
#endif
#ifndef S3_LINK_LRCK
#define S3_LINK_LRCK 16
#endif
#ifndef S3_LINK_DATA
#define S3_LINK_DATA 17
#endif
#ifndef S3_LINK_UART_TX
#define S3_LINK_UART_TX 8
#endif
#ifndef S3_LINK_UART_RX
#define S3_LINK_UART_RX 9
#endif

/* the audio-board pins, chip A only */
#ifndef S3_DAC_BCLK
#define S3_DAC_BCLK 5
#endif
#ifndef S3_DAC_LRCK
#define S3_DAC_LRCK 6
#endif
#ifndef S3_DAC_DOUT
#define S3_DAC_DOUT 7
#endif

enum { S3_DIR_IN = 0, S3_DIR_OUT = 1 };

typedef struct {
    int link_is_master;   /* 1 = this chip DRIVES the link BCLK/LRCK        */
    int link_is_tx;       /* 1 = this chip SENDS audio on the link          */
    int bclk_dir;         /* S3_DIR_OUT on A, S3_DIR_IN on B                */
    int lrck_dir;
    int data_dir;         /* S3_DIR_IN on A (it receives), OUT on B         */
    int uses_dac;         /* only A touches GPIO 5/6/7 at all               */
} s3_link_cfg;

static s3_link_cfg s3_link_config(int role)
{
    s3_link_cfg c;
    /* ⚑ THE LINK MASTER IS **A**, AND IT IS THE CHIP THAT RECEIVES.
     *
     * That inversion is the whole point of D1 and is the line most likely to
     * be "corrected" by someone who assumes the sender clocks the wire. It
     * does not: A owns the ONLY oscillator in the instrument, so A must drive
     * BCLK/LRCK on BOTH its I2S peripherals -- the one feeding the DAC and
     * the one receiving B. B is a slave that transmits. Reverse this and the
     * two chips have two clocks, which is precisely what the one-DAC decision
     * exists to make impossible. */
    c.link_is_master = (role == S3_ROLE_A);
    c.link_is_tx     = (role == S3_ROLE_B);
    c.bclk_dir       = (role == S3_ROLE_A) ? S3_DIR_OUT : S3_DIR_IN;
    c.lrck_dir       = (role == S3_ROLE_A) ? S3_DIR_OUT : S3_DIR_IN;
    c.data_dir       = (role == S3_ROLE_A) ? S3_DIR_IN  : S3_DIR_OUT;
    c.uses_dac       = (role == S3_ROLE_A);
    return c;
}

/* ---- D2: the wire frame --------------------------------------------------
 *
 * Fixed length, magic-led, checksummed. Not text: a half-connected wire makes
 * framing garbage, and a text parser will happily read a plausible number out
 * of noise. FIXED-WIDTH TYPES ONLY: the first draft used `unsigned long`,
 * which is 4 bytes on the S3 and 8 on the host -- so the host gate would have
 * gated a DIFFERENT LAYOUT than the wire carries.
 *
 * ⚠ THE CHECKSUM COVERS offsetof(sum), NOT sizeof-2. The first draft summed
 * sizeof-2 bytes; tail padding put the sum field INSIDE that range, so the
 * sender (sum bytes still zero) and the receiver (sum bytes filled) computed
 * different values and EVERY frame was rejected. Two perfectly wired boards
 * would have reported NO PEER forever -- a detector wrong in the direction
 * that discards good input, on the exact build meant to prove the wire.
 * Playbook 75. The codec gate corrupts every byte and also round-trips a
 * clean frame, so both directions of that failure are now toothed. */
#include <stdint.h>
#include <stddef.h>

#define S3_LINK_MAGIC0 0x4Au   /* 'J' */
#define S3_LINK_MAGIC1 0x36u   /* '6' */

typedef struct {
    uint8_t  m0, m1;
    uint8_t  role;
    uint8_t  voice_base;
    uint8_t  voices;
    uint8_t  pad;
    uint16_t patch;
    uint32_t crc;      /* the coefficient CRC -- the field that matters */
    uint16_t sum;      /* frame checksum; MUST stay the LAST field      */
} s3_link_frame;

static uint16_t s3_link_sum(const s3_link_frame *f)
{
    const uint8_t *p = (const uint8_t *)f;
    uint16_t s = 0; size_t i;
    for (i = 0; i < offsetof(s3_link_frame, sum); ++i)
        s = (uint16_t)(s + p[i] * 31u + 7u);
    return s;
}

/* ---- D2: the handshake ---------------------------------------------------
 *
 * WHAT IT MUST ESTABLISH, before a note is allowed to sound:
 *   1. the peer exists and is the OPPOSITE role (s3_pair_check)
 *   2. both chips hold the SAME patch index
 *   3. both chips run the SAME BUILD and derived the same patch -- by
 *      exchanging the BASE-0 answer-key fingerprint for the current patch.
 *      ⚠ NOT the key each chip plays from. The per-base keys (O6/D3) DIFFER
 *      BY DESIGN between the chips -- chip A verifies itself against the
 *      base-0 table and chip B against base-3 -- so comparing "my key" with
 *      "your key" across the wire would read CRC_DIFFERS on every correctly
 *      working pair, forever. The first draft did exactly that, caught in
 *      the bench-path audit before any wire existed. Each chip PROVES its
 *      own playing bank locally (the RECALL CRC check mutes on mismatch);
 *      the wire's job is only to prove the two chips share one build and one
 *      patch, and the base-0 fingerprint answers that on both roles.
 *   4. both agree which GLOBAL voices each owns (D3's base)
 *
 * ⚠ 3 IS THE ONE THAT MATTERS AND THE ONE MOST EASILY SKIPPED. Chips that
 * agree on the patch INDEX but built different coefficients are exactly the
 * D3 species: silent, self-consistent, and audible only as a wrong chord.
 * The index handshake alone would pass. */
enum {
    S3_HS_OK = 0,
    S3_HS_NO_PEER,        /* nothing answered                              */
    S3_HS_BAD_PAIR,       /* two masters or two slaves                     */
    S3_HS_PATCH_DIFFERS,  /* different patch index                         */
    S3_HS_CRC_DIFFERS,    /* same index, DIFFERENT coefficients            */
    S3_HS_BASE_OVERLAP    /* the two chips claim the same global voices    */
};

typedef struct {
    int  present;         /* did the peer answer at all                    */
    int  role;
    int  patch;
    int  voice_base;
    int  voices;
    unsigned long crc;
} s3_peer;

static int s3_handshake_check(const s3_role_cfg *me, int my_patch,
                              unsigned long my_crc, const s3_peer *peer)
{
    if (!peer->present) return S3_HS_NO_PEER;
    if (s3_pair_check(me->role, peer->role) != S3_PAIR_OK) return S3_HS_BAD_PAIR;
    if (peer->patch != my_patch)                           return S3_HS_PATCH_DIFFERS;
    if (peer->crc   != my_crc)                             return S3_HS_CRC_DIFFERS;
    /* disjoint global voice ranges (D3). Overlap means one chip's detune is
     * duplicated and another global voice is never sounded at all. */
    if (!(me->voice_base + me->voices <= peer->voice_base ||
          peer->voice_base + peer->voices <= me->voice_base))
        return S3_HS_BASE_OVERLAP;
    return S3_HS_OK;
}

/* ---- D2: PATCH-FOLLOW, the decision as a pure function -------------------
 *
 * WHY IT EXISTS: both boards run the same image, so both carry the 4-second
 * patch stepper. Free-running, the two steppers agree only by luck, and the
 * handshake reads PATCH_DIFFERS nearly always -- the bench criterion "wait
 * for OK" would be unreachable. So: CHIP A IS THE SOURCE OF TRUTH. When a
 * valid peer is present, chip B never self-steps; it requests whatever patch
 * A advertises. Chip A never follows anyone.
 *
 * Returns the patch to request, or -1 for "no action". A separate query,
 * s3_follow_holds_stepper, tells B's own stepper to stand down even while
 * the patches already agree. Pure functions: gated in d1_link_gate.c. */
static int s3_follow_patch(int my_role, int peer_present, int peer_role,
                           int my_patch, int peer_patch)
{
    if (my_role != S3_ROLE_B || !peer_present) return -1;
    if (s3_pair_check(my_role, peer_role) != S3_PAIR_OK) return -1;
    return (peer_patch != my_patch) ? peer_patch : -1;
}

static int s3_follow_holds_stepper(int my_role, int peer_present, int peer_role)
{
    return my_role == S3_ROLE_B && peer_present &&
           s3_pair_check(my_role, peer_role) == S3_PAIR_OK;
}

static const char *s3_handshake_name(int hs)
{
    switch (hs) {
    case S3_HS_OK:            return "OK";
    case S3_HS_NO_PEER:       return "NO PEER ANSWERED -- check the UART pair and ground";
    case S3_HS_BAD_PAIR:      return "BAD PAIR -- both chips strapped the same way";
    case S3_HS_PATCH_DIFFERS: return "PATCH INDEX DIFFERS between the chips";
    case S3_HS_CRC_DIFFERS:   return "SAME PATCH, DIFFERENT COEFFICIENTS -- silent defect";
    case S3_HS_BASE_OVERLAP:  return "GLOBAL VOICE RANGES OVERLAP -- a voice is duplicated";
    default:                  return "?";
    }
}

#endif /* JUNO_S3_LINK_H */
