/* delay_recall.c — per-patch DELAY effect recall (slot-1 / v39 effect).
 *
 * Everything here is TRANSCRIBED from the plugin's own recall, never guessed:
 * a Unicorn oracle (scratchpad tools/gen_delay_overlay.py, gen_delaytime_lut.py)
 * RUNS the real value-tree dispatch (sub_7FF91E019A30) for the delay leaves and
 * reports the exact engine coefficients each writes. Recovered mappings:
 *   Wet Level  (102528) = DELAY LEVEL / 255                 [dispatch idx 796]
 *   Feedback   (102560) = DELAY FEEDBACK / 255 * 0.9        [dispatch idx 1179]
 *   On/Off     (102576) = 1 if DELAY LEVEL > 0 else 0       [dispatch idx 796]
 *   Mute/enable(102592) = same as On/Off (0 in the muted default => no output)
 *   Dry Level  (102512) = DELAY DIRECT LEVEL / 255          [dispatch idx 1181]
 *   Delay Time (102352) = ((float)H*DELAYTIME_MS[byte])*(1/16384000)-(2/16384)
 *                         [dispatch idx 797; RATE-PARAMETERIZED, bit-exact any H]
 *   High-cut + LF/HF damp filter block (102368..102688): CONSTANT across all 64
 *     bank patches (every patch uses the default DELAY HIGH CUT / DAMP settings),
 *     so the plugin recomputes the same coefficients each time — reproduced here
 *     as the FILT[] table (dispatch idx 1180/1182..1185).
 * The Wet/Feedback formulas were checked bit-exact vs the oracle for every
 * delay-active patch (0 mismatches). Rendering an impulse through the transcribed
 * juno_master_render with v39=0 and these coefficients produces the expected
 * regenerating echoes at the DELAY TIME interval; all 64 patches render finite.
 *
 * Record byte positions (from Script.xml value-tree schema + the proven
 * serialization order): DELAY TYPE = record 650, DELAY LEVEL = blob 40,
 * DELAY TIME = blob 49, DELAY FEEDBACK = record 3057, DELAY DIRECT LEVEL = 3060.
 */
#include "juno_engine.h"
#include "delay_recall.h"
#include "finefx_recall.h"
#include <string.h>

/* DELAY TIME byte -> per-byte delay time in INTEGER MILLISECONDS (10..800 ms),
 * rate-independent (dispatch idx 797). The engine coefficient at 102352 is affine
 * in the host rate H: coeff = ((float)H * ms) * (1/16384000) - (2/16384) — see the
 * three float32 ops in juno_apply_delay (bit-exact 768/768 at 44100/48000/96000,
 * scratchpad/oracle/delaytime_rate_spec.md). The old fixed uint32 table was exactly
 * this formula frozen at H=96000, so it played delay-mode patches ~2x off at 48 kHz;
 * this ms table + the formula is correct at any host rate. */
static const uint16_t DELAYTIME_MS[256] = {
   10,  10,  11,  12,  13,  14,  14,  15,  16,  17,  18,  19,  20,  20,  21,  22,
   23,  24,  25,  26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,
   39,  40,  41,  42,  43,  44,  45,  47,  48,  49,  50,  51,  52,  54,  55,  56,
   57,  58,  60,  61,  62,  63,  65,  66,  67,  69,  70,  71,  73,  74,  75,  77,
   78,  80,  81,  82,  84,  85,  87,  88,  90,  91,  93,  95,  96,  98,  99, 101,
  102, 104, 106, 107, 109, 111, 113, 114, 116, 118, 120, 121, 123, 125, 127, 129,
  131, 132, 134, 136, 138, 140, 142, 144, 146, 148, 150, 152, 154, 157, 159, 161,
  163, 165, 167, 170, 172, 174, 176, 179, 181, 183, 186, 188, 191, 193, 196, 198,
  201, 203, 206, 208, 211, 213, 216, 219, 221, 224, 227, 230, 232, 235, 238, 241,
  244, 247, 250, 253, 256, 259, 262, 265, 268, 271, 274, 278, 281, 284, 287, 291,
  294, 297, 301, 304, 308, 311, 315, 318, 322, 325, 329, 333, 337, 340, 344, 348,
  352, 356, 360, 364, 368, 372, 376, 380, 384, 388, 392, 397, 401, 405, 410, 414,
  419, 423, 428, 432, 437, 442, 446, 451, 456, 461, 466, 471, 476, 481, 486, 491,
  496, 501, 506, 512, 517, 522, 528, 533, 539, 545, 550, 556, 562, 567, 573, 579,
  585, 591, 597, 603, 610, 616, 622, 628, 635, 641, 648, 654, 661, 668, 675, 681,
  688, 695, 702, 709, 717, 724, 731, 738, 746, 753, 761, 768, 776, 784, 792, 800,
};

