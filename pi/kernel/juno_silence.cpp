//
// juno_silence.cpp — the SILENCE PROBE (SHIP LAW).
//
// "never validate by ear" applies to the live layer too. Before the DAC opens,
// the firmware must PROVE its own end state: quiet input (no notes held) on the
// shipped bank must give SILENT output. A non-silent idle means a stuck voice, a
// self-oscillating filter, or a DC offset — the class of fault the user's ears
// used to catch on the S3. Here the firmware catches it, logs a SIL: line with
// per-voice peaks, and a STUCK verdict blocks the flash.
//
// The probe renders through the SAME fork-join the audio path uses, so it needs
// no I2S and runs under QEMU (proving the mechanism) AND on silicon (proving the
// shipped image is safe before sound is possible).
//
#include "juno_forkjoin.h"
#include <circle/logger.h>

// Silence is NOT digital zero. The plugin's own idle output has a small, steady
// noise floor (the JUNO chorus/BBD): measured on the x86 engine (== the plugin,
// bit-exact) the no-note floor is 0..0.00081 across all 64 factory patches
// (~ -62 dBFS), boot patch 0 = 0.00049. That floor is CORRECT output, not a
// fault. The threshold sits well above it and far below any audible stuck voice
// (a real note peaks ~0.03..0.2), so it accepts the genuine floor and still
// catches the S3-class defect (a stuck/self-oscillating voice reaching the DAC).
#define SIL_EPS  0.01f              // -40 dBFS: > 12x the idle floor, << a note
#define SIL_FR   12000             // 0.25 s @ 48 kHz — long enough for slow build-up
#define SIL_CHUNK 1024

// Measure the current (no-note) output of the fork-join. Returns 1 = SILENT,
// 0 = STUCK. Logs the SIL: line either way (the image's own proof).
int juno_silence_check (CJunoForkJoin *fork)
{
	CLogger *log = CLogger::Get ();

#ifdef JUNO_SIL_STUCK
	// SEEN-TO-FAIL: hold a note so the idle is NOT silent; the probe must catch it.
	fork->NoteOn (60, 100);
	log->Write ("sil", LogWarning, "JUNO_SIL_STUCK set — injecting a held note");
#endif

	static float buf[2 * SIL_CHUNK];
	float vpk[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
	float outpk = 0.0f;

	int done = 0;
	while (done < SIL_FR) {
		int n = SIL_FR - done; if (n > SIL_CHUNK) n = SIL_CHUNK;
		fork->RenderBlock (buf, n, vpk);
		for (int i = 0; i < 2 * n; ++i) {
			float a = buf[i] < 0 ? -buf[i] : buf[i];
			if (a > outpk) outpk = a;
		}
		done += n;
	}

	int worst = 0; for (int v = 1; v < 8; ++v) if (vpk[v] > vpk[worst]) worst = v;
	int silent = outpk <= SIL_EPS;

	log->Write ("sil", LogNotice,
		"SIL: out_peak=%.7f worst_voice=%d (%.7f) -> %s",
		outpk, worst, vpk[worst], silent ? "SILENT" : "STUCK");
	log->Write ("sil", LogNotice,
		"SIL voices: %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f",
		vpk[0], vpk[1], vpk[2], vpk[3], vpk[4], vpk[5], vpk[6], vpk[7]);

	if (!silent)
		log->Write ("sil", LogError,
			"SILENCE PROBE: STUCK — idle bank is not silent; DAC MUST NOT OPEN");
	return silent;
}

// Standalone QEMU mode (JUNO_SILENCE): build a fork-join, load the boot bank,
// run the probe, halt. Proves the SHIP-LAW mechanism without I2S.
#include <circle/multicore.h>
#include <circle/memory.h>

void run_juno_silence (void)
{
	CLogger *log = CLogger::Get ();
	log->Write ("sil", LogNotice, "SILENCE-PROBE mode: boot bank, no notes, 4-core render");

	CJunoForkJoin *fork = new CJunoForkJoin (CMemorySystem::Get ());
	if (fork == 0 || !fork->Setup (48000.0f)) {
		log->Write ("sil", LogPanic, "silence: fork setup failed");
		return;
	}
	if (!fork->Initialize ()) {
		log->Write ("sil", LogPanic, "silence: CMultiCoreSupport init failed");
		return;
	}
	fork->BroadcastPatch (0);                 // the shipped boot patch, no notes

	int ok = juno_silence_check (fork);
	fork->Stop ();

	log->Write ("sil", LogNotice, "SILENCE PROBE RESULT: %s",
		    ok ? "SILENT — safe to open the DAC" : "STUCK — image unsafe");
	log->Write ("sil", LogNotice, "SILENCE PROBE COMPLETE");
}
