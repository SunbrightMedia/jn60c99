#include <stdlib.h>
/* d4_role_gate.c -- O6/D4: every role case, on a workstation, with teeth.
 *
 * There is no second board here. This gate exists so the ROLE DECISION does
 * not first execute on silicon -- the failure mode this session has already
 * paid for twice (playbook 67, 72).
 *
 * ⚠ WHAT IT CANNOT PROVE: that the pin reads what the wire does. That is
 * hardware and stays UNPROVEN until two boards exist. Everything below is the
 * LOGIC only, and saying so is the point.
 *
 * usage: d4_role_gate [tooth]      (exit 0 = green)
 */
#include <stdio.h>
#include <string.h>
#include "s3_role.h"

static int fails;
static void ck(int cond, const char *what)
{
    printf("  %-62s %s\n", what, cond ? "ok" : "*** FAIL");
    if (!cond) ++fails;
}

int main(int argc, char **argv)
{
    int tooth = (argc > 1) ? atoi(argv[1]) : 0;
    s3_role_cfg A = s3_role_config(s3_role_of(0));   /* pin high  -> A */
    s3_role_cfg B = s3_role_config(s3_role_of(1));   /* pin low   -> B */

    if (tooth == 1) A.voice_base = B.voice_base;     /* D3 regression */
    if (tooth == 2) B.i2s_master = 1;                /* two clocks   */
    if (tooth == 3) A.owns_dac = B.owns_dac = 1;     /* two DACs     */

    printf("=== O6/D4 ROLE BY STRAP PIN (GPIO %d) ===\n\n", S3_ROLE_PIN);
    printf("  UNSTRAPPED pin reads HIGH -> %s\n", s3_role_name(A.role));
    printf("  TIED TO GROUND            -> %s\n\n", s3_role_name(B.role));

    ck(A.role == S3_ROLE_A, "an unstrapped board is chip A (today's behaviour)");
    ck(B.role == S3_ROLE_B, "a grounded strap is chip B");

    /* D3: the two chips must own DISJOINT, CONTIGUOUS global voices */
    ck(A.voice_base == 0,                   "chip A owns global voice 0 upward");
    ck(B.voice_base == A.voices,            "chip B's base continues where A ends");
    ck(A.voice_base != B.voice_base,        "the bases DIFFER (the D3 defect)");
    ck(A.voices + B.voices == 6,            "six voices in total (END_GOAL)");

    /* D1: exactly one clock, exactly one DAC */
    ck(A.i2s_master + B.i2s_master == 1,    "EXACTLY ONE chip generates the clock");
    ck(A.owns_dac  + B.owns_dac  == 1,      "EXACTLY ONE chip drives the DAC");
    ck(A.i2s_master && A.owns_dac,          "the clock and the DAC are the SAME chip");

    /* the mis-strap check */
    ck(s3_pair_check(S3_ROLE_A, S3_ROLE_B) == S3_PAIR_OK,   "A+B is a valid pair");
    ck(s3_pair_check(S3_ROLE_B, S3_ROLE_A) == S3_PAIR_OK,   "B+A is a valid pair");
    ck(s3_pair_check(S3_ROLE_A, S3_ROLE_A) == S3_PAIR_TWO_MASTERS,
       "TWO MASTERS is caught, not played");
    ck(s3_pair_check(S3_ROLE_B, S3_ROLE_B) == S3_PAIR_TWO_SLAVES,
       "TWO SLAVES is caught, not played (silence with no error)");

    printf("\n%s\n", fails ? "D4 LOGIC: RED" : "D4 LOGIC: GREEN");
    printf("⚠ the PIN-to-WIRE mapping is UNPROVEN until two boards exist.\n");
    return fails ? 1 : 0;
}
