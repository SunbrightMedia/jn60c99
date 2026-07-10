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

/* Constant high-cut + damp filter block (offset, bits) — the plugin's recomputed
 * coefficients for the default DELAY HIGH CUT (7) / LF+HF DAMP settings that every
 * bank patch uses. From value-tree dispatch idx 1180 (high cut) and 1182..1185
 * (LF/HF damp). Offsets 102448/102496 stay 0 (filter switches off). */
static const uint32_t FILT[] = {
  102368,0x3f03df74u, 102384,0x3f83df74u, 102400,0x3f03df74u, 102416,0xbee549c0u,
  102432,0xbf1cd8f1u, 102464,0x3f4ba5b0u, 102480,0x3fb50bf3u,
  102608,0x3bab929au, 102624,0x3f800000u, 102640,0x3f800000u,
  102656,0x3d28e14bu, 102672,0x3f800000u, 102688,0x3f800000u
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

    if (dtype != 0)                            /* slot 1 not routing the delay block */
        return;

    for (k = 0; k < sizeof(FILT) / sizeof(FILT[0]); k += 2) {
        bits = FILT[k + 1];
        memcpy(&f, &bits, sizeof f);
        JF(state, (int)FILT[k]) = f;
    }
    JF(state, 102528) = (float)level  / 255.0f;             /* Wet      */
    JF(state, 102560) = (float)fb     / 255.0f * 0.9f;      /* Feedback */
    JF(state, 102576) = level >= 2 ? 1.0f : 0.0f;           /* On/Off (curve: v0,v1->0, v2->1) */
    JF(state, 102592) = level >= 2 ? 1.0f : 0.0f;           /* Mute/enable */
    JF(state, 102512) = (float)direct / 255.0f;             /* Dry      */
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
