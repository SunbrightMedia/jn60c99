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

    printf("\n%s\n", fails ? "D1/D2 LOGIC: RED" : "D1/D2 LOGIC: GREEN");
    printf("⚠ NO WIRE EXISTS. Pins, peripherals and the UART are UNPROVEN.\n");
    return fails ? 1 : 0;
}
