/* jx_dispatch_note.c -- the JX-3P per-voice NOTE / GATE dispatch handlers,
 * transcribed bit-literal from the plugin's machine code.
 *
 * Source of truth (disasm via jx3p/tools/disasm.py, binary via truth.py):
 *   dispatch 0x3EBB00 routes id 433+v ("note", v=0..7) -> 0x3E0130+0x20*v
 *   and id 450+v ("gate") -> 0x3E0C50+0x80*v.  Calling convention:
 *   rcx = PROC unit object, edx = flag, r8d = posted value.
 *
 * PER-VOICE DELTA TABLE (verified by dumping v0,v1,v2 and v7; the 16
 * handlers are STRUCTURALLY IDENTICAL, differing only in these constants):
 *   note handler 0x3E0130+0x20*v : loads [proc + 0x110 + 0x10*v] only.
 *   gate handler 0x3E0C50+0x80*v : tests [proc + 0x644 + 4*v], loads
 *     [proc + 0x110 + 0x10*v], sets r9d = v, tail-jmp 0x3E3D70 (shared).
 *
 * OBJECT GRAPH (READ from the code; pointer values PROVEN(executed) by
 * reading a live instance built under tools/verify/jx_emu.py):
 *   proc+0x010+0x10*v -> o010(v)  vtbl 0x9BEF78 (all 8 voices share it)
 *   proc+0x110+0x10*v -> o110(v)  vtbl 0x9BF540 (shared)
 *   proc+0x210+0x10*v -> o210(v)  vtbl 0x9BEE10 (shared)
 *   proc+0x290+0x10*v -> o290(v)  vtbl 0x9BE800 (shared)
 * Because every voice shares one vtable per base, EVERY virtual call in
 * these paths resolves to one concrete function; no callback seam remains.
 *
 * CONCRETE TARGETS (all transcribed below, full depth):
 *   o110 slot 0x20  0x35FCB0  note: value = lut13[note] + temper[(r9+note)%12]
 *                              - temper[(0x15-a)%12], posted immediate
 *   o110 slot 0x18  0x35FD80  immediate post of param [o110+0x60]
 *   o110 slot 0x80  0x35FC00  gate-on  pulse: post (r8!=0)?1:0 to [o110+0x70]
 *   o110 slot 0x88  0x35FEE0  gate-off pulse: post (r8==1)?1:0 to [o110+0x74]
 *   o110 slot 0x28  0x35FDA0  post (r8!=0)?1:0 to [o110+0x64]
 *   o290 slot 0x20  0x359200  post lut1b[clamp(r8,0,1)] to [o290+0x834]
 *   o290 slot 0x18  0x359390  post lut22[clamp(vel,0,127)] to [o290+0x84c]
 *   o210 slot 0xC0  0x35C570  post lut21[clamp(vel,0,127)] to [o210+0xC5C]
 *   o010 slot 0x50  0x35D1B0  post lut1c[clamp(any,0,1)] to [o010+0x28]
 *   gate tail       0x3E3D70  the shared per-voice gate sequence
 *   value mapper    0x358960  switch(case) -> clamp + static-LUT read
 *   post chain      0x357F30 -> 0x3F2D30 -> 0x3F4390 (IMMEDIATE store)
 *
 * POST PLUMBING (0x357F30): rcx = obj+8 -> [obj+8] -> [[obj+8]] = the DSP
 * STATE BLOB itself (the 0xAAC310 allocation jx.state[unit] points at; its
 * head doubles as the parameter manager).  0x3F4390:
 *   rec = [state+0x38] + idx*0x28 ; *(float*)[rec+0x20] = value
 * i.e. an immediate float store through the parameter record table.  The
 * RAMPED poster 0x3F4560 and the ramp arm 0x3F4AC0 are NOT REACHED by any
 * function in this call graph (every reached wrapper tail-jumps 0x357F30);
 * they are documented, not transcribed.
 *
 * POINTER-PATH MAP (PROC -> written regions), offsets PROVEN(executed):
 *   1. proc_blob itself: dword [proc+0x644+4*v] written (the stored gate);
 *      dwords [proc+0x63C] (lo) and [proc+0x640] (hi) read.  In addition the
 *      DISPATCH 0x3EBB00 itself, right after the vcall into each handler,
 *      stores the raw posted value into a shadow dword: note id 433+v ->
 *      [proc+0x444+4*v] (store at 0x3EBF54 for v=0), gate id 450+v ->
 *      [proc+0x464+4*v] (0x3EC06C for v=0); stride PROVEN(executed) on
 *      v=1,5,7.  Those stores belong to the dispatch of these ids and are
 *      included in the exported functions.  Lowest proc write 0x444,
 *      highest 0x644+4*hi (hi=7 -> 0x660).
 *   2. state_blob (via o110+8 -> P1 -> P1+0 == state, then the record table
 *      [state+0x38], rec+0x20 -> back INTO state_blob).  Param index ->
 *      state offset, read from the live record table; the pattern is exact
 *      over all 64 used records:
 *        voice-strided params (idx k+106*v -> off base_k + 0x3F00*v):
 *          k=  1 note        -> 0x0130 + 0x3F00*v   ([o110+0x60])
 *          k=  2 gate level  -> 0x0140 + 0x3F00*v   ([o110+0x64])
 *          k= 12 any-gate    -> 0x0730 + 0x3F00*v   ([o010+0x28])
 *          k= 76 vel lin     -> 0x3380 + 0x3F00*v   ([o210+0xC5C])
 *          k= 98 vel curve   -> 0x3B80 + 0x3F00*v   ([o290+0x84C])
 *          k= 99 const-1     -> 0x3C10 + 0x3F00*v   ([o290+0x834])
 *        trigger pulses (idx 911+2v / 912+2v):
 *          on  911+2v -> 0x41F70 + 0x20*v           ([o110+0x70])
 *          off 912+2v -> 0x41F80 + 0x20*v           ([o110+0x74])
 *      Lowest state write 0x130, highest 0x41F80+0x20*7 = 0x42060.
 *   No other memory is written by any function on these paths.
 *
 * STOPPED-AT calls: NONE into the CRT/math imports and NO unresolved vtable
 * slots -- the whole graph bottoms out in the immediate store 0x3F4390.
 * The repo's expf/tanf twins are therefore not needed here.
 *
 * READ-ONLY ENVIRONMENT (jx_dn_cbs): the note handler 0x35FCB0 reads three
 * o110 fields that are runtime state of ANOTHER parameter's handler, not of
 * this path: [o110+0x50] = pointer to a 12-float temper table (static RVA
 * 0x9BF320, all zero at build), [o110+0x58], [o110+0x5C] (both 0 at build).
 * They are inputs here, never written; the struct carries them so the gate
 * can drive them once their writer is transcribed.  NULL/zero = build state.
 *
 * Static data embedded below is the BINARY'S OWN .rdata (READ from the
 * image at the listed RVAs), not captures.
 *
 * Transcription is LITERAL: each branch mirrors an instruction.  Do not
 * "improve" the logic -- bit-exact or nothing (RULE 1 of the project).
 */
