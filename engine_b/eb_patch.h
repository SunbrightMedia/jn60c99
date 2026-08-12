/* eb_patch.h — THE PARAMETER PATH. Engine B's only parameter input.
 *
 * Engine B takes a COMPACT PATCH -- a few dozen bytes -- instead of the plugin's
 * 20,223-byte record. The starting point is docs/preset/COMPACT_FORMAT.md's
 * 118-byte set.
 *
 * *** THAT SET IS INSUFFICIENT. MEASURED THIS SESSION, AND IT IS A REAL DEFECT
 * IN THE FORMAT, NOT A DETAIL. ***
 *
 * Reconstructing each patch from its 118 bytes into patch 0's record as a
 * template and RENDERING it through the oracle (48 kHz, note 60 velocity 100,
 * 8,000 frames) diverges from the original record on 7 of the 64 factory
 * patches -- 1, 9, 17, 25, 33, 41, 49 -- by between -3.3 dB and +2.6 dB relative.
 * Those are the seven ARPEGGIATOR patches, and the cause is that the format
 * carries none of ARPEGGIO SW, TYPE or STEP (blob 282/283, 290/291, 298/299).
 *
 * The reason is visible in the format's own stated method: the live-byte scan
 * hashed AUDIO CELLS, and with no transport clock the arpeggiator writes none.
 * A byte set derived by probing is only as complete as the probe, which is the
 * same structural blindness that hid KEY ASSIGN, the fine-FX leaf table and the
 * MONO retrigger latch from the port's gates.
 *
 * Adding those six bytes gives 64/64 BIT-EXACT rendered audio -- a strictly
 * stronger check than the engine-state hash the 118-byte claim rests on.
 * Three more are added on top, and they cost nothing because they are constant
 * across the factory bank -- which is exactly why the scan could not see them:
 *   blob 112  the high-nibble byte of ASSIGN MODE. Without it, KEY ASSIGN is
 *             recoverable only because the template happens to supply a zero
 *             nibble. KEY ASSIGN is the single parameter this project has
 *             already been bitten hardest by; it must not be carried by luck.
 *   blob 466/467  F ENV VARIATION, the VCF envelope SOURCE -- the port's own
 *             "pluck has a slow attack" bug. It VARIES across the bank (value 1
 *             in patches 1, 5, 10, 35, 36, 47, 61) yet the 118-byte set carries
 *             neither of its bytes. MEASURED: dropping it happens to be audio-
 *             inert under this driving, so it is a latent hole rather than a
 *             demonstrated audible defect -- but it is a parameter that varies
 *             and is not stored, which is not a state a format may ship in.
 *
 * TOTAL: 127 bytes. Still 159 patches in a 24LC256, versus the 277 the 118-byte
 * figure promises.
 *
 * WHAT IS STILL OWED, and it is the same debt COMPACT_FORMAT.md already lists:
 * this was derived by driving the PORT. Per docs/trackb/THREE_WAY_GATE.md only
 * a scan against the PLUGIN can retire the claim, and the factory bank cannot
 * exercise a parameter no factory patch moves (EFFECT TYPE 4 / FLANGER remains
 * the named example).
 *
 * It is wired in from the first commit ON PURPOSE. A parameter path retro-fitted
 * later is a parameter path that quietly grew a second, undocumented input --
 * which is how the sealed port ended up with a fine-FX family it recalled from
 * nowhere and left at zero. eb_patch_decode() is the ONLY writer of eb_params,
 * and eb_patch_coverage() answers, mechanically, whether the 118 bytes actually
 * carry every parameter engine B reads.
 *
 * BYTE ENCODING (the plugin's own, transcribed from src/juno_apply.c
 * record_byte()): the record body past the 16-character name is NIBBLE-PACKED.
 * A parameter at record offset `roff` is
 *
 *     value = ((rec[roff] & 0xF) << 4) | (rec[roff+1] & 0xF)
 *
 * and the blob pointer is record+16, so a blob offset is roff-16. Front-panel
 * parameter number p lives at roff = 16 + 2p. Both bytes of a pair must be
 * carried by the compact set or the parameter is not readable at all -- which is
 * exactly the condition eb_patch_coverage() reports.
 */
