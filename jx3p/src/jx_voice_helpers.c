/* jx_voice_helpers.c -- helpers called by the JX voice render arm
 * (sub_1803A22C0), transcribed from scratchpad/jxdump2 (decompile fn_*.c is
 * the spec; every float-vs-double choice checked against 01_closure.asm,
 * because IDA prints single-precision constants without an 'f' suffix).
 * Table bytes re-derived from truth/JX3P.vst3 (SHA256SUMS verified) at the
 * rvas the code addresses; the dump's 256-byte raw prefixes cross-checked
 * byte-identical (03_constants.txt truncates long raws).
 *
 * STATUS: PROVEN (helper null 0/53932 vs Unicorn; render null EXACTLY 0).
 * Compile with -ffp-contract=off (load-bearing: no fused madds exist in the
 * original SSE2 scalar code).
 *
 * Call tree inside sub_1803A22C0 (call counts from the decompile):
 *   sub_1803A2180  x64  -> fmodf            (leaf otherwise)
 *   sub_1803A2210  x23  -> fmodf            (leaf otherwise)
 *   sub_1803A2010  x7   -> (none; table unk_1809C1400)
 *   sub_1803A9950  x4   -> (none)
 *   sub_18039A250  x2   -> (none; tables dword_1809C1300/dword_1809C137C)
 * All five are leaves: no deeper sub_* calls anywhere.
 */

#include <math.h>

#include "jx_voice_helpers.h"

/* dword_1809C1300 / dword_1809C137C @ rva 0x1809C1300 (.rdata, 256 contiguous
 * bytes = 64 x f32): [0..30] = 2^-1..2^-31, [31] = 2^-32 (this element sits at
 * 0x1809C137C, IDA's second label), [32..63] = 2^1..2^32.
 * dword_1809C137C == &table[31].
 * STATUS: READ -- bytes read from truth/JX3P.vst3 .rdata at the rva; dump raw
 * prefix cross-checked byte-identical. */
static const float jx_tab_9C1300[64] = {
  0x1.0000000000000p-1F, 0x1.0000000000000p-2F, 0x1.0000000000000p-3F, 0x1.0000000000000p-4F,
  0x1.0000000000000p-5F, 0x1.0000000000000p-6F, 0x1.0000000000000p-7F, 0x1.0000000000000p-8F,
  0x1.0000000000000p-9F, 0x1.0000000000000p-10F, 0x1.0000000000000p-11F, 0x1.0000000000000p-12F,
  0x1.0000000000000p-13F, 0x1.0000000000000p-14F, 0x1.0000000000000p-15F, 0x1.0000000000000p-16F,
  0x1.0000000000000p-17F, 0x1.0000000000000p-18F, 0x1.0000000000000p-19F, 0x1.0000000000000p-20F,
  0x1.0000000000000p-21F, 0x1.0000000000000p-22F, 0x1.0000000000000p-23F, 0x1.0000000000000p-24F,
  0x1.0000000000000p-25F, 0x1.0000000000000p-26F, 0x1.0000000000000p-27F, 0x1.0000000000000p-28F,
  0x1.0000000000000p-29F, 0x1.0000000000000p-30F, 0x1.0000000000000p-31F, 0x1.0000000000000p-32F,
  0x1.0000000000000p+1F, 0x1.0000000000000p+2F, 0x1.0000000000000p+3F, 0x1.0000000000000p+4F,
  0x1.0000000000000p+5F, 0x1.0000000000000p+6F, 0x1.0000000000000p+7F, 0x1.0000000000000p+8F,
  0x1.0000000000000p+9F, 0x1.0000000000000p+10F, 0x1.0000000000000p+11F, 0x1.0000000000000p+12F,
  0x1.0000000000000p+13F, 0x1.0000000000000p+14F, 0x1.0000000000000p+15F, 0x1.0000000000000p+16F,
  0x1.0000000000000p+17F, 0x1.0000000000000p+18F, 0x1.0000000000000p+19F, 0x1.0000000000000p+20F,
  0x1.0000000000000p+21F, 0x1.0000000000000p+22F, 0x1.0000000000000p+23F, 0x1.0000000000000p+24F,
  0x1.0000000000000p+25F, 0x1.0000000000000p+26F, 0x1.0000000000000p+27F, 0x1.0000000000000p+28F,
  0x1.0000000000000p+29F, 0x1.0000000000000p+30F, 0x1.0000000000000p+31F, 0x1.0000000000000p+32F,
};
#define jx_tab_9C137C (&jx_tab_9C1300[31])

/* unk_1809C1400 @ rva 0x1809C1400 (.rdata, 6032 bytes = 29 rows x 208 bytes =
 * 29 x 26 f64). Odd indices are zero pad lanes (each coefficient is stored as a
 * 16-byte (double, 0.0) pair); sub_1803A2010 reads indices 0,2,..,24 = 13
 * polynomial coefficients per row; row = (int)(x + 20.0), x in [-20.0, 8.9].
 * STATUS: READ -- bytes read from truth/JX3P.vst3 .rdata at the rva (dump raw
 * is truncated at 256 bytes; its prefix cross-checked byte-identical).
 * Hex-float literals are exact bit images. */
