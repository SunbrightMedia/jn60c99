/* juno_preset.c — see juno_preset.h. Capture-free: bank nibble-decode (proven
 * layout, docs/PRESET_BANK_FORMAT.md) -> per-DB step -> engine offset+tableId
 * (src/juno_param_map.h, from Script.xml + the vtable oracle) -> bit-exact LUT
 * apply (juno_param_apply_lut, incl. the verified noise byte-0 gate). */
#include "juno_engine.h"
#include "juno_params.h"
#include "juno_param_map.h"
#include "juno_preset.h"
#include "juno_fx.h"
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
        /* Arp settings — stride-4 arp block, decoded positions 149/153/157
         * (deserializer record bytes 298/306/314; docs/PRESET_BANK_FORMAT.md).
         * TYPE: 0=UP->set_mode 15, 1=UP&DOWN->17, >=2=DOWN->16.
         * RANGE (the "STEP" knob is the octave range): stored value = set_range
         * arg (0=1oct, 1=2oct, >=2=3oct). Works for ANY preset. */
        { int sw=(149<ndec)?dec[149]:0, ty=(153<ndec)?dec[153]:0, rg=(157<ndec)?dec[157]:0;
          info->arp_on    = (sw==1);
          info->arp_mode  = (ty==0)?15:(ty==1)?17:16;
          info->arp_range = (rg>2)?2:rg; }
    }

    int applied=0;
    for (int i=0;i<JUNO_PARAM_MAP_N;i++){
        const juno_param_map_ent *e=&JUNO_PARAM_MAP[i];
        int step=step_synth(dec,ndec,e->db);
        if (step<0 || step>255) continue;
        juno_param_apply_lut(st, e->off, e->tid, step, /*broadcast=*/1);
        applied++;
    }
    /* DCO PWM SOURCE (DB759, range 0..5): one-hot demux into the 4 PWM-mod
     * switches 3888 (LFO) / 3904 (ENV1) / 3920 (ENV2) / 3936 (Manual). These are
     * vtable-only setters (no LUT tableId); the demux + offsets are proven by the
     * PWM mix DSP (voice_render.c:1083-1089) and the rec0 capture (src=LFO ->
     * 3888=1.0, rest 0). 0=MANUAL, 1=LFO, 2/3=ENV1±, 4/5=ENV2± (ENV polarity sign
     * is a refinement; the selected magnitude is faithful). Without this the
     * engine default (3888=1.0 = LFO) leaks into MANUAL patches. */
    { int src = step_synth(dec,ndec,759);
      if (src >= 0){
        juno_param_apply_value(st, 3888, (src==1)?1.0f:0.0f, 1);          /* LFO    */
        juno_param_apply_value(st, 3904, (src==2||src==3)?1.0f:0.0f, 1);  /* ENV1   */
        juno_param_apply_value(st, 3920, (src==4||src==5)?1.0f:0.0f, 1);  /* ENV2   */
        juno_param_apply_value(st, 3936, (src==0)?1.0f:0.0f, 1);          /* Manual */
      }
    }
    /* FX-A DELAY activation (DB875=0=DELAY). The driver previously ran the FX-A
     * slot as a chorus (mode int = JUNO chorus mode) — a stray 2nd chorus that
     * made the stereo image far too wide. The System-8 multi-FX (v39 slot,
     * params+136) is the FX-A; for DELAY its mode int must be 1 (master_render.c
     * v39==1 = stereo delay) and the host sets that from info->fxa_v39. The delay
     * zone coefficients (4297xxx) are already seeded bit-exact by
     * juno_runtime_coeffs_apply; only the two panel sends + the input "Mute" gate
     * need writing (global FX nodes -> broadcast 0). Transforms are curve-22
     * (=step/255), proven bit-exact. DB796 DELAY LEVEL @4297760, DB797 DELAY TIME
     * @4297584, the un-seeded input gate @4297840 -> 1.0. */
    int fxa = step_fx(dec,ndec,JUNO_DB_FXA);
    if (fxa == 0){  /* DELAY */
        int dl = step_synth(dec,ndec,796);   /* DELAY LEVEL */
        int dt = step_synth(dec,ndec,797);   /* DELAY TIME  */
        if (dl>=0 && dl<=255) juno_param_apply_value(st, 4297760, juno_lut_apply(22,dl), 0);
        if (dt>=0 && dt<=255) juno_param_apply_value(st, 4297584, juno_lut_apply(22,dt), 0);
        juno_param_apply_value(st, 4297840, 1.0f, 0);   /* input gate open */
    }
    if (info) info->fxa_v39 = (fxa==0) ? 1 : 0;  /* 1=delay; 0=off (other FX-A modes TODO) */

    /* Additional capture-validated bindings (refs/db_engine_map_full.json) kept out
     * of the generated LUT map because each needs a tableId override or a
     * non-identity step transform. All round-trip bit-exact vs the rec0 capture. */
    { int s;
      /* DB798 PORTAMENTO TIME -> 624, tableId 7 (the param-table's tid4 is stale;
       * step 10 -> 0x3ad61183 exact). Per-voice glide-time 1-pole coefficient. */
      s = step_synth(dec,ndec,798); if (s>=0 && s<=255) juno_param_apply_lut(st, 624, 7, s, 1);
      /* DB803 TEMPO SYNC -> 1056 (LFO Tempo Rate Sw), tableId 52 (0/1 switch). */
      s = step_synth(dec,ndec,803); if (s>=0 && s<=255) juno_param_apply_lut(st, 1056, 52, s, 1);
      /* DB801 BEND RANGE -> 4128: a 0..23 SEMITONE value, engine = LUT21(step+160)
       * = (R+32)/255 (R=11 -> 0x3e2cacad exact). NOT the plain 0..255 LUT path. */
      s = step_synth(dec,ndec,801); if (s>=0 && s+160<=255) juno_param_apply_lut(st, 4128, 21, s+160, 1);
    }
    juno_chorus_set_rates(st);   /* capture-free JUNO chorus I/II rates */
    if (info) info->applied=applied;
    free(dec); free(rec);
    return 0;
}
