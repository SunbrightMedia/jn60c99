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

/* 127, NOT the 118 of docs/preset/COMPACT_FORMAT.md. MEASURED here, against the
 * oracle, and the difference is a real defect in that format -- see the header
 * comment above and docs/engineb/COMPACT_FORMAT_FINDING.md. */
#define EB_PATCH_BYTES   127
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

/* Internal consistency of this file's own tables. 0 = ok. */
int eb_patch_selftest(void);

#endif /* ENGINEB_EB_PATCH_H */
