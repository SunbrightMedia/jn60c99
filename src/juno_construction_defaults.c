/* juno_construction_defaults.c — faithful transcription of the JUNO-60 plugin's
 * construction-default writer sub_7FF91E0066B0 (@ rva 0x3A66B0).
 *
 * The binary function walks the descriptor vector at *(engine+56) (stride-5
 * descriptors; value-slot pointer at element index 4, i.e. desc_base+32).
 * For descriptors 0..589 it indexes the inlined vector directly (v2[5*i+4]);
 * for 590..1120 it resolves the descriptor base via sub_7FF91DFE8120(v1,N)=
 * *v1 + 40*N and writes +32. Both are the same operation: write the value-slot
 * of descriptor N.
 *
 * It writes 0.0f to EVERY descriptor's value-slot, then 1.0f to exactly 16 of
 * them. Those 16 are the "PlugIn Sw" enable switches (descriptors 90,91,200,201,
 * 310,311,420,421,530,531,640,641,750,751,860,861 — 2 per voice across 8 voices,
 * spaced 110 descriptors / 10512 bytes apart). The 1.0-set is read verbatim from
 * the decompile, NOT from the oracle.
 *
 * The descriptor index -> engine byte offset map is the registry
 * (refs/registry_defaults.json) in descriptor order; each of the 1121 descriptors
 * already enumerates its own per-voice offset (no broadcast needed). This is a
 * GENERAL mechanism: it depends only on the registry layout and the binary's
 * 1.0-set, never on any preset's values. */
#include "juno_engine.h"
#include "desc_offsets.h"

void juno_construction_defaults(unsigned char *st)
{
    int i;
    /* zero every descriptor value-slot */
    for (i = 0; i < JUNO_DESC_N; ++i)
        JF(st, JUNO_DESC_OFFSET[i]) = 0.0f;
    /* set the 16 PlugIn Sw descriptors to 1.0f */
    for (i = 0; i < 16; ++i)
        JF(st, JUNO_DESC_OFFSET[JUNO_DESC_ONE[i]]) = 1.0f;
}