static const double jx_tab_9C1400[29][26] = {
  { /* row 0 : x in [-20,-19) before clamp */
    -0x1.0ba2897ae299dp+0, 0.0,
    -0x1.47668bd5fef2cp-2, 0.0,
    -0x1.4da0e2eb89fa1p-5, 0.0,
    -0x1.6a844533fa657p-9, 0.0,
    -0x1.bb033a6c39d2dp-14, 0.0,
    -0x1.20a9157d835c9p-19, 0.0,
    -0x1.3967034bc8857p-26, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
  },
  { /* row 1 : x in [-19,-18) before clamp */
    -0x1.0e2424049b667p+0, 0.0,
    -0x1.5b333bc2006cap-2, 0.0,
    -0x1.739fdfaa367bfp-5, 0.0,
    -0x1.a80c43a29e6f0p-9, 0.0,
    -0x1.100aa15489ab0p-13, 0.0,
    -0x1.742792f9152cdp-19, 0.0,
    -0x1.a816826b3d9e4p-26, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
  },
  { /* row 2 : x in [-18,-17) before clamp */
    -0x1.b5351722e03dap+0, 0.0,
    -0x1.291941379b53ep-1, 0.0,
    -0x1.504143b19ab2ep-4, 0.0,
    -0x1.95b5f93b1cb38p-8, 0.0,
    -0x1.1336d4980da22p-12, 0.0,
    -0x1.8e196005cb679p-18, 0.0,
    -0x1.dfaf26d01b7fcp-25, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
  },
  { /* row 3 : x in [-17,-16) before clamp */
    -0x1.2c035028231a0p+1, 0.0,
    -0x1.b08b3601dafa0p-1, 0.0,
    -0x1.03a27d8674576p-3, 0.0,
    -0x1.4c4052c8e5555p-7, 0.0,
    -0x1.de0dd2edb9971p-12, 0.0,
    -0x1.6eaa4f39c773cp-17, 0.0,
    -0x1.d48202ff4756cp-24, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
  },
  { /* row 4 : x in [-16,-15) before clamp */
    -0x1.9052397c14599p+1, 0.0,
    -0x1.32abf43bc2bbep+0, 0.0,
    -0x1.8728fcdc057bbp-3, 0.0,
    -0x1.09dfe482c6dadp-6, 0.0,
    -0x1.9653ec03036c4p-11, 0.0,
    -0x1.4afbd7e22a0bbp-16, 0.0,
    -0x1.c119a9db98d25p-23, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
  },
  { /* row 5 : x in [-15,-14) before clamp */
    -0x1.2edf0f8b69ef2p+2, 0.0,
    -0x1.f0d513429291dp+0, 0.0,
    -0x1.533b3225577a2p-2, 0.0,
    -0x1.edb6dc8fa2fbbp-6, 0.0,
    -0x1.93e679228bb4fp-10, 0.0,
    -0x1.603da00191f43p-15, 0.0,
    -0x1.ffb515a30f48cp-22, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
    0.0, 0.0,
  },
  { /* row 6 : x in [-14,-13) before clamp */
    0x1.9c2b10f47d65fp+0, 0.0,
    0x1.0387a50017897p-4, 0.0,
    0x1.a1c7c19c16a17p-1, 0.0,
    0x1.69d642b5b2ce6p+0, 0.0,
    0x1.d2dd2cef4a832p+1, 0.0,
    0x1.fdfa49b7f25a5p+0, 0.0,
    0x1.07ea2c70a5397p-1, 0.0,
    0x1.3e27007e1a711p-4, 0.0,
    0x1.e29754060710bp-8, 0.0,
    0x1.d5b54f631973ep-12, 0.0,
    0x1.1e010a01f4f3dp-16, 0.0,
    0x1.8e2045921d923p-22, 0.0,
    0x1.e4d47d09ac761p-29, 0.0,
  },
  { /* row 7 : x in [-13,-12) before clamp */
    0x1.f1f506d007f98p-4, 0.0,
    0x1.14478649fd286p+0, 0.0,
    0x1.dc49d2c7a5c47p-1, 0.0,
    0x1.8bca58a4b2e69p+0, 0.0,
    0x1.40e3f449eac61p+1, 0.0,
    0x1.49e2d377fe841p+0, 0.0,
    0x1.546c4b21a6994p-2, 0.0,
    0x1.a12916e185dedp-5, 0.0,
    0x1.449ac8b30b704p-8, 0.0,
    0x1.45e9eadfc52fdp-12, 0.0,
    0x1.9aeb1fbc7f5bdp-17, 0.0,
    0x1.28e6398526206p-22, 0.0,
    0x1.781c35474aa45p-29, 0.0,
  },
  { /* row 8 : x in [-12,-11) before clamp */
    0x1.1808196a12382p-1, 0.0,
    -0x1.a2a3e89291882p-6, 0.0,
    0x1.5fea0ba507f4dp+1, 0.0,
    0x1.13e2ba760a01ap+0, 0.0,
    0x1.75531c549348ep+1, 0.0,
    0x1.f389904ca0901p+0, 0.0,
    0x1.315c77cc3364dp-1, 0.0,
    0x1.abadadc913dd2p-4, 0.0,
    0x1.75d7853b4a070p-7, 0.0,
    0x1.a19f3665db705p-11, 0.0,
    0x1.2333b9670748ep-15, 0.0,
    0x1.cfa429bcf13ebp-21, 0.0,
    0x1.42b2400e4529ep-27, 0.0,
  },
  { /* row 9 : x in [-11,-10) before clamp */
    0x1.9071044ff5cdep+0, 0.0,
    0x1.7688c7ab24cfbp+0, 0.0,
    0x1.6516d0250f999p+0, 0.0,
    0x1.f96afa5c91de2p-2, 0.0,
    0x1.017508d1e2d2dp+1, 0.0,
    0x1.7ac8acd238c2bp+0, 0.0,
    0x1.f73efc270e963p-2, 0.0,
    0x1.7f0c6f7898c4bp-4, 0.0,
    0x1.6c50317c7919dp-7, 0.0,
    0x1.bb329344a47c4p-11, 0.0,
    0x1.50c1339f36294p-15, 0.0,
    0x1.2444279f369b8p-20, 0.0,
    0x1.bbaf9b1f8310bp-27, 0.0,
  },
  { /* row 10 : x in [-10,-9) before clamp */
    0x1.8ac61d54323cbp-1, 0.0,
    0x1.16ed10ff0df5ep+0, 0.0,
    0x1.3d0bfbfbf60d2p+0, 0.0,
    0x1.364fd1485bdd4p-1, 0.0,
    0x1.77092dcd2824dp+0, 0.0,
    0x1.20ad4345e3321p+0, 0.0,
    0x1.a325a46cc25b7p-2, 0.0,
    0x1.5fc0a9d42b9a5p-4, 0.0,
    0x1.71e6bcc9c12adp-7, 0.0,
    0x1.f221f67767186p-11, 0.0,
    0x1.a3394fa63cff2p-15, 0.0,
    0x1.931dd04b6d4e4p-20, 0.0,
    0x1.53135bee32b41p-26, 0.0,
  },
  { /* row 11 : x in [-9,-8) before clamp */
    0x1.fab68bd024506p-1, 0.0,
    0x1.02070a8f37c26p+0, 0.0,
    0x1.24de8f5a2df13p+0, 0.0,
    0x1.b85a17cc156a8p-1, 0.0,
    0x1.688b6b2244c09p+0, 0.0,
    0x1.12c93a76a5679p+0, 0.0,
    0x1.abdc478fe3909p-2, 0.0,
    0x1.89b5fc8ded3cep-4, 0.0,
    0x1.c9e3436c191a6p-7, 0.0,
    0x1.565bb29b6bed1p-10, 0.0,
    0x1.40a41764ea317p-14, 0.0,
    0x1.578dc4af70ddep-19, 0.0,
    0x1.4240d17822cfap-25, 0.0,
  },
  { /* row 12 : x in [-8,-7) before clamp */
    0x1.083219c72c952p+0, 0.0,
    0x1.f91e14b03f872p-1, 0.0,
    0x1.2a5300484b5b3p+0, 0.0,
    0x1.b0d21618235cfp-1, 0.0,
    0x1.52b4f48237ae3p+0, 0.0,
    0x1.20ef9bd0a25a2p+0, 0.0,
    0x1.ffc412cdf09a1p-2, 0.0,
    0x1.0beadea9579e3p-3, 0.0,
    0x1.621e3526ecc18p-6, 0.0,
    0x1.2c9545a7cf514p-9, 0.0,
    0x1.3f538edad88b0p-13, 0.0,
    0x1.83da35b0d3527p-18, 0.0,
    0x1.9c3403a1d7704p-24, 0.0,
  },
  { /* row 13 : x in [-7,-6) before clamp */
    0x1.0e5aca3828c0bp+1, 0.0,
    0x1.39877a2ebc505p+1, 0.0,
    0x1.5a2e36df43c72p+0, 0.0,
    0x1.bfc1b2ab31930p+0, 0.0,
    0x1.d4ddc857443e2p+0, 0.0,
    0x1.07a25bc7b6122p+0, 0.0,
    0x1.60248ac63d31ap-2, 0.0,
    0x1.2c1d2a8bef343p-4, 0.0,
    0x1.4fee01f3d2af3p-7, 0.0,
    0x1.eb40c16c602b5p-11, 0.0,
    0x1.c1834be594c22p-15, 0.0,
    0x1.ce352f7052a14p-20, 0.0,
    0x1.8f5303b32de46p-26, 0.0,
  },
  { /* row 14 : x in [-6,-5) before clamp */
    0x1.546886433a0fdp+0, 0.0,
    0x1.de7afca3eeeddp-1, 0.0,
    0x1.154079e47463ap+0, 0.0,
    0x1.116ee981ee1c0p+0, 0.0,
    0x1.1fdccdc5c9d1fp+0, 0.0,
    0x1.f90bffdd6201bp-1, 0.0,
    0x1.19e62d0854370p-1, 0.0,
    0x1.89e28499dbd62p-3, 0.0,
    0x1.61427cc8cd226p-5, 0.0,
    0x1.98fa41166cefdp-8, 0.0,
    0x1.28a4a550614ebp-11, 0.0,
    0x1.ebe6c2fd21c80p-16, 0.0,
    0x1.64a10db1278d2p-21, 0.0,
  },
  { /* row 15 : x in [-5,-4) before clamp */
    0x1.6a2a6188744bcp+5, 0.0,
    0x1.9ef17526a8939p+2, 0.0,
    0x1.2f2c4de2a1e38p+2, 0.0,
    0x1.f1e497ab98fb6p+4, 0.0,
    0x1.19eb426848ea2p+3, 0.0,
    -0x1.33a742b841300p+4, 0.0,
    -0x1.339f73b2f64cep+4, 0.0,
    -0x1.1331a050921afp+3, 0.0,
    -0x1.2300f85b8e369p+1, 0.0,
    -0x1.83279b2cb4a92p-2, 0.0,
    -0x1.404a73a85bbbdp-5, 0.0,
    -0x1.2eabe07b777f7p-9, 0.0,
    -0x1.f531a50166475p-15, 0.0,
  },
  { /* row 16 : x in [-4,-3) before clamp */
    0x1.1e3ed7961b4ecp+5, 0.0,
    -0x1.b03985e26673bp+2, 0.0,
    -0x1.3a21c28e64047p+6, 0.0,
    -0x1.b804bc8913b47p+5, 0.0,
    0x1.90bf330f4ae8bp+1, 0.0,
    0x1.16d5a4f2b7817p+4, 0.0,
    0x1.8388c94995a92p+2, 0.0,
    -0x1.a89be24a9b21cp-1, 0.0,
    -0x1.2f95a55754048p+0, 0.0,
    -0x1.8c45e11b56474p-2, 0.0,
    -0x1.08426513ebc10p-4, 0.0,
    -0x1.730d9921f5551p-8, 0.0,
    -0x1.b52b6163ab08dp-13, 0.0,
  },
  { /* row 17 : x in [-3,-2) before clamp */
    0x1.e9baeb854df61p-5, 0.0,
    -0x1.184dbd43281d7p+4, 0.0,
    -0x1.2cb9093f3119ep+5, 0.0,
    -0x1.36e51b0360467p+4, 0.0,
    0x1.4b1c479e1ff75p+4, 0.0,
    0x1.12c15d1b86249p+5, 0.0,
    0x1.38422ca6357bdp+4, 0.0,
    0x1.03a6552aa4d97p+2, 0.0,
    -0x1.01b205858d971p+0, 0.0,
    -0x1.b2db6b0b9b388p-1, 0.0,
    -0x1.d1bfde1d64981p-3, 0.0,
    -0x1.e289cc71303fcp-6, 0.0,
    -0x1.972676baaff10p-10, 0.0,
  },
  { /* row 18 : x in [-2,-1) before clamp */
    -0x1.7f878f6aa37c6p+6, 0.0,
    -0x1.49ccd77cbe58dp+9, 0.0,
    -0x1.e1ab227cf96c6p+10, 0.0,
    -0x1.7a97b350da0e3p+11, 0.0,
    -0x1.32158606af148p+11, 0.0,
    -0x1.5c60ad00d3809p+7, 0.0,
    0x1.d9b2248883302p+10, 0.0,
    0x1.1ff5ed0fbc85bp+11, 0.0,
    0x1.73a5f4ebc6782p+10, 0.0,
    0x1.2bc5f8881b956p+9, 0.0,
    0x1.2fb073de13b9bp+7, 0.0,
    0x1.63b74ac928f59p+4, 0.0,
    0x1.712c7dcfb7a6cp+0, 0.0,
  },
  { /* row 19 : x in [-1,0) before clamp */
    0x1.0000000000000p+0, 0.0,
    0x1.633a6e530963ep-1, 0.0,
    0x1.0beac2728819ep-2, 0.0,
    0x1.5e1088391ec28p-2, 0.0,
    0x1.128afe1f08590p+1, 0.0,
    0x1.4130ad724e28dp+3, 0.0,
    0x1.f8e0833ff60c2p+4, 0.0,
    0x1.109d0e0254b86p+6, 0.0,
    0x1.95f74c1ef5280p+6, 0.0,
    0x1.99710e67bba67p+6, 0.0,
    0x1.0ad292f032446p+6, 0.0,
    0x1.9517e46bad584p+4, 0.0,
    0x1.0fc6e0594edfcp+2, 0.0,
  },
  { /* row 20 : x in [0,1) before clamp */
    0x1.0000000000000p+0, 0.0,
    0x1.6a7ea2005da36p-1, 0.0,
    -0x1.1d834a7726a7bp-2, 0.0,
    0x1.de3d803a8b798p+2, 0.0,
    -0x1.d3f5a9860b002p+5, 0.0,
    0x1.1f361f4852481p+8, 0.0,
    -0x1.d1677864916a3p+9, 0.0,
    0x1.ffdc7b0fd846ap+10, 0.0,
    -0x1.80569b74398b0p+11, 0.0,
    0x1.8401ccc5d777cp+11, 0.0,
    -0x1.f7947a390e3c7p+10, 0.0,
    0x1.7b6354df48556p+9, 0.0,
    -0x1.f83e15d18b94fp+6, 0.0,
  },
  { /* row 21 : x in [1,2) before clamp */
    0x1.8accfbb6200ebp+9, 0.0,
    -0x1.4eab6cd513aa7p+12, 0.0,
    0x1.e4d1d374f9076p+13, 0.0,
    -0x1.769d32869f4ebp+14, 0.0,
    0x1.1e7d710a436b6p+14, 0.0,
    0x1.07de077801647p+10, 0.0,
    -0x1.1a6831f397b96p+14, 0.0,
    0x1.44591582d0117p+14, 0.0,
    -0x1.9bb02e88d8813p+13, 0.0,
    0x1.49e0007fa0216p+12, 0.0,
    -0x1.4d52a60776e32p+10, 0.0,
    0x1.863851d2b67edp+7, 0.0,
    -0x1.95405f77f8926p+3, 0.0,
  },
  { /* row 22 : x in [2,3) before clamp */
    -0x1.854b445c08f35p+10, 0.0,
    0x1.605ca17641228p+11, 0.0,
    0x1.1d10898034225p+9, 0.0,
    -0x1.4ae3afae6873bp+12, 0.0,
    0x1.39e74531903c9p+12, 0.0,
    -0x1.1874b79711de3p+10, 0.0,
    -0x1.5d3cb834a7e50p+10, 0.0,
    0x1.6245e78d2f6c7p+10, 0.0,
    -0x1.4330b6640b775p+9, 0.0,
    0x1.5d5fbd3b60342p+7, 0.0,
    -0x1.cc5cfe5902707p+4, 0.0,
    0x1.578e58c427acap+1, 0.0,
    -0x1.bf402fcbe3f67p-4, 0.0,
  },
  { /* row 23 : x in [3,4) before clamp */
    -0x1.412d24ff2b346p+13, 0.0,
    0x1.1ca14a4dd3e65p+12, 0.0,
    0x1.8735ca6320208p+12, 0.0,
    -0x1.33fce9d8a2e95p+4, 0.0,
    -0x1.7ae85ac6ac75ep+12, 0.0,
    0x1.e2fbb9264f21ep+10, 0.0,
    0x1.3008d7eb00d67p+11, 0.0,
    -0x1.2fa55b58539d2p+11, 0.0,
    0x1.0036bb52c5ee6p+10, 0.0,
    -0x1.ef2b454722568p+7, 0.0,
    0x1.1d5935fcfd9c7p+5, 0.0,
    -0x1.6f2a0bf6c464dp+1, 0.0,
    0x1.981f3951140c2p-4, 0.0,
  },
  { /* row 24 : x in [4,5) before clamp */
    0x1.1c78d0f6bfacbp+14, 0.0,
    -0x1.1042c739741e0p+16, 0.0,
    0x1.9c806b72b720ap+14, 0.0,
    0x1.6e3cbcbaf14ddp+14, 0.0,
    -0x1.37a203dffb799p+8, 0.0,
    -0x1.ae21421493b79p+14, 0.0,
    0x1.6ff9afff6c23ap+14, 0.0,
    -0x1.37c4b5eb13f3fp+13, 0.0,
    0x1.4014fe598b344p+11, 0.0,
    -0x1.a1f48a4a8432ap+8, 0.0,
    0x1.556ecfc891f94p+5, 0.0,
    -0x1.3fd4b5d6f0d18p+1, 0.0,
    0x1.072f49a9c8981p-4, 0.0,
  },
  { /* row 25 : x in [5,6) before clamp */
    -0x1.2965e005caa69p+1, 0.0,
    -0x1.4590e24b3203ep-1, 0.0,
    -0x1.4f9e93e845162p+1, 0.0,
    -0x1.51d90be600ca8p+2, 0.0,
    -0x1.1f92b83d90785p+2, 0.0,
    0x1.e86492659ab89p+0, 0.0,
    0x1.5a37fcf9fcef9p+2, 0.0,
    -0x1.323efc18ae711p+2, 0.0,
    0x1.c56cde4cc3518p+0, 0.0,
    -0x1.712b1bd0d993ep-2, 0.0,
    0x1.5a99eaab9d804p-5, 0.0,
    -0x1.61b517b681b3cp-9, 0.0,
    0x1.313374c8bcb2ep-14, 0.0,
  },
  { /* row 26 : x in [6,7) before clamp */
    -0x1.2ea1fd6423851p+2, 0.0,
    -0x1.3a7296f84bab9p+2, 0.0,
    -0x1.85bfc76cb7aa5p+3, 0.0,
    -0x1.b24b6d8dabae9p+2, 0.0,
    -0x1.60bb99ff88797p+3, 0.0,
    0x1.e3544ed8f7220p+2, 0.0,
    0x1.95eb2c792a317p+1, 0.0,
    -0x1.d0b4ee76e88cbp+1, 0.0,
    0x1.4030089313c9cp+0, 0.0,
    -0x1.cd06fb07feb67p-3, 0.0,
    0x1.78216e0c091e9p-6, 0.0,
    -0x1.4aea50973187bp-10, 0.0,
    0x1.ea421f9e72299p-16, 0.0,
  },
  { /* row 27 : x in [7,8) before clamp */
    0x1.724da9ba32dacp+7, 0.0,
    -0x1.995c6f041265cp+7, 0.0,
    -0x1.f3bccd6b17dd5p+3, 0.0,
    0x1.7e62b0c1f920bp+4, 0.0,
    -0x1.a19971f6ef63dp+5, 0.0,
    -0x1.c9c98043aa9b4p+4, 0.0,
    0x1.a35672ee16b44p+5, 0.0,
    -0x1.8aa1b9777e8fep+4, 0.0,
    0x1.7b5fffcd4e968p+2, 0.0,
    -0x1.a8634432f2fa8p-1, 0.0,
    0x1.1890a8260d9d4p-4, 0.0,
    -0x1.98957c868432dp-9, 0.0,
    0x1.fb236a8a23b70p-15, 0.0,
  },
  { /* row 28 : x in [8,9) before clamp */
    0x1.8dbf5780e1ffbp+3, 0.0,
    0x1.bf3b9c63e077ap-1, 0.0,
    -0x1.0ad627fbd1cb7p+0, 0.0,
    -0x1.f71e896e9524bp+4, 0.0,
    -0x1.0543ac24af740p+6, 0.0,
    -0x1.67dc5b05755cfp+5, 0.0,
    0x1.0a890f8a9fe25p+6, 0.0,
    -0x1.b3acd820e90a1p+4, 0.0,
    0x1.6da46e3ad1de8p+2, 0.0,
    -0x1.65b5b83908280p-1, 0.0,
    0x1.9e12b91e7e4f0p-5, 0.0,
    -0x1.082c046b008e5p-9, 0.0,
    0x1.1f7a12d686114p-15, 0.0,
  },
};

