/* juno_engine.h — state model + accessors for the C99 voice-engine transcription.
 *
 * The decompiled engine operates on a large flat state block via byte offsets
 * (e.g. *(float*)(a1 + 320)). We mirror that exactly: the state is a raw byte
 * buffer and stages address it through the F()/I() accessors below. This is a
 * literal transcription choice — it guarantees we reproduce the plugin's memory
 * layout and aliasing precisely; named fields are layered on as offsets are
 * confirmed (see docs/VOICE_RENDER_MAP.md). Build with -fno-strict-aliasing.
 */
#ifndef JUNO_ENGINE_H
#define JUNO_ENGINE_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Per-voice / shared state layout — DERIVED by diffing the offset constants of
 * the 8 specialised voice-render copies (sub_180369070..sub_180383F20); every
 * one of their 1222 state references falls into exactly one of these regions
 * (see docs/POLYPHONY.md):
 *   main per-voice block : offsets [176,10672]   -> +v*10512  (8 blocks tile
 *                          [176,84272) exactly: 176 + 8*10512 == 84272)
 *   shared global block  : offsets [84272,84432] -> +0 (all voices share it)
 *   aux one-shot edge     : offset  101504        -> +v*32
 * voice_render is one routine parameterised by voice index; voice 0 is identical
 * to the original voice-0 function. MAIN_BASE0 (320) is the first field the note
 * driver writes; the block itself starts at 176. */
#define JUNO_VOICE_MAIN_BASE0   320
#define JUNO_VOICE_MAIN_STRIDE  10512
#define JUNO_VOICE_AUX_BASE0    101504
#define JUNO_VOICE_AUX_STRIDE   32
#define JUNO_NUM_VOICES         8

/* Offset accessors into the state block `st` (an unsigned char*). The casts
 * mirror the decompile (float / dword) memory reads exactly.
 *
 * === EB_DEVCELLS: THE DEVICE REBASE, AS A BUILD FLAG ===================
 *
 * The microcontroller cannot hold an 11 MB array. engine_b/dev/ebdev.h carries
 * the ~30 KB of it that recall actually touches and `ebdev_at(off)` maps a port
 * offset to its device address. Until 2026-08-12 that substitution was done by
 * a PYTHON TEXT REWRITE in tools/engineb/devrecall_gate.py, which copied these
 * sources into a scratch tree and applied ~20 exact-string edits. That could
 * not ship: an ESP-IDF build cannot run a regex over its own inputs, and the
 * gate then proved a tree that was not the tree being flashed.
 *
 * So it is a flag, here, in the checked-in source. `JCELL(st, off)` is the ONE
 * place the address is formed; with EB_DEVCELLS undefined it is textually
 * different from the old expression and semantically the identity, and that
 * claim is checked by rebuilding libjuno.so and byte-comparing it.
 *
 * The other rebased sites -- the raw pointer casts in delay_recall.c,
 * effect_modes.c, reverb_recall.c and juno_driver.c, and eb_coefs.c /
 * eb_master_coefs.c / eb_chorus_shim.c's own cell accessors -- use JCELL or
 * their own #ifdef with the same name. Nothing may reach a cell any other way;
 * tools/engineb/devrecall_gate.py refuses a build that does. */
#ifdef EB_DEVCELLS
#include "ebdev.h"
#define JCELL(st, off)  ebdev_at((unsigned long)(off))
#else
#define JCELL(st, off)  ((void *)((unsigned char *)(st) + (off)))
#endif
#define JF(st, off)  (*(float   *)JCELL((st), (off)))   /* float  */
#define JI(st, off)  (*(int32_t *)JCELL((st), (off)))   /* int32  */

/* Full engine state size. The initializer (sub_1803990C0) writes up to offset
 * ~10.69 MB (all 8 voices + global blocks); the master reads a counter at
 * +11022344. 12 MB covers the whole block with margin. */
#define JUNO_STATE_BYTES  (12u * 1024u * 1024u)