/* --- Tempo-synced DELAY TIME (TEMPO SYNC blob 59 != 0) ------------------------
 * When the patch's TEMPO SYNC switch is on, the plugin IGNORES the manual ms table
 * and quantizes the DELAY TIME byte into one of 16 note divisions, then computes
 * ms = beats(division) * 60000 / BPM. Derived by driving the plugin's own dispatch
 * under Unicorn (idx 797 time byte sweep 0..255 + idx 803 sync, all 3 rates):
 *   division d = (byte == 0) ? 0 : (byte + 16) / 17     (byte 0 alone; then 17-wide)
 *   d 0..15 = 1/32, 1/16T, 1/32D, 1/16, 1/8T, 1/16D, 1/8, 1/4T, 1/8D, 1/4,
 *             1/2T, 1/4D, 1/2, 1T, 1/2D, 1/1   (beats 0.125 .. 4.0)
 * The recall-time default tempo is the baked 128 BPM (TEMPO param default 880 ->
 * 40 + 88.0), at which every division's ms is exactly representable in float32 —
 * SYNC_MS_128 below. The resulting coefficient goes through the SAME 3-op affine
 * formula as the manual path and is bit-exact 48/48 (16 divisions x 3 rates) vs the
 * plugin's dispatch output; the live-tempo law ms=f32(beats*60000/BPM) is bit-exact
 * vs the plugin's tempo pushes at 60/88/176 BPM. See juno_apply_delay_tempo. */
static const double SYNC_BEATS[16] = {
    0.125, 1.0 / 6.0, 0.1875, 0.25, 1.0 / 3.0, 0.375, 0.5, 2.0 / 3.0,
    0.75, 1.0, 4.0 / 3.0, 1.5, 2.0, 8.0 / 3.0, 3.0, 4.0
};
static const float SYNC_MS_128[16] = {   /* beats * 468.75 (128 BPM), all exact */
    58.59375f, 78.125f, 87.890625f, 117.1875f, 156.25f, 175.78125f, 234.375f,
    312.5f, 351.5625f, 468.75f, 625.0f, 703.125f, 937.5f, 1250.0f, 1406.25f, 1875.0f
};

static int sync_division(int byte) { return byte == 0 ? 0 : (byte + 16) / 17; }

/* ms -> engine coefficient: the plugin's exact 3-float-op sequence (order matters:
 * H*ms exceeds 2^24 so the -2 must come after the scale). */
static float dly_ms_to_coeff(int Hr, float ms)
{
    float dt = (float)Hr * ms;               /* mulss H,ms        */
    dt = dt * (1.0f / 16384000.0f);          /* mulss C1          */
    return dt - (2.0f / 16384.0f);           /* subss C2 (2^-13)  */
}

/* The patch's delay-time coefficient: synced (TEMPO SYNC blob 59 != 0, at the
 * recall-default 128 BPM) or manual (per-byte ms table). */
static float dly_time_coeff(int Hr, int time_byte, int sync)
{
    float ms = sync ? SYNC_MS_128[sync_division(time_byte & 0xFF)]
                    : (float)DELAYTIME_MS[time_byte & 0xFF];
    return dly_ms_to_coeff(Hr, ms);
}

/* DELAY slot-1 coefficient block (offset, bits) — the plugin's engine constants for
 * every DELAY-active (v39==0) patch. Extracted bit-for-bit from the captured MASTER
 * unit states (idstate64/state_pN_master.bin) and CONFIRMED constant across all 16
 * v39==0 patches (1 distinct value per cell). Only WET (102528, per-patch =
 * DELAY LEVEL/255), DELAY TIME (102352, per-patch / tempo-sync), and ON/OFF (102576)
 * are per-patch; everything else — the high-cut/LF-HF-damp filter, feedback
 * (102560=0.4235294 constant, NOT the byte the old code read), dry (102512=1.0), and
 * the enable switches — is this fixed block. Captured at 48 kHz; the filter feedback
 * coeffs (1.379/-0.530/0.206) are rate-dependent — see the rate caveat below.
 * (The old FILT[] held WRONG values, e.g. 102368=0.515 vs 0.152, so all delay-active
 * patches had the wrong delay tone/feedback.) */
static const uint32_t FILT[] = {
  102368,0x3e1b31ceu, 102384,0x00000000u, 102400,0x00000000u, 102416,0x3fb07de6u,
  102432,0xbf07c840u, 102448,0x00000000u, 102464,0x3e52bdc7u, 102480,0x3fb50bf3u,
  102496,0x3f800000u, 102512,0x3f800000u, 102544,0x387fd974u, 102560,0x3ed8d8d9u,
  102592,0x3f800000u, 102608,0x3c2b929au, 102624,0x3f800000u, 102640,0x3f800000u,
  102656,0x3f4ba5b0u, 102672,0x3f800000u, 102688,0x3f800000u
};

/* DELAY TYPE 1 — the "dual delay" (patch 41 "Multirhythm" etc.). Unlike TYPE 0
 * (a single tap), TYPE 1 runs TWO delay instances: the first-instance block at
 * 102xxx (a variant of the TYPE-0 block — 102544/102592/102608 differ) AND a full
 * SECOND instance at 4297584.. All 17 factory TYPE-1 patches share the same constant
 * cells below (verified 8/8 incl. a level-0 patch); only TIME (102352 / 4297584),
 * WET (102528 / 4297760) and the level gate (feedback 102560, ON 102576 / 4297824)
 * are per-patch. Bit-for-bit from the captured MASTER states state_pN_master.bin.
 * TIME is tempo-synced for most TYPE-1 patches (the manual byte formula matches only
 * a subset — same open sync item as reverb 6497168 / delay 102352; see
 * docs/FX_COLDLOAD_TODO.md); the manual formula is used until the sync law is
 * derived, which lands the tap close (exact where the patch's division coincides). */
