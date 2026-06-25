/* juno_preset.c — see juno_preset.h. Capture-free: bank nibble-decode (proven
 * layout, docs/PRESET_BANK_FORMAT.md) -> per-DB step -> engine offset+tableId
 * (src/juno_param_map.h, from Script.xml + the vtable oracle) -> bit-exact LUT
 * apply (juno_param_apply_lut, incl. the verified noise byte-0 gate). */
#include "juno_engine.h"
#include "juno_params.h"
#include "juno_param_map.h"
#include "juno_preset.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define JUNO_BANK_HDR  23
#define JUNO_BANK_REC  20223

/* synth-voice block is stride-1: k = db - 736 ; FX selectors stride-4. */
static int step_synth(const unsigned char *dec, int n, int db){
    int k = db - 736; return (k>=0 && k<n) ? dec[k] : -1;
}
static int step_fx(const unsigned char *dec, int n, int db){
    int k = 309 + (db - 871)*4; return (k>=0 && k<n) ? dec[k] : -1;
}

int juno_preset_load(unsigned char *st, const char *bank_path, int record,
                     juno_preset_info *info)
{
    FILE *f = fopen(bank_path, "rb");
    if (!f) return -1;
    if (fseek(f, JUNO_BANK_HDR + record*JUNO_BANK_REC, SEEK_SET) != 0){ fclose(f); return -2; }
    unsigned char *rec = malloc(JUNO_BANK_REC);
    size_t got = fread(rec, 1, JUNO_BANK_REC, f);
    fclose(f);
    if (got < (size_t)JUNO_BANK_REC){ free(rec); return -3; }

    int ndec = JUNO_BANK_REC/2;
    unsigned char *dec = malloc(ndec);
    for (int k=0;k<ndec;k++) dec[k] = (unsigned char)(rec[2*k]*16 + rec[2*k+1]);

    if (info){
        memset(info,0,sizeof *info);
        /* 16-char name at decoded k=78 (full-record stream) */
        for (int j=0;j<16;j++){ int c=dec[78+j]; info->name[j]=(c>=32&&c<127)?(char)c:' '; }
        info->name[16]=0;
        info->model       = step_fx(dec,ndec,JUNO_DB_MODEL);
        info->filter_type = step_fx(dec,ndec,JUNO_DB_FILTER);
        info->chorus_mode = step_fx(dec,ndec,JUNO_DB_CHORUS);
        info->fxa_type    = step_fx(dec,ndec,JUNO_DB_FXA);
        info->reverb_type = step_fx(dec,ndec,JUNO_DB_REVERB);
    }

    int applied=0;
    for (int i=0;i<JUNO_PARAM_MAP_N;i++){
        const juno_param_map_ent *e=&JUNO_PARAM_MAP[i];
        int step=step_synth(dec,ndec,e->db);
        if (step<0 || step>255) continue;
        juno_param_apply_lut(st, e->off, e->tid, step, /*broadcast=*/1);
        applied++;
    }
    if (info) info->applied=applied;
    free(dec); free(rec);
    return 0;
}
