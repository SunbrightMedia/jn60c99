/* eb_devseq.h -- THE DEVICE RECALL SEQUENCE, ONE SOURCE.
 *
 * WHY THIS FILE EXISTS AT ALL. The firmware's recall and the host tool that
 * computes the firmware's expected answer must run THE SAME SEQUENCE, in the
 * same order, with the same arguments. Write it twice and the two drift, and
 * then a CRC comparison between them measures the drift instead of the chip --
 * which is playbook defect 28 (a gate that cannot be configured like the
 * device) with the roles swapped. So the sequence is here, compiled into both:
 *
 *     tools/engineb/devboot/devcrc.c   the host oracle (-DEB_DEVCELLS)
 *     esp32s3/main/juno_s3_listen.c    the firmware     (-DEB_DEVCELLS)
 *
 * It is EB_DEVCELLS-only by construction: every function below reaches the
 * engine state through ebdev_at(), so there is no flat-array build of it and
 * no second addressing mode to get wrong.
 *
 * THE SEQUENCE IS tools/engineb/devrecall/gate.c's `recall()` + `notes()`,
 * which is what the 1,152-case BIT-IDENTICAL gate certifies. Nothing is added
 * to it here and nothing is reordered; the only thing this file adds is the
 * cell-array reload in front (see eb_devseq_cold below).
 *
 * NOTHING HERE IS JUNO-SPECIFIC EXCEPT THE FIVE PORT ENTRY POINTS IT CALLS.
 * END_GOAL item 7: another port supplies its own bank_apply/spread/condition/
 * tempo/note quintet and the shape is unchanged.
 */
#ifndef EB_DEVSEQ_H
#define EB_DEVSEQ_H

#include <stdint.h>
#include <stddef.h>

/* A one-record "bank": the 23-byte header the port's reader skips plus one
 * 20,223-byte record. juno_bank_apply() indexes bank + 23 + idx*20223 and
 * bound-checks idx against 64 only, so a bank of one at idx 0 is exact. It is
 * 20,246 bytes, touched once per patch change and never in the audio path --
 * PSRAM is the right home for it on a device that has any. */
#define EB_DEVSEQ_BANK_BYTES  (23u + 20223u)

/* Load the baked cell image (tile + segments + scatter, exactly the layout
 * tools/engineb/devboot/bootgen.c writes) into EBDEV_S. `nv` is the number of
 * scatter ROWS in the image and MUST equal EBDEV_NV, or the image was built
 * for a different device; returns non-zero and loads nothing if it does not.
 *
 * THIS IS THE COLD-RECALL STEP, and it is a decision rather than a detail.
 * docs/engineb/DEVICE_RECALL.md defect (1) is that warm recall != cold recall
 * -- 24 of 64 coefficients move when patch A precedes patch B -- while every
 * gate and every host oracle recalls cold. Re-seeding the array from the boot
 * image before each patch change makes the device's recall COLD too, so the
 * host oracle's per-patch CRC is a valid prediction of what the chip must
 * produce. It costs one ~30 KB memcpy from flash inside the burst, which is
 * outside the audio window and therefore free where it matters.
 *
 * THE PRICE, STATED: the port's own order-dependence is then not reproduced.
 * That is correct for a device whose recall is a program change and wrong for
 * one that must imitate a DAW's live parameter edits. When the parameter path
 * (C6) arrives this decision has to be revisited, not inherited. */
int eb_devseq_boot_cells(const unsigned char *img, unsigned nv);

/* Copy the record template and install one compact patch over it. `bank` must
 * be EB_DEVSEQ_BANK_BYTES; `tpl` is the template's first `tpl_bytes` bytes
 * (the rest of the record is zero -- MEASURED irrelevant: the highest record
 * position that reaches a coefficient is 3952). Returns non-zero on a bad
 * argument. */
int eb_devseq_install(unsigned char *bank, const unsigned char *tpl,
                      size_t tpl_bytes, const uint8_t *patch_bytes);

/* juno_bank_apply + seed_voices(=broadcast) + unison spread + CONDITION +
 * LFO tempo, in the gate's own order. `bpm` is the host tempo the arpeggiated
 * patches' LFO sync uses; the gate uses 128.0f. */
void eb_devseq_recall(unsigned char *bank, float bpm);

/* Sound `n` notes. voice[i] is the VOICE INDEX -- this is deliberately not an
 * allocator. C4 owns the allocator; C3 owns proving that recall on the chip
 * produces the right coefficients, and picking the voice by hand keeps the two
 * questions apart. */
void eb_devseq_notes_on(const int *voice, const int *midi, const int *vel, int n);
void eb_devseq_notes_off(const int *voice, int n);

/* CRC-32 (IEEE 802.3, reflected, init/final 0xFFFFFFFF -- the zlib one).
 * DEFINED HERE rather than taken from the platform: the host oracle and the
 * chip must compute the same function, and "esp_crc32_le's argument convention"
 * is exactly the kind of assumption that turns a mismatch into a mystery. */
uint32_t eb_devseq_crc32(const void *p, size_t n);

#endif /* EB_DEVSEQ_H */