static const uint32_t DLY1_A[] = {   /* first instance 102xxx: always-constant cells */
  102368,0x3e1b31ceu, 102416,0x3fb07de6u, 102432,0xbf07c840u, 102464,0x3e52bdc7u,
  102480,0x3fb50bf3u, 102496,0x3f800000u, 102512,0x3f800000u, 102544,0x3f9bd7cau,
  102592,0x00000000u, 102608,0x3bab929au, 102624,0x3f800000u, 102640,0x3f800000u,
  102656,0x3f4ba5b0u, 102672,0x3f800000u
};
static const uint32_t DLY1_B[] = {   /* second instance 4297584..: always-constant cells */
  4297600,0x3e1b31ceu, 4297616,0x00000000u, 4297632,0x00000000u, 4297648,0x3fb07de6u,
  4297664,0xbf07c840u, 4297680,0x00000000u, 4297696,0x3e52bdc7u, 4297712,0x3fb50bf3u,
  4297728,0x3f800000u, 4297744,0x3f800000u, 4297776,0x387fd974u, 4297792,0x3efefeffu,
  4297808,0x3ed8d8d9u, 4297840,0x3f800000u, 4297856,0x3f800000u, 4297872,0x00000000u,
  4297888,0x40000000u, 4297904,0x3c2b929au, 4297920,0x3f800000u, 4297936,0x3f800000u,
  4297952,0x3f4ba5b0u, 4297968,0x3f800000u, 4297984,0x3f800000u
};

/* --- Rate arms for the FX-config cells the constant tables got wrong. ---
 * The FILT/DLY1/S1CHORUS/S1REVERB tables were captured at 48 kHz; a subset of
 * their cells is RATE-DEPENDENT (the plugin's FX config writes per-rate values,
 * same architecture as juno_prepare's rate classes). Measured bit-for-bit from
 * the plugin's own build+recall at 44100/48000/88200/96000 (scratchpad/oracle/
 * rate_fullscan.py + rate88_dump.py): cells fall into a continuous 2sin(pi*f/H)
 * family (4 distinct arms), a 96k-clamped family (88200 uses the 96k bits), and
 * 2-class {44100, else} switches. We store the exact measured bits per arm —
 * bit-exact by construction at all four verified rates. This closes the 44.1 kHz
 * (and 96 kHz) cold-render drift: a 1-ULP-seeded divergence at the delay/FX
 * read-back onset (~frame 2722 @44.1k) that accumulated to ~1.7% RMS. */
static void put_rate(unsigned char *state, int Hr, int off,
                     uint32_t b44, uint32_t b48, uint32_t b88, uint32_t b96)
{
    uint32_t bits = (Hr == 44100) ? b44 : (Hr == 48000) ? b48
                  : (Hr == 88200) ? b88 : b96;
    float f; memcpy(&f, &bits, sizeof f);
    JF(state, off) = f;
}
/* shared arm sets (same values appear in every FX block instance) */
#define ARM_HCSW  0x3f800000u, 0x00000000u, 0x00000000u, 0x00000000u  /* High-Cut Sw   */
#define ARM_HFDMP 0x3f800000u, 0x3f4ba5b0u, 0x3f4ba5b0u, 0x3f4ba5b0u  /* HF-Damp Fc    */
#define ARM_LFX1  0x388b3cdfu, 0x387fd974u, 0x37ffd974u, 0x37ffd974u  /* 96k-clamped   */
#define ARM_LFX2  0x3c3abeeau, 0x3c2b929au, 0x3bbabeeau, 0x3bab929au  /* 2sin(pi*80/H) */
#define ARM_CHDEP 0x3cdb8001u, 0x3cef0001u, 0x3d5c0001u, 0x3d6f8001u  /* chorus depth  */
#define ARM_CHLF  0x3b696eb3u, 0x3b56774fu, 0x3ae96eb3u, 0x3ad6774fu  /* chorus LF     */

/* logical byte from a nibble pair at record offset `off` (record is nibble-packed
 * past the 16-char name; see juno_apply.c record_byte). */
static int rec_byte(const unsigned char *rec, int off)
{
    return ((rec[off] & 0xF) << 4) | (rec[off + 1] & 0xF);
}
/* front-panel blob value at blob position `bp` (blob = record + 16). */
static int blob_val(const unsigned char *rec, int bp)
{
    const unsigned char *b = rec + 16;
    return ((b[2 * bp] & 0xF) << 4) | (b[2 * bp + 1] & 0xF);
}

/* SLOT-1-hosted chorus block — DELAY TYPE (v39) 2 or 3 route a second chorus (I/II)
 * into slot 1 instead of the delay. The engine block at 6395312..6396448 is what the
 * plugin recalls; 18 cells are constants (captured bit-for-bit from the master states,
 * identical for modes 2 and 3), and two are per-patch, driven by the repurposed DELAY
 * TIME / DELAY LEVEL bytes (blob 53 / 52):
 *   6395312 (rate/level) = (blob53/255)*11 - 8   [verified bit-exact 14/14]
 *   6396176 (depth)      =  blob52/255           [verified bit-exact 14/14]
 * The constant filter coeffs (0x3f03df74 etc.) are captured @48 kHz and are
 * rate-dependent — see docs/FX_COLDLOAD_TODO.md. */
