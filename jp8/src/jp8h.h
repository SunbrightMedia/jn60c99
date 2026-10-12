/* jp8h.h -- the JUPITER-8 as a DAW runs it (jp8_host.c): the plugin's own process(), patch load, setupProcessing,
 * setActive, getState / setState, UI timer, MIDI learn, edit controller and engine, lifted, on the memory the host
 * oracle had after booting the plugin up to the point a host learns its sample rate (a JP8H v2 template). One
 * instance per process. Build: ISO C99 (-std=c99) with the lifted source and jp8_rt.c; or, for the plugin's own
 * parallelism (its eight engine workers on eight threads), add -D_POSIX_C_SOURCE=200809L -DJP8H_THREADS and -lpthread:
 * the same output, bit for bit (jp8_host_gate.sh grades both). */
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
 * a string parsed (the strings in the host's scratch area: the host-object area does not grow after jp8h_init) */
int  jp8h_param_get(uint32_t id, double *v);
int  jp8h_param_set(uint32_t id, double v, uint32_t *result);
int  jp8h_param_to_plain(uint32_t id, double v, double *plain);
int  jp8h_param_to_norm(uint32_t id, double plain, double *v);
int  jp8h_param_string(uint32_t id, double v, uint16_t out[128], uint32_t *result);
int  jp8h_param_parse(uint32_t id, const uint16_t *text, double *v, uint32_t *result);
int  jp8h_ctl_raw(int slot, uint32_t id, double v, uint32_t *result, uint64_t *xmm0);
/* what a DAW asks the controller when it loads the plugin -- the plugin's own answers: the parameters (VST3
 * ParameterInfo; an index outside [0, count) is refused: the plugin itself throws), the MIDI mapping (IMidiMapping: CC n,
 * 128 aftertouch, 129 pitch bend -> the parameter id process() takes), the units (IUnitInfo), the controller's own state
 * (empty: the plugin writes none) and setComponentState (the component's state handed to the controller, as a DAW does
 * after jp8h_set_state). Strings are UTF-16, 0-ended. */
typedef struct { uint32_t id; uint16_t title[128], short_title[128], units[128]; int32_t step_count; double default_value;
                 int32_t unit_id, flags; } jp8h_pinfo;                                     /* 792 bytes, VST3's */
typedef struct { int32_t id, parent_id; uint16_t name[128]; int32_t program_list_id; } jp8h_uinfo;   /* 268 bytes */
int  jp8h_param_count(int32_t *n);
int  jp8h_param_info(int32_t index, jp8h_pinfo *info, uint32_t *result);
int  jp8h_midi_assignment(int32_t bus, int16_t channel, int16_t cc, uint32_t *id, uint32_t *result);  /* result 0: mapped */
int  jp8h_unit_count(int32_t *n);
int  jp8h_unit_info(int32_t index, jp8h_uinfo *info, uint32_t *result);
int  jp8h_program_list_count(int32_t *n);
int  jp8h_selected_unit(int32_t *id);
int  jp8h_select_unit(int32_t id, uint32_t *result);
int  jp8h_ctl_get_state(void *buf, size_t cap, size_t *n, uint32_t *result);
int  jp8h_ctl_set_state(const void *data, size_t n, uint32_t *result);
int  jp8h_component_state(const void *data, size_t n, uint32_t *result);
/* v8 (E1): THE EDITOR -- the virtual screen a host's machine has (GetSystemMetrics 78 / 79), the editor opened
 * (IEditController::createView("editor") + IPlugView::attached), a panel window's zoom getter (the window found by its
 * fit's call; w x h its Script.xml size, e.g. the main panel 3940 x 2004), the windows laid out so far */
int  jp8h_screen(int32_t cx, int32_t cy);
int  jp8h_attach_editor(uint64_t *view, uint32_t *result);
int  jp8h_window_zoom(int32_t w, int32_t h, int32_t *zoom);
int  jp8h_windows(int32_t *wh, int cap);
int  jp8h_frame_size(int32_t *w, int32_t *h, int32_t *n);   /* the last size the view asked the host's frame for; n asks */
const char *jp8h_error(void);
/* gates */
void    *jp8h_guest(uint64_t gaddr, size_t len);
uint64_t jp8h_heap_top(void);
uint64_t jp8h_jobs(void);
uint64_t jp8h_com_next(void);
int      jp8h_threaded(void);                                       /* 1: JP8H_THREADS (the workers' stacks are their own) */
int      jp8h_edits(uint32_t *id, double *val, int cap);           /* the performEdit calls so far (all, count returned) */
void     jp8h_heap_stats(uint64_t *live_blocks, uint64_t *free_blocks); /* the heap's reuse layer (jp8_rt.c) */
#endif
