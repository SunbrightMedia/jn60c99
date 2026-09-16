//
// juno_split.cpp — the MULTI-CORE split, on Circle's CMultiCoreSupport.
//
// The synth's 8 voices are spread across the A53's cores. Design proven bit-exact
// on the host (pi/probe/block_split_gate.c + split_battery.c): each core owns a
// PRIVATE engine copy and a fixed voice set, runs the per-sample control tick on
// its own copy, and renders only its voices into a shared per-voice buffer; the
// audio core (0) then sums canonically and runs the master. Structure mirrors
// MiniDexed: a per-block fork-join with volatile status flags (no atomics/IPIs).
//
// THIS is a self-checking GATE: core 0 also renders a single-core reference and
// compares the split output to it, block for block. A green result under QEMU's
// 4-core emulation proves the REAL concurrency (barrier + memory ordering + per-
// core copies), not just the numerics.
//
#include <circle/multicore.h>
#include <circle/memory.h>
#include <circle/logger.h>
#include <circle/synchronize.h>
#include <circle/alloc.h>
#include <circle/util.h>
#include <circle/timer.h>

extern "C" {
void *juno_gui_create(float,int);
void  juno_gui_reinit(void*,float,int);
int   juno_gui_apply_bank(void*,const char*,int,int);
void  juno_gui_note_on(void*,int,int);
void  juno_gui_tick(void*);
int   juno_gui_render(void*,float*,int);
unsigned char *juno_gui_state(void*);
void  juno_enable_hw_ftz(void);
// engine internals used by the split render (same as the proven host gate)
unsigned int juno_voice_render(unsigned char*,int,float*,float*);
float *juno_master_render(unsigned char*,float**,float**);
void  juno_flush_denormals(unsigned char*);
extern const unsigned char juno_bank_blob[];
extern const unsigned char juno_bank_blob_end[];
}

#define JS_SR      48000.0f
#define JS_NF      128
#define JS_NOFF    84272u
#define JS_NLEN    164u
#define JS_CORES   4

enum { ST_IDLE = 0, ST_BUSY = 1, ST_EXIT = 2 };

class CJunoSplit : public CMultiCoreSupport
{
public:
	CJunoSplit(CMemorySystem *pMem)
	: CMultiCoreSupport(pMem), m_banklen(0), m_pass(0), m_total(0), m_worstdiff(0.0f)
	{
		for (int i = 0; i < JS_CORES; ++i) { m_ctx[i] = 0; m_status[i] = ST_IDLE; }
		m_ref = 0;
		m_bound[0] = 0; m_bound[1] = 2; m_bound[2] = 4; m_bound[3] = 6; m_bound[4] = 8;
	}

	// Create the 4 private engine copies + a single-core reference (core 0 only).
	boolean Setup(void)
	{
		m_banklen = (int)(juno_bank_blob_end - juno_bank_blob);
		for (int i = 0; i < JS_CORES; ++i) {
			m_ctx[i] = juno_gui_create(JS_SR, 0);
			if (!m_ctx[i]) return FALSE;
		}
		m_ref = juno_gui_create(JS_SR, 0);
		return m_ref != 0;
	}

	void Run(unsigned nCore) override
	{
		juno_enable_hw_ftz();                 // per-core FTZ (rigidity rule 4)
		if (nCore == 0) { RunGate(); return; }
		// worker cores: spin on the flag, render owned voices, signal done
		for (;;) {
			while (m_status[nCore] == ST_IDLE) { }      // wait to be kicked
			DataMemBarrier();
			if (m_status[nCore] == ST_EXIT) break;
			RenderVoices(m_ctx[nCore], m_bound[nCore], m_bound[nCore+1]);
			DataSyncBarrier();                          // publish vbuf before IDLE
			m_status[nCore] = ST_IDLE;
		}
	}

private:
	// one core's block: tick its copy, render its voices into the shared vbuf
	void RenderVoices(void *ctx, int lo, int hi)
	{
		unsigned char *st = juno_gui_state(ctx), nblk[JS_NLEN];
		for (int s = 0; s < JS_NF; ++s) {
			juno_gui_tick(ctx);
			memcpy(nblk, st + JS_NOFF, JS_NLEN);
			for (int v = lo; v < hi; ++v) {
				float l = 0, r = 0; memcpy(st + JS_NOFF, nblk, JS_NLEN);
				juno_voice_render(st, v, &l, &r); m_vbuf[v][s] = l;
			}
			juno_flush_denormals(st);
		}
	}

