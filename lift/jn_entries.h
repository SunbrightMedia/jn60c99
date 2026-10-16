/* jn_entries.h -- every plugin rva the host glue (lift/jn_host.c) CALLS DIRECTLY, in ONE place. Each must be a lift
 * root even when it is not a pdata function start: a leaf with no unwind data has no pdata entry, and when only the glue
 * calls it no edge in the plugin's own code reaches it -- CC_LEARN (0x31AA40) and the commit's second call (0x2853C0)
 * are such leaves (found 2026-10-16: the surfaces gate trapped on 0x31AA40). tools/lift/jn_extra_roots.py roots every
 * JN_RVA_* below, so an entry added here is lifted by construction. (The engine render's transport 0x3C7400 is not an
 * entry: it is --replace'd by the host's render composition.) */
#ifndef JN_ENTRIES_H
#define JN_ENTRIES_H
#define JN_RVA_VOICE_WRAP    0x398F30ULL   /* one sample of one voice: rcx=state[v], edx=v, r8=&{*main, *sub} */
#define JN_RVA_MASTER_WRAP   0x398EC0ULL   /* one sample of the master mix: rcx=state[8], rdx=a2[16], r8=&{*L, *R} */
#define JN_RVA_ASG_GET_COUNT 0x355A60ULL   /* the assigner's voice count (rcx=assign[v]); a leaf (no pdata) */
#define JN_RVA_ASG_SET_COUNT 0x355940ULL   /* set it (rcx=assign[v], edx=count) -- resets the assigner */
#define JN_RVA_UITICK        0x320120ULL   /* the plugin's UI timer (host_process_emu drains it through the core) */
#define JN_RVA_CC_LEARN      0x31AA40ULL   /* the CC menu's Learn: rcx = core + 24, edx = the record index; a leaf */
#define JN_RVA_CC_FORGET     0x3192E0ULL   /* the CC menu's Forget */
#define JN_RVA_REC_ID        0x319C50ULL   /* the record at an index -> its parameter id: rcx = core + 24, edx = index */
#define JN_RVA_MODEL_SET     0x283DB0ULL   /* the editor's record set: rcx = model, rdx = object, r8 = value, r9 = 1 */
#define JN_RVA_COMMIT0       0x285320ULL   /* the panel's commit, three calls on the model (editor_gate.py TRIO) */
#define JN_RVA_COMMIT1       0x2853C0ULL   /*   ... the second is a leaf (no pdata) */
#define JN_RVA_COMMIT2       0x283120ULL
/* the editor (host_process_emu.attach_editor / window_conv, docs/WINDOW_ZOOM.md) */
#define JN_RVA_ZOOM_GET      0x2AA590ULL   /* a panel window's zoom getter: rcx = the window (window_conv) */
#define JN_RVA_VO_GET        0x34E170ULL   /* the model's value-object list: rcx = model (the zoom drive finds vs objects) */
#define JN_RVA_WINDOW_FIT    0x312750ULL   /* a panel window's fit to the screen: NOT called -- a lifter HOOK
                                              (gen_juno_lift.sh --hook): the glue finds each window by it, as the oracle */
#endif
