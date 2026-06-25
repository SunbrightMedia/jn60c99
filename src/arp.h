/* arp.h — faithful C99 transcription of the JUNO-60 (RolandCloud "Cloud 60")
 * CArpeggio step/clock engine, ported verbatim from the decompiled binary
 * (allcode/decomp_380000.c and decomp_3C0000.c, image base 0x7FF91DC60000).
 * See docs/ARP_DSP.md for the full struct map and behaviour spec.
 *
 * TRANSCRIPTION ETHOS: transcribe verbatim, do not approximate or invent. The
 * arp object in the original is a single ~4080-byte struct addressed by raw byte
 * offset relative to `a1`. We keep that byte-exact (juno_arp_state, below) and
 * access it through the JF/JI macros exactly as src/voice_render.c does.
 *
 * vtable -> callbacks: the original emits notes through the object vtable:
 *   noteOn  = (**a1)(a1, note, vel, key)        (vtable slot 0)
 *   noteOff = (*(*a1 + 8))(a1, note, 64)        (vtable slot 1)
 * We replace those indirect calls with a host-supplied callback interface
 * (juno_arp_callbacks). The faithful struct's +0 vptr slot is NOT used to hold
 * a real vtable here; instead the wrapper (juno_arp) carries the callbacks and
 * the dispatch helpers juno_arp_note_on/off read them. The faithful struct stays
 * byte-exact; host glue lives only in the wrapper.
 *
 * The +3480 direction-selector function pointer is likewise kept faithful: it is
 * stored in the faithful struct at offset 3480 as a C function pointer to one of
 * the juno_arp_sel_* transcriptions below (see sub_7FF91E01FCB0).
 *
 * Build with -fno-strict-aliasing (state is addressed by raw offset).
 */
#ifndef JUNO_ARP_H
#define JUNO_ARP_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* The faithful arp object. The decompile reads up to offset ~4080; +3496..+4045
 * is the CKbdArp staged-pattern record. 4096 covers it with margin. Accessed by
 * byte offset only — do NOT add named members here, it must stay layout-exact. */
#define JUNO_ARP_STATE_BYTES  4096u

typedef unsigned char juno_arp_state[JUNO_ARP_STATE_BYTES];

/* Host callback interface (replaces the object vtable slots 0/1). */
typedef struct juno_arp_callbacks {
    void (*note_on)(void *ud, int note, int vel, int key); /* vtable slot 0  */
    void (*note_off)(void *ud, int note, int vel);         /* vtable slot 1  */
    void *ud;
} juno_arp_callbacks;

/* Wrapper: the byte-exact faithful struct plus host glue (callbacks). The
 * faithful code only ever touches `st`; the dispatch helpers consult `cb`. */
typedef struct juno_arp {
    juno_arp_state     st;   /* the 4080-byte CArpeggio object (offset-addressed) */
    juno_arp_callbacks cb;   /* host glue; not part of the faithful layout        */
} juno_arp;

/* ---- public API -------------------------------------------------------- */

/* Construct: transcription of CArpeggio ctor sub_7FF91E01D270 (@rva 0x3BD270)
 * plus wiring of the callback struct. Zeroes the state first (the original is
 * placement-constructed over heap that the surrounding allocator had cleared).
 * Installs the default ORDER selector at +3480 (matches the ctor leaving +3480
 * for the mode installer; we default it so an un-set-mode arp is still safe). */
void juno_arp_init(juno_arp *arp, const juno_arp_callbacks *cb);

/* Held-note add: sub_7FF91E023440 (@rva 0x3C3440). a2=key (0..127), a3=velocity.
 * a3==0 routes to remove (matches the original key-up-as-note-on-vel-0 path). */
void juno_arp_note_on(juno_arp *arp, int key, int vel);

/* Held-note remove: sub_7FF91E01F110 (@rva 0x3BF110) -> sub_7FF91E01F2A0. */
void juno_arp_note_off(juno_arp *arp, int key);

/* Mode installer: sub_7FF91E01FCB0 (@rva 0x3BFCB0). Installs the +3480 selector
 * by mode index (see docs/ARP_DSP.md §5). */
void juno_arp_set_mode(juno_arp *arp, int mode);

/* Octave range setter: sub_7FF91E01FE60 (@rva 0x3BFE60). */
void juno_arp_set_range(juno_arp *arp, int octaves);

/* Enable/run setter: sub_7FF91E01FE90 (@rva 0x3BFE90). a2 = running flag. */
void juno_arp_set_running(juno_arp *arp, int running);

/* Clock driver: sub_7FF91E01DEA0 (@rva 0x3BDEA0). Advances the sample position
 * `nsamples` ticks; fires the scanner each time +24 reaches the +3048 boundary,
 * and sweeps the 16 voice slots for note-offs. Emits via the callbacks. */
void juno_arp_clock(juno_arp *arp, int nsamples);

/* Direct scanner entry (one step engine call). Exposed for tests; normally
 * driven by juno_arp_clock. sub_7FF91E020260 (@rva 0x3C0260). */
void juno_arp_scan(juno_arp *arp);

/* ---- direction selectors (the +3480 function pointer targets) ---------- */
/* Each takes the faithful state pointer (and the original's extra args, ignored
 * by the position-independent ones). Returns the chosen MIDI key, or <0 none. */
typedef int64_t (*juno_arp_selector)(unsigned char *a1, int a2, int64_t a3);

int64_t juno_arp_sel_up(unsigned char *a1, int a2, int64_t a3);     /* mode 15 */
int64_t juno_arp_sel_down(unsigned char *a1, int a2, int64_t a3);   /* mode 16 */
int64_t juno_arp_sel_updown(unsigned char *a1, int a2, int64_t a3); /* mode 17 */
int64_t juno_arp_sel_random(unsigned char *a1, int a2, int64_t a3); /* mode 18 */
int64_t juno_arp_sel_order(unsigned char *a1, int a2, int64_t a3);  /* default */
int64_t juno_arp_sel_transpose(unsigned char *a1, int a2, int64_t a3); /* m11  */

#ifdef __cplusplus
}
#endif

/* CKbdArp preset-pattern loader (sub_7FF91E023010): stage a 550-byte style/
 * variation pattern record so the next clock boundary expands it. */
void juno_arp_load_pattern(juno_arp *arp, const unsigned char *mode_hdr, const unsigned char *pattern);

#endif /* JUNO_ARP_H */
