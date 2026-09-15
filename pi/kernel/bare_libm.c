/* bare_libm.c — the exact math the engine needs, with no glibc libm.
 *
 * The engine's only libm calls are fabs/fabsf, fmax/fmaxf, fmin/fminf, lrint
 * and fmodf. Every one is an EXACTLY-defined operation (not an approximation
 * like sin/exp), so any conformant implementation is bit-identical to glibc's
 * — which is why linking glibc libm is unnecessary (and painful on bare metal:
 * its objects pull in errno/TLS and crash the bare-metal linker).
 *
 * Seven map straight to AArch64 instructions via the compiler builtins
 * (FABS / FMAXNM / FMINNM / FCVT*), so there is no call and no recursion —
 * verify_engine.sh disassembles this object to confirm no self-call remains.
 * fmodf has no single instruction, so it is the classic exact bit-twiddling
 * remainder (public-domain musl algorithm): exact for all finite inputs, hence
 * bit-identical to glibc. tools/... proof: verify_engine.sh re-runs the 12-patch
 * hash under qemu-user with THIS math linked and shows it still matches the
 * glibc-linked reference. */
#include <stdint.h>

float  fabsf (float x)          { return __builtin_fabsf (x); }
double fabs  (double x)         { return __builtin_fabs  (x); }
float  fmaxf (float a, float b) { return __builtin_fmaxf (a, b); }
float  fminf (float a, float b) { return __builtin_fminf (a, b); }
double fmax  (double a, double b){ return __builtin_fmax (a, b); }
double fmin  (double a, double b){ return __builtin_fmin (a, b); }
long   lrint (double x)         { return __builtin_lrint (x); }

/* exact float remainder (musl __fmodf, public domain) */
float fmodf (float x, float y)
{
	union { float f; uint32_t i; } ux = { x }, uy = { y };
	int ex = (ux.i >> 23) & 0xff;
	int ey = (uy.i >> 23) & 0xff;
	uint32_t sx = ux.i & 0x80000000u;
	uint32_t uxi = ux.i;
	uint32_t i;

	if (uy.i << 1 == 0 || (uy.i << 1) > 0xff000000u || ex == 0xff)
		return (x * y) / (x * y);           /* y==0, y NaN, or x inf/NaN -> NaN */
	if (uxi << 1 <= uy.i << 1) {
		if (uxi << 1 == uy.i << 1)
			return 0.0f * x;
		return x;
	}

	/* normalize x and y */
	if (!ex) {
		for (i = uxi << 9; i >> 31 == 0; ex--, i <<= 1) ;
		uxi <<= -ex + 1;
	} else {
		uxi &= -1u >> 9;
		uxi |= 1u << 23;
	}
	if (!ey) {
		for (i = uy.i << 9; i >> 31 == 0; ey--, i <<= 1) ;
		uy.i <<= -ey + 1;
	} else {
		uy.i &= -1u >> 9;
		uy.i |= 1u << 23;
	}

	/* x mod y */
	for (; ex > ey; ex--) {
		i = uxi - uy.i;
		if (i >> 31 == 0) {
			if (i == 0)
				return 0.0f * x;
			uxi = i;
		}
		uxi <<= 1;
	}
	i = uxi - uy.i;
	if (i >> 31 == 0) {
		if (i == 0)
			return 0.0f * x;
		uxi = i;
	}
	for (; uxi >> 23 == 0; uxi <<= 1, ex--) ;

	/* scale result up */
	if (ex > 0) {
		uxi -= 1u << 23;
		uxi |= (uint32_t) ex << 23;
	} else {
		uxi >>= -ex + 1;
	}
	uxi |= sx;
	ux.i = uxi;
	return ux.f;
}
