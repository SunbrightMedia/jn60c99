/* s3_role.h -- O6/D4: ONE IMAGE, FLASHED TWICE, ROLE DECIDED BY A STRAP PIN.
 *
 * WHY ONE IMAGE. Two images means two things to build, two to flash, two to
 * keep in step, and a whole class of defect where chip A is newer than chip B
 * and nothing says so. The engine is identical on both chips; only four
 * numbers differ. So the difference is a PIN, not a build.
 *
 * THE ROLES (FINAL_GUIDE D1, user-decided 2026-08-12: ONE DAC, chip A is the
 * only clock):
 *
 *   chip A -- MASTER. I2S0 TX master into the single audio board; I2S1 RX
 *             master from chip B. Owns the DAC. Owns GLOBAL voices 0..2.
 *   chip B -- SLAVE.  I2S TX slave, clocked by A's BCLK/LRCK. No DAC of its
 *             own, no clock of its own. Owns GLOBAL voices 3..5.
 *
 * Drift between the chips is then impossible BY CONSTRUCTION rather than
 * corrected, and chip B gets its sample tick for free.
 *
 * ⚑ WHY THE DECISION IS A PURE FUNCTION AND NOT AN `if` IN app_main.
 *
 * There is no second board in this environment. A role decision written inline
 * could not be gated at all, and would first execute on hardware -- which is
 * how this session has already paid for O3's missing knob source (playbook 67)
 * and MSPROF's stub clock (playbook 72): logic whose first run is on silicon.
 * `s3_role_of` and `s3_role_config` take no hardware and touch nothing, so
 * tools/engineb/d4_role_gate.c can exercise every case on a workstation.
 *
 * What the gate CANNOT prove is that the pin reads what the wire does. That is
 * hardware, it is stated here rather than assumed, and it stays UNPROVEN until
 * two boards exist.
 */
#ifndef JUNO_S3_ROLE_H
#define JUNO_S3_ROLE_H

/* THE STRAP PIN. Free on this board: 5/6/7 are I2S, 18 is MIDI RX, 19/20 are
 * USB, 26-37 are flash and the octal PSRAM, 43/44 are the console UART, and
 * 0/45/46 are boot straps. GPIO 4 is next to the I2S trio, so the jumper is a
 * short wire to the ground pin beside it. */
#ifndef S3_ROLE_PIN
#define S3_ROLE_PIN 4
#endif

/* ⚑ THE SENSE IS DELIBERATE: PULLED UP = A, TIED TO GROUND = B.
 *
 * An unconnected pin reads HIGH through the internal pull-up, so a board with
 * NO jumper is chip A -- the master, the one with the DAC, the one that makes
 * sound on its own. That is the configuration a single board has today, so an
 * unstrapped board keeps behaving exactly as this firmware already does, and
 * the two-chip build is the one that requires a deliberate act.
 *
 * The opposite sense would make a broken jumper turn the master into a mute
 * slave, which is a silent failure. This way a broken jumper produces TWO
 * masters -- which the pair check below catches and says out loud. */
enum { S3_ROLE_A = 0, S3_ROLE_B = 1 };

typedef struct {
    int role;          /* S3_ROLE_A | S3_ROLE_B                             */
    int voice_base;    /* GLOBAL index of this chip's local voice 0 (D3)    */
    int voices;        /* how many voices this chip sounds                  */
    int i2s_master;    /* 1 = generates BCLK/LRCK, 0 = receives them        */
    int owns_dac;      /* 1 = drives the audio board                        */
} s3_role_cfg;

/* SIX VOICES OVER TWO CHIPS, three each. The six are GLOBAL 0..5, which is
 * D3's assumption and is flagged there as the user's audible decision -- the
 * CONDITION tables have eight entries and the JUNO-60 has six voices. */
#define S3_VOICES_PER_CHIP 3

/* strap_reads_low: 1 when S3_ROLE_PIN is pulled to ground. */
static int s3_role_of(int strap_reads_low)
{
    return strap_reads_low ? S3_ROLE_B : S3_ROLE_A;
}

static s3_role_cfg s3_role_config(int role)
{
    s3_role_cfg c;
    c.role       = role;
    c.voices     = S3_VOICES_PER_CHIP;
    c.voice_base = (role == S3_ROLE_B) ? S3_VOICES_PER_CHIP : 0;
    c.i2s_master = (role == S3_ROLE_A);
    c.owns_dac   = (role == S3_ROLE_A);
    return c;
}

/* ⚑ THE MIS-STRAP CHECK, AND WHY IT IS HERE RATHER THAN LEFT TO NOTICE.
 *
 * D3 was a SILENT defect: two chips dealing the same analog scatter, with
 * nothing crashing and every CRC still matching. A mis-strapped pair is the
 * same species. Two chip As fight over one DAC's clock; two chip Bs make no
 * clock at all and the instrument is silent with no error anywhere.
 *
 * Neither chip can see the other's pin, so this cannot be checked locally --
 * it is checked when the link handshake reports the peer's role (D2). This
 * function is what that handshake calls, and it exists now so the rule is
 * written down with the roles rather than invented later.
 *
 * Returns 0 if the pair is valid, non-zero for the fault, so a caller may
 * print it and mute rather than play half an instrument. */
enum { S3_PAIR_OK = 0, S3_PAIR_TWO_MASTERS = 1, S3_PAIR_TWO_SLAVES = 2 };

static int s3_pair_check(int my_role, int peer_role)
{
    if (my_role == S3_ROLE_A && peer_role == S3_ROLE_A) return S3_PAIR_TWO_MASTERS;
    if (my_role == S3_ROLE_B && peer_role == S3_ROLE_B) return S3_PAIR_TWO_SLAVES;
    return S3_PAIR_OK;
}

static const char *s3_role_name(int role)
{
    return (role == S3_ROLE_A) ? "A (MASTER, owns the DAC and the clock)"
                               : "B (SLAVE, clocked by A, no DAC)";
}

#endif /* JUNO_S3_ROLE_H */
