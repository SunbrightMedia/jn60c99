/* test_regression.c — locks in the verified behavior of the capture-free port.
 *
 * Guards (all binary-derived, no capture in the product path):
 *  1. ORACLE:   capture-free seed + preset_load(record 0) reproduces the real
 *               plugin's loaded state (src/captured_patch.c) 58/58 bit-exact
 *               at 96 kHz (the capture's rate).
 *  2. SR-FAMILY: envelope/HPF/LFO-delay coefficients select the SR family at
 *               apply time (44.1k value = 2.1769x the 96k value, bit-checked
 *               against both family tables).
 *  3. NOTE PATH: note-on writes M.CV = LUT32[note] (per-key detune semitone
 *               table) and velocity slots = vel/127 + LUT57[vel]; the static
 *               pitch base 4448 = -4.75 is never touched.
 *  4. SMOKE:    a spread of factory presets render finite, non-silent, and
 *               within level bounds at 44.1 kHz.
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_preset.h"
#include "../src/juno_params.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void juno_capture_free_seed(unsigned char *);
void juno_overlay_patch(unsigned char *);

static int g_fail = 0;
#define CHECK(cond, ...) do { if (!(cond)) { g_fail++; printf("FAIL: " __VA_ARGS__); printf("\n"); } } while (0)

static unsigned char *fresh(int sr)
{
    unsigned char *st = malloc(JUNO_STATE_BYTES);
    memset(st, 0, JUNO_STATE_BYTES);
    JF(st, 16) = (float)sr;
    juno_chorus_init(st);
    juno_engine_init(st);
    juno_capture_free_seed(st);
    return st;
}

/* 1. record-0 oracle, bit-exact at 96 kHz */
static void test_oracle(void)
{
    unsigned char *z = calloc(JUNO_STATE_BYTES, 1);
    unsigned char *o = calloc(JUNO_STATE_BYTES, 1);
    juno_overlay_patch(o);

    unsigned char *st = fresh(96000);
    juno_preset_info pi;
    CHECK(juno_preset_load(st, "refs/preset_banks/bank1.bin", 0, &pi) == 0, "oracle: preset load");

    int n = 0, ok = 0;
    for (unsigned off = 0; off < 11000; off += 4) {
        unsigned a, e, g;
        memcpy(&a, z + off, 4); memcpy(&e, o + off, 4); memcpy(&g, st + off, 4);
        if (a == e) continue;               /* offset not in the oracle set */
        n++;
        if (e == g) ok++;
        else printf("  oracle mismatch off %u: want %08x got %08x\n", off, e, g);
    }
    CHECK(n >= 58 && ok == n, "oracle: %d/%d bit-exact (want all of >=58)", ok, n);
    printf("oracle: %d/%d bit-exact\n", ok, n);
    free(z); free(o); free(st);
}

/* 2. SR-family selection at apply time */
static void test_sr_family(void)
{
    unsigned char *a = fresh(44100), *c = fresh(96000);
    juno_preset_info pi;
    juno_preset_load(a, "refs/preset_banks/bank1.bin", 0, &pi);
    juno_preset_load(c, "refs/preset_banks/bank1.bin", 0, &pi);
    float f44 = JF(a, 2784), f96 = JF(c, 2784);   /* ENV1 attack coefficient */
    unsigned b96; memcpy(&b96, &f96, 4);
    CHECK(b96 == 0x3e378a96u, "sr-family: 96k ENV1 attack bits %08x != oracle 3e378a96", b96);
    CHECK(fabsf(f44 / f96 - 2.1769f) < 0.001f, "sr-family: 44.1k/96k ratio %.4f != 2.1769", f44 / f96);
    printf("sr-family: 96k bit-exact, 44.1k ratio %.4f\n", f44 / f96);
    free(a); free(c);
}

/* 3. note path invariants */
static void test_note_path(void)
{
    unsigned char *st = fresh(44100);
    juno_preset_info pi;
    juno_preset_load(st, "refs/preset_banks/bank1.bin", 0, &pi);

    float base = JF(st, 4448);
    CHECK(base == -4.75f, "note: static pitch base 4448 = %g != -4.75", base);

    juno_note_on_vel(st, 0, 92, 107);
    unsigned cv, lin, cur; float f;
    memcpy(&cv, (unsigned char *)st + 304, 4);
    CHECK(cv == 0x40d56419u, "note: M.CV(note92) bits %08x != 40d56419 (LUT32[92], runtime-dump exact)", cv);
    memcpy(&lin, (unsigned char *)st + 6864, 4);
    f = 107.0f / 127.0f; memcpy(&cur, &f, 4);
    CHECK(lin == cur, "note: linear velocity bits %08x != vel/127", lin);
    memcpy(&cur, (unsigned char *)st + 9680, 4);
    f = juno_lut_apply(57, 107);
    unsigned want; memcpy(&want, &f, 4);
    CHECK(cur == want && cur == 0x3f93c210u, "note: curve velocity bits %08x != LUT57[107] (3f93c210)", cur);
    CHECK(JF(st, 4448) == -4.75f, "note: note-on must not touch 4448");
    printf("note path: M.CV/velocity/base all exact\n");
    free(st);
}

/* 4. quick render smoke on a preset spread */
static void test_smoke(void)
{
    static const int recs[] = { 0, 1, 7, 9, 27, 39, 40, 63 };
    const int SR = 44100, N = SR / 2;
    for (unsigned k = 0; k < sizeof recs / sizeof recs[0]; ++k) {
        unsigned char *st = fresh(SR);
        juno_preset_info pi;
        CHECK(juno_preset_load(st, "refs/preset_banks/bank1.bin", recs[k], &pi) == 0,
              "smoke: rec %d load", recs[k]);
        static struct juno_host_shim sh;
        memset(&sh, 0, sizeof sh);
        juno_driver_attach_host(st, &sh, pi.chorus_mode ? pi.chorus_mode : 2);
        juno_note_on(st, 0, 60);
        double e = 0, pk = 0; int bad = 0;
        for (int i = 0; i < N; ++i) {
            float l = 0, r = 0;
            juno_driver_render_sample(st, &l, &r);
            if (!isfinite(l) || !isfinite(r)) bad = 1;
            e += (double)l * l;
            if (fabsf(l) > pk) pk = fabsf(l);
        }
        double rms = sqrt(e / N);
        CHECK(!bad, "smoke: rec %d produced non-finite output", recs[k]);
        CHECK(rms > 1e-4, "smoke: rec %d near-silent (rms %.6f)", recs[k], rms);
        CHECK(pk < 2.0, "smoke: rec %d out of level bounds (peak %.3f)", recs[k], pk);
        free(st);
    }
    printf("smoke: %u presets finite/non-silent/in-bounds\n",
           (unsigned)(sizeof recs / sizeof recs[0]));
}

int main(void)
{
    test_oracle();
    test_sr_family();
    test_note_path();
    test_smoke();
    if (g_fail) { printf("REGRESSION: %d failure(s)\n", g_fail); return 1; }
    printf("OK: all regression guards pass\n");
    return 0;
}