/* === PORT-OWNED SHADOW CELLS (2026-08-15) ==============================
 * The plugin's engine object is exactly operator new(0xA83010) =
 * 11,022,352 bytes (src/juno_apply.c:30, src/reverb_recall.c:4,
 * src/juno_driver.c:15,:85; the oracle selects allocations of that exact
 * size, tools/verify/e2e_emu.py:50,:284). The port's array is 12 MB, so
 * [11022352, 12582912) is memory NO PLUGIN CELL CAN OCCUPY.
 *
 * Every port-vs-plugin comparison in the tree stops at or below that
 * bound: coldstate_ab.py:35 MEANINGFUL=11022352, port_writeset.py:13
 * SZ=0xA83010, recall_fullstate_diff.py:46 STATE_SZ=0xA83010 with its
 * highest REGION ending at 11022360, recall_gate.py scoped to cells
 * < 10512. These cells are therefore invisible to every A/B and can never
 * false-fail one (checked by tools/verify/shadow_bounds_gate.py).
 * 11022400 is 48 bytes clear of the object end, 40 bytes clear of the
 * highest compared REGION, and on the engine's 16-byte cell grid. A scan
 * of every 7-9 digit literal in src/ finds no other offset at or above
 * 11022352 (highest is 11022348, the master's route latch).
 *
 * WHY THEY EXIST. Several recall arms are gated on the effect type IN
 * FORCE BEFORE the recall, not on the new one (see src/chorus_recall.c).
 * JUNO_PROG_EFX / JUNO_PROG_DLY cannot answer that question: both are
 * CLAMPED (src/effect_modes.c:62, src/delay_recall.c:453) and neither is
 * written at all at type >= 6, so they lose the raw leaf value. These
 * cells hold the RAW leaf byte, never a routing value.
 *
 * WHY IN THE STATE and not in gui/juno_bridge.c's juno_ctx: juno_ctx
 * reaches exactly 1 of the 9 callers of juno_bank_apply. The device
 * (engine_b/dev/eb_devseq.c:50 passes DEVST=(unsigned char*)0), the trunk
 * null gate, the devrecall gate, the boot-image generator and every C
 * test have no ctx and would silently get the default. All 9 callers
 * already thread `state`, and 8 of 9 already call juno_engine_prepare, so
 * a state-resident shadow is carried by every path for free. The plugin's
 * own precedent is a state cell too: 11022348, the master's route latch
 * (src/master_render.c:890 etc.), is the plugin remembering its last
 * route IN THE STATE.
 *
 * THE CONTRACT, STATED AS IT MUST BE: EVERY WRITER OF A ROUTING CELL IS
 * ALSO A WRITER OF ITS SHADOW. Whoever puts an EFFECT TYPE into
 * JUNO_PROG_EFX puts the same RAW leaf into JUNO_PREV_EFX at or after
 * that write; likewise JUNO_PROG_DLY -> JUNO_PREV_DLY. The routing cell
 * takes the CLAMPED type, the shadow takes the RAW one, so the relation
 * is prog == clamp(shadow), never plain equality.
 *
 * THE FIRST WORDING OF THIS CONTRACT SAID "any FUTURE setter outside
 * juno_bank_apply must update them too". THAT WAS FALSE THE DAY IT WAS
 * WRITTEN: gui/juno_bridge.c juno_gui_set_chorus_mode already existed,
 * already wrote JUNO_PROG_EFX, and already left the shadow stale — a
 * shipped WASM export that made the same EFFECT TYPE in force produce two
 * different engines (measured; see the comment at that function). A rule
 * about the future cannot be checked, so this one names the present:
 *
 *   THE COMPLETE WRITER SET, whole tree, generated/build copies excluded
 *   (tools/verify/shadow_sync_gate.py check S re-derives it every run and
 *   is RED on any writer not in it):
 *     src/juno_prepare.c:279-280  seeds PROG_DLY=0 PROG_EFX=2, shadows at
 *                                 :290-291 in the same block.
 *     src/effect_modes.c:64       PROG_EFX inside juno_apply_effect_modes;
 *                                 its caller juno_bank_apply shadows at
 *                                 src/juno_apply.c:821.
 *     src/delay_recall.c:454      PROG_DLY inside juno_apply_delay; same
 *                                 caller, shadowed at src/juno_apply.c:822.
 *     src/juno_apply.c:821-822    the recall's own shadow update, LAST so
 *                                 every applier above read the PREVIOUS type.
 *     gui/juno_bridge.c           juno_gui_set_chorus_mode (EFX) and
 *                                 juno_gui_recall_factory (DLY) — both write
 *                                 the pair themselves.
 *   EXEMPT, AND ONLY THESE: gui/juno_bridge.c juno_gui_set / juno_gui_poke
 *   are RAW cell writers for the harness. They take an arbitrary offset, so
 *   they are not routing setters and cannot be made to maintain anything;
 *   a harness that pokes a routing cell (tools/engineb/fx_chorus_cost.c,
 *   tools/verify/finefx_port_dump.c) owns the consequence. Neither recalls
 *   afterwards, so neither can read a stale shadow today.
 *
 * A NEW APPLIER MUST NOT ADD A SHADOW WRITE OF ITS OWN. The recall's
 * update stays at the single site src/juno_apply.c:821-822, at the END,
 * because every applier must see the type that was in force BEFORE this
 * recall. Seeded by juno_engine_prepare.
 *
 * Under -DEB_DEVCELLS they must also be listed in
 * docs/engineb/data/devrecall/static_extra.txt, or ebdev_at() misses and
 * the firmware's miss detector mutes the board (loud, not silent).
 *
 * TWO GATES, NOT ONE, because they answer different questions:
 * tools/verify/shadow_bounds_gate.py — can these port-only cells false-fail
 * a port-vs-plugin comparison? tools/verify/shadow_sync_gate.py — is the
 * shadow TRUE? Both run in `make verify`. */