static const uint32_t S1CHORUS[] = {
  6395328,0x3f800000u, 6396128,0x3cef0001u, 6396160,0x3f000000u, 6396192,0x3f03df74u,
  6396208,0x3f83df74u, 6396224,0x3f03df74u, 6396240,0xbee549c0u, 6396256,0xbf1cd8f1u,
  6396288,0x3f4ba5b0u, 6396304,0x3fb50bf3u, 6396320,0x3f800000u, 6396336,0x3b56774fu,
  6396352,0x3f800000u, 6396368,0x3f800000u, 6396384,0x3f800000u, 6396400,0x387fd974u,
  6396432,0x3f800000u, 6396448,0x3f800000u, 6396528,0x3db40000u
};
static void apply_slot1_chorus(unsigned char *state, const unsigned char *rec, int dtype)
{
    int b53 = blob_val(rec, 53), b52 = blob_val(rec, 52);
    int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
    unsigned k; uint32_t bits; float f;
    for (k = 0; k < sizeof(S1CHORUS) / sizeof(S1CHORUS[0]); k += 2) {
        bits = S1CHORUS[k + 1]; memcpy(&f, &bits, sizeof f);
        JF(state, (int)S1CHORUS[k]) = f;
    }
    /* rate-dependent cells (table holds the 48k arm; see put_rate above). 6396272
     * (High-Cut Sw) is 44.1k-only=1.0 and was previously never written; 6396528 is
     * 2-class {44100-arm, else}. The slot-1 delay's HF-Damp 102656 is written to the
     * rate-CONSTANT 0x3f4ba5b0 by this config on every rate (plugin@44.1k holds
     * 0.795 here, NOT prepare's 44.1 class-D default 1.0 — measured, rate_fullscan). */
    put_rate(state, Hr, 6396128, ARM_CHDEP);
    put_rate(state, Hr, 6396272, ARM_HCSW);
    put_rate(state, Hr, 6396336, ARM_CHLF);
    put_rate(state, Hr, 6396400, ARM_LFX1);
    put_rate(state, Hr, 6396528, 0x3d256000u, 0x3db40000u, 0x3db40000u, 0x3db40000u);
    { uint32_t hb = 0x3f4ba5b0u; memcpy(&f, &hb, sizeof f); JF(state, 102656) = f; }
    JF(state, 6395312) = ((float)b53 / 255.0f) * 11.0f - 8.0f;   /* chorus rate/level */
    JF(state, 6396176) = (float)b52 / 255.0f;                    /* chorus depth      */
    /* Chorus I (dtype 2) vs II (dtype 3): these four routing/filter cells carry the
     * I/II distinction (constant per mode; exact bits from the master states). */
    {
        static const uint32_t M2[] = {6396464,0x3f800000u, 6396480,0x00000000u,
                                       6396496,0x3f800000u, 6396512,0x3f800000u};
        static const uint32_t M3[] = {6396464,0x00000000u, 6396480,0x3f800000u,
                                       6396496,0x3f353f7du, 6396512,0x3fb4dd2fu};
        const uint32_t *M = (dtype == 3) ? M3 : M2;
        for (k = 0; k < 8; k += 2) {
            bits = M[k + 1]; memcpy(&f, &bits, sizeof f);
            JF(state, (int)M[k]) = f;
        }
    }
    /* Fine-FX filters (CHORUS HIGH/LOW CUT / PRE DELAY) — generalize the S1CHORUS/
     * ARM defaults above to the patch's actual byte (identity at the default). */
    juno_apply_chorus_finefx(state, rec, Hr);
}

/* SLOT-1-hosted REVERB block — DELAY TYPE (v39) 5 routes a reverb into slot 1.
 * 42 engine constants (captured bit-for-bit from the v39==5 master states, same
 * filter-constant family as the delay/chorus) + one per-patch depth (6497344 =
 * blob52/255). 6497168 is a tempo-synced delay time (same Phase-4 sync gap as
 * cell 102352; the manual-time formula is used until sync is derived — see
 * docs/FX_COLDLOAD_TODO.md). Constants captured @48 kHz (rate-dependent filter). */
