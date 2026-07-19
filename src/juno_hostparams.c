/* juno_hostparams.c -- the plugin's host-visible parameter set (the 79 params a
 * VST3 host such as Ableton exposes), for the in-browser panel. GENERATED from
 * truth/Script.xml value-tree leaves + the validated cumulative record-offset map
 * (scratchpad/gen_host_params_spec.py -> host_params_spec.json ->
 * scratchpad/gen_hostparams_c.py). Each row: display name, section, the RECORD
 * byte offset (roff) of the leaf's stored value, the leaf TYPE (serialization
 * width), the SEMANTIC range [min,max] from Script.xml (what a real host shows;
 * min<0 = two's-complement low byte, same law as the proven SCATTER DEPTH
 * decode), and the leaf default in the decode frame.
 *
 * Honesty note on "editing reproduces the plugin's recall": editing the record
 * at roff and re-running juno_bank_apply reproduces the port's recall, which is
 * PROVEN bit-exact against the plugin for every factory-bank value (render A/B
 * 57/57 + arp 7/7) and for every 0..255 value of the single-input front-panel
 * cells (exhaustive recall gate). For extended enum leaves BEYOND the factory
 * bank's value set the port's law is INFERRED, not yet plugin-proven -- known
 * open case: HPF TYPE 2..8 currently maps to the TYPE-1 tables (the factory
 * bank only exercises types 0 and 1); VCA MODE >2 falls back to the switch
 * default, REVERB/EFFECT/DELAY TYPE >5 clamp/no-op. See the oracle-proof task
 * in the tracker before treating those edges as the plugin's own behavior.
 *
 * NOTHING here is derived from a capture -- Script.xml is allowed plugin data.
 * type: 0=int1x7 (1 byte), 1=int2x4 (nibble pair), 2=int8x4 (8 bytes; the port
 * reads the low byte as a nibble pair at roff/roff+1).
 */
typedef struct { const char *name; const char *section; int roff; int type; int min; int max; int def; } juno_hostparam;

