//
// juno_forkjoin.cpp — the shared fork-join implementation (see juno_forkjoin.h).
//
// Zero DSP math here: it only calls the engine's proven host API + the same
// engine internals the host split gate uses (juno_voice_render / master / flush),
// distributing the 8 voices across 4 cores. The distribution is proven bit-exact
// vs single core on the host (pi/probe/block_split_gate.c, split_battery.c) and
// on 4 emulated cores (pi/kernel/juno_split.cpp).
//
#include "juno_forkjoin.h"
#include <circle/synchronize.h>
#include <circle/util.h>

extern "C" {
#include "../probe/juno_probe_core.h"     // struct juno_ev, juno_storm_fire
void *juno_gui_create (float, int);
void  juno_gui_reinit (void *, float, int);
int   juno_gui_apply_bank (void *, const char *, int, int);
void  juno_gui_note_on (void *, int, int);
void  juno_gui_note_off (void *, int);
void  juno_gui_tick (void *);
unsigned char *juno_gui_state (void *);
void  juno_enable_hw_ftz (void);
unsigned int juno_voice_render (unsigned char *, int, float *, float *);
float *juno_master_render (unsigned char *, float **, float **);
void  juno_flush_denormals (unsigned char *);
extern const unsigned char juno_bank_blob[];
extern const unsigned char juno_bank_blob_end[];
}

#define NOISE_OFF 84272u        // SHARED noise/LFSR block — copied per voice so
#define NOISE_LEN 164u          // each render sees the same pre-voice noise state

// DETECTOR-REACH MUTATION SWITCH (default 0 = production). The rule "every gate
// must be SEEN TO FAIL" (CLAUDE.md) needs the split gate to go RED on a real
// concurrency/split defect. Build the gate with `make JUNO_SPLIT=1 JS_MUT=n` to
// inject one fault and confirm the gate catches it (or, for the memory-ordering
// barriers, honestly map what QEMU's near-lockstep TCG cannot catch):
//   1 = drop the kick DataSyncBarrier      2 = drop the vbuf-visibility DataMemBarrier
//   3 = drop the worker's publish barrier  4 = voice-5 not rendered (the S3 defect)
//   5 = worker FPCR/FTZ not enabled
#ifndef JS_MUT
#define JS_MUT 0
#endif

enum { ST_IDLE = 0, ST_BUSY = 1, ST_EXIT = 2 };

CJunoForkJoin::CJunoForkJoin (CMemorySystem *pMem)
:	CMultiCoreSupport (pMem), m_banklen (0), m_sr (48000.0f), m_frames (0)
{
	for (int i = 0; i < NCORES; ++i) { m_ctx[i] = 0; m_status[i] = ST_IDLE; }
	m_bound[0] = 0; m_bound[1] = 2; m_bound[2] = 4; m_bound[3] = 6; m_bound[4] = 8;
}

boolean CJunoForkJoin::Setup (float sr)
{
	m_sr = sr;
	m_banklen = (int) (juno_bank_blob_end - juno_bank_blob);
	for (int i = 0; i < NCORES; ++i) {
		m_ctx[i] = juno_gui_create (sr, 0);
		if (m_ctx[i] == 0) return FALSE;
	}
	return TRUE;
}

void CJunoForkJoin::Run (unsigned nCore)
{
#if JS_MUT != 5
	juno_enable_hw_ftz ();                       // per-core FTZ (rigidity rule 4)
#endif
	if (nCore == 0) return;                       // caller drives core 0
	for (;;) {
		while (m_status[nCore] == ST_IDLE) { }   // wait to be kicked
		DataMemBarrier ();
		if (m_status[nCore] == ST_EXIT) break;
		RenderVoices ((int) nCore);
#if JS_MUT != 3
		DataSyncBarrier ();                       // publish vbuf before IDLE
#endif
		m_status[nCore] = ST_IDLE;
	}
}

