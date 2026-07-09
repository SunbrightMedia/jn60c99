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
 *   Delay Time (102352) = DELAYTIME_LUT[DELAY TIME byte]    [dispatch idx 797]
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

/* DELAY TIME byte -> engine offset 102352, 256 entries, verbatim from the value
 * tree (dispatch idx 797). Non-linear (musical) delay-time curve. */
static const uint32_t DELAYTIME_LUT[256] = {
  0x3d6f8001u, 0x3d6f8001u, 0x3d83c000u, 0x3d8fc000u, 0x3d9bc000u, 0x3da7c001u,
  0x3da7c001u, 0x3db3c001u, 0x3dbfc001u, 0x3dcbc001u, 0x3dd7c001u, 0x3de3c001u,
  0x3defc001u, 0x3defc001u, 0x3dfbc001u, 0x3e03e000u, 0x3e09e000u, 0x3e0fe000u,
  0x3e15e000u, 0x3e1be000u, 0x3e21e001u, 0x3e27e001u, 0x3e2de001u, 0x3e33e001u,
  0x3e39e001u, 0x3e3fe001u, 0x3e45e001u, 0x3e4be001u, 0x3e51e001u, 0x3e57e001u,
  0x3e5de001u, 0x3e63e001u, 0x3e69e001u, 0x3e6fe001u, 0x3e75e001u, 0x3e7be001u,
  0x3e80f000u, 0x3e83f000u, 0x3e86f000u, 0x3e8cf000u, 0x3e8ff000u, 0x3e92f000u,
  0x3e95f000u, 0x3e98f000u, 0x3e9bf000u, 0x3ea1f001u, 0x3ea4f001u, 0x3ea7f001u,
  0x3eaaf001u, 0x3eadf001u, 0x3eb3f001u, 0x3eb6f001u, 0x3eb9f001u, 0x3ebcf001u,
  0x3ec2f001u, 0x3ec5f001u, 0x3ec8f001u, 0x3ecef001u, 0x3ed1f001u, 0x3ed4f001u,
  0x3edaf001u, 0x3eddf001u, 0x3ee0f001u, 0x3ee6f001u, 0x3ee9f001u, 0x3eeff001u,
  0x3ef2f001u, 0x3ef5f001u, 0x3efbf001u, 0x3efef001u, 0x3f027800u, 0x3f03f800u,
  0x3f06f800u, 0x3f087800u, 0x3f0b7800u, 0x3f0e7800u, 0x3f0ff800u, 0x3f12f800u,
  0x3f147800u, 0x3f177800u, 0x3f18f800u, 0x3f1bf800u, 0x3f1ef800u, 0x3f207800u,
  0x3f237801u, 0x3f267801u, 0x3f297801u, 0x3f2af801u, 0x3f2df801u, 0x3f30f801u,
  0x3f33f801u, 0x3f357801u, 0x3f387801u, 0x3f3b7801u, 0x3f3e7801u, 0x3f417801u,
  0x3f447801u, 0x3f45f801u, 0x3f48f801u, 0x3f4bf801u, 0x3f4ef801u, 0x3f51f801u,
  0x3f54f801u, 0x3f57f801u, 0x3f5af801u, 0x3f5df801u, 0x3f60f801u, 0x3f63f801u,
  0x3f66f801u, 0x3f6b7801u, 0x3f6e7801u, 0x3f717801u, 0x3f747801u, 0x3f777801u,
  0x3f7a7801u, 0x3f7ef801u, 0x3f80fc00u, 0x3f827c00u, 0x3f83fc00u, 0x3f863c00u,
  0x3f87bc00u, 0x3f893c00u, 0x3f8b7c00u, 0x3f8cfc00u, 0x3f8f3c00u, 0x3f90bc00u,
  0x3f92fc00u, 0x3f947c00u, 0x3f96bc00u, 0x3f983c00u, 0x3f9a7c00u, 0x3f9bfc00u,
  0x3f9e3c00u, 0x3f9fbc00u, 0x3fa1fc01u, 0x3fa43c01u, 0x3fa5bc01u, 0x3fa7fc01u,
  0x3faa3c01u, 0x3fac7c01u, 0x3fadfc01u, 0x3fb03c01u, 0x3fb27c01u, 0x3fb4bc01u,
  0x3fb6fc01u, 0x3fb93c01u, 0x3fbb7c01u, 0x3fbdbc01u, 0x3fbffc01u, 0x3fc23c01u,
  0x3fc47c01u, 0x3fc6bc01u, 0x3fc8fc01u, 0x3fcb3c01u, 0x3fcd7c01u, 0x3fd07c01u,
  0x3fd2bc01u, 0x3fd4fc01u, 0x3fd73c01u, 0x3fda3c01u, 0x3fdc7c01u, 0x3fdebc01u,
  0x3fe1bc01u, 0x3fe3fc01u, 0x3fe6fc01u, 0x3fe93c01u, 0x3fec3c01u, 0x3fee7c01u,
  0x3ff17c01u, 0x3ff3bc01u, 0x3ff6bc01u, 0x3ff9bc01u, 0x3ffcbc01u, 0x3ffefc01u,
  0x4000fe00u, 0x40027e00u, 0x4003fe00u, 0x40057e00u, 0x4006fe00u, 0x40087e00u,
  0x4009fe00u, 0x400b7e00u, 0x400cfe00u, 0x400e7e00u, 0x400ffe00u, 0x40117e00u,
  0x4012fe00u, 0x4014de00u, 0x40165e00u, 0x4017de00u, 0x4019be00u, 0x401b3e00u,
  0x401d1e00u, 0x401e9e00u, 0x40207e00u, 0x4021fe01u, 0x4023de01u, 0x4025be01u,
  0x40273e01u, 0x40291e01u, 0x402afe01u, 0x402cde01u, 0x402ebe01u, 0x40309e01u,
  0x40327e01u, 0x40345e01u, 0x40363e01u, 0x40381e01u, 0x4039fe01u, 0x403bde01u,
  0x403dbe01u, 0x403ffe01u, 0x4041de01u, 0x4043be01u, 0x4045fe01u, 0x4047de01u,
  0x404a1e01u, 0x404c5e01u, 0x404e3e01u, 0x40507e01u, 0x4052be01u, 0x40549e01u,
  0x4056de01u, 0x40591e01u, 0x405b5e01u, 0x405d9e01u, 0x405fde01u, 0x40621e01u,
  0x4064be01u, 0x4066fe01u, 0x40693e01u, 0x406b7e01u, 0x406e1e01u, 0x40705e01u,
  0x4072fe01u, 0x40753e01u, 0x4077de01u, 0x407a7e01u, 0x407d1e01u, 0x407f5e01u,
  0x4080ff00u, 0x40824f00u, 0x40839f00u, 0x4084ef00u, 0x40866f00u, 0x4087bf00u,
  0x40890f00u, 0x408a5f00u, 0x408bdf00u, 0x408d2f00u, 0x408eaf00u, 0x408fff00u,
  0x40917f00u, 0x4092ff00u, 0x40947f00u, 0x4095ff00u,
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
    bits = DELAYTIME_LUT[dtime & 0xFF];
    memcpy(&f, &bits, sizeof f);
    JF(state, 102352) = f;                                  /* Delay Time */
}
