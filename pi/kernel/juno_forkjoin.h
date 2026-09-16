//
// juno_forkjoin.h — the ONE shared-nothing fork-join, shared by the GATE and PLAY.
//
// The synth's 8 voices are spread across the A53's 4 cores. Each core owns a
// PRIVATE engine copy and a FIXED voice set (0-1 | 2-3 | 4-5 | 6-7), runs the
// per-sample control tick on its own copy, and renders only its voices into a
// shared per-voice buffer; the audio core (0) then sums canonically and runs
// the master. Structure mirrors MiniDexed: a per-block fork-join with volatile
// status flags (no atomics/IPIs) plus ARM DataSyncBarrier/DataMemBarrier.
//
// This class is the SINGLE implementation of that fork-join. juno_split.cpp
// drives it as a self-checking GATE (compares its output to a single-core
// reference, block for block, on 4 emulated cores). juno_sound.cpp drives it
// from the I2S GetChunk callback for real audio on silicon. The gate therefore
// proves the EXACT code PLAY runs — not a copy of it.
//
#ifndef JUNO_FORKJOIN_H
#define JUNO_FORKJOIN_H

#include <circle/multicore.h>
#include <circle/memory.h>
#include <circle/types.h>

struct juno_ev;                 // pi/probe/juno_probe_core.h (full-surface event)

class CJunoForkJoin : public CMultiCoreSupport
{
public:
	enum { NCORES = 4, MAXBLK = 1024 };      // MAXBLK caps one fork-join's frames

	explicit CJunoForkJoin (CMemorySystem *pMem);

	// Create the 4 private engine copies at sample rate sr. Call before
	// Initialize() (which starts the secondary cores into Run()).
	boolean Setup (float sr);

	// CMultiCoreSupport entry. Core 0 returns at once (the caller drives it —
	// the gate loop, or the I2S IRQ). Cores 1..3 spin on their status flag,
	// render their voice set when kicked, and signal done.
	void Run (unsigned nCore) override;

	// The fork-join: render `frames` interleaved stereo frames into out[2*frames]
	// across all 4 cores. Bit-identical to the single-core juno_gui_render over
	// the same frames (proven by the gate). Safe for any frames >= 0; rendered in
	// <= MAXBLK sub-blocks so the per-voice buffer stays bounded.
	void RenderBlock (float *out, int frames);

	void Stop (void);               // release the workers (they leave Run())

	// Broadcast control to EVERY private copy so voice allocation stays in
	// lockstep (the firmware rule). The gate mirrors each to its reference.
	void BroadcastPatch (int idx);  // reinit + apply_bank (cold patch select)
	void NoteOn (int note, int vel);
	void FireEvent (const struct juno_ev *e);   // note/patch/host/tempo

private:
	void RenderVoices (int core);   // worker: its voices, m_frames samples

	void *m_ctx[NCORES];
	int   m_banklen;
	float m_sr;
	int   m_bound[NCORES + 1];
	volatile int m_status[NCORES];
	volatile int m_frames;
	float m_vbuf[8][MAXBLK];
};

#endif
