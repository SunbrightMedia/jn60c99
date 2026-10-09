/* bare_log10.c -- log10 for the bare-metal build (no glibc libm: its objects pull in errno and crash
 * the bare-metal linker). The engine never calls it; the GUI meter in gui/juno_bridge.c does
 * (juno_gui_meter_tick's dB step, (int)(log10(d) * 333 + 999), CLAIMS A37), and the bridge is linked
 * whole. log10 is not exactly defined like bare_libm.c's functions, so equality with the plugin rests
 * on the meter's margin (docs/LED_METER.md: the nearest float lies 6.47e-9 from its step, so any
 * log10 within 1e-12 gives the plugin's step) -- and is CHECKED, not argued: tools/repro/
 * pi_log10_check.c runs this function on the host against glibc's for every float the meter can see
 * (0.001 .. 1) and requires the same step for each (task #62, which found the Pi link broken by the
 * meter's log10).
 *
 * The algorithm is fdlibm's e_log10.c as in musl (src/math/log10.c):
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunSoft, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */
#include <stdint.h>

static double from_bits(uint64_t b) { union { uint64_t i; double f; } u = { b }; return u.f; }

double log10(double x)
{
	const double ivln10hi = from_bits(0x3fdbcb7b15200000ull), ivln10lo = from_bits(0x3dbb9438ca9aadd5ull),
	             log10_2hi = from_bits(0x3fd34413509f6000ull), log10_2lo = from_bits(0x3d59fef311f12b36ull),
	             Lg1 = from_bits(0x3fe5555555555593ull), Lg2 = from_bits(0x3fd999999997fa04ull),
	             Lg3 = from_bits(0x3fd2492494229359ull), Lg4 = from_bits(0x3fcc71c51d8e78afull),
	             Lg5 = from_bits(0x3fc7466496cb03deull), Lg6 = from_bits(0x3fc39a09d078c69full),
	             Lg7 = from_bits(0x3fc2f112df3e5244ull);
	union { double f; uint64_t i; } u = { x };
	double hfsq, f, s, z, R, w, t1, t2, dk, y, hi, lo, val_hi, val_lo;
	uint32_t hx;
	int k;

	hx = (uint32_t)(u.i >> 32);
	k = 0;
	if (hx < 0x00100000 || hx >> 31) {
		if (u.i << 1 == 0)
			return -1 / (x * x);            /* log(+-0) = -inf */
		if (hx >> 31)
			return (x - x) / 0.0;           /* log(-#) = NaN */
		k -= 54;                            /* subnormal: scale x up */
		x *= from_bits(0x4350000000000000ull);   /* 0x1p54 */
		u.f = x;
		hx = (uint32_t)(u.i >> 32);
	} else if (hx >= 0x7ff00000) {
		return x;
	} else if (hx == 0x3ff00000 && u.i << 32 == 0)
		return 0;

	/* reduce x into [sqrt(2)/2, sqrt(2)] */
	hx += 0x3ff00000 - 0x3fe6a09e;
	k += (int)(hx >> 20) - 0x3ff;
	hx = (hx & 0x000fffff) + 0x3fe6a09e;
	u.i = (uint64_t)hx << 32 | (u.i & 0xffffffff);
	x = u.f;

	f = x - 1.0;
	hfsq = 0.5 * f * f;
	s = f / (2.0 + f);
	z = s * s;
	w = z * z;
	t1 = w * (Lg2 + w * (Lg4 + w * Lg6));
	t2 = z * (Lg1 + w * (Lg3 + w * (Lg5 + w * Lg7)));
	R = t2 + t1;

	/* hi + lo = f - hfsq + s * (hfsq + R) ~ log(1 + f) */
	hi = f - hfsq;
	u.f = hi;
	u.i &= (uint64_t)-1 << 32;
	hi = u.f;
	lo = f - hi - hfsq + s * (hfsq + R);

	/* val_hi + val_lo ~ log10(1 + f) + k * log10(2) */
	val_hi = hi * ivln10hi;
	dk = k;
	y = dk * log10_2hi;
	val_lo = dk * log10_2lo + (lo + hi) * ivln10lo + lo * ivln10hi;

	w = y + val_hi;
	val_lo += (y - w) + val_hi;
	val_hi = w;

	return val_lo + val_hi;
}
