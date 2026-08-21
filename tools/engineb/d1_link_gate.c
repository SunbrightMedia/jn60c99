/* d1_link_gate.c -- O6/D1+D2: the link's direction table and handshake, gated.
 *
 * ⚠ WHAT THIS CANNOT PROVE, stated first so the green line is not misread:
 * there are TWO BOARDS AND NO WIRE. Nothing here touches an I2S peripheral, a
 * pin or a UART. It proves the DECISION TABLE and the HANDSHAKE RULES only.
 * Whether GPIO 15 on A actually reaches GPIO 15 on B is hardware.
 *
 * usage: d1_link_gate [tooth]      (exit 0 = green)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "s3_link.h"

static int fails;
static void ck(int c, const char *w)
{ printf("  %-64s %s\n", w, c ? "ok" : "*** FAIL"); if (!c) ++fails; }

int main(int argc, char **argv)
{
    int t = (argc > 1) ? atoi(argv[1]) : 0;
    s3_role_cfg RA = s3_role_config(S3_ROLE_A), RB = s3_role_config(S3_ROLE_B);
    s3_link_cfg A  = s3_link_config(S3_ROLE_A), B  = s3_link_config(S3_ROLE_B);
    s3_peer pB, pA;
    unsigned long CRC = 0xABCD1234ul;

    if (t == 1) B.link_is_master = 1;                 /* two clocks        */
    if (t == 2) B.data_dir = S3_DIR_IN;               /* nobody drives DATA*/
    if (t == 3) A.link_is_tx = 1;                     /* both transmit     */

    printf("=== O6/D1 LINK DIRECTION TABLE ===\n");
    printf("  BCLK %d   LRCK %d   DATA %d   UART TX %d / RX %d\n",
           S3_LINK_BCLK, S3_LINK_LRCK, S3_LINK_DATA,
           S3_LINK_UART_TX, S3_LINK_UART_RX);
    printf("  A: bclk=%s lrck=%s data=%s  master=%d tx=%d dac=%d\n",
           A.bclk_dir ? "OUT":"IN", A.lrck_dir ? "OUT":"IN",
           A.data_dir ? "OUT":"IN", A.link_is_master, A.link_is_tx, A.uses_dac);
    printf("  B: bclk=%s lrck=%s data=%s  master=%d tx=%d dac=%d\n\n",
           B.bclk_dir ? "OUT":"IN", B.lrck_dir ? "OUT":"IN",
           B.data_dir ? "OUT":"IN", B.link_is_master, B.link_is_tx, B.uses_dac);

    /* every wire must have EXACTLY ONE driver -- the property a wiring
     * mistake violates and a schematic drawing does not check */
    ck(A.bclk_dir + B.bclk_dir == 1, "BCLK has exactly one driver");
    ck(A.lrck_dir + B.lrck_dir == 1, "LRCK has exactly one driver");
    ck(A.data_dir + B.data_dir == 1, "DATA has exactly one driver");

    ck(A.link_is_master + B.link_is_master == 1, "exactly one link clock master");
    ck(A.link_is_tx + B.link_is_tx == 1,         "exactly one link transmitter");
    ck(A.link_is_master && !A.link_is_tx,
       "A is the link MASTER and the RECEIVER (D1's inversion)");
    ck(B.link_is_tx && !B.link_is_master,
       "B TRANSMITS as a SLAVE -- it owns no oscillator");
    ck(A.uses_dac + B.uses_dac == 1,             "exactly one chip drives the DAC");
    ck(A.link_is_master == A.uses_dac,
       "the clock master is the DAC owner -- one oscillator in the instrument");

    /* the link pins must not collide with the DAC pins or the console/MIDI */
    ck(S3_LINK_BCLK != S3_DAC_BCLK && S3_LINK_LRCK != S3_DAC_LRCK &&
       S3_LINK_DATA != S3_DAC_DOUT, "link pins do not collide with the DAC pins");
    ck(S3_LINK_UART_TX != 43 && S3_LINK_UART_RX != 44 &&
       S3_LINK_UART_TX != 18 && S3_LINK_UART_RX != 18,
       "control UART avoids the console (43/44) and MIDI RX (18)");
    ck(S3_ROLE_PIN != S3_LINK_BCLK && S3_ROLE_PIN != S3_LINK_LRCK &&
       S3_ROLE_PIN != S3_LINK_DATA && S3_ROLE_PIN != S3_LINK_UART_TX &&
       S3_ROLE_PIN != S3_LINK_UART_RX, "the strap pin is not a link pin");

    /* ---- D2: the handshake ------------------------------------------- */
    printf("\n=== O6/D2 HANDSHAKE ===\n");
    pB.present = 1; pB.role = S3_ROLE_B; pB.patch = 7;
    pB.voice_base = 3; pB.voices = 3; pB.crc = CRC;
    pA.present = 1; pA.role = S3_ROLE_A; pA.patch = 7;
    pA.voice_base = 0; pA.voices = 3; pA.crc = CRC;

    ck(s3_handshake_check(&RA, 7, CRC, &pB) == S3_HS_OK, "a correct pair passes");
    ck(s3_handshake_check(&RB, 7, CRC, &pA) == S3_HS_OK, "and passes from B's side");

    { s3_peer p = pB; p.present = 0;
      ck(s3_handshake_check(&RA,7,CRC,&p) == S3_HS_NO_PEER, "a missing peer is caught"); }
    { s3_peer p = pB; p.role = S3_ROLE_A;
      ck(s3_handshake_check(&RA,7,CRC,&p) == S3_HS_BAD_PAIR, "two masters is caught"); }
    { s3_peer p = pB; p.patch = 8;
      ck(s3_handshake_check(&RA,7,CRC,&p) == S3_HS_PATCH_DIFFERS, "a patch mismatch is caught"); }
    { s3_peer p = pB; p.crc = CRC ^ 1ul;
      ck(s3_handshake_check(&RA,7,CRC,&p) == S3_HS_CRC_DIFFERS,
         "SAME PATCH but DIFFERENT COEFFICIENTS is caught (the silent one)"); }
    { s3_peer p = pB; p.voice_base = 0;
      ck(s3_handshake_check(&RA,7,CRC,&p) == S3_HS_BASE_OVERLAP,
         "overlapping global voice ranges is caught (the D3 species)"); }

    /* ---- D2: patch-follow (chip A is the source of truth) ------------- */
    printf("\n=== O6/D2 PATCH-FOLLOW ===\n");
    ck(s3_follow_patch(S3_ROLE_B, 1, S3_ROLE_A, 4, 9) == 9,
       "B with a valid peer follows A's patch");
    ck(s3_follow_patch(S3_ROLE_B, 1, S3_ROLE_A, 9, 9) == -1,
       "B already on A's patch does nothing");
    ck(s3_follow_patch(S3_ROLE_A, 1, S3_ROLE_B, 4, 9) == (t == 5 ? 9 : -1),
       "A NEVER follows -- it is the source of truth (tooth 5 flips this)");
    ck(s3_follow_patch(S3_ROLE_B, 0, S3_ROLE_A, 4, 9) == (t == 6 ? 9 : -1),
       "B with NO peer follows nobody: single-board mode (tooth 6 flips)");
    ck(s3_follow_patch(S3_ROLE_B, 1, S3_ROLE_B, 4, 9) == -1,
       "B never follows another B -- an invalid pair is no truth source");
    ck(s3_follow_holds_stepper(S3_ROLE_B, 1, S3_ROLE_A) == 1,
       "B's own stepper stands down while a valid peer is present");
    ck(s3_follow_holds_stepper(S3_ROLE_B, 0, S3_ROLE_A) == (t == 7 ? 1 : 0),
       "B with no peer keeps its stepper: today's behaviour (tooth 7 flips)");
    ck(s3_follow_holds_stepper(S3_ROLE_A, 1, S3_ROLE_B) == 0,
       "A's stepper is never held");

    /* ---- D2: the wire codec ------------------------------------------- */
    printf("\n=== O6/D2 WIRE CODEC ===\n");
    {
        s3_link_frame f;
        size_t i;
        int allrej = 1;
        memset(&f, 0, sizeof f);
        f.m0 = S3_LINK_MAGIC0; f.m1 = S3_LINK_MAGIC1;
        f.role = S3_ROLE_B; f.voice_base = 3; f.voices = 3;
        f.patch = 7; f.crc = 0xABCD1234u;
        f.sum = s3_link_sum(&f);
        /* THE CASE THE FIRST SHIPPED BUILD FAILED: a clean frame, sender and
         * receiver computing the same checksum. sizeof-2 coverage put the sum
         * field inside its own range and rejected every frame (playbook 75). */
        ck(f.sum == s3_link_sum(&f),
           "a CLEAN frame verifies (the case the first build failed)");
        ck(offsetof(s3_link_frame, sum) + sizeof(uint16_t)
               <= sizeof(s3_link_frame) &&
           offsetof(s3_link_frame, sum) >= sizeof(s3_link_frame) - 4,
           "sum is the last field and outside its own coverage");
        /* every COVERED byte, corrupted, must be caught */
        for (i = 0; i < offsetof(s3_link_frame, sum); ++i) {
            s3_link_frame g = f;
            ((uint8_t *)&g)[i] ^= 0x5A;
            if (g.sum == s3_link_sum(&g)) allrej = 0;
        }
        ck(allrej, "every covered byte, corrupted, is rejected");
        ck(sizeof(f.crc) == 4 && sizeof(f.patch) == 2,
           "fixed-width fields: the host gates the layout the WIRE carries");
        if (t == 4) {
            /* THE TOOTH: recompute the checksum the way the first build did
             * -- over sizeof-2 bytes -- and require the round trip to FAIL,
             * proving this gate would have caught that build. */
            uint16_t bad = 0; const uint8_t *p = (const uint8_t *)&f;
            for (i = 0; i < sizeof(s3_link_frame) - 2; ++i)
                bad = (uint16_t)(bad + p[i] * 31u + 7u);
            ck(f.sum == bad, "TOOTH 4: the sizeof-2 checksum round-trips");
        }
    }

    printf("\n%s\n", fails ? "D1/D2 LOGIC: RED" : "D1/D2 LOGIC: GREEN");
    printf("⚠ NO WIRE EXISTS. Pins, peripherals and the UART are UNPROVEN.\n");
    return fails ? 1 : 0;
}