#include <stdint.h>
#if JX_DN_TOOTH
#define JXDN_TOOTHVAL 1   /* the tooth skews one gate store by one */
#else
#define JXDN_TOOTHVAL 0
#endif
#include <string.h>

typedef struct {
    /* [o110+0x50] temper table.  The plugin's index is a SIGNED remainder
     * mod 12 (range -11..11); for negative indexes its movss reads the
     * static bytes BEFORE the table at RVA 0x9BF320 (parts of adjacent
     * vftable pointers, fixed at the preferred/emulated image base
     * 0x180000000).  To stay bit-exact the port keeps a 23-dword table,
     * base index 11: temper23[11 + rem].  NULL -> the binary's own bytes
     * (jxdn_temper_default below, READ from the image, 0x9BF2F4..0x9BF34F).
     */
    const float *temper23;
    int32_t      o110_58;    /* [o110+0x58] (0x35FCB0 compares vs 7)      */
    int32_t      o110_5c;    /* [o110+0x5C] (transpose-ish int)           */
} jx_dn_cbs;                 /* no true callbacks remain -- see header    */

/* RVA 0x9BF2F4..0x9BF34F: 11 dwords preceding + the 12-zero table itself */
static const uint32_t jxdn_temper_default[23] = {
    0x3f800000,0x3f800000,0x00000000,0x80b37340,0x00000001,0x806e555c,
    0x00000001,0x80b373c8,0x00000001,0x8035f630,0x00000001,
    0,0,0,0,0,0,0,0,0,0,0,0
};

