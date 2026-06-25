/* juno_preset.h — capture-free factory-bank preset loader for the JUNO-60 port.
 * Decodes a bank record (deserializer-proven layout) and applies it to engine
 * state via the bit-exact LUT apply. Returns the FX selectors so the host can
 * set the chorus mode and activate the reverb. */
#ifndef JUNO_PRESET_H
#define JUNO_PRESET_H

typedef struct {
    char name[20];
    int  chorus_mode;   /* DB873: 0=off 1=? 2=CH1 3=CH2          */
    int  reverb_type;   /* DB876: 0..5 (3=HALL2)                 */
    int  fxa_type;      /* DB875: 0=DELAY ...                    */
    int  model;         /* DB871: 0=JUNO-60                      */
    int  filter_type;   /* DB872                                 */
    int  applied;       /* number of voice params applied        */
} juno_preset_info;

/* Load bank record `record` from `bank_path` into engine state `st` (which must
 * already have had juno_chorus_init + juno_engine_init + juno_runtime_coeffs_apply
 * run). Applies the exposed voice params (broadcast to all voices) and fills
 * `info`. Returns 0 on success, <0 on error. */
int juno_preset_load(unsigned char *st, const char *bank_path, int record,
                     juno_preset_info *info);

#endif
