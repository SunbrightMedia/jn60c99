//
// juno_split.cpp — the self-checking GATE for the shared fork-join.
//
// It drives CJunoForkJoin (juno_forkjoin.cpp — the SAME unit the PLAY I2S path
// runs) on Circle's 4 emulated cores and compares its output, block for block,
// to a single-core reference (juno_gui_render — the proven bit-exact audio path).
// A green result under QEMU's 4-core emulation proves the REAL concurrency
// (barrier + memory ordering + per-core copies), across:
//   - all 64 factory patches (sustained 8-note chord);
//   - the 5 seeded full-surface STORMS the single-core bit-exact gate uses;
//   - the DMA block length PLAY actually renders (RenderBlock == single-core at
//     the I2S chunk size, not only at the 128-frame gate block).
//
#include "juno_forkjoin.h"
#include <circle/logger.h>
#include <circle/synchronize.h>

extern "C" {
#include "../probe/juno_probe_core.h"       // struct juno_ev, juno_storm_build/fire
void *juno_gui_create (float, int);
void  juno_gui_reinit (void *, float, int);
int   juno_gui_apply_bank (void *, const char *, int, int);
void  juno_gui_note_on (void *, int, int);
int   juno_gui_render (void *, float *, int);
extern const unsigned char juno_bank_blob[];
extern const unsigned char juno_bank_blob_end[];
}

#define JS_SR      48000.0f
#define JS_NF      128                       // gate block (fine event granularity)
#define JS_DMA     1024                      // == PLAY I2S chunk frames
#define JS_MAXTEST 2048                      // largest block the gate compares

class CJunoSplitGate
{
public:
	CJunoSplitGate (CJunoForkJoin *fork)
	: m_fork (fork), m_ref (0), m_banklen (0) {}

	boolean Setup (void)
	{
		m_banklen = (int) (juno_bank_blob_end - juno_bank_blob);
		m_ref = juno_gui_create (JS_SR, 0);      // the single-core reference
		return m_ref != 0;
	}

	void Run (void)
	{
		CLogger *log = CLogger::Get ();
		log->Write ("split", LogNotice,
			"MULTI-CORE split gate: 4 cores, voices 0-1|2-3|4-5|6-7, barrier fork-join");

		int ppass = 0, spass = 0, dpass = 0; float worst = 0;

		// ---- Phase 1: ALL 64 factory patches, sustained 8-note chord --------
		const int chord[8] = { 45, 48, 52, 55, 60, 64, 67, 72 };
		const int PBLK = 16;
		for (int p = 0; p < 64; ++p) {
			GPatch (p);
			for (int k = 0; k < 8; ++k) GNoteOn (chord[k], 100);
			int ok = 1; float md = 0;
			for (int b = 0; b < PBLK && ok; ++b) ok &= CompareBlock (JS_NF, &md);
			if (md > worst) worst = md;
			if (ok) ++ppass;
			else log->Write ("split", LogNotice,
				"patch %2d: !! DIFF (max|diff| = %u ppb)", p, ppb (md));
			if (ok && (p & 7) == 7)
				log->Write ("split", LogNotice,
					"  ..patches %d/64 done, all MATCH (worst %u ppb)", p + 1, ppb (worst));
		}
		log->Write ("split", LogNotice, "PATCHES: %d/64 identical to single-core", ppass);

		// ---- Phase 2: seeded STORMS across the WHOLE surface ----------------
		static const unsigned seeds[] =
			{ 0x0badc0deu, 0x00005eedu, 0x00c0ffeeu, 0x0a11ce99u, 0xdeadbeefu };
		const int NSEED = (int) (sizeof (seeds) / sizeof (seeds[0]));
		const int SBLK = 188;                    // 188 * 128 = 24064 frames/storm
		static struct juno_ev evs[JUNO_MAXEV];
		for (int si = 0; si < NSEED; ++si) {
			int total = SBLK * JS_NF;
			int nev = juno_storm_build (seeds[si], total, JS_SR, 0, evs, JUNO_MAXEV);
			GPatch (0);                          // identical cold start everywhere
			int ei = 0, ok = 1; float md = 0;
			for (int b = 0; b < SBLK && ok; ++b) {
				int bend = (b + 1) * JS_NF;
				while (ei < nev && evs[ei].time < bend) GEvent (&evs[ei++]);
				ok &= CompareBlock (JS_NF, &md);
			}
			if (md > worst) worst = md;
			if (ok) ++spass;
			log->Write ("split", LogNotice,
				"storm %08x: %s over %d blocks, %d events (max|diff| = %u ppb)",
				seeds[si], ok ? "== MATCH" : "!! DIFF", SBLK, nev, ppb (md));
		}
		log->Write ("split", LogNotice, "STORMS: %d/%d identical to single-core", spass, NSEED);

		// ---- Phase 3: the block SIZES PLAY may hand us ----------------------
		// PLAY's GetChunk asks for a DMA block; Circle may hand any size. Prove
		// RenderBlock equals single-core at the deployed 1024, at 1536 (> MAXBLK,
		// so the internal sub-block loop must stitch two fork-joins seamlessly),
		// and at a small 100. Covers the sub-block stitching, not only 128/1024.
		const int sizes[]  = { JS_DMA, 1536, 100 };
		const int NSZ = (int) (sizeof (sizes) / sizeof (sizes[0]));
		const int dpatch[] = { 0, 27, 48 };
		const int NDP = (int) (sizeof (dpatch) / sizeof (dpatch[0]));
		int dtot = 0;
		for (int i = 0; i < NDP; ++i)
			for (int z = 0; z < NSZ; ++z) {
				GPatch (dpatch[i]);
				for (int k = 0; k < 8; ++k) GNoteOn (chord[k], 100);
				int ok = 1; float md = 0;
				for (int b = 0; b < 3 && ok; ++b) ok &= CompareBlock (sizes[z], &md);
				if (md > worst) worst = md;
				++dtot; if (ok) ++dpass;
				else log->Write ("split", LogNotice,
					"block patch %2d size %d: !! DIFF (max|diff| = %u ppb)",
					dpatch[i], sizes[z], ppb (md));
			}
		log->Write ("split", LogNotice,
			"BLOCK-SIZE {1024,1536,100}: %d/%d identical to single-core", dpass, dtot);

		// ---- Phase 4: voice STEALING ---------------------------------------
		// 13 distinct notes onto 8 physical voices forces the allocator to steal.
		// Every copy + the reference get the identical note stream, so stealing
		// must land on the same voices in lockstep — the class where a harness
		// bug once hid (split_battery). Held long, many blocks, to expose drift.
		const int steal[13] = { 40,44,47,50,53,55,58,60,62,64,67,69,72 };
		const int spatch[] = { 0, 40, 63 };
		const int NSP = (int) (sizeof (spatch) / sizeof (spatch[0]));
		int stpass = 0;
		for (int i = 0; i < NSP; ++i) {
			GPatch (spatch[i]);
			for (int k = 0; k < 13; ++k) GNoteOn (steal[k], 100);   // > 8 → steal
			int ok = 1; float md = 0;
			for (int b = 0; b < 24 && ok; ++b) ok &= CompareBlock (JS_NF, &md);
			if (md > worst) worst = md;
			if (ok) ++stpass;
			else log->Write ("split", LogNotice,
				"steal patch %2d: !! DIFF (max|diff| = %u ppb)", spatch[i], ppb (md));
		}
		log->Write ("split", LogNotice,
			"VOICE-STEAL (13 notes): %d/%d identical to single-core", stpass, NSP);

		m_fork->Stop ();

		int pass  = ppass + spass + dpass + stpass;
		int total = 64 + NSEED + dtot + NSP;
		log->Write ("split", LogNotice,
			"MULTI-CORE RESULT: %d/%d scenarios identical to single-core "
			"(64 patches + %d storms + %d block-size + %d voice-steal; worst %u ppb)",
			pass, total, NSEED, dtot, NSP, ppb (worst));
		if (pass == total)
			log->Write ("split", LogNotice,
			  "SPLIT BIT-EXACT ON 4 EMULATED CORES — barrier + per-core copies proven");
		else
			log->Write ("split", LogNotice, "SPLIT DIVERGED — concurrency defect (see DIFF rows)");
		log->Write ("split", LogNotice, "SPLIT GATE COMPLETE");
	}

private:
	static unsigned ppb (float d) { return (unsigned) (d * 1000000000.0f); }