/* RVA 0x9B4860, 128 dwords */
static const uint32_t jxdn_lut13[128] = {
    0xbf800000,0xbf6aaaab,0xbf555555,0xbf400000,0xbf2aaaaa,0xbf155556,
    0xbf000000,0xbed55556,0xbeaaaaaa,0xbe800000,0xbe2aaaac,0xbdaaaaa8,
    0x00000000,0x3daaaab0,0x3e2aaaa8,0x3e800000,0x3eaaaaac,0x3ed55554,
    0x3f000000,0x3f155556,0x3f2aaaaa,0x3f400000,0x3f555556,0x3f6aaaaa,
    0x3f800000,0x3f8aaaaa,0x3f955556,0x3fa00000,0x3faaaaaa,0x3fb55556,
    0x3fc00000,0x3fcaaaaa,0x3fd55556,0x3fe00000,0x3feaaaaa,0x3ff55556,
    0x40000000,0x40055555,0x400aaaab,0x40100000,0x40155555,0x401aaaab,
    0x40200000,0x40255555,0x402aaaab,0x40300000,0x40355555,0x403aaaab,
    0x40400000,0x40455556,0x404aaaaa,0x40500000,0x40555556,0x405aaaaa,
    0x40600000,0x40655556,0x406aaaaa,0x40700000,0x40755556,0x407aaaaa,
    0x40800000,0x4082aaab,0x40855555,0x40880000,0x408aaaab,0x408d5555,
    0x40900000,0x4092aaab,0x40955555,0x40980000,0x409aaaab,0x409d5555,
    0x40a00000,0x40a2aaab,0x40a55555,0x40a80000,0x40aaaaab,0x40ad5555,
    0x40b00000,0x40b2aaab,0x40b55555,0x40b80000,0x40baaaab,0x40bd5555,
    0x40c00000,0x40c2aaab,0x40c55555,0x40c80000,0x40caaaab,0x40cd5555,
    0x40d00000,0x40d2aaab,0x40d55555,0x40d80000,0x40daaaab,0x40dd5555,
    0x40e00000,0x40e2aaaa,0x40e55556,0x40e80000,0x40eaaaaa,0x40ed5556,
    0x40f00000,0x40f2aaaa,0x40f55556,0x40f80000,0x40faaaaa,0x40fd5556,
    0x41000000,0x41015555,0x4102aaab,0x41040000,0x41055555,0x4106aaab,
    0x41080000,0x41095555,0x410aaaab,0x410c0000,0x410d5555,0x410eaaab,
    0x41100000,0x41115555,0x4112aaab,0x41140000,0x41155555,0x4116aaab,
    0x41180000,0x41195555
};
/* as float: first (-1.0, -0.9166666865348816, -0.8333333134651184, -0.75) last (9.5, 9.583333015441895) */
/* RVA 0x9B6590, 2 dwords */
static const uint32_t jxdn_lut1b[2] = {
    0x3f800000,0x00000000
};
/* as float: first (1.0, 0.0) last (1.0, 0.0) */
/* RVA 0x9B6598, 2 dwords */
static const uint32_t jxdn_lut1c[2] = {
    0x00000000,0x3f800000
};
/* as float: first (0.0, 1.0) last (0.0, 1.0) */
/* RVA 0x9B9B20, 128 dwords */
static const uint32_t jxdn_lut21[128] = {
    0x00000000,0x3c010204,0x3c810204,0x3cc18306,0x3d010204,0x3d214285,
    0x3d418306,0x3d61c387,0x3d810204,0x3d912245,0x3da14285,0x3db162c6,
    0x3dc18306,0x3dd1a347,0x3de1c387,0x3df1e3c8,0x3e010204,0x3e091224,
    0x3e112245,0x3e193265,0x3e214285,0x3e2952a5,0x3e3162c6,0x3e3972e6,
    0x3e418306,0x3e499326,0x3e51a347,0x3e59b367,0x3e61c387,0x3e69d3a7,
    0x3e71e3c8,0x3e79f3e8,0x3e810204,0x3e850a14,0x3e891224,0x3e8d1a34,
    0x3e912245,0x3e952a55,0x3e993265,0x3e9d3a75,0x3ea14285,0x3ea54a95,
    0x3ea952a5,0x3ead5ab5,0x3eb162c6,0x3eb56ad6,0x3eb972e6,0x3ebd7af6,
    0x3ec18306,0x3ec58b16,0x3ec99326,0x3ecd9b36,0x3ed1a347,0x3ed5ab57,
    0x3ed9b367,0x3eddbb77,0x3ee1c387,0x3ee5cb97,0x3ee9d3a7,0x3eeddbb7,
    0x3ef1e3c8,0x3ef5ebd8,0x3ef9f3e8,0x3efdfbf8,0x3f010204,0x3f03060c,
    0x3f050a14,0x3f070e1c,0x3f091224,0x3f0b162c,0x3f0d1a34,0x3f0f1e3c,
    0x3f112245,0x3f13264d,0x3f152a55,0x3f172e5d,0x3f193265,0x3f1b366d,
    0x3f1d3a75,0x3f1f3e7d,0x3f214285,0x3f23468d,0x3f254a95,0x3f274e9d,
    0x3f2952a5,0x3f2b56ad,0x3f2d5ab5,0x3f2f5ebd,0x3f3162c6,0x3f3366ce,
    0x3f356ad6,0x3f376ede,0x3f3972e6,0x3f3b76ee,0x3f3d7af6,0x3f3f7efe,
    0x3f418306,0x3f43870e,0x3f458b16,0x3f478f1e,0x3f499326,0x3f4b972e,
    0x3f4d9b36,0x3f4f9f3e,0x3f51a347,0x3f53a74f,0x3f55ab57,0x3f57af5f,
    0x3f59b367,0x3f5bb76f,0x3f5dbb77,0x3f5fbf7f,0x3f61c387,0x3f63c78f,
    0x3f65cb97,0x3f67cf9f,0x3f69d3a7,0x3f6bd7af,0x3f6ddbb7,0x3f6fdfbf,
    0x3f71e3c8,0x3f73e7d0,0x3f75ebd8,0x3f77efe0,0x3f79f3e8,0x3f7bf7f0,
    0x3f7dfbf8,0x3f800000
};
/* as float: first (0.0, 0.007874015718698502, 0.015748031437397003, 0.023622047156095505) last (0.9921259880065918, 1.0) */
/* RVA 0x9B9D20, 128 dwords */
static const uint32_t jxdn_lut22[128] = {
    0x00000000,0x3b0260b4,0x3b7d9dcf,0x3bb91d8e,0x3bf05e32,0x3c12695d,
    0x3c2b5e89,0x3c432f8c,0x3c59fd5a,0x3c6fe8e9,0x3c828994,0x3c8cce86,
    0x3c96d3c6,0x3ca0a9cb,0x3caa610d,0x3cb40a0a,0x3cbdb538,0x3cc77312,
    0x3cd15412,0x3cdb68b0,0x3ce5c168,0x3cf06eb0,0x3cfb8104,0x3d03846f,
    0x3d098b5c,0x3d0fdd84,0x3d168326,0x3d1d847c,0x3d24e9c5,0x3d2cbb3d,
    0x3d350122,0x3d3dc3ae,0x3d470b21,0x3d50dfb6,0x3d5b49a9,0x3d66513b,
    0x3d71fea4,0x3d7e5a22,0x3d85b5f7,0x3d8c9e29,0x3d93e9bd,0x3d9b9cd5,
    0x3da3bb91,0x3dac4a0e,0x3db54c6a,0x3dbec6c5,0x3dc8bd3c,0x3dd333ee,
    0x3dde2ef8,0x3de9b277,0x3df5c28f,0x3e0131ad,0x3e07cc7c,0x3e0eb3c2,
    0x3e15e992,0x3e1d6ff8,0x3e254903,0x3e2d76c4,0x3e35fb48,0x3e3ed8a0,
    0x3e4810de,0x3e51a60a,0x3e5b9a3a,0x3e65ef78,0x3e70a7d7,0x3e7bc565,
    0x3e83a518,0x3e899c25,0x3e8fc8de,0x3e962c4e,0x3e9cc77d,0x3ea39b6e,
    0x3eaaa930,0x3eb1f1c0,0x3eb97632,0x3ec13782,0x3ec936bf,0x3ed174ef,
    0x3ed9f31c,0x3ee2b244,0x3eebb37c,0x3ef4f7be,0x3efe801c,0x3f0426cf,
    0x3f0930a1,0x3f0e5e0d,0x3f13af92,0x3f1925b8,0x3f1ec100,0x3f2481f0,
    0x3f2a6909,0x3f3076d1,0x3f36abce,0x3f3d087d,0x3f438d6a,0x3f4a3b11,
    0x3f5111fa,0x3f5812aa,0x3f5f3da0,0x3f669366,0x3f6e147a,0x3f75c164,
    0x3f7d9aa7,0x3f82d061,0x3f86ea22,0x3f8b1ad2,0x3f8f62b6,0x3f93c210,
    0x3f983922,0x3f9cc82c,0x3fa16f74,0x3fa62f38,0x3fab07ba,0x3faff93c,
    0x3fb50404,0x3fba284e,0x3fbf665f,0x3fc4be7b,0x3fca30df,0x3fcfbdd1,
    0x3fd56592,0x3fdb2862,0x3fe10684,0x3fe70039,0x3fed15c7,0x3ff34767,
    0x3ff99566,0x40000000
};
/* as float: first (0.0, 0.001989406533539295, 0.0038698797579854727, 0.00564927514642477) last (1.9498717784881592, 2.0) */

