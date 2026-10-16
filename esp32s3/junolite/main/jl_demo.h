/* jl_demo.h -- the demo the firmware plays when no MIDI has arrived: each preset
 * plays a 6-note chord, then a 4-note chord, then 1.2 s of release. 5 s per preset.
 * jl_demo_step(t) runs at block t (block = JL_BLOCK frames); returns the preset index. */
#ifndef JL_DEMO_H
#define JL_DEMO_H
#include "jl_synth.h"
#define JL_DEMO_PRESET_BLOCKS ((int)(5.0 * JL_SR / JL_BLOCK))
static const int jl_chordA[6] = { 45, 57, 60, 64, 67, 72 };   /* Am7 add, 6 voices */
static const int jl_chordB[4] = { 53, 57, 60, 65 };            /* F */
static inline int jl_demo_step(long t)
{
    int pr = (int)((t / JL_DEMO_PRESET_BLOCKS) % jl_npresets);
    long b = t % JL_DEMO_PRESET_BLOCKS, s = JL_SR / JL_BLOCK;   /* blocks per second (689) */
    if (b == 0) jl_set_patch(&jl_presets[pr]);
    if (b == 0)          for (int i = 0; i < 6; ++i) jl_note_on(jl_chordA[i], 100);
    if (b == 16 * s / 10) for (int i = 0; i < 6; ++i) jl_note_off(jl_chordA[i]);
    if (b == 2 * s)      for (int i = 0; i < 4; ++i) jl_note_on(jl_chordB[i], 100);
    if (b == 36 * s / 10) for (int i = 0; i < 4; ++i) jl_note_off(jl_chordB[i]);
    return pr;
}
#endif
