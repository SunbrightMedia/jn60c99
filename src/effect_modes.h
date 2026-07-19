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

/* Slot-2 (EFFECT TYPE) program cell — the plugin's OWN state cell for this int
 * (Prog_ID_EFX; adjacent to JUNO_PROG_DLY = 11022056). PROVEN under Unicorn
 * (scratchpad/ext_sweeps.py 2026-07-19): the plugin's EFFECT TYPE setter writes
 * clamp(v,<=5) here for every value 0..255, and the constructor+setSampleRate
 * leave it at the power-on default 2 (chorus I) — the same value the master's
 * params+112 chase reads (v551==2 at power-on, read via the plugin's own pointer
 * table). Holds the int EFFECT TYPE 0..5. (An earlier revision stored this at
 * the free cell 11022060, which the plugin never writes; that hid the power-on
 * routing from the state gates and made the webapp warm up in the wrong slot-2
 * arm — the plugin free-runs the 2..4 chorus block from power-on.) */
#define JUNO_PROG_EFX  11022052

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