/* ---- bit-pattern access (no type-punning UB; -fno-strict-aliasing) ---- */
static float jxdn_f(uint32_t bits) { float f; memcpy(&f, &bits, 4); return f; }

/* 0x358960 case bodies: clamp(r8, lo, hi) then LUT read.  Literal cmov
 * order: eax = (r8 < 0) ? 0 : r8 (cmovns / cmovge); eax = min(eax, hi). */
static float jxdn_case_lut(const uint32_t *t, int32_t lo, int32_t hi, int32_t x)
{
    int32_t a = lo;
    if (x >= lo) a = x;          /* case 0x1D uses lo=0x64; ours use 0 */
    if (a > hi) a = hi;
    return jxdn_f(t[a]);
}
#define JXDN_MAP13(x) jxdn_case_lut(jxdn_lut13, 0, 0x7F, (x))  /* 0x358BCC */
#define JXDN_MAP1B(x) jxdn_case_lut(jxdn_lut1b, 0, 1,    (x))  /* 0x358CC4 */
#define JXDN_MAP1C(x) jxdn_case_lut(jxdn_lut1c, 0, 1,    (x))  /* 0x358CE3 */
#define JXDN_MAP21(x) jxdn_case_lut(jxdn_lut21, 0, 0x7F, (x))  /* 0x358D81 */
#define JXDN_MAP22(x) jxdn_case_lut(jxdn_lut22, 0, 0x7F, (x))  /* 0x358DA0 */