static const uint32_t S1REVERB[] = {
  6497184,0x3e1b31ceu, 6497232,0x3fb07de6u, 6497248,0xbf07c840u, 6497280,0x3e52bdc7u,
  6497296,0x3fb50bf3u, 6497312,0x3f800000u, 6497328,0x3f800000u, 6497360,0x387fd974u,
  6497376,0x3ed8d8d9u, 6497392,0x3f800000u, 6497408,0x3f800000u, 6497424,0x3c2b929au,
  6497440,0x3f800000u, 6497456,0x3f800000u, 6497472,0x3f4ba5b0u, 6497488,0x3f800000u,
  6497504,0x3f800000u, 10692016,0xc0bafafbu, 10692032,0x3f800000u, 10693008,0x3cef0001u,
  10693040,0x3f000000u, 10693056,0x3f008081u, 10693072,0x3f03df74u, 10693088,0x3f83df74u,
  10693104,0x3f03df74u, 10693120,0xbee549c0u, 10693136,0xbf1cd8f1u, 10693168,0x3f4ba5b0u,
  10693184,0x3fb50bf3u, 10693200,0x3f800000u, 10693216,0x3b56774fu, 10693232,0x3f800000u,
  10693248,0x3f800000u, 10693264,0x3f800000u, 10693280,0x387fd974u, 10693312,0x3f800000u,
  10693328,0x3f800000u, 10693344,0xbf800000u, 10693360,0x3f800000u, 10759360,0x446f8000u,
  10759472,0x3d000000u, 10759840,0x3f29d800u
};
static void apply_slot1_reverb(unsigned char *state, const unsigned char *rec, float tc)
{
    int b52 = blob_val(rec, 52);
    int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
    unsigned k; uint32_t bits; float f;
    for (k = 0; k < sizeof(S1REVERB) / sizeof(S1REVERB[0]); k += 2) {
        bits = S1REVERB[k + 1]; memcpy(&f, &bits, sizeof f);
        JF(state, (int)S1REVERB[k]) = f;
    }
    /* rate-dependent cells (table holds the 48k arm; see put_rate above). The two
     * High-Cut switches (6497264 / 10693152) are 44.1k-only=1.0 and were previously
     * never written; 10759360 is the affine H*0.02-2 predelay (880/958/1762/1918);
     * 102656 (slot-1 delay HF-Damp) is rate-CONSTANT 0x3f4ba5b0 under this config
     * (same as the chorus config — measured, rate_fullscan/rate88_dump). */
    put_rate(state, Hr, 6497264,  ARM_HCSW);
    put_rate(state, Hr, 6497360,  ARM_LFX1);
    put_rate(state, Hr, 6497424,  ARM_LFX2);
    put_rate(state, Hr, 6497472,  ARM_HFDMP);
    put_rate(state, Hr, 10693008, ARM_CHDEP);
    put_rate(state, Hr, 10693152, ARM_HCSW);
    put_rate(state, Hr, 10693216, ARM_CHLF);
    put_rate(state, Hr, 10693280, ARM_LFX1);
    put_rate(state, Hr, 10759360, 0x445c0000u, 0x446f8000u, 0x44dc4000u, 0x44efc000u);
    { uint32_t hb = 0x3f4ba5b0u; memcpy(&f, &hb, sizeof f); JF(state, 102656) = f; }
    JF(state, 6497344) = (float)b52 / 255.0f;   /* reverb depth              */
    JF(state, 6497168) = tc;                    /* delay time (sync-aware)   */
    /* Slot-1-reverb fine-FX: the DELAY fine-FX knobs move the reverb's delay-filter
     * block (6497xxx), the CHORUS fine-FX knobs its chorus-filter block (10693xxx),
     * same laws as TYPE 0 / TYPE 2,3; identity at the default byte (overwrites the
     * S1REVERB placeholders). See finefx_recall.c (proven by finefx_pillar3_gate DT5). */
    juno_apply_delay_finefx_slot1rev(state, rec, Hr);
    juno_apply_chorus_finefx_slot1rev(state, rec, Hr);
}

/* DELAY TYPE 1: dual delay — first instance (102xxx) + second instance (4297584..).
 * Wired with the sync-aware time `tc`: populating both blocks exactly as the
 * captured master states renders BIT-EXACT under our master path (proven by
 * grafting the plugin's populated blocks into the tap-fixed patch-41 state —
 * stereo-identical over the full 8000-sample capture).
 *
 * DELAY TYPE 4 (`second`=0): the SAME first-instance delay block as TYPE 1, but
 * NO second instance. The factory bank contains no type-4 patch, so this arm fell
 * through the type routing entirely, leaving slot 1 at prepare defaults — TYPE-4
 * patches rendered SILENT (found via a user bank; 7 patches affected). PROVEN from
 * the plugin's own recall of a type-4 patch under Unicorn (chillwave patch 14,
 * state dump 2026-07-19): the first instance carries the full TYPE-1 signature
 * (102544 rate arm, 102608 0x3bab929a, 102592=0, wet=level/255, per-patch fb law,
 * ON) while the second instance stays ALL ZERO.
 *   INCOMPLETE (tracked): TYPE 4 ALSO drives a modulated delay-line/reverb block
 *   at ~6429408..6430544 (mask 0x2000, -5.6 gain, DPF-family coefficients) that
 *   this port does not yet populate — so TYPE-4 patches SOUND but are not yet
 *   bit-exact (the reverb-tail component is missing). Deriving that block is a
 *   separate task; the delay body above is faithful on its own. */