/* sub_18039A250 @ rva 0x39A250 -- transcribed from dump; STATUS: READ
 * (unproven until null).
 * asm: every branch is one mulss with a table f32 -- all single precision.
 * The decompile's "result * 4294967300.0" for a2 > 32 is really
 * mulss dword_1809C137C[32] after "mov edx, 32" (asm 0x18039A261..0x18039A279):
 * table element [32] = 2^32f exactly; transcribed as the table access the
 * machine performs. The a2 < -32 branch clamps a2 = -32 and indexes
 * jx_tab_9C1300[~(-32)] = [31] = 2^-32f (the element IDA labels
 * dword_1809C137C[0]). */
float jx_h_39A250(float result, int a2)
{
  if ( a2 < -32 )
  {
    a2 = -32;
    return result * jx_tab_9C1300[~a2];
  }
  if ( a2 > 32 )
    return result * jx_tab_9C137C[32];
  if ( a2 < 0 )
    return result * jx_tab_9C1300[~a2];
  if ( a2 > 0 )
    return result * jx_tab_9C137C[a2];
  return result;
}

/* sub_1803A2010 @ rva 0x3A2010 -- transcribed from dump; STATUS: READ
 * (unproven until null).
 * asm: pure double chain -- maxsd qword_1809C2BE8 (-20.0), minsd
 * qword_1809C2BC8 (8.9), addsd qword_180B1BE08 (+20.0) then cvttsd2si
 * (C (int) truncation), imul 0xD0 row stride, 12 mulsd/addsd terms in
 * exactly the order written below (addsd sequence t0, x^2, x^3, ..., x^12).
 * fmax/fmin match maxsd/minsd here: maxsd returns the second operand (-20.0)
 * on NaN input, and fmax(NaN, -20.0) = -20.0 likewise; after that no NaN can
 * reach minsd. Power products are staged left-to-right exactly as the asm
 * stages registers (v2 = x^3, v4 = x^5, v5 = x^7, v6 = x^9; each *v1*v1 step
 * is one mulsd). */
