#include "fx.h"
#include <string.h>
#include "eb_master.h"
#include "gen/msq_fx.h"

typedef char fx_coef_size_assert[(sizeof(eb_master_coef) == MSQ_FX_COEF_BYTES) ? 1 : -1];
typedef char fx_state_size_assert[(sizeof(eb_master_state) == MSQ_FX_STATE_BYTES) ? 1 : -1];

const unsigned msq_fx_state_bytes = sizeof(eb_master_state);
static eb_master_coef MC;                 /* internal RAM: read every sample */
static eb_master_state *MS;
static const eb_master_rings RINGS;       /* all NULL: delay type 0 + chorus touch none */
static int dep_b, lvl_b;

static void  put(size_t off, uint32_t u) { memcpy((char *)&MC + off, &u, 4); }

#ifdef ESP_PLATFORM
#include "esp_attr.h"
EXT_RAM_BSS_ATTR static eb_master_state FX_PSRAM;      /* ~730 KB, zeroed at boot */
#endif

void fx_init(void *state_mem)
{
#ifdef ESP_PLATFORM
    if (!state_mem) state_mem = &FX_PSRAM;
#endif
    MS = (eb_master_state *)state_mem;
    memset(MS, 0, sizeof *MS);
    for (int i = 0; i < MSQ_FX_NSEED; ++i) memcpy((char *)MS + MSQ_FX_SEED[i][0], &MSQ_FX_SEED[i][1], 4);
    memcpy(&MC, MSQ_FX_COEF, sizeof MC);
    fx_set_chorus(0);
    fx_set_reverb(0);
}

void fx_set_chorus(int b)
{
    b = b < 0 ? 0 : (b > 255 ? 255 : b);
    dep_b = b;
    put(MSQ_FX_OFF_CHO_WET, MSQ_FX_WET[b]);
    put(MSQ_FX_OFF_IN_K84544, MSQ_FX_K84544[b]);
}

void fx_set_reverb(int b)
{
    b = b < 0 ? 0 : (b > 255 ? 255 : b);
    lvl_b = b;
#ifdef MSQ_FX_TOOTH
    if (b == 200) { put(MSQ_FX_OFF_REV_SEND, MSQ_FX_SEND[b] ^ 1u); return; }   /* TOOTH: one LSB wrong */
#endif
    put(MSQ_FX_OFF_REV_SEND, MSQ_FX_SEND[b]);
}

int fx_chorus_byte(void) { return dep_b; }
int fx_reverb_byte(void) { return lvl_b; }

void fx_process_f(const float *voice, float *L, float *R, int n)
{
    float v[8] = {0};
    for (int i = 0; i < n; ++i) {
        v[0] = voice[i] * FX_IN_GAIN;
        eb_master_render(MS, &MC, &RINGS, v, &L[i], &R[i]);
    }
}

void fx_process(const float *voice, int16_t *lr, int n)
{
    float L[64], R[64];
    while (n > 0) {
        int k = n > 64 ? 64 : n;
        fx_process_f(voice, L, R, k);
        for (int i = 0; i < k; ++i) {
            float a = L[i] * 32767.0f, b = R[i] * 32767.0f;
            int x = (int)(a >= 0 ? a + 0.5f : a - 0.5f), y = (int)(b >= 0 ? b + 0.5f : b - 0.5f);
            if (x > 32767) x = 32767;
            if (x < -32768) x = -32768;
            if (y > 32767) y = 32767;
            if (y < -32768) y = -32768;
            lr[0] = (int16_t)x; lr[1] = (int16_t)y; lr += 2;
        }
        voice += k; n -= k;
    }
}

static uint32_t crc32(const void *d, unsigned n)
{
    const uint8_t *p = d; uint32_t c = 0xFFFFFFFFu;
    for (unsigned i = 0; i < n; ++i) { c ^= p[i]; for (int k = 0; k < 8; ++k) c = (c >> 1) ^ (0xEDB88320u & (0u - (c & 1u))); }
    return ~c;
}

/* call right after fx_init (depth 0, level 0, nothing rendered yet) */
int fx_selfcheck(uint32_t *coef_crc, uint32_t *state_crc)
{
    *coef_crc = crc32(&MC, sizeof MC);
    *state_crc = crc32(MS, sizeof *MS);
    return *coef_crc == MSQ_FX_COEF_CRC && *state_crc == MSQ_FX_STATE_CRC;
}

/* Render a libm-free test signal (an exact-float saw) through a FRESH state at
 * full chorus and reverb, CRC the float output bits, then re-initialise. The
 * host (tools/fx_crc.c, 32-bit) runs this same function; equal CRCs prove the
 * S3's arithmetic reproduces the host's, and tools/fx_gate.c proves the host
 * reproduces the recall path. */
uint32_t fx_render_crc(void)
{
    float in[64], L[64], R[64];
    uint32_t c = 0xFFFFFFFFu;
    fx_init(MS);
    fx_set_chorus(255); fx_set_reverb(200);
    for (int b = 0; b < 4800 / 64; ++b) {
        for (int i = 0; i < 64; ++i) { int k = b * 64 + i; in[i] = k < 2400 ? (float)(((k * 37) % 400) - 200) * 40.0f : 0.0f; }
        fx_process_f(in, L, R, 64);
        for (int i = 0; i < 64; ++i) {
            const uint8_t *pl = (const uint8_t *)&L[i], *pr = (const uint8_t *)&R[i];
            for (int j = 0; j < 4; ++j) { c ^= pl[j]; for (int k = 0; k < 8; ++k) c = (c >> 1) ^ (0xEDB88320u & (0u - (c & 1u))); }
            for (int j = 0; j < 4; ++j) { c ^= pr[j]; for (int k = 0; k < 8; ++k) c = (c >> 1) ^ (0xEDB88320u & (0u - (c & 1u))); }
        }
    }
    fx_init(MS);
    return ~c;
}

int fx_overrun(void) { return MS ? MS->rev.overrun : 0; }
