/* juno_hostparams.c -- the plugin's host-visible parameter set (the 79 params a
 * VST3 host such as Ableton exposes), for the in-browser panel. GENERATED from
 * truth/Script.xml value-tree leaves + the validated cumulative record-offset map
 * (scratchpad/gen_host_params_spec.py -> host_params_spec.json ->
 * scratchpad/gen_hostparams_c.py). Each row: display name, section, the RECORD byte
 * offset (roff) of the leaf's low nibble-pair, the leaf TYPE (serialization width),
 * the value max, and the leaf default. Editing the record at roff per the leaf type
 * and re-running juno_bank_apply reproduces the plugin's own recall for that value
 * (the recall is render-A/B bit-exact, 57/57). NOTHING here is derived from a
 * capture -- Script.xml is allowed plugin data. Regenerate: gen_hostparams_c.py.
 *
 * type: 0=int1x7 (1 byte, 0..127), 1=int2x4 (nibble pair, 0..255),
 *       2=int8x4 (8 bytes; port reads low byte as a nibble pair, 0..255).
 */
typedef struct { const char *name; const char *section; int roff; int type; int max; int def; } juno_hostparam;

static const juno_hostparam HOSTPARAMS[] = {
    {"DCO RANGE"          ,"DCO"     ,   48, 1, 255,   3},
    {"DCO PWM DEPTH"      ,"DCO"     ,   44, 1, 255,   0},
    {"DCO PWM LEVEL"      ,"DCO"     ,   68, 1, 255, 128},
    {"DCO PWM SOURCE"     ,"DCO"     ,   46, 1, 255,   0},
    {"DCO SAW LEVEL"      ,"DCO"     ,   70, 1, 255,   0},
    {"DCO SUB LEVEL"      ,"DCO"     ,   72, 1, 255,   0},
    {"DCO NOISE LEVEL"    ,"DCO"     ,   74, 1, 255,   0},
    {"DCO LFO MOD"        ,"DCO"     ,   34, 1, 255, 128},
    {"HPF CUTOFF FREQ"    ,"HPF"     ,   92, 1, 255,   0},
    {"HPF TYPE"           ,"HPF"     ,  618, 2, 255,   0},
    {"VCF CUTOFF FREQ"    ,"VCF"     ,   86, 1, 255, 255},
    {"VCF CUTOFF FREQ H"  ,"VCF"     , 1876, 2, 255, 255},
    {"VCF RESONANCE"      ,"VCF"     ,   90, 1, 255,   0},
    {"VCF ENV MOD"        ,"VCF"     ,   94, 1, 255, 128},
    {"VCF KEY FOLLOW"     ,"VCF"     ,  104, 1, 255, 128},
    {"VCF LFO MOD"        ,"VCF"     ,   36, 1, 255, 128},
    {"VCF VELOCITY SENS"  ,"VCF"     , 1868, 1, 255,   0},
    {"VCA TONE"           ,"VCA"     ,  114, 1, 255, 128},
    {"VCA LEVEL"          ,"VCA"     ,  148, 1, 255, 128},
    {"VCA MODE"           ,"VCA"     ,  490, 2, 255,   1},
    {"VCA VELOCITY SENS"  ,"VCA"     , 2102, 1, 255,   0},
    {"ENV1 ATTACK"        ,"ENV1"    ,   96, 1, 255,   0},
    {"ENV1 DECAY"         ,"ENV1"    ,   98, 1, 255,   0},
    {"ENV1 SUSTAIN"       ,"ENV1"    ,  100, 1, 255, 255},
    {"ENV1 RELEASE"       ,"ENV1"    ,  102, 1, 255,   0},
    {"ENV2 ATTACK"        ,"ENV2"    ,  106, 1, 255,   0},
    {"ENV2 DECAY"         ,"ENV2"    ,  108, 1, 255,   0},
    {"ENV2 SUSTAIN"       ,"ENV2"    ,  110, 1, 255, 255},
    {"ENV2 RELEASE"       ,"ENV2"    ,  112, 1, 255,   0},
    {"LFO RATE"           ,"LFO"     ,   32, 1, 255, 145},
    {"LFO RATE H"         ,"LFO"     ,  674, 2, 255, 255},
    {"LFO DELAY TIME"     ,"LFO"     ,   30, 1, 255,   0},
    {"LFO KEY TRIG"       ,"LFO"     ,   40, 1, 255,   0},
    {"LFO TRIG ENV"       ,"LFO"     ,  554, 2, 255,   0},
    {"BEND RANGE"         ,"BEND"    ,  130, 1, 255,  11},
    {"BEND GAIN"          ,"BEND"    ,  506, 2, 255,   0},
    {"BEND SENS DCO"      ,"BEND"    ,  514, 2, 255,  43},
    {"BEND SENS VCF"      ,"BEND"    ,  522, 2, 255,  43},
    {"MOD SENS DCO"       ,"MOD"     ,  530, 2, 255,  22},
    {"MOD SENS VCF"       ,"MOD"     ,  538, 2, 255,  22},
    {"MASTER TUNE"        ,"GLOBAL"  ,   20, 1, 255, 100},
    {"PORTAMENTO"         ,"GLOBAL"  ,  124, 1, 255,   0},
    {"LEGATO"             ,"GLOBAL"  ,  126, 1, 255,   0},
    {"ASSIGN MODE"        ,"GLOBAL"  ,  128, 1, 255,   0},
    {"TEMPO SYNC"         ,"GLOBAL"  ,  134, 1, 255,   0},
    {"CONDITION"          ,"GLOBAL"  ,  498, 2, 255, 128},
    {"OCTAVE SHIFT"       ,"GLOBAL"  ,  338, 2, 255,   0},
    {"KEY HOLD"           ,"GLOBAL"  ,  346, 2, 255,   0},
    {"ARPEGGIO SW"        ,"ARP"     ,  298, 2, 255,   0},
    {"ARPEGGIO TYPE"      ,"ARP"     ,  306, 2, 255,   0},
    {"ARPEGGIO STEP"      ,"ARP"     ,  314, 2, 255,   0},
    {"EFFECT TYPE"        ,"EFFECT"  ,  634, 2, 255,   2},
    {"EFFECT TONE"        ,"EFFECT"  ,  642, 2, 255, 128},
    {"EFFECT DEPTH"       ,"EFFECT"  ,  116, 1, 255,   0},
    {"FLANGER MANUAL"     ,"EFFECT"  , 3502, 1, 255, 128},
    {"FLANGER RESONANCE"  ,"EFFECT"  , 3504, 1, 255, 230},
    {"FLANGER LOW CUT"    ,"EFFECT"  , 3508, 0, 127,   2},
    {"DELAY TYPE"         ,"DELAY"   ,  650, 2, 255,   0},
    {"DELAY LEVEL"        ,"DELAY"   ,  120, 1, 255,   0},
    {"DELAY TIME"         ,"DELAY"   ,  122, 1, 255, 128},
    {"DELAY TAP TIME"     ,"DELAY"   , 3056, 0, 127,  50},
    {"DELAY FEEDBACK"     ,"DELAY"   , 3057, 1, 255, 120},
    {"DELAY HIGH CUT"     ,"DELAY"   , 3059, 0, 127,   7},
    {"DELAY DIRECT LEVEL" ,"DELAY"   , 3060, 1, 255, 255},
    {"DELAY LF DAMP"      ,"DELAY"   , 3068, 2, 255,   0},
    {"DELAY LF DAMP FREQ" ,"DELAY"   , 3076, 2, 255,   0},
    {"DELAY HF DAMP"      ,"DELAY"   , 3084, 2, 255,   0},
    {"DELAY HF DAMP FREQ" ,"DELAY"   , 3092, 2, 255,  13},
    {"CHORUS PRE DELAY"   ,"CHORUS"  , 3286, 0, 127,  20},
    {"CHORUS LOW CUT"     ,"CHORUS"  , 3287, 0, 127,   2},
    {"CHORUS HIGH CUT"    ,"CHORUS"  , 3288, 0, 127,  13},
    {"REVERB LEVEL"       ,"REVERB"  ,  118, 1, 255,   0},
    {"REVERB TYPE"        ,"REVERB"  ,  658, 2, 255,   2},
    {"REVERB TIME"        ,"REVERB"  ,  666, 2, 255, 128},
    {"REVERB PRE DELAY"   ,"REVERB"  , 3947, 0, 127,  20},
    {"REVERB LOW CUT"     ,"REVERB"  , 3948, 0, 127,   2},
    {"REVERB HIGH CUT"    ,"REVERB"  , 3949, 0, 127,  11},
    {"REVERB DENSITY"     ,"REVERB"  , 3950, 0, 127,  10},
    {"REVERB DIRECT LEVEL","REVERB"  , 3951, 1, 255, 255},
};
#define JUNO_HOSTPARAM_COUNT ((int)(sizeof(HOSTPARAMS)/sizeof(HOSTPARAMS[0])))