	// audio core: kick workers, render its own voices + master interleaved
	void RenderSplitBlock(float *out)
	{
		for (int c = 1; c < JS_CORES; ++c) { m_status[c] = ST_BUSY; }
		DataSyncBarrier();                                     // kick published
		for (int c = 1; c < JS_CORES; ++c) { while (m_status[c] != ST_IDLE) { } }
		DataMemBarrier();                                      // see workers' vbuf

		void *ctx = m_ctx[0]; unsigned char *sa = juno_gui_state(ctx), nblk[JS_NLEN];
		for (int s = 0; s < JS_NF; ++s) {
			juno_gui_tick(ctx);
			memcpy(nblk, sa + JS_NOFF, JS_NLEN);
			for (int v = m_bound[0]; v < m_bound[1]; ++v) {
				float l = 0, r = 0; memcpy(sa + JS_NOFF, nblk, JS_NLEN);
				juno_voice_render(sa, v, &l, &r); m_vbuf[v][s] = l;
			}
			float sc = 0, *a2[16]; for (int j = 0; j < 16; ++j) a2[j] = &sc;
			for (int v = 0; v < 8; ++v) a2[2*v] = &m_vbuf[v][s];
			float L = 0, R = 0, *a3[2] = { &L, &R };
			juno_master_render(sa, a2, a3); juno_flush_denormals(sa);
			out[2*s] = L; out[2*s+1] = R;
		}
	}

	void Broadcast_note_on(int note, int vel)
	{
		for (int i = 0; i < JS_CORES; ++i) juno_gui_note_on(m_ctx[i], note, vel);
		juno_gui_note_on(m_ref, note, vel);
	}
	void Broadcast_patch(int p)
	{
		for (int i = 0; i < JS_CORES; ++i) {
			juno_gui_reinit(m_ctx[i], JS_SR, 0);
			juno_gui_apply_bank(m_ctx[i], (const char*)juno_bank_blob, m_banklen, p);
		}
		juno_gui_reinit(m_ref, JS_SR, 0);
		juno_gui_apply_bank(m_ref, (const char*)juno_bank_blob, m_banklen, p);
	}

	void RunGate(void)
	{
		CLogger *log = CLogger::Get();
		log->Write("split", LogNotice,
			"MULTI-CORE split gate: 4 cores, voices 0-1|2-3|4-5|6-7, barrier fork-join");

		const int patches[] = { 0, 5, 11, 27, 42, 48, 60, 7 };
		const int NPAT = sizeof(patches)/sizeof(patches[0]);
		const int chord[8] = { 45, 48, 52, 55, 60, 64, 67, 72 };
		const int NBLK = 24;
		float refblk[2*JS_NF];

		for (int p = 0; p < NPAT; ++p) {
			Broadcast_patch(patches[p]);
			for (int k = 0; k < 8; ++k) Broadcast_note_on(chord[k], 100);

			int ok = 1; float md = 0;
			for (int b = 0; b < NBLK && ok; ++b) {
				juno_gui_render(m_ref, refblk, JS_NF);   // single-core reference
				RenderSplitBlock(m_splblk);              // the real 4-core split
				for (int n = 0; n < 2*JS_NF; ++n) {
					float d = refblk[n] - m_splblk[n]; if (d < 0) d = -d;
					if (d > md) md = d;
					if (d != 0.0f) ok = 0;
				}
			}
			if (md > m_worstdiff) m_worstdiff = md;
			++m_total; if (ok) ++m_pass;
			// CLogger has no %g; report max|diff| as parts-per-billion (0 = exact).
			log->Write("split", LogNotice, "patch %2d: %s (max|diff| = %u ppb)",
				   patches[p], ok ? "== MATCH" : "!! DIFF",
				   (unsigned)(md * 1000000000.0f));
		}

		// stop the workers
		for (int c = 1; c < JS_CORES; ++c) m_status[c] = ST_EXIT;
		DataSyncBarrier();

		log->Write("split", LogNotice, "MULTI-CORE RESULT: %d/%d patches identical to single-core",
			   m_pass, m_total);
		if (m_pass == m_total)
			log->Write("split", LogNotice,
			  "SPLIT BIT-EXACT ON 4 EMULATED CORES — barrier + per-core copies proven");
		else
			log->Write("split", LogNotice, "SPLIT DIVERGED — concurrency defect (see DIFF rows)");
		log->Write("split", LogNotice, "SPLIT GATE COMPLETE");
	}

	void *m_ctx[JS_CORES];
	void *m_ref;
	int   m_banklen;
	int   m_bound[5];
	volatile int m_status[JS_CORES];
	float m_vbuf[8][JS_NF];
	float m_splblk[2*JS_NF];
	int   m_pass, m_total; float m_worstdiff;
};

void run_juno_split(void)
{
	CLogger *log = CLogger::Get();
	CJunoSplit *split = new CJunoSplit(CMemorySystem::Get());
	if (split == 0 || !split->Setup()) {
		log->Write("split", LogPanic, "split: engine setup failed (out of memory?)");
		return;
	}
	if (!split->Initialize()) {              // starts the secondary cores
		log->Write("split", LogPanic, "split: CMultiCoreSupport init failed");
		return;
	}
	split->Run(0);                           // core 0 runs the gate; returns when done
	log->Write("split", LogNotice, "PROBE COMPLETE — halting.");
}