// worker core: tick its copy, render its voice set into the shared vbuf
void CJunoForkJoin::RenderVoices (int core)
{
	unsigned char *st = juno_gui_state (m_ctx[core]), nblk[NOISE_LEN];
	int lo = m_bound[core], hi = m_bound[core + 1], n = m_frames;
#if JS_MUT == 4
	if (core == 2) hi = m_bound[core + 1] - 1;    // voice 5 never rendered (S3 defect)
#endif
	for (int s = 0; s < n; ++s) {
		juno_gui_tick (m_ctx[core]);
		memcpy (nblk, st + NOISE_OFF, NOISE_LEN);
		for (int v = lo; v < hi; ++v) {
			float l = 0, r = 0; memcpy (st + NOISE_OFF, nblk, NOISE_LEN);
			juno_voice_render (st, v, &l, &r); m_vbuf[v][s] = l;
		}
		juno_flush_denormals (st);
	}
}

void CJunoForkJoin::RenderBlock (float *out, int frames, float *vpk)
{
	int done = 0;
	while (done < frames) {
		int n = frames - done; if (n > MAXBLK) n = MAXBLK;
		m_frames = n;

		for (int c = 1; c < NCORES; ++c) m_status[c] = ST_BUSY;   // kick workers
#if JS_MUT != 1
		DataSyncBarrier ();
#endif
		for (int c = 1; c < NCORES; ++c) while (m_status[c] != ST_IDLE) { }
#if JS_MUT != 2
		DataMemBarrier ();                                        // see their vbuf
#endif

		// audio core: its own voices + master interleaved per sample, so the
		// master reads the control smoothers at THIS sample (== single-core)
		unsigned char *sa = juno_gui_state (m_ctx[0]), nblk[NOISE_LEN];
		float *o = out + 2 * done;
		for (int s = 0; s < n; ++s) {
			juno_gui_tick (m_ctx[0]);
			memcpy (nblk, sa + NOISE_OFF, NOISE_LEN);
			for (int v = m_bound[0]; v < m_bound[1]; ++v) {
				float l = 0, r = 0; memcpy (sa + NOISE_OFF, nblk, NOISE_LEN);
				juno_voice_render (sa, v, &l, &r); m_vbuf[v][s] = l;
			}
			float sc = 0, *a2[16]; for (int j = 0; j < 16; ++j) a2[j] = &sc;
			for (int v = 0; v < 8; ++v) a2[2 * v] = &m_vbuf[v][s];
			float L = 0, R = 0, *a3[2] = { &L, &R };
			juno_master_render (sa, a2, a3); juno_flush_denormals (sa);
			o[2 * s] = L; o[2 * s + 1] = R;
			if (vpk)                                     // per-voice peak (probe)
				for (int v = 0; v < 8; ++v) {
					float a = m_vbuf[v][s]; if (a < 0) a = -a;
					if (a > vpk[v]) vpk[v] = a;
				}
		}
		done += n;
	}
}

void CJunoForkJoin::Stop (void)
{
	for (int c = 1; c < NCORES; ++c) m_status[c] = ST_EXIT;
	DataSyncBarrier ();
}

void CJunoForkJoin::BroadcastPatch (int idx)
{
	for (int i = 0; i < NCORES; ++i) {
		juno_gui_reinit (m_ctx[i], m_sr, 0);
		juno_gui_apply_bank (m_ctx[i], (const char *) juno_bank_blob, m_banklen, idx);
	}
}

void CJunoForkJoin::NoteOn (int note, int vel)
{
	for (int i = 0; i < NCORES; ++i) juno_gui_note_on (m_ctx[i], note, vel);
}

void CJunoForkJoin::NoteOff (int note)
{
	for (int i = 0; i < NCORES; ++i) juno_gui_note_off (m_ctx[i], note);
}

void CJunoForkJoin::FireEvent (const struct juno_ev *e)
{
	for (int i = 0; i < NCORES; ++i)
		juno_storm_fire (m_ctx[i], juno_bank_blob, m_banklen, e);
}
