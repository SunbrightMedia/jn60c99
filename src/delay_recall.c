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
    unsigned k; uint32_t bits; float f;
    for (k = 0; k < sizeof(S1CHORUS) / sizeof(S1CHORUS[0]); k += 2) {
        bits = S1CHORUS[k + 1]; memcpy(&f, &bits, sizeof f);
        JF(state, (int)S1CHORUS[k]) = f;
    }
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
static void apply_slot1_reverb(unsigned char *state, const unsigned char *rec)
{
    int b52 = blob_val(rec, 52), b53 = blob_val(rec, 53);
    int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
    unsigned k; uint32_t bits; float f, dt;
    for (k = 0; k < sizeof(S1REVERB) / sizeof(S1REVERB[0]); k += 2) {
        bits = S1REVERB[k + 1]; memcpy(&f, &bits, sizeof f);
        JF(state, (int)S1REVERB[k]) = f;
    }
    JF(state, 6497344) = (float)b52 / 255.0f;                     /* reverb depth       */
    dt = (float)Hr * (float)DELAYTIME_MS[b53 & 0xFF];             /* time (manual; sync TODO) */
    dt = dt * (1.0f / 16384000.0f);
    dt = dt - (2.0f / 16384.0f);
    JF(state, 6497168) = dt;
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
    int fb     = rec_byte(rec, 3057);         /* DELAY FEEDBACK                  */
    int direct = rec_byte(rec, 3060);         /* DELAY DIRECT LEVEL              */
    unsigned k;
    uint32_t bits;
    float f;

    *(int32_t *)(state + JUNO_PROG_DLY) = (int32_t)dtype;  /* per-patch slot-1 mode */

    if (dtype == 2 || dtype == 3) {            /* slot 1 hosts chorus I/II */
        apply_slot1_chorus(state, rec, dtype);
        return;
    }
    if (dtype == 5) {                          /* slot 1 hosts reverb */
        apply_slot1_reverb(state, rec);
        return;
    }
    if (dtype != 0)                            /* other types: slot 1 not the delay block */
        return;

    (void)fb; (void)direct;   /* feedback (102560) and dry (102512) are engine constants (in FILT) */
    for (k = 0; k < sizeof(FILT) / sizeof(FILT[0]); k += 2) {
        bits = FILT[k + 1];
        memcpy(&f, &bits, sizeof f);
        JF(state, (int)FILT[k]) = f;
    }
    JF(state, 102528) = (float)level  / 255.0f;             /* Wet (per-patch = LEVEL/255) */
    JF(state, 102576) = level >= 2 ? 1.0f : 0.0f;           /* On/Off (curve: v0,v1->0, v2->1) */
    /* Delay Time (102352): rate-parameterized. coeff = ((float)H*ms)*(1/16384000)
     * - (2/16384), in THIS three-op float32 order (the algebraically-equal
     * ((H*ms-2)/16384) is wrong — H*ms exceeds 2^24 so the -2 vanishes before the
     * scale). Hr from state[16] exactly as prepare/apply read it; unset => 96 kHz. */
    {
        int Hr = (int)JF(state, 16); if (Hr <= 0) Hr = 96000;
        float dt = (float)Hr * (float)DELAYTIME_MS[dtime & 0xFF]; /* mulss H,ms   */
        dt = dt * (1.0f / 16384000.0f);                          /* mulss C1      */
        dt = dt - (2.0f / 16384.0f);                             /* subss C2 (2^-13) */
        JF(state, 102352) = dt;
    }
}