	// broadcast to the fork's 4 copies AND mirror to the single-core reference
	void GPatch (int p)
	{
		m_fork->BroadcastPatch (p);
		juno_gui_reinit (m_ref, JS_SR, 0);
		juno_gui_apply_bank (m_ref, (const char *) juno_bank_blob, m_banklen, p);
	}
	void GNoteOn (int n, int v) { m_fork->NoteOn (n, v); juno_gui_note_on (m_ref, n, v); }
	void GEvent (const struct juno_ev *e)
	{
		m_fork->FireEvent (e);
		juno_storm_fire (m_ref, juno_bank_blob, m_banklen, e);
	}

	// render one `frames`-frame block both ways; accumulate max|diff|; 1 if equal
	int CompareBlock (int frames, float *md)
	{
		static float refblk[2 * JS_MAXTEST];
		static float splblk[2 * JS_MAXTEST];
		juno_gui_render (m_ref, refblk, frames);     // single-core reference
		m_fork->RenderBlock (splblk, frames);        // the real 4-core split
		int ok = 1;
		for (int n = 0; n < 2 * frames; ++n) {
			float d = refblk[n] - splblk[n]; if (d < 0) d = -d;
			if (d > *md) *md = d;
			if (d != 0.0f) ok = 0;
		}
		return ok;
	}

	CJunoForkJoin *m_fork;
	void *m_ref;
	int   m_banklen;
};

void run_juno_split (void)
{
	CLogger *log = CLogger::Get ();
	CJunoForkJoin *fork = new CJunoForkJoin (CMemorySystem::Get ());
	CJunoSplitGate *gate = new CJunoSplitGate (fork);
	if (fork == 0 || gate == 0 || !fork->Setup (JS_SR) || !gate->Setup ()) {
		log->Write ("split", LogPanic, "split: engine setup failed (out of memory?)");
		return;
	}
	if (!fork->Initialize ()) {              // starts the secondary cores into Run()
		log->Write ("split", LogPanic, "split: CMultiCoreSupport init failed");
		return;
	}
	gate->Run ();                            // core 0 drives the gate; workers help
	log->Write ("split", LogNotice, "PROBE COMPLETE — halting.");
}
