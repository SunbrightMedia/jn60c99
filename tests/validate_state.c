/* validate_state.c — per-stage validation against the live plugin's engine state.
 * Initialises our engine (chorus_init + engine_init + captured runtime coeffs) and
 * compares it to the memory-scanned plugin state (state_dump/), over the offsets the
 * DSP actually reads. A "stable gap" (offset stable across t0/t1 but != our value)
 * is a real transcription/coefficient error; dynamic state (t0!=t1) is expected to
 * differ. Passes iff zero stable gaps.
 *   argv: <state_t0.bin> <state_t1.bin> <dsp_read_offsets.txt>
 */
#include "../src/juno_engine.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define N 12058624
int main(int argc, char **argv)
{
    if (argc < 4) { printf("usage: %s t0 t1 offs\n", argv[0]); return 2; }
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    JF(st, 16) = 96000.0f;
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    static unsigned char t0[N], t1[N];
    FILE *f0 = fopen(argv[1],"rb"), *f1 = fopen(argv[2],"rb"), *fo = fopen(argv[3],"r");
    if (!f0||!f1||!fo) { printf("FAIL: missing inputs (run `make validate`)\n"); return 2; }
    if (fread(t0,1,N,f0)!=N || fread(t1,1,N,f1)!=N) { printf("FAIL: short dump\n"); return 2; }
    int checked=0, match=0, dyn=0, gap=0; char line[64];
    while (fgets(line,sizeof line,fo)) {
        long o = atol(line); if (o<=0 || o+4>N) continue; checked++;
        int eq_plugin = !memcmp(st+o, t0+o, 4);
        int stable    = !memcmp(t0+o, t1+o, 4);
        if (eq_plugin) match++;
        else if (!stable) dyn++;                     /* dynamic state: expected */
        else { gap++; if (gap<=20) { float a,b; memcpy(&a,st+o,4); memcpy(&b,t0+o,4);
                 printf("  STABLE GAP off=%ld ours=%g plugin=%g\n", o, a, b); } }
    }
    printf("checked %d DSP-read offsets: match=%d, dynamic-state(expected diff)=%d, STABLE GAPS=%d\n",
           checked, match, dyn, gap);
    if (gap) { printf("FAIL: %d stable gaps (real errors)\n", gap); return 1; }
    printf("OK: every stable/coefficient field matches the live plugin (%d dynamic-state diffs expected)\n", dyn);
    free(st); return 0;
}
