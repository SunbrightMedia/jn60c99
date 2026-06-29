/* juno_voice_constants.c — the System-8 framework value-slots that the JUNO-60
 * voice render reads (the "Mod Sens / MOD Sens / Velocity Sens / Bend Sens VCF"
 * descriptor block + the master M.CV slot). The construction-default writer zeros
 * these; the registration framework then writes a fixed non-zero default into each.
 *
 * PROVENANCE — every value is a binary constant, not a capture paste:
 *   each is LUT[tableId][step], whose 32-bit pattern is an exact .rdata literal
 *   (verified in data_sections/seg_rdata_935650.bin). The DB→engine map
 *   (refs/db_engine_map_full.json) shows all four sens slots read 0 in ALL 64
 *   factory banks (default-riding) — so for every factory preset the engine's
 *   framework default IS the value, and juno_preset_load never overwrites it.
 *
 * HONEST LIMITATION (do not overstate):
 *   - The decode *position* for these descriptors cannot be pinned from any
 *     factory bank (they ride the default everywhere), so a preset that set them
 *     to a NON-default step would not yet round-trip. The PD-pad memory capture
 *     shows off 7472 (Bend Sens VCF) at a DIFFERENT value (0x3e48c8c9) than the
 *     factory default (0x3e2cacad) — evidence this slot CAN be patched per-preset.
 *     We therefore apply these BEFORE juno_preset_load, so a future position-pinned
 *     decode can override them; for the 64 factory banks the default is exact.
 *   - In record-0 the three voice-block scalers are gated OFF in the DSP (Mod Sw
 *     @4000=0, MOD Sw @7376=0, Vel mult @7504=0), so they are sonically inert;
 *     they are written to reproduce the engine's framework STATE, not to colour
 *     the sound. M.CV @10816 is a stored master slot the render path never reads.
 */
#include "juno_engine.h"
#include "juno_params.h"

void juno_voice_constants(unsigned char *st)
{
    /* Per-voice main-block framework scalers — LUT tableId 22 (= step/255), the
     * contiguous n/255 .rdata table at rva 0x96d300..; broadcast to all 8 voices
     * (the param system's per-voice fan-out, +10512*v). */
    juno_param_apply_lut(st, 3984, 22,  22, /*broadcast=*/1); /* Mod Sens DCO  22/255 = LUT22[22]  @rva 0x96d338 */
    juno_param_apply_lut(st, 7360, 22, 220, /*broadcast=*/1); /* MOD Sens VCF 220/255 = LUT22[220] @rva 0x96d650 */
    juno_param_apply_lut(st, 7424, 22, 105, /*broadcast=*/1); /* Velocity Sens 105/255 = LUT22[105] @rva 0x96d484 */
    juno_param_apply_lut(st, 7472, 22,  43, /*broadcast=*/1); /* Bend Sens VCF  43/255 = LUT22[43]  @rva 0x96d38c */

    /* M.CV master value-slot (param_id 111), pitch/CV LUT tableId 32; index 36 =
     * 2.0003 = .rdata 0x400004f7 @rva 0x97f6a0 (same table as the voice M.CV pitch
     * base 6.66847 = LUT32[92]). Master slot — render path never reads it; write
     * once (broadcast=0). Do NOT broadcast: 10816 + 7*10512 = 84400 lands in the
     * shared region [84000,90000) and would clobber the DSP-read coefficient that
     * engine_init puts at 84400 (voice_render.c). */
    juno_param_apply_lut(st, 10816, 32, 36, /*broadcast=*/0); /* M.CV (master) 2.0003 = LUT32[36] @rva 0x97f6a0 */
}