/* param index -> state offset (the record table [state+0x38], rec+0x20;
 * PROVEN(executed) readout, pattern exact over all 64 used records) */
#define JXDN_VSTRIDE 0x3F00
#define JXDN_OFF_NOTE(v)   (0x0130 + JXDN_VSTRIDE * (v))   /* idx   1+106v */
#define JXDN_OFF_GLEVEL(v) (0x0140 + JXDN_VSTRIDE * (v))   /* idx   2+106v */
#define JXDN_OFF_ANY(v)    (0x0730 + JXDN_VSTRIDE * (v))   /* idx  12+106v */
#define JXDN_OFF_VLIN(v)   (0x3380 + JXDN_VSTRIDE * (v))   /* idx  76+106v */
#define JXDN_OFF_VCRV(v)   (0x3B80 + JXDN_VSTRIDE * (v))   /* idx  98+106v */
#define JXDN_OFF_ONE(v)    (0x3C10 + JXDN_VSTRIDE * (v))   /* idx  99+106v */
#define JXDN_OFF_TRGON(v)  (0x41F70 + 0x20 * (v))          /* idx 911+2v   */
#define JXDN_OFF_TRGOFF(v) (0x41F80 + 0x20 * (v))          /* idx 912+2v   */

/* 0x357F30 -> 0x3F2D30 -> 0x3F4390: immediate store through the record */
static void jxdn_post(uint8_t *st, int32_t off, float val)
{
    memcpy(st + off, &val, 4);
}

