/* jx_recall.c -- apply a JX-3P bank patch to voice-0's coefficient block.
 *
 * The JX recall is the plugin's dispatch (0x3EBB00) fired over the front-panel
 * pool set in pool order. Proven separable (like the JUNO's juno_apply.c): 32
 * active pools, each a function of ONE input byte (2*pool+8 nibble-pair decode),
 * plus 7 interacting cells resolved by the value-pool-wins rule. The per-pool
 * single-byte tables in jx_recall_lut.h are the COMPLETE domain enumeration of
 * the plugin's own dispatch (captured under Unicorn), i.e. the exact function.
 *
 * PROVEN: jx3p/tools/jx_recall_gate.sh -- port block == oracle recall reference
 * bit-for-bit, all 64 factory patches (recall_ref_emu.py).
 *
 * blob_pos = 2*pool + 8, dispatch_idx = pool + 740 (name-proven, synth/jx3p.json).
 */
#include <stdint.h>
#include <string.h>
#include "jx_recall.h"
#include "jx_recall_lut.h"

#define BANK_HEADER 23
#define BANK_STRIDE 20223
#define BANK_BLOB   16
#define BANK_COUNT  64

static int decode_pool(const unsigned char *blob, int pool)
{
    int p = 2 * pool + 8;
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF);
}

static void put(unsigned char *blk, int cell, uint32_t v)
{
    memcpy(blk + cell, &v, 4);
}

/* Apply patch idx into voice-0 block `blk` (>= JX_RECALL_BLOCK bytes), which must
 * already hold the clean prepared-engine base. Returns #cells written. */
int jx_bank_apply(unsigned char *blk, const unsigned char *bank, int idx)
{
    const unsigned char *blob;
    int i, e, n = 0;
    if (!blk || !bank || idx < 0 || idx >= BANK_COUNT) return 0;
    blob = bank + BANK_HEADER + idx * BANK_STRIDE + BANK_BLOB;

    /* separable compose: every (pool,cell) entry except the overridden cells */
    for (e = 0; e < JX_RECALL_N_ENTRIES; ++e) {
        const jx_recall_entry *ent = &JX_RECALL[e];
        int ov = 0, k;
        for (k = 0; k < JX_RECALL_N_OVERRIDE; ++k)
            if (JX_RECALL_OVERRIDE[k].cell == ent->cell) { ov = 1; break; }
        if (ov) continue;                      /* interacting cell: handled below */
        put(blk, ent->cell, ent->v[decode_pool(blob, ent->pool)]);
        ++n;
    }
    /* interacting cells: value-pool wins (-1 => keep clean base) */
    for (i = 0; i < JX_RECALL_N_OVERRIDE; ++i) {
        const jx_recall_ov *o = &JX_RECALL_OVERRIDE[i];
        if (o->value_pool < 0) { put(blk, o->cell, o->clean); ++n; continue; }
        for (e = 0; e < JX_RECALL_N_ENTRIES; ++e)
            if (JX_RECALL[e].pool == o->value_pool && JX_RECALL[e].cell == o->cell) {
                put(blk, o->cell, JX_RECALL[e].v[decode_pool(blob, o->value_pool)]);
                break;
            }
        ++n;
    }
    return n;
}