#ifndef ENGINEB_EB_PATCH_H
#define ENGINEB_EB_PATCH_H

#include <stdint.h>
#include <stddef.h>
#include "eb_types.h"

/* 133. It was 118, then 127, and now 133, and each step was a MEASUREMENT
 * finding the previous one short. The last six (2026-08-12):
 *
 *   3270 3271 3272   CHORUS PRE DELAY / LOW CUT / HIGH CUT (record 3286-3288)
 *   3934             REVERB DENSITY                        (record 3950)
 *        PROVEN by execution: tools/engineb/devrecall_gate.py --patch-scan
 *        perturbs every record position over six base patches and reports the
 *        112 that move the recalled coefficients. These four are among them
 *        and were not carried. All four are CONSTANT in all 64 factory
 *        patches, which is exactly why the byte scan that produced the
 *        127-byte set could not see them -- the same blindness this header
 *        has always warned about, caught by the same method that produced it.
 *   490 491          BEND GAIN                             (record 506-507)
 *        NOT a scan result, and that is the point. The scan calls it INERT,
 *        because src/juno_apply.c:447-453 multiplies it by juno_curve(4,
 *        BEND RANGE) and juno_curve(22, BEND SENS), and with any of those at
 *        a zeroing value the whole product is 0 whatever BEND GAIN does. A
 *        single-byte perturbation scan can NEVER see a parameter that is one
 *        factor of a product of several. It is carried because the recall
 *        path READS it, which is the rule that does not depend on a probe
 *        being clever enough.
 *
 * The 2026-08-11 design said 132. It named record 506 and not 507 -- and 506
 * is the HIGH nibble, which for a parameter whose range is 0..3 can only ever
 * contribute multiples of 16 and therefore cannot carry the value at all. A
 * nibble-packed parameter needs BOTH its bytes or it is not readable, which is
 * the condition eb_patch_coverage() has always reported. So: 133, not 132.
 *
 * 134 (2026-08-12, C3). blob 110, LEGATO's HIGH nibble. MEASURED, not argued:
 * the round trip 134 bytes -> template -> juno_bank_apply -> coefficients is
 * BIT-IDENTICAL on 64/64 patches at three rates against a REAL template, an
 * all-zero one AND a RANDOMISED one; at 133 the randomised template DIVERGES
 * on patches 5 and 47 (tools/engineb/devboot/patchbank.c, executed).
 * src/juno_apply.c:652 reads LEGATO as ((blob[110]&0xF)<<4)|(blob[111]&0xF)
 * and tests `lg == 1 && as == 1`; 5 and 47 are the only two patches that
 * satisfy it, which is exactly what the sweep named.
 *
 * WHY EVERY GATE PASSED A FORMAT THAT WAS SHORT -- two blind spots, both
 * demonstrated by execution, now playbook entries 41 and 42:
 *   (a) --patch-scan's probe values are {0x00,0x03,0x0C,0x7F}, i.e. low
 *       nibbles {0,3,12,15}. LEGATO's only live value is 1. A scan that
 *       cannot EMIT the value an equality tests for is blind to 11 of the 16
 *       nibble values.
 *   (b) none of its six base patches satisfies LEGATO==1 && ASSIGN==1, so the
 *       gate could not have fired even with the right probe value.
 * The cheap refutation is a WHOLE-RECORD random template -- perturb every
 * non-carried position at once, then bisect. It named the byte in one run.
 *
 * HONEST SEVERITY: from a plugin-authored bank the byte is INERT today.
 * truth/Script.xml gives LEGATO a two-state stringTableRef (READ), so record
 * 126's low nibble is 0 in all 64 factory patches (executed). It becomes a
 * live defect the moment the DEVICE's own 8-bit parameter path writes LEGATO,
 * which END_GOAL item 5 requires: at 133 bytes, values 16..255 are unstorable.
 *
 * WHAT KEEPS IT FROM SHIPPING SHORT AGAIN: eb_patch_record_coverage() checks
 * the carried set against EB_RECALL_POS[] -- the measured list of every record
 * position that moves a recalled coefficient, plus the READ-but-inert list --
 * and eb_patch_selftest() fails if anything is uncovered. */
