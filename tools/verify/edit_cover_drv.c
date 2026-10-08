/* edit_cover_drv.c -- the driver of tools/verify/edit_cover_gate.py (CLAIMS A35).
 *
 * Compiled together with gui/juno_bridge.c and the src/ sources in the gate's variants
 * (the product; -DJUNO_EDIT_FULLCOPY, the reference; -DJUNO_EDIT_POISON, the
 * probe; + -DJUNO_EDIT_TOOTH=k, a tooth). It boots the engine as the product does
 * (create + plugin_init at the host rate), optionally sets the engine-rate
 * setting, then for each patch: the patch browser's load, three keys held, and
 * for every host parameter each value class -- min, max, mid, two seeded values
 * in range, max + 1 (dropped by the host entry) -- one host edit (the host entry
 * the render driver calls, rva 0x3C7AE0) and one block. It writes one line per
 * block: the FNV-1a hash of the block's samples; and per parameter: the hash of
 * the whole state from byte 176 (below it: the shim's address, never audio).
 * Plumbing only: every value is the library's own.
 *
 * usage: edit_cover_drv OUT BANK HOST_RATE ENGINE_SETTING(-1 = none) PATCH...
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef struct { int offset, type, channel, pitch; float velocity; } juno_host_note;
typedef struct { uint32_t id; int offset; double value; } juno_host_param;
void *juno_gui_create(float sample_rate, int chorus_mode);
int juno_gui_plugin_init(void *c);
int juno_gui_queue_patch(void *c, const unsigned char *bank, int len, int idx);
int juno_gui_model_set(void *c, uint32_t id, int32_t v);
int juno_gui_process_ex(void *c, const juno_host_note *ev, int nev, const juno_host_param *par, int npar,
                        int tempo_valid, double tempo, float *outL, float *outR, int n);
int juno_gui_host_count(void);
int juno_gui_host_min(int i);
int juno_gui_host_max(int i);
void juno_gui_host_set(void *c, int i, int v);
unsigned char *juno_gui_state(void *c);
unsigned juno_gui_state_bytes(void);
void juno_gui_destroy(void *c);
#if defined(JUNO_EDIT_POISON)
extern long juno_edit_probe_count;
#endif

#define BLK 256
#define ID_ENGINE_RATE 268419093u   /* vm.vs.sampleRate (Script.xml's value tree) */

static uint64_t fnv(const void *p, size_t n, uint64_t h)
{
    const unsigned char *b = (const unsigned char *)p;
    size_t i;
    for (i = 0; i < n; ++i) h = (h ^ b[i]) * 1099511628211ull;
    return h;
}
/* the whole state: a word fold (fast; any changed word changes it) */
static uint64_t state_hash(void *c)
{
    const unsigned char *st = juno_gui_state(c);
    unsigned n = juno_gui_state_bytes(), i;
    uint64_t h = 1469598103934665603ull, w;
    for (i = 176; i + 8 <= n; i += 8) {
        memcpy(&w, st + i, 8);
        h = (h ^ w) * 1099511628211ull;
        h ^= h >> 29;
    }
    return h;
}

static uint64_t block(void *c, FILE *out, const juno_host_note *ev, int nev)
{
    float L[BLK], R[BLK];
    uint64_t h = 1469598103934665603ull;
    juno_gui_process_ex(c, ev, nev, NULL, 0, 1, 120.0, L, R, BLK);
    h = fnv(L, sizeof L, h);
    h = fnv(R, sizeof R, h);
    fprintf(out, "b %016llx\n", (unsigned long long)h);
    return h;
}

int main(int argc, char **argv)
{
    FILE *out, *bf;
    unsigned char *bank;
    long blen;
    float rate;
    int eng, a, n = juno_gui_host_count();
    uint32_t seed = 12345u;
    if (argc < 6) { fprintf(stderr, "usage: edit_cover_drv OUT BANK HOST_RATE ENGINE_SETTING PATCH...\n"); return 2; }
    out = fopen(argv[1], "w");
    bf = fopen(argv[2], "rb");
    if (!out || !bf) return 2;
    fseek(bf, 0, SEEK_END);
    blen = ftell(bf);
    fseek(bf, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)blen);
    if (!bank || fread(bank, 1, (size_t)blen, bf) != (size_t)blen) return 2;
    fclose(bf);
    rate = (float)atof(argv[3]);
    eng = atoi(argv[4]);
    for (a = 5; a < argc; ++a) {
        int p = atoi(argv[a]), i, k;
        void *c = juno_gui_create(rate, 0);
        juno_host_note keys[3];
        if (!c || !juno_gui_plugin_init(c)) return 3;
        if (eng >= 0) juno_gui_model_set(c, ID_ENGINE_RATE, eng);
        juno_gui_queue_patch(c, bank, (int)blen, p);
        for (k = 0; k < 3; ++k) {
            keys[k].offset = 0; keys[k].type = 0; keys[k].channel = 0;
            keys[k].pitch = 48 + 7 * k; keys[k].velocity = 0.75f;
        }
        fprintf(out, "patch %d\n", p);
        block(c, out, NULL, 0);
        block(c, out, keys, 3);
        for (i = 0; i < n; ++i) {
            int lo = juno_gui_host_min(i), hi = juno_gui_host_max(i), vals[6], j;
            vals[0] = lo; vals[1] = hi; vals[2] = lo + (hi - lo) / 2;
            for (j = 3; j < 5; ++j) {
                seed = seed * 1664525u + 1013904223u;
                vals[j] = hi > lo ? lo + (int)((seed >> 8) % (uint32_t)(hi - lo + 1)) : lo;
            }
            vals[5] = hi + 1;
            for (j = 0; j < 6; ++j) {
                fprintf(out, "edit %d %d\n", i, vals[j]);
                juno_gui_host_set(c, i, vals[j]);
                block(c, out, NULL, 0);
            }
            fprintf(out, "s %016llx\n", (unsigned long long)state_hash(c));
        }
        juno_gui_destroy(c);
    }
#if defined(JUNO_EDIT_POISON)
    fprintf(out, "probe %ld\n", juno_edit_probe_count);
#endif
    fclose(out);
    return 0;
}