static const juno_hostparam HOSTPARAMS[] = {
    {"DCO RANGE"          ,"DCO"     ,   48, 1,   0,   5,   3},
    {"DCO PWM DEPTH"      ,"DCO"     ,   44, 1,   0, 255,   0},
    {"DCO PWM LEVEL"      ,"DCO"     ,   68, 1,   0, 255, 128},
    {"DCO PWM SOURCE"     ,"DCO"     ,   46, 1,   0,   5,   0},
    {"DCO SAW LEVEL"      ,"DCO"     ,   70, 1,   0, 255,   0},
    {"DCO SUB LEVEL"      ,"DCO"     ,   72, 1,   0, 255,   0},
    {"DCO NOISE LEVEL"    ,"DCO"     ,   74, 1,   0, 255,   0},
    {"DCO LFO MOD"        ,"DCO"     ,   34, 1,   0, 255, 128},
    {"HPF CUTOFF FREQ"    ,"HPF"     ,   92, 1,   0, 255,   0},
    {"HPF TYPE"           ,"HPF"     ,  618, 2,   0,   8,   0},
    {"VCF CUTOFF FREQ"    ,"VCF"     ,   86, 1,   0, 255, 255},
    {"VCF CUTOFF FREQ H"  ,"VCF"     , 1876, 2,   0, 255,   0},
    {"VCF RESONANCE"      ,"VCF"     ,   90, 1,   0, 255,   0},
    {"VCF ENV MOD"        ,"VCF"     ,   94, 1,   0, 255, 128},
    {"VCF KEY FOLLOW"     ,"VCF"     ,  104, 1,   0, 255, 128},
    {"VCF LFO MOD"        ,"VCF"     ,   36, 1,   0, 255, 128},
    {"VCF VELOCITY SENS"  ,"VCF"     , 1868, 1,   0, 255,   0},
    {"VCA TONE"           ,"VCA"     ,  114, 1,   0, 255, 128},
    {"VCA LEVEL"          ,"VCA"     ,  148, 1,   0, 255, 128},
    {"VCA MODE"           ,"VCA"     ,  490, 2,   0,   2,   1},
    {"VCA VELOCITY SENS"  ,"VCA"     , 2102, 1,   0, 255,   0},
    {"ENV1 ATTACK"        ,"ENV1"    ,   96, 1,   0, 255,   0},
    {"ENV1 DECAY"         ,"ENV1"    ,   98, 1,   0, 255,   0},
    {"ENV1 SUSTAIN"       ,"ENV1"    ,  100, 1,   0, 255, 255},
    {"ENV1 RELEASE"       ,"ENV1"    ,  102, 1,   0, 255,   0},
    {"ENV2 ATTACK"        ,"ENV2"    ,  106, 1,   0, 255,   0},
    {"ENV2 DECAY"         ,"ENV2"    ,  108, 1,   0, 255,   0},
    {"ENV2 SUSTAIN"       ,"ENV2"    ,  110, 1,   0, 255, 255},
    {"ENV2 RELEASE"       ,"ENV2"    ,  112, 1,   0, 255,   0},
    {"LFO RATE"           ,"LFO"     ,   32, 1,   0, 255, 145},
    {"LFO RATE H"         ,"LFO"     ,  674, 2,   0, 255, 146},
    {"LFO DELAY TIME"     ,"LFO"     ,   30, 1,   0, 255,   0},
    {"LFO KEY TRIG"       ,"LFO"     ,   40, 1,   0,   1,   0},
    {"LFO TRIG ENV"       ,"LFO"     ,  554, 2,   0,   1,   0},
    {"BEND RANGE"         ,"BEND"    ,  130, 1,   0,  23,  11},
    {"BEND GAIN"          ,"BEND"    ,  506, 2,   0,   3,   0},
    {"BEND SENS DCO"      ,"BEND"    ,  514, 2,   0, 255,  43},
    {"BEND SENS VCF"      ,"BEND"    ,  522, 2,   0, 255,  43},
    {"MOD SENS DCO"       ,"MOD"     ,  530, 2,   0, 255,  22},
    {"MOD SENS VCF"       ,"MOD"     ,  538, 2,   0, 255,  22},
    {"MASTER TUNE"        ,"GLOBAL"  ,   20, 1,   0, 200, 100},
    {"PORTAMENTO"         ,"GLOBAL"  ,  124, 1,   0, 255,   0},
    {"LEGATO"             ,"GLOBAL"  ,  126, 1,   0,   1,   0},
    {"ASSIGN MODE"        ,"GLOBAL"  ,  128, 1,   0,   3,   0},
    {"TEMPO SYNC"         ,"GLOBAL"  ,  134, 1,   0,   1,   0},
    {"CONDITION"          ,"GLOBAL"  ,  498, 2,   0, 255, 128},
    {"OCTAVE SHIFT"       ,"GLOBAL"  ,  338, 2,  -3,   3,   0},
    {"KEY HOLD"           ,"GLOBAL"  ,  346, 2,   0,   1,   0},
    {"ARPEGGIO SW"        ,"ARP"     ,  298, 2,   0,   1,   0},
    {"ARPEGGIO TYPE"      ,"ARP"     ,  306, 2,   0,   5,   0},
    {"ARPEGGIO STEP"      ,"ARP"     ,  314, 2,   0,   5,   0},
    {"EFFECT TYPE"        ,"EFFECT"  ,  634, 2,   0,   5,   2},
    {"EFFECT TONE"        ,"EFFECT"  ,  642, 2,   0, 255, 128},
    {"EFFECT DEPTH"       ,"EFFECT"  ,  116, 1,   0, 255,   0},
    {"FLANGER MANUAL"     ,"EFFECT"  , 3502, 1,   0, 255, 128},
    {"FLANGER RESONANCE"  ,"EFFECT"  , 3504, 1,   0, 255, 230},
    {"FLANGER LOW CUT"    ,"EFFECT"  , 3508, 0,   0,  17,   2},
    {"DELAY TYPE"         ,"DELAY"   ,  650, 2,   0,   5,   0},
    {"DELAY LEVEL"        ,"DELAY"   ,  120, 1,   0, 255,   0},
    {"DELAY TIME"         ,"DELAY"   ,  122, 1,   0, 255, 128},
    {"DELAY TAP TIME"     ,"DELAY"   , 3056, 0,   0, 100,  50},
    {"DELAY FEEDBACK"     ,"DELAY"   , 3057, 1,   0, 255, 120},
    {"DELAY HIGH CUT"     ,"DELAY"   , 3059, 0,   0,  14,   7},
    {"DELAY DIRECT LEVEL" ,"DELAY"   , 3060, 1,   0, 255, 255},
    {"DELAY LF DAMP"      ,"DELAY"   , 3068, 2,   0,  81,   0},
    {"DELAY LF DAMP FREQ" ,"DELAY"   , 3076, 2,   0,  10,   0},
    {"DELAY HF DAMP"      ,"DELAY"   , 3084, 2,   0,  81,   0},
    {"DELAY HF DAMP FREQ" ,"DELAY"   , 3092, 2,   0,  13,  13},
    {"CHORUS PRE DELAY"   ,"CHORUS"  , 3286, 0,   0,  80,  20},
    {"CHORUS LOW CUT"     ,"CHORUS"  , 3287, 0,   0,  17,   2},
    {"CHORUS HIGH CUT"    ,"CHORUS"  , 3288, 0,   0,  14,  13},
    {"REVERB LEVEL"       ,"REVERB"  ,  118, 1,   0, 255,   0},
    {"REVERB TYPE"        ,"REVERB"  ,  658, 2,   0,   5,   2},
    {"REVERB TIME"        ,"REVERB"  ,  666, 2,   0, 255, 128},
    {"REVERB PRE DELAY"   ,"REVERB"  , 3947, 0,   0, 100,  20},
    {"REVERB LOW CUT"     ,"REVERB"  , 3948, 0,   0,  17,   2},
    {"REVERB HIGH CUT"    ,"REVERB"  , 3949, 0,   0,  14,  11},
    {"REVERB DENSITY"     ,"REVERB"  , 3950, 0,   0,  10,  10},
    {"REVERB DIRECT LEVEL","REVERB"  , 3951, 1,   0, 255, 255},
};
#define JUNO_HOSTPARAM_COUNT ((int)(sizeof(HOSTPARAMS)/sizeof(HOSTPARAMS[0])))