static void apply_slot1_delay1(unsigned char *state, const unsigned char *rec, float tc, int second)
{
    int level = blob_val(rec, 52);            /* DELAY LEVEL */
    int fb    = rec_byte(rec, 3057);          /* DELAY FEEDBACK (per-patch law, see TYPE-0) */
    int direct = rec_byte(rec, 3060);         /* DELAY DIRECT LEVEL */
    int on = (level >= 2);
    int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
    unsigned k; uint32_t bits; float f;

    /* constant cells — first instance always; second instance only for TYPE 1 */
    for (k = 0; k < sizeof(DLY1_A) / sizeof(DLY1_A[0]); k += 2) {
        bits = DLY1_A[k + 1]; memcpy(&f, &bits, sizeof f); JF(state, (int)DLY1_A[k]) = f;
    }
    if (second)
        for (k = 0; k < sizeof(DLY1_B) / sizeof(DLY1_B[0]); k += 2) {
            bits = DLY1_B[k + 1]; memcpy(&f, &bits, sizeof f); JF(state, (int)DLY1_B[k]) = f;
        }
    /* rate-dependent cells (tables hold the 48k arm; see put_rate above).
     * First instance: 102544 has TYPE-1-specific arms (2sin(pi*10000/H) family);
     * 102608/102656 are rate-CONSTANT for TYPE 1 (verified: plugin@44.1k holds the
     * same 0x3bab929a / 0x3f4ba5b0 the table writes). Second instance mirrors the
     * TYPE-0 block cell-for-cell. */
    put_rate(state, Hr, 102544, 0x3fa754b5u, 0x3f9bd7cau, 0x3f2493b7u, 0x3f2493b7u);
    if (second) {
        put_rate(state, Hr, 4297680, ARM_HCSW);
        put_rate(state, Hr, 4297776, ARM_LFX1);
        put_rate(state, Hr, 4297904, ARM_LFX2);
        put_rate(state, Hr, 4297952, ARM_HFDMP);

        /* DELAY TIME (sync-aware, same value on both taps — matches every captured
         * TYPE-1 state, synced and manual). 102352 was already written by the caller. */
        JF(state, 4297584) = tc;
    }

    /* WET = DELAY LEVEL / 255 (both taps for TYPE 1). */
    JF(state, 102528)  = (float)level / 255.0f;
    if (second) JF(state, 4297760) = (float)level / 255.0f;

    /* Level gate: first-instance feedback (102560) + ON (102576) and second-instance
     * ON (4297824) drop to 0 when the delay is off (LEVEL < 2); the second-instance
     * feedback (4297808, in DLY1_B) stays constant, matching the captured states. */
    /* First-instance feedback: the plugin's own per-patch law (delay_fb_sweep.py,
     * bit-exact 768/768), gated to 0 when the delay is off exactly as the captured
     * OFF states show (render-equivalent either way: wet is 0). The old captured
     * constant 0x3ed8d8d9 was the fb=120 special case. DRY (102512) likewise gets
     * its per-patch law, overwriting the DLY1_A placeholder. */
    JF(state, 102560)  = on ? ((float)fb / 255.0f) * 0.9f : 0.0f;
    JF(state, 102512)  = (float)direct / 255.0f;
    JF(state, 102576)  = on ? 1.0f : 0.0f;
    if (second) JF(state, 4297824) = on ? 1.0f : 0.0f;
}