int         juno_host_param_count(void)    { return JUNO_HOSTPARAM_COUNT; }
const char *juno_host_param_name(int i)    { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].name    : ""; }
const char *juno_host_param_section(int i) { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].section : ""; }
int         juno_host_param_roff(int i)     { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].roff    : -1; }
int         juno_host_param_type(int i)     { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].type    :  0; }
int         juno_host_param_max(int i)      { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].max     :  0; }
int         juno_host_param_default(int i)  { return (i>=0 && i<JUNO_HOSTPARAM_COUNT) ? HOSTPARAMS[i].def     :  0; }

/* Decode a param's current value from a patch record (rec = record start, i.e.
 * bank + BANK_HEADER + idx*BANK_STRIDE). int1x7 is a single record byte; int2x4/
 * int8x4 are read as the plugin does -- the low byte's nibble pair at roff/roff+1. */
int juno_host_param_decode(const unsigned char *rec, int i)
{
    int r = juno_host_param_roff(i);
    if (r < 0 || !rec) return -1;
    if (juno_host_param_type(i) == 0) return rec[r] & 0x7F;
    return ((rec[r] & 0xF) << 4) | (rec[r+1] & 0xF);
}

/* Write value v (clamped to [0,max]) into a patch record for param i, using the
 * plugin's own per-leaf serialization so juno_bank_apply reads it back exactly. */
void juno_host_param_encode(unsigned char *rec, int i, int v)
{
    int r = juno_host_param_roff(i), mx = juno_host_param_max(i);
    if (r < 0 || !rec) return;
    if (v < 0) v = 0;
    if (v > mx) v = mx;
    if (juno_host_param_type(i) == 0) {
        rec[r] = (unsigned char)v;                       /* int1x7: single byte */
    } else {
        rec[r]   = (unsigned char)((rec[r]   & 0xF0) | ((v >> 4) & 0xF));
        rec[r+1] = (unsigned char)((rec[r+1] & 0xF0) | ( v       & 0xF));
    }
}