/* the plugin's signed magic division by 12 (0x2AAAAAAB, sar edx,1, +sign) */
static int32_t jxdn_div12(int32_t x)
{
    int64_t p = (int64_t)x * 0x2AAAAAABLL;
    int32_t t = (int32_t)(p >> 33);           /* sar edx, 1 */
    return t + (int32_t)((uint32_t)t >> 31);  /* + sign bit */
}
static int32_t jxdn_rem12(int32_t x) { return x - 12 * jxdn_div12(x); }

/* ---- 0x35FCB0 -- o110 slot 0x20: the NOTE body ---- */
static void jxdn_note_body(const jx_dn_cbs *cb, uint8_t *st, int v,
                           int flag, int note)
{
    const float *temper = cb->temper23
        ? cb->temper23 + 11 : (const float *)(const void *)jxdn_temper_default + 11;
    float x0 = JXDN_MAP13(note);              /* 358960 case 0x13 */
    int32_t a  = cb->o110_5c;
    int32_t r9 = 12 - a;                      /* cmovle -> 0 when a<=0 */
    float   x1, x2;
    if (a <= 0) r9 = 0;
    if (cb->o110_58 == 7) x1 = 0.0f;          /* cmp [rbx+0x58],7 */
    else x1 = temper[jxdn_rem12(0x15 - a)];   /* signed rem: -11..11 */
    x2 = temper[jxdn_rem12(r9 + note)];
    x2 = x2 - x1;                             /* subss */
    x2 = x2 + x0;                             /* addss */
    (void)flag;                               /* edx dead past 0x35FD80 */
    /* jmp [vtbl+0x18] = 0x35FD80: immediate post of [o110+0x60] */
    jxdn_post(st, JXDN_OFF_NOTE(v), x2);
}

/* ---- exported: id 433+v handler 0x3E0130+0x20*v ---- */
void jx_dispatch_note_cb(const jx_dn_cbs *cb, uint8_t *proc_blob,
                         uint8_t *state_blob, int v, int flag, int val)
{
#if JX_FULL_TOOTH
    val += 1;    /* the full-chain tooth: one semitone -- MUST be audible */
#endif

    /* the stub only null-checks [proc+0x110+0x10*v]; the live instance is
     * never null (PROVEN) */
    jxdn_note_body(cb, state_blob, v, flag, val);
    /* dispatch 0x3EBB00 shadow store (0x3EBF54 pattern): raw value */
    *(int32_t *)(proc_blob + 0x444 + 4 * v) = val;
}

/* ---- 0x35FC00 / 0x35FEE0 / 0x35FDA0 -- o110 pulse posts ---- */
static void jxdn_gate_on_pulse(uint8_t *st, int v, int r8)   /* 0x35FC00 */
{
    float x = (r8 != 0) ? 1.0f : 0.0f;        /* [rip const] = 0x3F800000 */
    jxdn_post(st, JXDN_OFF_TRGON(v), x);
}
static void jxdn_gate_off_pulse(uint8_t *st, int v, int r8)  /* 0x35FEE0 */
{
    float x = (r8 == 1) ? 1.0f : 0.0f;
    jxdn_post(st, JXDN_OFF_TRGOFF(v), x);
}
static void jxdn_gate_level(uint8_t *st, int v, int r8)      /* 0x35FDA0 */
{
    float x = (r8 != 0) ? 1.0f : 0.0f;
    jxdn_post(st, JXDN_OFF_GLEVEL(v), x);
}