double jx_h_3A2010(double a1)
{
  double v1; /* xmm11 */
  double v2; /* xmm2 */
  const double *v3; /* rax */
  double v4; /* xmm4 */
  double v5; /* xmm6 */
  double v6; /* xmm8 */

  v1 = fmin(fmax(a1, -20.0), 8.9);
  v2 = v1 * v1 * v1;
  v3 = (const double *)((const char *)&jx_tab_9C1400[0][0] + 208 * (int)(v1 + 20.0));
  v4 = v2 * v1 * v1;
  v5 = v4 * v1 * v1;
  v6 = v5 * v1 * v1;
  return v1 * v3[2]
       + *v3
       + v1 * v1 * v3[4]
       + v2 * v3[6]
       + v2 * v1 * v3[8]
       + v4 * v3[10]
       + v4 * v1 * v3[12]
       + v5 * v3[14]
       + v5 * v1 * v3[16]
       + v6 * v3[18]
       + v6 * v1 * v3[20]
       + v6 * v1 * v1 * v3[22]
       + v6 * v1 * v1 * v1 * v3[24];
}

/* sub_1803A2180 @ rva 0x3A2180 -- transcribed from dump; STATUS: READ
 * (unproven until null).
 * asm: comiss/addss/subss with dword_180B1BC54 (1.0f), dword_180B1C084
 * (-1.0f); fmodf second arg flt_180B1BD88 (2.0f). ALL single precision --
 * the decompile's unsuffixed 1.0/2.0 literals are IDA's rendering of f32
 * constants, so they carry the f suffix here.
 * NaN note (input NaN only): asm falls into the second fmodf path (comiss
 * unordered sets CF), C returns the NaN unchanged; both yield NaN, payload
 * may differ. Finite inputs are branch-identical. */