void juno_apply_delay(unsigned char *state, const unsigned char *rec)
{
    int dtype  = rec_byte(rec, 650);          /* DELAY TYPE -> v39 selector      */
    int level  = blob_val(rec, 52);           /* DELAY LEVEL (blob 52, NOT 40: blob 40 is
                                                  ENV1 ATTACK. dispatch=blob+744 pins 796->52;
                                                  was colliding with the knob recall — 11
                                                  patches had delay wrongly OFF.)            */
    int dtime  = blob_val(rec, 53);           /* DELAY TIME  (blob 53, NOT 49: blob 49 is
                                                  VCA TONE; 797->53.)                        */
    int sync   = blob_val(rec, 59) != 0;      /* TEMPO SYNC (blob 59; also LFO sync) */
    int fb     = rec_byte(rec, 3057);         /* DELAY FEEDBACK                  */
    int direct = rec_byte(rec, 3060);         /* DELAY DIRECT LEVEL              */
    int Hr = (int)JF(state, 16);
    unsigned k;
    uint32_t bits;
    float f, tc;
    if (Hr <= 0) Hr = 96000;

    /* The plugin CLAMPS out-of-range DELAY TYPE to 5 (routing int at 6/9/255 ==
     * the type-5 value, PROVEN by the setter spot sweep under Unicorn,
     * scratchpad/ext_sweeps.py 2026-07-19); the raw write diverged for >5. */
    if (dtype > 5) dtype = 5;
    *(int32_t *)(state + JUNO_PROG_DLY) = (int32_t)dtype;  /* per-patch slot-1 mode */

    /* Ring-buffer geometry ints — the plugin's recall writes these for EVERY
     * patch (PROVEN: identical in the type-0 and type-4 full-state dumps at
     * 44.1/48/88.2 kHz; the plugin's COLD state holds 0 here like the port's,
     * so they are recall-written, not prepare constants). Factory renders never
     * read them (57/57 was bit-exact before they were added), but the TYPE-4
     * arm reads 6429412 as its ring MASK every sample — with the port's former
     * 0 the mask underflowed to 0xFFFFFFFF and the ring addressing was garbage. */
    *(int32_t *)(state + 95828)    = 0x400;
    *(int32_t *)(state + 101028)   = 0x400;
    *(int32_t *)(state + 2199956)  = 0x80000;
    *(int32_t *)(state + 4297124)  = 0x80000;
    *(int32_t *)(state + 6395252)  = 0x80000;
    *(int32_t *)(state + 6429412)  = 0x2000;
    *(int32_t *)(state + 6463716)  = 0x2000;
    *(int32_t *)(state + 6496500)  = 0x2000;
    *(int32_t *)(state + 8594772)  = 0x80000;
    *(int32_t *)(state + 10691940) = 0x80000;
    *(int32_t *)(state + 10726260) = 0x2000;
    *(int32_t *)(state + 10759044) = 0x2000;

    /* Delay Time (102352): SYNC-AWARE, written for EVERY DELAY TYPE — the plugin's
     * recall dispatches the time leaf before the type routing, so 102352 carries
     * the (synced or manual) time in every captured state regardless of slot-1
     * mode. Rate-parameterized via the exact 3-op formula (dly_ms_to_coeff): the
     * algebraically-equal ((H*ms-2)/16384) is wrong — H*ms exceeds 2^24 so the -2
     * must come after the scale. Hr from state[16], unset => 96 kHz. */
    tc = dly_time_coeff(Hr, dtime, sync);
    JF(state, 102352) = tc;

    if (dtype == 2 || dtype == 3) {            /* slot 1 hosts chorus I/II */
        apply_slot1_chorus(state, rec, dtype);
        return;
    }
    if (dtype == 5) {                          /* slot 1 hosts reverb */
        apply_slot1_reverb(state, rec, tc);
        return;
    }
    if (dtype == 1 || dtype == 4) {            /* delay family: 1 = dual (both instances),
                                                  4 = single (first instance only — PROVEN
                                                  from the plugin's own recall of a type-4
                                                  user patch; no factory patch has type 4) */
        apply_slot1_delay1(state, rec, tc, dtype == 1);
        if (dtype == 1) {
            /* TYPE 1 second-instance fine-FX: HIGH CUT / DAMP / DIRECT move the
             * second delay instance (4297xxx), same law as TYPE-0, identity at the
             * default byte (overwrites the DLY1_B placeholders). See finefx_recall.c. */
            juno_apply_delay_finefx_2nd(state, rec, Hr);
        }
        if (dtype == 4) {
            /* TYPE-4 modulated-delay block (6429408..6430544), read by the
             * master render's type-4 arm (ring mask at 6429412). Laws PROVEN by
             * doctored-record full recalls of a type-4 user patch under Unicorn
             * (scratchpad/dtype4_block_derive.py, 17 recalls: per-param 3-point
             * sweeps + 44.1/88.2 rate runs + type-0 control):
             *   6429472 = -(12 - (time*(1/255))*12)  (bit-exact op chain over
             *             {0,136,255}; -0 at time 255 from the final negate)
             *   6430512 = DELAY LEVEL / 255 (wet)
             *   6429488 = 6430480 = 1.0 (enable gates)
             *   6430496/6430528/6430544 = constants (invariant across level/
             *             time/fb/hc/direct/tap sweeps and 44.1/88.2 rates)
             * fb/hc/direct/tap do NOT touch this block (swept, zero cells). */
            float t = (float)dtime * (1.0f / 255.0f);
            int lvl32 = level * 32; if (lvl32 > 255) lvl32 = 255;
            /* tail constants + the DPF stage [6430544..6430800], from the same
             * derivation (invariant across level/time/fb/hc/direct + reverb
             * level/time + effect depth/tone sweeps; three cells are rate-armed
             * 2-class {44100, else} — 88200 confirmed on the else arm for the
             * head block; tail follows the same family, noted in the comment). */
            static const uint32_t T4_TAIL[] = {
                6430496,0x3df465fcu, 6430528,0x3f03df74u, 6430544,0x3f83df74u,
                6430560,0x3f03df74u, 6430576,0xbee549c0u, 6430592,0xbf1cd8f1u,
                6430624,0x3f4ba5b0u, 6430640,0x3fb50bf3u, 6430672,0x3b56774fu,
                6430688,0x3f800000u, 6430704,0x3f800000u, 6430720,0x3f800000u,
                6430736,0x387fd974u, 6430752,0x3f4fcfd0u, 6430784,0x3f800000u,
                6430800,0x3f800000u
            };
            unsigned k4;
            for (k4 = 0; k4 < sizeof(T4_TAIL)/sizeof(T4_TAIL[0]); k4 += 2) {
                uint32_t b4 = T4_TAIL[k4 + 1]; float f4; memcpy(&f4, &b4, 4);
                JF(state, (int)T4_TAIL[k4]) = f4;
            }
            if (Hr == 44100) {          /* measured 44.1k arms (plugin recall) */
                static const uint32_t T4_44[] = {
                    6430608,0x3f800000u, 6430672,0x3b696eb3u, 6430736,0x388b3cdfu };
                for (k4 = 0; k4 < sizeof(T4_44)/sizeof(T4_44[0]); k4 += 2) {
                    uint32_t b4 = T4_44[k4 + 1]; float f4; memcpy(&f4, &b4, 4);
                    JF(state, (int)T4_44[k4]) = f4;
                }
            }
            JF(state, 6429472) = -(12.0f - t * 12.0f);
            JF(state, 6429488) = 1.0f;
            JF(state, 6430480) = 1.0f;
            JF(state, 6430512) = (float)level / 255.0f;
            /* 6430768 = min(level*32,255)/255 (candidate law: exact at the
             * measured 0/3/255 points; 7/8/100 probe pending — the 7-patch A/B
             * is the final arbiter) */
            JF(state, 6430768) = (float)lvl32 / 255.0f;
        }
        return;
    }
    if (dtype != 0)                            /* other types: slot 1 not the delay block */
        return;

    for (k = 0; k < sizeof(FILT) / sizeof(FILT[0]); k += 2) {
        bits = FILT[k + 1];
        memcpy(&f, &bits, sizeof f);
        JF(state, (int)FILT[k]) = f;
    }
    /* FEEDBACK (102560) and DRY (102512) are PER-PATCH, not engine constants: the
     * plugin's own dispatch (idx 1179/1181, executed over all 256 values x 3 rates,
     * tools/verify/delay_fb_sweep.py) gives the bit-exact, rate-independent laws
     *   102560 = f32(byte/255) * f32(0.9)      (mulss order proven)
     *   102512 = f32(byte)/255
     * The old FILT constants (0.4235294 / 1.0) were a CAPTURE that coincided with
     * the modal factory bytes (fb 120, direct 255) — proven wrong by the 64-patch
     * render A/B for the 5 patches with other fb bytes {0,76,114,209} (A3). These
     * overwrite the FILT placeholders after the block. */
    JF(state, 102560) = ((float)fb / 255.0f) * 0.9f;
    JF(state, 102512) = (float)direct / 255.0f;
    /* rate-dependent FILT cells (table holds the 48k arm; see put_rate above) */
    put_rate(state, Hr, 102448, ARM_HCSW);
    put_rate(state, Hr, 102544, ARM_LFX1);
    put_rate(state, Hr, 102608, ARM_LFX2);
    put_rate(state, Hr, 102656, ARM_HFDMP);
    JF(state, 102528) = (float)level  / 255.0f;             /* Wet (per-patch = LEVEL/255) */
    JF(state, 102576) = level >= 2 ? 1.0f : 0.0f;           /* On/Off (curve: v0,v1->0, v2->1) */

    /* Fine-FX filter params (DELAY HIGH CUT / LF+HF DAMP / LF+HF DAMP FREQ) — the
     * leaves the plugin's recall enumerator does NOT fire but a host's preset-load
     * applies (see finefx_recall.c). Overwrites the FILT[]/put_rate default cells
     * with the per-byte law; a no-op for default-fine-FX patches (identity at the
     * default byte). TYPE-0 only: TYPE 2/3/5 route slot-1 to chorus/reverb which
     * own these cells, and TYPE 1/4 use the DLY1_A signature. */
    juno_apply_delay_finefx(state, rec, Hr);
}

