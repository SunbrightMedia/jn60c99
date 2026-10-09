/* master_render_itcm.c — a SECOND COMPILATION of src/master_render.c, placed in
 * ITCM. Exactly the same device as daisy/voice_render_itcm.c; read that file's
 * comment first. Together the two ITCM copies are ~32 KB of the 64 KB ITCM, so
 * the whole hot text fits and the sweep can report the TOTAL that placement can
 * ever buy, not just the voice half of it. */
#define juno_master_render juno_master_render_itcm
#include "../src/master_render.c"