float jx_h_3A2180(float result)
{
  if ( result > 1.0f )
    return fmodf(result + 1.0f, 2.0f) - 1.0f;
  if ( result < -1.0f )
    return fmodf(result - 1.0f, 2.0f) + 1.0f;
  return result;
}

/* sub_1803A2210 @ rva 0x3A2210 -- transcribed from dump; STATUS: READ
 * (unproven until null).
 * The decompile shows "__m128 sub_1803A2210(double a1)" with *(float *)&a1
 * lane games ("local variable allocation has failed"): the real contract is
 * float in xmm0[0] -> float in xmm0[0], and every call site in
 * sub_1803A22C0 reads .m128_f32[0] only (e.g. decompile line 2069), so this
 * is transcribed as a scalar float function. The v1 = 0x40000000u /
 * 0xC0000000 lane initialisations in the decompile are dead bit patterns
 * (2.0f / -2.0f) whose live lane is overwritten before return.
 * asm: comiss 1.0f / -1.0f, fmodf(x -+ 1.0f, 2.0f) +- 1.0f, then
 * xmm1 = addss(x, x); comiss dword_180B1C078 (-0.5f): below => return
 * subss(dword_180B1C098 (-2.0f), xmm1); else comiss dword_180B1BBAC (0.5f):
 * above => return subss(flt_180B1BD88 (2.0f), xmm1); else return xmm1.
 * ALL single precision.
 * NaN note (input NaN only): asm takes the second fmodf and the -2.0f - v2
 * paths, C skips the fmodf; both yield NaN, payload may differ. */
