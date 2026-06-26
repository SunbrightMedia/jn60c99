/* juno_reverb_coeffs.c — capture-free seed for the HALL2 reverb coefficient
 * blocks (input allpass @10693xxx, send CV @10692xxx, tank/DPF/HPF/LPF @10759xxx).
 *
 * Provenance: 46 of 48 values are literal constants in the plugin's .rdata
 * (data_sections/seg_rdata_935650.bin; rva = file VA, ImageBase 0x180000000) —
 * the HALL2 reverb's fixed filter/tap design, selected by reverb type, identical
 * for every preset. The 2 non-literal values are documented inline (a JUNO
 * chorus-CV formula and a 1-pole node default already used by the chorus block).
 * Every value verified 4-byte bit-exact. These offsets were removed from the
 * former PD-Juno-Pad memory capture (src/runtime_coeffs_data.c). NOT fitted.
 */
#include <stdint.h>
#include <string.h>

static void rev_put_bits(unsigned char *st, int off, uint32_t bits)
{
    memcpy(st + off, &bits, sizeof(bits));
}

void juno_reverb_coeffs_apply(unsigned char *st)
{
#define PUT(s, o, b) rev_put_bits((s), (o), (b))
    PUT(st, 10692016, 0xc0bafafbu); /* reverb/CH2 input CV = (step*11)/255 - 8 with step 50 (= -5.84314); JUNO chorus-CV formula (src/juno_fx.c) */
    PUT(st, 10692032, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10693008, 0x3d6f8001u); /* reverb input allpass 1-pole coeff 0.0584717 (same as chorus node 6396128; node-mechanism default, see juno_fx_filter_coeffs.c) */
    PUT(st, 10693040, 0x3f000000u); /* 0.5  .rdata @rva 0x93cc69 */
    PUT(st, 10693056, 0x3f008081u); /* 0.501961  .rdata @rva 0x96d4e0 */
    PUT(st, 10693072, 0x3f03df74u); /* 0.515128  .rdata @rva 0x989054 */
    PUT(st, 10693088, 0x3f83df74u); /* 1.03026  .rdata @rva 0x989058 */
    PUT(st, 10693104, 0x3f03df74u); /* 0.515128  .rdata @rva 0x989054 */
    PUT(st, 10693120, 0xbee549c0u); /* -0.447828  .rdata @rva 0x988fa4 */
    PUT(st, 10693136, 0xbf1cd8f1u); /* -0.612685  .rdata @rva 0x988fa8 */
    PUT(st, 10693168, 0x3f4ba5b0u); /* 0.795497  .rdata @rva 0x986d9c */
    PUT(st, 10693184, 0x3fb50bf3u); /* 1.41443  .rdata @rva 0x988f9c */
    PUT(st, 10693200, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10693216, 0x3ad6774fu); /* 0.00163625  .rdata @rva 0x987ef4 */
    PUT(st, 10693232, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10693248, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10693264, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10693280, 0x3f2493b7u); /* 0.642879  .rdata @rva 0x988114 */
    PUT(st, 10693312, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10693344, 0xbf800000u); /* -1  .rdata @rva 0x96cce0 */
    PUT(st, 10693360, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10759376, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10759392, 0x3f000000u); /* 0.5  .rdata @rva 0x93cc69 */
    PUT(st, 10759408, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10759424, 0x3f800000u); /* 1  .rdata @rva 0x96963c */
    PUT(st, 10759440, 0x3efefeffu); /* 0.498039  .rdata @rva 0x96d4dc */
    PUT(st, 10759504, 0x37ae2650u); /* 2.07603e-05  .rdata @rva 0x98bc64 */
    PUT(st, 10759520, 0x3f7f8b7eu); /* 0.998222  .rdata @rva 0x9d9f38 */
    PUT(st, 10759536, 0xbf7f8b7eu); /* -0.998222  .rdata @rva 0x9d9f3c */
    PUT(st, 10759552, 0x3f7f16fbu); /* 0.996444  .rdata @rva 0x9d9f40 */
    PUT(st, 10759568, 0x3d434c95u); /* 0.0476805  .rdata @rva 0x9da20c */
    PUT(st, 10759584, 0x3dc34c95u); /* 0.0953609  .rdata @rva 0x9da210 */
    PUT(st, 10759600, 0x3d434c95u); /* 0.0476805  .rdata @rva 0x9da20c */
    PUT(st, 10759616, 0x3fa5addfu); /* 1.29437  .rdata @rva 0x9da218 */
    PUT(st, 10759632, 0xbef85dc7u); /* -0.48509  .rdata @rva 0x9da21c */
    PUT(st, 10759648, 0x3d090dbbu); /* 0.0334604  .rdata @rva 0x9da6c0 */
    PUT(st, 10759664, 0x3f2d8fd1u); /* 0.677976  .rdata @rva 0x9de3f4 */
    PUT(st, 10759680, 0xbf586ee2u); /* -0.845442  .rdata @rva 0x9de3f0 */
    PUT(st, 10759696, 0x3d090dbbu); /* 0.0334604  .rdata @rva 0x9da6c0 */
    PUT(st, 10759712, 0x3f2d8fd1u); /* 0.677976  .rdata @rva 0x9de3f4 */
    PUT(st, 10759728, 0xbf586ee2u); /* -0.845442  .rdata @rva 0x9de3f0 */
    PUT(st, 10759744, 0x3d090dbbu); /* 0.0334604  .rdata @rva 0x9da6c0 */
    PUT(st, 10759760, 0x3f19d713u); /* 0.600938  .rdata @rva 0x9de3fc */
    PUT(st, 10759776, 0xbf4afeb9u); /* -0.792949  .rdata @rva 0x9de3f8 */
    PUT(st, 10759792, 0x3d090dbbu); /* 0.0334604  .rdata @rva 0x9da6c0 */
    PUT(st, 10759808, 0x3f19d713u); /* 0.600938  .rdata @rva 0x9de3fc */
    PUT(st, 10759824, 0xbf4afeb9u); /* -0.792949  .rdata @rva 0x9de3f8 */
    PUT(st, 10759872, 0x00000100u); /* 3.58732e-43  .rdata @rva 0x938023 */
#undef PUT
}
