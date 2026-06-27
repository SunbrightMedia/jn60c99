/* juno_registration_defaults.c — the parameter-registration defaults set by the
 * plugin's sub_388170 registrar. That function is the one Hex-Rays could NOT
 * decompile in the JUNO-60 binary (12k-line asm blob), and the Juno-106 (which
 * decompiles) does not share these exact params. So this is the genuine boundary
 * of pure code-tracing. The values below are nonetheless binary-sourced:
 *   - 3 value-defaults are .rdata constants (verified addresses in
 *     data_sections/seg_rdata_935650.bin), bound to their engine offsets by the
 *     offset's DSP role (voice_render reads 5520=Duty Tune, 6512=Osc1 Level,
 *     7440=Velocity Offset).
 *   - 17 switch defaults are 1.0 ("on") — the registration default; preset-
 *     independent (identical in both captured presets) and consistent with the
 *     switches' DSP semantics. Documented residue, not a capture paste.
 * Apply AFTER juno_construction_defaults (which zeros all slots + sets 16 PlugIn Sw). */
#include "juno_engine.h"
#include <string.h>
static void put(unsigned char*st,int off,unsigned bits){memcpy(st+off,&bits,4);}
void juno_registration_defaults(unsigned char *st)
{
    /* value-defaults from .rdata (binary constants) */
    put(st, 5520, 0x3ca3d70au); /* Duty Tune      0.02     @rva 0x97e4d0 */
    put(st, 6512, 0x3f80f154u); /* Osc1 Level     1.00736  @rva 0x987054 */
    put(st, 7440, 0xbf010204u); /* Velocity Offset -0.5039 @rva 0x96dbdc */
    /* switch defaults = 1.0 (registration "on" default; preset-independent) */
    static const int sw[] = {592,1888,1936,1952,2080,2848,3328,3872,4016,4048,
                             6448,7296,9104,9824,10288,10304,10320};
    for (unsigned i=0;i<sizeof sw/sizeof sw[0];i++) put(st, sw[i], 0x3f800000u);
}