/* ---- 0x3E3D70 -- the shared gate tail (rcx=proc, edx=flag, r8d=val,
 * r9d=v).  Object null-checks elided: all pointers PROVEN non-null. ---- */
static void jxdn_gate_tail(uint8_t *pb, uint8_t *st, int v, int flag, int val)
{
    int32_t lo, hi, i, any;
    if (val != 0) {
        /* o290 slot 0x20 = 0x359200 (r8d=0): lut1b[0] -> [o290+0x834] */
        jxdn_post(st, JXDN_OFF_ONE(v), JXDN_MAP1B(0));
        /* o290 slot 0x18 = 0x359390 (edx=flag, r8d=val): case 0x22 */
        jxdn_post(st, JXDN_OFF_VCRV(v), JXDN_MAP22(val));
        /* o210 slot 0xC0 = 0x35C570 (edx=flag, r8d=val): case 0x21 */
        jxdn_post(st, JXDN_OFF_VLIN(v), JXDN_MAP21(val));
        /* o110 slot 0x28 = 0x35FDA0, r8d=1 */
        jxdn_gate_level(st, v, 1);
    } else {
        /* o110 slot 0x28, r8d=0 (0x3E3DFF path) */
        jxdn_gate_level(st, v, 0);
    }
    *(int32_t *)(pb + 0x644 + 4 * v) = val + JXDN_TOOTHVAL;   /* 0x3E3E18 */
    any = 0;
    lo = *(int32_t *)(pb + 0x63C);
    hi = *(int32_t *)(pb + 0x640);
    for (i = lo; i <= hi; ++i)                /* 0x3E3E36 scan, first hit */
        if (*(int32_t *)(pb + 0x644 + 4 * i) != 0) { any = 1; break; }
    for (i = lo; i <= hi; ++i) {              /* 0x3E3E5F loop */
        /* o010(i) slot 0x50 = 0x35D1B0 (edx=flag, r8d=any): case 0x1C */
        jxdn_post(st, JXDN_OFF_ANY(i), JXDN_MAP1C(any));
    }
    (void)flag;   /* ebp carried through, dead in every reached callee */
}

/* ---- exported: id 450+v handler 0x3E0C50+0x80*v ---- */
void jx_dispatch_gate_cb(const jx_dn_cbs *cb, uint8_t *proc_blob,
                         uint8_t *state_blob, int v, int flag, int val)
{
    (void)cb;
    if (val != 0) {
        if (*(int32_t *)(proc_blob + 0x644 + 4 * v) == 0)
            /* o110 slot 0x80 = 0x35FC00, r8d=1 */
            jxdn_gate_on_pulse(state_blob, v, 1);
    } else {
        /* o110 slot 0x88 = 0x35FEE0, r8d=1 */
        jxdn_gate_off_pulse(state_blob, v, 1);
    }
    jxdn_gate_tail(proc_blob, state_blob, v, flag, val);
    /* dispatch 0x3EBB00 shadow store (0x3EC06C pattern): raw value */
    *(int32_t *)(proc_blob + 0x464 + 4 * v) = val;
}

/* ---- the required plain entry points (build-state environment) ---- */
static const jx_dn_cbs jxdn_default_cbs = { 0, 0, 0 };

void jx_dispatch_note(uint8_t *proc_blob, uint8_t *state_blob,
                      int v, int flag, int val)
{
    jx_dispatch_note_cb(&jxdn_default_cbs, proc_blob, state_blob,
                        v, flag, val);
}

void jx_dispatch_gate(uint8_t *proc_blob, uint8_t *state_blob,
                      int v, int flag, int val)
{
    jx_dispatch_gate_cb(&jxdn_default_cbs, proc_blob, state_blob,
                        v, flag, val);
}
