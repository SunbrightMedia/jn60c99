/* effect_modes.h — per-patch recall for EFFECT TYPE modes 1 and 5.
 *
 * The master's slot-2 selector v551 = EFFECT TYPE (rec 634) picks the algorithm:
 *   0 = DlyDly (overdrive)   1 = DlyPan (DISTORTION + PANNER)   2/3 = DlyCh (chorus)
 *   4 = DlyFlSt (flanger)    5 = DlyMfx1 (CHORUS/ENSEMBLE variant)   dflt = reverb.
 * Modes 2/3/4 (chorus) are supplied by juno_engine_prepare + chorus_recall; modes 1
 * and 5 route to blocks juno_engine_prepare leaves zero (86288 / 96336), so their
 * structural coefficients + per-patch recall must be written here when a patch selects
 * them. All values are bit-exact from the binary (see effect_luts.h / docs/EFFECT_MODES.md).
 *
 * v551 routing: the master reads EFFECT TYPE through params+112, which the driver
 * points at the engine cell state[JUNO_PROG_EFX]. juno_apply_effect_modes writes the
 * patch's EFFECT TYPE there so slot 2 follows the loaded patch (mirrors DELAY TYPE
 * -> JUNO_PROG_DLY for slot 1). */
#ifndef JUNO_EFFECT_MODES_H
#define JUNO_EFFECT_MODES_H

/* Slot-2 (EFFECT TYPE) program cell — a scratch state cell the driver points the
 * master's params+112 chase at (adjacent to JUNO_PROG_DLY = 11022056; the master
 * does not read 11022060, verified). Holds the int EFFECT TYPE 0..5. */
#define JUNO_PROG_EFX  11022060

#ifdef __cplusplus
extern "C" {
#endif

/* Apply EFFECT TYPE modes 1 & 5 recall for the patch at record `rec` (record start =
 * blob - 16). Writes state[JUNO_PROG_EFX] = EFFECT TYPE (slot-2 routing) for every
 * patch, the shared slot-2 "Effect SW" wet level (84544) for every patch, and — when
 * the patch selects mode 1 or mode 5 — that mode's structural block + per-patch cells.
 * Modes 0/2/3/4 leave their blocks to prepare/chorus_recall. */
void juno_apply_effect_modes(unsigned char *state, const unsigned char *rec);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_EFFECT_MODES_H */