float jx_h_3A2210(float a1)
{
  float v2; /* xmm1 lane 0 */

  if ( a1 <= 1.0f )
  {
    if ( a1 < -1.0f )
      a1 = fmodf(a1 - 1.0f, 2.0f) + 1.0f;
  }
  else
  {
    a1 = fmodf(a1 + 1.0f, 2.0f) - 1.0f;
  }
  v2 = a1 + a1;
  if ( a1 >= -0.5f )
  {
    if ( a1 <= 0.5f )
      return v2;
    else
      return 2.0f - v2;
  }
  else
  {
    return -2.0f - v2;
  }
}

/* sub_1803A9950 @ rva 0x3A9950 -- transcribed from dump; STATUS: READ
 * (unproven until null).
 * asm: mulss dword_1809C2BE0 (16777216.0f = 2^24), cvttss2si (C (int)
 * truncation), integer bit tests on bits 23 (bt edx,17h) and 21
 * (and eax,200000h), doubling via add edx,edx / lea edx,[rdx*2+1]
 * (wrapping -- transcribed through unsigned to keep defined-behaviour
 * wrap identical to the machine), then and 0xFFFFFF / or 0xFF000000
 * selected by bit 24 (cmovz), cvtdq2ps (signed (float) conversion), and
 * mulss dword_1809C2B90 = 0x33800000 = 2^-24f exactly (the decompile
 * prints it as 0.000000059604645). ALL float ops single precision. */
float jx_h_3A9950(float a1)
{
  int v1; /* edx */
  int v2; /* edx */
  int v3; /* eax */
  int v4; /* ecx */
  int v5; /* eax */
  int v6; /* edx, signed for the (float) conversion */

  v1 = (int)(float)(a1 * 16777216.0f);
  if ( !v1 )
  {
    v2 = 1;
    goto LABEL_8;
  }
  v3 = v1 & 0x200000;
  if ( (v1 & 0x800000) != 0 )
  {
    if ( !v3 )
    {
LABEL_5:
      v2 = (int)(2u * (unsigned int)v1);
      goto LABEL_8;
    }
  }
  else if ( v3 )
  {
    goto LABEL_5;
  }
  v2 = (int)(2u * (unsigned int)v1 + 1u);
LABEL_8:
  v4 = v2;
  v5 = v2 & 0xFFFFFF;
  v6 = (int)((unsigned int)v2 | 0xFF000000u);
  if ( (v4 & 0x1000000) == 0 )
    v6 = v5;
  return (float)v6 * 0x1p-24f;
}

/* FP environment control for the null harness: set FTZ|DAZ to match the
 * plugin's runtime MXCSR. Not part of the DSP; harness-only. */
#if defined(__SSE__) && !defined(__EMSCRIPTEN__)
#include <xmmintrin.h>
#include <pmmintrin.h>
void jx_set_ftz(void){ _mm_setcsr((_mm_getcsr() | 0x8000 | 0x0040)); }
#else
/* WASM has no MXCSR: denormals stay IEEE. The same documented caveat the
 * JUNO web build carries; the host gates all run with real FTZ. */
void jx_set_ftz(void){}
#endif

/* sub_1803A21E0: positive-side wrap. Verbatim from the decompile (only the
 * result>1 branch wraps; no negative branch in the original). STATUS: READ. */
float jx_h_3A21E0(float result)
{
  if ( result > 1.0F )
    return fmodf(result + 1.0F, 2.0F) - 1.0F;
  return result;
}

/* ---- statically linked CRT math, transcribed from the binary ----
 * The plugin does NOT import expf/tanf: both live in the image (expf @
 * 0x722EA0, tanf @ 0x725150) and both begin with a CPU-feature dispatch
 * (dword @ 0xCEFC0C). That flag is 0 in a fresh image, and the Unicorn
 * oracle executes a fresh image, so the ground truth is the NON-FMA path,
 * transcribed here instruction by instruction. System libm differs by 1 ulp
 * on some inputs (seen to fail: patches 30/43/53/54/56/62 before this).
 * STATUS: READ until the A/B gate is EXACTLY 0 again.
 * Host-only for now: uses unsigned __int128 (the Payne-Hanek path). */
#include <stdint.h>
#include <string.h>

static inline double   jxm_asd(uint64_t b){ double d; memcpy(&d,&b,8); return d; }
static inline uint64_t jxm_asu(double d){ uint64_t b; memcpy(&b,&d,8); return b; }
static inline float    jxm_asf(uint32_t b){ float f; memcpy(&f,&b,4); return f; }
static inline uint32_t jxm_asi(float f){ uint32_t b; memcpy(&b,&f,4); return b; }