#define EB_PATCH_BYTES   134
#define EB_RECORD_BYTES  20223
#define EB_BANK_HEADER   23
#define EB_BANK_BLOB_OFF 16
#define EB_BANK_COUNT    64

typedef struct { uint8_t b[EB_PATCH_BYTES]; } eb_patch;

/* The live blob offsets, ascending: docs/preset/compact_bytes.json PLUS the nine
 * this session measured it to be missing. eb_patch_selftest() re-checks the
 * count and the ordering rather than trusting the transcription. */
extern const uint16_t eb_patch_offsets[EB_PATCH_BYTES];

/* Pull patch `idx` out of a full factory bank image into 118 bytes.
 * Returns 0 on success, non-zero on a bad bank or index. */
int eb_patch_extract(const uint8_t *bank, size_t len, int idx, eb_patch *out);

/* Write the 118 bytes back into a 20,223-byte template record, in place. This is
 * the reconstruction half of the format's proof, and it is what firmware does at
 * load time if it ever needs a full record. */
int eb_patch_install(uint8_t *record, const eb_patch *p);

/* One carried blob byte, or -1 if that offset is not in the 118. */
int eb_patch_byte(const eb_patch *p, int blob_off);

/* One SINGLE-BYTE (int1x7) parameter at RECORD offset `roff`, 0..127, or -1 if
 * that byte is not carried. The fine-FX leaves are read this way. */
int eb_patch_param_raw(const eb_patch *p, int roff);

/* One nibble-packed parameter at RECORD offset `roff`, 0..255,
 * or -1 if either of its two bytes is not carried. */
int eb_patch_param(const eb_patch *p, int roff);

/* Decode into eb_params. Returns the number of parameters that could NOT be
 * read because the compact format does not carry them -- 0 means the format is
 * sufficient for every parameter engine B currently reads. Unreadable fields are
 * left at 0 AND counted; they are never silently defaulted.
 *
 * `missing`, if non-NULL, receives up to `nmiss` record offsets of the
 * parameters that were not carried. */
int eb_patch_decode(const eb_patch *p, eb_params *out,
                    int *missing, int nmiss);

/* Same question without a patch: which of engine B's parameters are outside the
 * 118-byte set at all? Returns the count and fills `missing` the same way.
 * Prints nothing. This is the gate the format needs and does not yet have. */
int eb_patch_coverage(int *missing, int nmiss);

/* Parameters whose blob position engine B has NOT derived. Returns the count and
 * fills `names`. This is a different failure from `missing`: UNRESOLVED means the
 * work has not been done, MISSING means the format does not carry a parameter
 * whose position is known. */
int eb_patch_unresolved(const char **names, int n);

/* Human name for a record offset in the binding table ("?" if unknown). */
const char *eb_patch_name_of(int roff);

/* EVERY RECALL-AFFECTING RECORD POSITION MUST BE CARRIED.
 *
 * This is the mechanical net, and it is a different question from
 * eb_patch_coverage(): that one asks whether the parameters THIS FILE KNOWS
 * ABOUT are readable, so a parameter nobody thought to put in TAB is invisible
 * to it. This one asks whether every record byte the port's recall reacts to
 * is stored, and it does not need anybody to have thought of the parameter.
 *
 * EB_RECALL_POS[] is two lists concatenated:
 *   - MEASURED: the 112 positions that move eb_render_coefs or eb_master_coef,
 *     from tools/engineb/devrecall_gate.py --patch-scan (four probe values,
 *     six base patches, three of them with every nibble randomised). PROVEN.
 *   - READ-BUT-INERT: positions the recall path reads whose effect a
 *     single-byte scan structurally cannot see, each with its file:line. READ.
 *
 * Returns the number of positions not carried; fills `missing` with them.
 * 0 is the only acceptable answer. */
int eb_patch_record_coverage(int *missing, int nmiss);

/* Internal consistency of this file's own tables, INCLUDING the record
 * coverage above. 0 = ok. */
int eb_patch_selftest(void);

#endif /* ENGINEB_EB_PATCH_H */
