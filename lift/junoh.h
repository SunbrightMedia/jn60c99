/* junoh.h -- the JUNO-60 as a DAW runs it (lift/jn_host.c): the plugin's own process(), patch load, setupProcessing,
 * setActive, getState / setState, UI timer, MIDI learn, the editor, LIFTED (lift/jn_lift.c on jp8/src/jp8_cpu.h via
 * jp8_rt.c), on the memory the JUNO host oracle (tools/verify/host_process_emu.HostProcess) had after booting the
 * plugin up to the point a host learns its sample rate (a JNH1 template, tools/lift/jn_host_ref.py). One instance per
 * process. Plumbing only, the oracle's, line for line (docs/JUNO_LIFT.md L4); no plugin logic is reimplemented here.
 * Build: ISO C99 (-std=c99) with lift/jn_lift.c and jp8/src/jp8_rt.c, -DJP8_RELOC -DJP8_GS_BASE=0x580000000ULL
 * (the oracle's TEB). The ONE replacement is the engine render's thread transport (0x3C7400, --replace): jn_host.c's
 * jp8_hook composes it over the plugin's own voice / master, exactly as the oracle's e2e_emu does. */
#ifndef JUNOH_API_H
#define JUNOH_API_H
#include <stddef.h>
#include <stdint.h>

enum { JUNOH_OK = 0, JUNOH_E_TEMPLATE = -1, JUNOH_E_TRAP = -3, JUNOH_E_ARG = -4, JUNOH_E_STATE = -5 };
typedef struct { int on; int offset; int channel; int pitch; float velocity; } junoh_event;   /* a VST3 note event */
typedef struct { uint32_t id; int offset; double value; } junoh_param;                           /* one queue point */
typedef struct { uint32_t state; double ppq, cycle_start, cycle_end, tempo; } junoh_ctx;        /* VST3 ProcessContext */

int  junoh_init(const void *tmpl, size_t len, double rate, int max_block);   /* the template (raw), then the setup */
int  junoh_set_rate(double rate);                                    /* setActive(0), setupProcessing, setActive(1) */
int  junoh_set_active(int on);
int  junoh_ui_tick(void);                                            /* the plugin's UI timer (rva 0x320120) */
int  junoh_cc_learn(uint32_t id);                                    /* the CC menu's Learn for parameter id (0x31AA40) */
int  junoh_cc_forget(uint32_t id);                                   /* the CC menu's Forget (0x3192E0) */
int  junoh_load_patch(const void *rec, size_t n);                    /* a bank record's bytes after its 16-byte name */
int  junoh_process(int n, const junoh_event *ev, int nev, const junoh_param *par, int npar, const junoh_ctx *ctx,
                   uint32_t *outl, uint32_t *outr);                  /* ctx NULL: no process context; n = 0: flush */
int  junoh_get_state(void *buf, size_t cap, size_t *n);              /* IComponent::getState: *n bytes, cap copied */
int  junoh_set_state(const void *data, size_t n, uint32_t *result);  /* IComponent::setState; *result its answer */
/* the edit controller (IEditController): a parameter set, the host round trip -- the JUNO editor's set (A42). The
 * buffers the calls write are bump-allocated in the host-object area as the oracle allocates them. */
int  junoh_model_set(uint64_t obj, uint32_t value);                  /* the editor's record set (rva 0x283DB0) */
int  junoh_rec_id(int index, uint32_t *id, uint64_t *obj);           /* the record at index -> its parameter id + object */
/* gates / the drive */
const char *junoh_error(void);
void    *junoh_guest(uint64_t gaddr, size_t len);                    /* host pointer of [a, a+n) (one band) */
uint64_t junoh_heap_top(void);
uint64_t junoh_com_next(void);
uint64_t junoh_renders(void);                                        /* engine render calls served so far */
int      junoh_edits(uint32_t *id, double *val, int cap);            /* the performEdit calls so far (all, count) */
uint64_t junoh_core(void);                                           /* the plugin's core object (a template fact) */
#endif