int         juno_host_param_count(void)    { return JUNO_HOSTPARAM_COUNT; }
const char *juno_host_param_name(int i)    { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].name    : ""; }
const char *juno_host_param_section(int i) { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].section : ""; }
int         juno_host_param_roff(int i)     { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].roff    : -1; }
int         juno_host_param_type(int i)     { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].type    :  0; }
int         juno_host_param_min(int i)      { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].min     :  0; }
int         juno_host_param_max(int i)      { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].max     :  0; }
int         juno_host_param_default(int i)  { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].def     :  0; }

/* Decode a param's current value from a patch record (rec = record start, i.e.
 * bank + BANK_HEADER + idx*BANK_STRIDE). int1x7 is a single record byte; int2x4/
 * int8x4 read the low byte's nibble pair at roff/roff+1, as the plugin does.
 * Signed leaves (min < 0) map the two's-complement top half back to negatives. */
int juno_host_param_decode(const unsigned char *rec, int i)
{
    int r = juno_host_param_roff(i), v;
    if (r < 0 || !rec) return -1;
    if (juno_host_param_type(i) == 0) v = rec[r] & 0x7F;
    else v = ((rec[r] & 0xF) << 4) | (rec[r+1] & 0xF);
    if (juno_host_param_min(i) < 0 && v >= 128) v -= 256;   /* two's complement */
    return v;
}

/* Write value v (clamped to the leaf's semantic [min,max]) into a patch record
 * for param i, using the plugin's own per-leaf serialization so juno_bank_apply
 * reads it back exactly. Negative v serializes as two's-complement low byte. */
void juno_host_param_encode(unsigned char *rec, int i, int v)
{
    int r = juno_host_param_roff(i);
    if (r < 0 || !rec) return;
    if (v < juno_host_param_min(i)) v = juno_host_param_min(i);
    if (v > juno_host_param_max(i)) v = juno_host_param_max(i);
    if (v < 0) v += 256;                                    /* two's complement */
    if (juno_host_param_type(i) == 0) {
        rec[r] = (unsigned char)v;                          /* int1x7: single byte */
    } else {
        rec[r]   = (unsigned char)((rec[r]   & 0xF0) | ((v >> 4) & 0xF));
        rec[r+1] = (unsigned char)((rec[r+1] & 0xF0) | ( v       & 0xF));
    }
}