/* exp2 fraction table @ 0xACC1C0 (64 doubles, biased-exp 0x3FF). */
static const uint64_t jxm_exp_tab[64] = {
0x3ff0000000000000ULL,0x3ff02c9a3e778061ULL,0x3ff059b0d3158574ULL,0x3ff0874518759bc8ULL,
0x3ff0b5586cf9890fULL,0x3ff0e3ec32d3d1a2ULL,0x3ff11301d0125b51ULL,0x3ff1429aaea92de0ULL,
0x3ff172b83c7d517bULL,0x3ff1a35beb6fcb75ULL,0x3ff1d4873168b9aaULL,0x3ff2063b88628cd6ULL,
0x3ff2387a6e756238ULL,0x3ff26b4565e27cddULL,0x3ff29e9df51fdee1ULL,0x3ff2d285a6e4030bULL,
0x3ff306fe0a31b715ULL,0x3ff33c08b26416ffULL,0x3ff371a7373aa9cbULL,0x3ff3a7db34e59ff7ULL,
0x3ff3dea64c123422ULL,0x3ff4160a21f72e2aULL,0x3ff44e086061892dULL,0x3ff486a2b5c13cd0ULL,
0x3ff4bfdad5362a27ULL,0x3ff4f9b2769d2ca7ULL,0x3ff5342b569d4f82ULL,0x3ff56f4736b527daULL,
0x3ff5ab07dd485429ULL,0x3ff5e76f15ad2148ULL,0x3ff6247eb03a5585ULL,0x3ff6623882552225ULL,
0x3ff6a09e667f3bcdULL,0x3ff6dfb23c651a2fULL,0x3ff71f75e8ec5f74ULL,0x3ff75feb564267c9ULL,
0x3ff7a11473eb0187ULL,0x3ff7e2f336cf4e62ULL,0x3ff82589994cce13ULL,0x3ff868d99b4492edULL,
0x3ff8ace5422aa0dbULL,0x3ff8f1ae99157736ULL,0x3ff93737b0cdc5e5ULL,0x3ff97d829fde4e50ULL,
0x3ff9c49182a3f090ULL,0x3ffa0c667b5de565ULL,0x3ffa5503b23e255dULL,0x3ffa9e6b5579fdbfULL,
0x3ffae89f995ad3adULL,0x3ffb33a2b84f15fbULL,0x3ffb7f76f2fb5e47ULL,0x3ffbcc1e904bc1d2ULL,
0x3ffc199bdd85529cULL,0x3ffc67f12e57d14bULL,0x3ffcb720dcef9069ULL,0x3ffd072d4a07897cULL,
0x3ffd5818dcfba487ULL,0x3ffda9e603db3285ULL,0x3ffdfc97337b9b5fULL,0x3ffe502ee78b3ff6ULL,
0x3ffea4afa2a490daULL,0x3ffefa1bee615a27ULL,0x3fff50765b6e4540ULL,0x3fffa7c1819e90d8ULL};

float jx_h_expf_722EA0(float a1)
{
  uint32_t ix = jxm_asi(a1), ax = ix & 0x7fffffffu;
  if ((int32_t)ax >= 0x7f800000) {            /* @0x722FE0 special gate */
    if (ix == 0x7f800000u) return a1;         /* +inf -> +inf */
    if (ix == 0xff800000u) return 0.0f;       /* -inf -> +0   */
    return jxm_asf(ix | 0x400000u);           /* nan -> quieted nan */
  }
  double xd = (double)a1;
  double z  = 92.33248261689366 * xd;         /* 64/ln2, @0xAC5DF0 */
  if (z >= 8192.0)  return jxm_asf(0x7f800000u);  /* overflow  -> +inf */
  if (z < -9600.0)  return 0.0f;                  /* underflow -> +0   */
  /* cvtpd2dq: round to nearest even */
#if defined(__x86_64__)
  int32_t n; { double t = z; __asm__("cvtsd2si %1, %0" : "=r"(n) : "x"(t)); }
#else
  /* portable twin of cvtsd2si (round-to-nearest-even; invalid -> INT_MIN).
   * WASM path only; the x86 asm stays the proven form. */
  int32_t n; { double t = z;
    if (t != t || t >= 2147483648.0 || t < -2147483648.5) n = (int32_t)0x80000000;
    else { double r = __builtin_rint(t); n = (int32_t)r; } }
#endif
  double kd = (double)n;
  double r  = xd - kd * 0.010830424696249145;     /* ln2/64, @0xAC5E00 */
  uint32_t idx = (uint32_t)n & 63u;
  int32_t  top = (n - (int32_t)idx) >> 6;
  double r2 = r * r;
  double p  = 0.16666666666666666 * r + 0.5;      /* @0xAC5E10 / @0xAC5E20 */
  double q  = r2 * p + r;
  double s  = jxm_asd(jxm_exp_tab[idx]);
  double s2 = jxm_asd((uint64_t)(uint32_t)(top + 0x3ff) << 52);
  return (float)((q * s + s) * s2);
}

