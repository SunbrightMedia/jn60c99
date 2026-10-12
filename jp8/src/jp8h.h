/* jp8h.h -- the JUPITER-8 as a DAW runs it (jp8_host.c): the plugin's own process(), patch load, setupProcessing,
 * setActive, getState / setState and engine, lifted, on the memory the host oracle had after booting the plugin up to
 * the point a host learns its sample rate (a JP8H v2 template). One instance per process. */
#ifndef JP8H_API_H
#define JP8H_API_H
#include <stddef.h>
#include <stdint.h>

enum { JP8H_OK = 0, JP8H_E_TEMPLATE = -1, JP8H_E_TRAP = -3, JP8H_E_ARG = -4, JP8H_E_STATE = -5 };
typedef struct { int on; int offset; int channel; int pitch; float velocity; } jp8h_event;   /* a VST3 note event */
typedef struct { uint32_t id; int offset; double value; } jp8h_param;                           /* one queue point */
typedef struct { uint32_t state; double ppq, cycle_start, cycle_end, tempo; } jp8h_ctx;        /* VST3 ProcessContext */

int  jp8h_init(const void *tmpl, size_t len, double rate, int max_block);   /* the template (raw), then the setup */
int  jp8h_set_rate(double rate);                                    /* setActive(0), setupProcessing, setActive(1) */
int  jp8h_set_active(int on);
int  jp8h_ui_tick(void);                                            /* the plugin's UI timer (call it as its 50 ms do) */
int  jp8h_cc_learn(uint32_t id);                                    /* the CC menu's Learn for parameter id */
int  jp8h_cc_forget(uint32_t id);                                   /* the CC menu's Forget */
int  jp8h_load_patch(const void *rec, size_t n);                    /* a bank record's bytes after its 16-byte name */
int  jp8h_process(int n, const jp8h_event *ev, int nev, const jp8h_param *par, int npar, const jp8h_ctx *ctx,
                  uint32_t *outl, uint32_t *outr);                  /* ctx NULL: no process context */
int  jp8h_get_state(void *buf, size_t cap, size_t *n);              /* IComponent::getState: *n bytes, cap copied */
int  jp8h_set_state(const void *data, size_t n, uint32_t *result);  /* IComponent::setState; *result its answer */
/* the edit controller (IEditController): a parameter's normalized value, set, plain <-> normalized, its display string,
 * a string parsed (each string call takes 256 bytes of the host-object area, as the plugin's host oracle does) */
int  jp8h_param_get(uint32_t id, double *v);
int  jp8h_param_set(uint32_t id, double v, uint32_t *result);
int  jp8h_param_to_plain(uint32_t id, double v, double *plain);
int  jp8h_param_to_norm(uint32_t id, double plain, double *v);
int  jp8h_param_string(uint32_t id, double v, uint16_t out[128], uint32_t *result);
int  jp8h_param_parse(uint32_t id, const uint16_t *text, double *v, uint32_t *result);
int  jp8h_ctl_raw(int slot, uint32_t id, double v, uint32_t *result, uint64_t *xmm0);
const char *jp8h_error(void);
/* gates */
void    *jp8h_guest(uint64_t gaddr, size_t len);
uint64_t jp8h_heap_top(void);
uint64_t jp8h_jobs(void);
uint64_t jp8h_com_next(void);
int      jp8h_edits(uint32_t *id, double *val, int cap);           /* the performEdit calls so far (all, count returned) */
#endif