#define JUNO_PREV_EFX  11022400u  /* previous EFFECT TYPE leaf (rec 634) */
#define JUNO_PREV_DLY  11022416u  /* previous DELAY  TYPE leaf (rec 650) */

/* juno_engine_init — exact transcription of sub_1803990C0. Fills the engine
 * state `st` with the real coefficients. Set JF(st,16) to the sample rate first
 * (44100 selects one precomputed coefficient set; any other value the second).
 * Returns the sample rate it used. */
uint32_t juno_engine_init(unsigned char *st);

/* juno_engine_prepare — the coefficients the plugin's sample-rate prepare
 * (CWaveGen::setSampleRate 0x3C7A20 + smoother snap-all 0x3C29B0) writes but the
 * constructor juno_engine_init does not: 33 DSP-read voice-0 offsets (replicated
 * to voices 1..7 by seed_voices) + 57 shared/master-FX offsets (written once).
 * All binary-derived — see src/juno_prepare.c. Call AFTER juno_engine_init.
 * Verified: with these applied the C engine matches the binary's prepared state
 * on 1571/1573 DSP-read offsets (tools/oracle/full_ab.py). */
void juno_engine_prepare(unsigned char *st);

/* juno_chorus_init — exact transcription of sub_1803A1300, the chorus/master
 * state constructor: zeroes the BBD delay buffers and writes the integer control
 * fields (delay-line lengths, ring indices) the master indexes its circular
 * buffers with. Call BEFORE juno_engine_init. Without it the master's buffer
 * masks are -1 and it reads out of bounds. (Returns the state pointer; unused.) */
void *juno_chorus_init(unsigned char *st);

/* NOTE: the former juno_runtime_coeffs_apply / _loaded (a captured one-patch
 * baseline) have been RETIRED. Every coefficient the DSP reads at playback now
 * comes from the binary: juno_engine_init (constructor) + juno_engine_prepare
 * (setSampleRate + snap-all prepared state) + the per-patch recall. See
 * docs/BITEXACT_AUDIT.md. */

/* juno_flush_denormals — flush the engine's recursive DSP state (envelope,
 * filter, delay/chorus/reverb feedback) to zero, reproducing the x86 plugin's
 * SSE FTZ/DAZ behaviour that WebAssembly lacks. Call once per rendered sample;
 * prevents decayed tails from settling into the denormal range (whose ~100x
 * slower ops cause the intermittent audio crackle). See src/juno_ftz.c. */
void juno_flush_denormals(unsigned char *st);

/* juno_enable_hw_ftz — put the CPU into the plugin's SSE flush-to-zero /
 * denormals-are-zero mode (x86 only). On WebAssembly / non-SSE targets this is a
 * no-op and juno_flush_denormals() is the per-sample fallback. Call once after
 * init. juno_hw_ftz_available() returns 1 when the hardware mode was applied. */
void juno_enable_hw_ftz(void);
int  juno_hw_ftz_available(void);

/* voice_render — exact transcription of sub_180369070, parameterised by voice.
 * Produces one mono sample for voice `voice` (0..7) from engine state `base`;
 * writes it to *outL and *outR (the plugin duplicates the mono voice to both
 * channels; stereo comes from chorus). Selects per-voice offsets internally
 * (main +voice*10512, shared +0, aux +voice*32); voice==0 is bit-identical to
 * the original. Render voices in order 0..7 per sample (shared block chains).
 * Returns the sample as a bit pattern (the decompile returns it in eax). */
uint32_t juno_voice_render(unsigned char *base, int voice, float *outL, float *outR);

/* The driver's single call site goes through this pointer. It defaults to
 * juno_voice_render; an embedded harness may point it at an identically
 * compiled copy placed in another memory, to A/B code placement inside one
 * boot. Swapping it changes NO arithmetic. See src/juno_driver.c. */
extern uint32_t (*juno_voice_render_fn)(unsigned char *base, int voice,
                                        float *outL, float *outR);

/* juno_master_render — exact transcription of sub_180363380. The master process:
 * sums the 8 voice samples, runs the stereo BBD chorus, and writes the final
 * true-stereo output. Per-sample.
 *   a1 : engine state.
 *   a2 : array of 8 voice-sample pointers at EVEN indices a2[0,2,..,14] (the
 *        plugin's voice-buffer layout; odd slots are unused).
 *   a3 : {float* L, float* R} — receives 2*state[101264] (L), 2*state[101280] (R).
 * Returns a3[1] (the decompile returns the R pointer in rax); unused by callers.
 *
 * The chorus/reverb/output coefficient fields are all supplied bit-exactly from
 * the binary by juno_engine_prepare (the effect prepare/enable state) + the
 * per-patch recall (delay/reverb/chorus). See docs/MASTER_RENDER_MAP.md. */
float *juno_master_render(unsigned char *a1, float **a2, float **a3);

/* Placement A/B indirection for the master stage — see juno_voice_render_fn. */
extern float *(*juno_master_render_fn)(unsigned char *a1, float **a2, float **a3);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_ENGINE_H */