/* Host-tempo recompute for the tempo-synced delay time — the delay sibling of
 * juno_apply_lfo_tempo. The plugin's tempo push (dispatch idx 375) rewrites the
 * delay-time cells as ms = f32(beats(division) * 60000 / BPM) through the same
 * 3-op coefficient formula — verified bit-exact vs the plugin's own dispatch at
 * 60/88/176 BPM (the 128-BPM recall default equals the SYNC_MS_128 path). Inert
 * while the patch's TEMPO SYNC is off. time_byte/sync/dtype are the loaded patch's
 * DELAY TIME byte (blob 53), TEMPO SYNC (blob 59 != 0) and DELAY TYPE (rec 650). */
void juno_apply_delay_tempo(unsigned char *state, int time_byte, int sync,
                            int dtype, float bpm)
{
    int Hr;
    float ms, tc;
    if (!sync || bpm <= 0.0f) return;
    Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
    ms = (float)(SYNC_BEATS[sync_division(time_byte & 0xFF)] * 60000.0 / (double)bpm);
    tc = dly_ms_to_coeff(Hr, ms);
    JF(state, 102352) = tc;                       /* always carries the time      */
    if (dtype == 1) JF(state, 4297584) = tc;      /* dual-delay second instance   */
    if (dtype == 5) JF(state, 6497168) = tc;      /* reverb-hosted delay instance */
}

/* LIVE TEMPO SYNC flip (value-tree leaf blob 59, dispatch idx 803) — measured from
 * the plugin's own live dispatch under emulation (fuzz seed 70 + sync probes,
 * DELAY TYPE 1 and 5, both directions): the live flip rewrites ONLY the active
 * slot-1 INSTANCE time cell — synced value (at the current host BPM) on engage,
 * the patch's MANUAL time on disengage — and, unlike recall/tempo push, does NOT
 * touch the first-instance/base cell 102352 (writing it would introduce a fresh
 * divergence: the plugin provably leaves it at manual time on a live flip). The
 * type-1 flip also rewrites 4297792 with its unchanged recall value (inert; not
 * modeled). TYPE 0 (probed): the active instance IS the base cell — the live flip
 * rewrites 102352 (synced ON / manual OFF). TYPES 2/3 (probed): the flip re-writes
 * the repurposed chorus rate cell 6395312 with its UNCHANGED value (inert; not
 * modeled). */
void juno_live_delay_sync(unsigned char *state, int time_byte, int sync,
                          int dtype, float bpm)
{
    int Hr = (int)JF(state, 16);
    float ms, tc;
    if (Hr <= 0) Hr = 96000;
    if (sync && bpm > 0.0f)
        ms = (float)(SYNC_BEATS[sync_division(time_byte & 0xFF)] * 60000.0 / (double)bpm);
    else
        ms = (float)DELAYTIME_MS[time_byte & 0xFF];
    tc = dly_ms_to_coeff(Hr, ms);
    if (dtype == 0) JF(state, 102352)  = tc;
    if (dtype == 1) JF(state, 4297584) = tc;
    if (dtype == 5) JF(state, 6497168) = tc;
}
