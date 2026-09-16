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
#include "../probe/juno_probe_core.h"   // the ONE proven full-surface storm generator
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
	// Broadcast ONE storm event (note/patch/host/tempo) to every core copy AND
	// the reference — the firmware rule that keeps voice allocation in lockstep.
	void BroadcastEvent(const struct juno_ev *e)
	{
		const unsigned char *bk = juno_bank_blob;
		for (int i = 0; i < JS_CORES; ++i) juno_storm_fire(m_ctx[i], bk, m_banklen, e);
		juno_storm_fire(m_ref, bk, m_banklen, e);
	}

	// Render ONE block on both paths; accumulate max|diff|; return 1 if identical.
	int CompareOneBlock(float *md)
	{
		float refblk[2*JS_NF];
		juno_gui_render(m_ref, refblk, JS_NF);   // single-core reference
		RenderSplitBlock(m_splblk);              // the real 4-core split
		int ok = 1;
		for (int n = 0; n < 2*JS_NF; ++n) {
			float d = refblk[n] - m_splblk[n]; if (d < 0) d = -d;
			if (d > *md) *md = d;
			if (d != 0.0f) ok = 0;
		}
		return ok;
	}

	void RunGate(void)
	{
		CLogger *log = CLogger::Get();
		log->Write("split", LogNotice,
			"MULTI-CORE split gate: 4 cores, voices 0-1|2-3|4-5|6-7, barrier fork-join");

		// ---- Phase 1: ALL 64 factory patches, sustained 8-note chord --------
		// A patch's whole voice/FX/master path, block for block. Continuity over
		// PBLK blocks would expose any per-voice, FX or noise drift.
		const int chord[8] = { 45, 48, 52, 55, 60, 64, 67, 72 };
		const int PBLK = 16;
		int ppass = 0, ptot = 0; float pworst = 0;
		for (int p = 0; p < 64; ++p) {
			Broadcast_patch(p);
			for (int k = 0; k < 8; ++k) Broadcast_note_on(chord[k], 100);
			int ok = 1; float md = 0;
			for (int b = 0; b < PBLK && ok; ++b) ok &= CompareOneBlock(&md);
			if (md > pworst) pworst = md;
			++ptot; if (ok) ++ppass;
			if (!ok)
				log->Write("split", LogNotice,
					"patch %2d: !! DIFF (max|diff| = %u ppb)",
					p, (unsigned)(md * 1000000000.0f));
			else if ((p & 7) == 7)
				log->Write("split", LogNotice,
					"  ..patches %d/64 done, all MATCH (worst %u ppb)",
					p + 1, (unsigned)(pworst * 1000000000.0f));
		}
		log->Write("split", LogNotice, "PATCHES: %d/64 identical to single-core", ppass);

		// ---- Phase 2: seeded STORMS across the WHOLE surface ----------------
		// The SAME 5 seeds the single-core bit-exact storm gate uses. The proven
		// full-surface generator (notes, patch changes, all 79 host params,
		// tempo) is broadcast to every core copy + the reference at block
		// boundaries; the split must track the reference block for block.
		static const unsigned seeds[] =
			{ 0x0badc0deu, 0x00005eedu, 0x00c0ffeeu, 0x0a11ce99u, 0xdeadbeefu };
		const int NSEED = (int)(sizeof(seeds)/sizeof(seeds[0]));
		const int SBLK = 188;                      // 188 * 128 = 24064 frames/storm
		                                           // (matches the single-core storm gate's ~24000)
		static struct juno_ev evs[JUNO_MAXEV];
		int spass = 0, stot = 0; float sworst = 0;
		for (int si = 0; si < NSEED; ++si) {
			int total = SBLK * JS_NF;
			int nev = juno_storm_build(seeds[si], total, JS_SR, 0, evs, JUNO_MAXEV);
			Broadcast_patch(0);                    // identical cold start everywhere
			int ei = 0, ok = 1; float md = 0;
			for (int b = 0; b < SBLK && ok; ++b) {
				int bend = (b + 1) * JS_NF;
				while (ei < nev && evs[ei].time < bend) BroadcastEvent(&evs[ei++]);
				ok &= CompareOneBlock(&md);
			}
			if (md > sworst) sworst = md;
			++stot; if (ok) ++spass;
			log->Write("split", LogNotice,
				"storm %08x: %s over %d blocks, %d events (max|diff| = %u ppb)",
				seeds[si], ok ? "== MATCH" : "!! DIFF", SBLK, nev,
				(unsigned)(md * 1000000000.0f));
		}
		log->Write("split", LogNotice, "STORMS: %d/%d identical to single-core", spass, stot);

		// stop the workers
		for (int c = 1; c < JS_CORES; ++c) m_status[c] = ST_EXIT;
		DataSyncBarrier();

		m_pass = ppass + spass; m_total = ptot + stot;
		m_worstdiff = pworst > sworst ? pworst : sworst;
		log->Write("split", LogNotice,
			"MULTI-CORE RESULT: %d/%d scenarios identical to single-core "
			"(64 patches + %d storms; worst %u ppb)",
			m_pass, m_total, NSEED, (unsigned)(m_worstdiff * 1000000000.0f));
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
