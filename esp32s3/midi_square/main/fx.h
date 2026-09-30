/* fx -- the JUNO FX stage ONLY (the proven engine_b master chain: input stage,
 * delay OFF, JUNO CHORUS, HALL 1 reverb, output stage), fed by the minisynth
 * voice in voice slot 0. No JUNO voice code. Coefficients and the seeded state
 * come from main/gen/msq_fx.h, which tools/fxgen.c reads out of the proven
 * recall; the two knobs select recalled table entries (EFFECT DEPTH and REVERB
 * LEVEL, the plugin's own 8-bit bytes). */
#ifndef MSQ_FX_H
#define MSQ_FX_H
#include <stdint.h>

/* the state is ~730 KB: the caller provides it (PSRAM on the S3) */
extern const unsigned msq_fx_state_bytes;
void     fx_init(void *state_mem);          /* NULL on the S3: a PSRAM static */
void     fx_set_chorus(int depth_byte);   /* 0..255, 0 = bypass (the plugin's own law) */
void     fx_set_reverb(int level_byte);   /* 0..255 */
int      fx_chorus_byte(void);
int      fx_reverb_byte(void);
/* voice: n mono samples in the synth's float scale (+-8192 = the old -12 dBFS
 * square). Writes n interleaved int16 stereo frames. */
void     fx_process(const float *voice, int16_t *lr, int n);
/* raw float outputs for the host gate (same arithmetic, before int16) */
void     fx_process_f(const float *voice, float *L, float *R, int n);
/* CRC32 of the live coefficient set and of the seeded state vs the host values
 * (tools/fxgen.c). Call right after fx_init. 1 = both match. */
int      fx_selfcheck(uint32_t *coef_crc, uint32_t *state_crc);
uint32_t fx_render_crc(void);             /* fixed-signal render CRC (re-inits the state) */
int      fx_overrun(void);                /* reverb tap overrun (must stay 0) */
/* synth scale -> engine voice scale. MEASURED (host, fx.c): the master stage
 * gains x4.4 dry and x10.8 at full chorus. With 6 voices (+-4096 each) the
 * QEMU stress chord (7-osc unison, full chorus + reverb) hit full scale at
 * 1/196608, so 1.5x lower: one square ~0.06 FS dry (~2000), the worst-case
 * chord at about full scale. */
#define  FX_IN_GAIN  (1.0f / 294912.0f)
#endif