/* 2/pi bit string @ 0xACD850 (176 bytes; indexed by byte offset). */
static const uint8_t jxm_inv_pio4[176] = {
0xe0,0xf1,0x1b,0xc1,0x0c,0x58,0x21,0x74,0x35,0x7e,0xc4,0x7e,0xed,0xaf,0xa9,0x4b,
0x4a,0x29,0xde,0xe7,0x1c,0xf4,0xec,0xc5,0x97,0xaf,0x1f,0xeb,0x9e,0xd4,0xb5,0xa8,
0x7f,0x79,0x9a,0xfd,0x18,0x3d,0xdd,0x26,0x2c,0x9f,0x3c,0xfb,0xd9,0xb4,0x7d,0xb4,
0x29,0x68,0x2d,0x46,0xbc,0xbc,0x3f,0x60,0x16,0x78,0xff,0x5f,0xe2,0x7f,0xec,0xa0,
0xe4,0xf7,0x2e,0x7e,0x11,0x72,0xd2,0xe7,0x4c,0x0d,0xe6,0x58,0x47,0xe6,0x04,0xf9,
0x7d,0xd1,0x9a,0xc0,0x71,0xa6,0x13,0x12,0xed,0xba,0xd4,0xd7,0x08,0xa2,0xfb,0x9c,
0xa6,0xc4,0x72,0xac,0x77,0xf8,0x73,0x48,0x46,0x27,0xa8,0xbb,0x24,0x19,0x80,0x4b,
0x37,0x09,0xe9,0xb8,0x91,0xdc,0x86,0x15,0xef,0x7a,0xaf,0x8e,0x45,0xf9,0x07,0x41,
0x0e,0xf1,0x64,0x56,0x8a,0x6d,0x03,0x77,0xd3,0xd4,0x47,0x5f,0x9d,0xf0,0xa7,0x54,
0x10,0x39,0xb9,0x0d,0xe6,0x8b,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x18,0x2d,0x44,0x54,0xfb,0x21,0xf9,0x3f,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

static inline uint64_t jxm_ld64(const uint8_t *p){ uint64_t v; memcpy(&v,p,8); return v; }

/* rational tan kernel + odd-quadrant reciprocal, @0x725416..0x72547B */
static double jxm_tan_poly(double z, uint32_t q)
{
  double z2  = z * z;
  double num = -0.017203248047148168 * z2 + 0.3852960712639954;
  double den = (0.01844239256901656 * z2 + -0.5139650547885454) * z2
             + 1.1558882143468838;
  double t   = num / den;
  double res = z + (z2 * z) * t;
  if (q & 1u) res = -1.0 / res;
  return res;
}

float jx_h_tanf_725150(float a1)
{
  uint32_t ix = jxm_asi(a1);
  if ((ix & 0x7f800000u) == 0x7f800000u)      /* inf/nan -> errno path @0x74D7D0 */
    return a1 - a1;                           /* INFERRED edge; DSP-unreachable */
  double d  = (double)a1;
  uint64_t ax = jxm_asu(d) & 0x7fffffffffffffffULL;
  if ((int64_t)ax <= (int64_t)0x3fe921fb54442d18ULL) {   /* |x| <= pi/4 */
    if ((int64_t)ax >= (int64_t)0x3f20000000000000ULL)   /* >= 2^-13 */
      return (float)jxm_tan_poly(d, 0);
    if ((int64_t)ax >= (int64_t)0x3e40000000000000ULL) { /* >= 2^-27: cubic */
      double z2 = d * d;
      return (float)(z2 * d * 0.3333333333333333 + d);
    }
    /* tiny: raise inexact only, return x (result of the mul/add is dropped) */
    volatile float sink = a1 * 0.99999994f + 4294967296.0f; (void)sink;
    return a1;
  }
  uint64_t sign = jxm_asu(d) & 0x8000000000000000ULL;
  double z; uint32_t q;
  if ((int64_t)ax < (int64_t)0x4160000000000000ULL) {    /* |x| < 2^23 */
    double xa = jxm_asd(ax);
    double zn = 0.6366197723675814 * xa + 0.5;           /* 2/pi @0xAC7350 */
#if defined(__x86_64__)
    int32_t n; { double t = zn; __asm__("cvttsd2si %1, %0" : "=r"(n) : "x"(t)); }
#else
    /* portable twin of cvttsd2si (truncate; invalid -> INT_MIN) */
    int32_t n; { double t = zn;
      if (t != t || t >= 2147483648.0 || t <= -2147483649.0)
          n = (int32_t)0x80000000;
      else n = (int32_t)t; }
#endif
    q = (uint32_t)n & 3u;
    double kd = (double)n;
    double r  = xa - kd * 1.5707963267341256;            /* pio2_1  */
    double w  = kd * 6.077100506506192e-11;              /* pio2_1t */
    z = r - w;
  } else {                                               /* Payne-Hanek @0x7252B8 */
    uint64_t u = ax;
    int64_t  e = (int64_t)(u >> 52) - 0x3ff;
    int64_t  off = 0x86 - (e >> 3);
    uint64_t m0 = jxm_ld64(jxm_inv_pio4 + off);
    uint64_t frac = ((u << 12) >> 12) | (1ULL << 52);
    uint64_t m1 = jxm_ld64(jxm_inv_pio4 + off + 8);
    uint64_t m2 = jxm_ld64(jxm_inv_pio4 + off + 16);
    uint64_t e7 = (uint64_t)e & 7u;
    unsigned __int128 p0 = (unsigned __int128)m0 * frac;
    unsigned __int128 p1 = (unsigned __int128)m1 * frac;
    unsigned __int128 p2 = (unsigned __int128)m2 * frac;
    uint64_t lo  = (uint64_t)p0;
    uint64_t mid = (uint64_t)p1 + (uint64_t)(p0 >> 64);
    uint64_t hi  = (uint64_t)(p1 >> 64) + (mid < (uint64_t)p1);
    hi += (uint64_t)p2;
    unsigned cl = (unsigned)(0x36 - e7);
    uint64_t sh  = hi >> cl;
    uint64_t cf  = (hi >> (cl - 1)) & 1u;
    uint64_t neg = 0;
    if (cf) { hi = ~hi; mid = ~mid; lo = ~lo; neg = 0x8000000000000000ULL; }
    q = (uint32_t)((sh + cf) & 3u);
    unsigned c2 = (unsigned)(e7 + 10);
    hi = (hi << c2) >> c2;
    int64_t ebase = (int64_t)c2 - 0x40;
    unsigned b;
    if (hi != 0) { b = 63u - (unsigned)__builtin_clzll(hi); }
    else { hi = mid; mid = lo; lo = 0; b = 63u - (unsigned)__builtin_clzll(hi);
           ebase -= 0x40; }
    ebase += b;
    int64_t sc = (int64_t)b - 0x34;
    if (sc > 0) {
      uint64_t t = hi;
      hi >>= sc; mid >>= sc;
      mid |= t << (0x40 - sc);
    } else if (sc < 0) {
      int64_t c = -sc; uint64_t t9 = mid;
      hi <<= c; mid <<= c;
      hi  |= t9 >> (0x40 - c);
      mid |= lo >> (0x40 - c);
    }
    uint64_t bits = (hi & ~(1ULL << 52)) | neg
                  | ((uint64_t)(ebase + 0x3ff) << 52);
    z = jxm_asd(bits) * 1.5707963267948966;
  }
  double res = jxm_tan_poly(z, q);
  return (float)jxm_asd(jxm_asu(res) ^ sign);
}
