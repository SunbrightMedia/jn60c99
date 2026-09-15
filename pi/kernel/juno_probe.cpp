//
// juno_probe.cpp — the bit-exact gate ON THE METAL.
//
// Renders the ORIGINAL JUNO port (src/, no levers, no compromises) on the
// bare-metal kernel at 48000 Hz and compares each patch's sample hash to the
// x86 host reference baked in below. The host reference IS the plugin's output
// (the x86 engine nulls EXACTLY 0 vs the plugin). So every "== MATCH" line is
// proof that the synth is bit-identical to the plugin on real ARM silicon.
//
#include <circle/logger.h>
#include <circle/alloc.h>

extern "C" {
#include "../probe/juno_probe_core.h"
// the factory bank, embedded by bank_blob.S (.incbin of truth/presetbankog1.bin)
extern const unsigned char juno_bank_blob[];
extern const unsigned char juno_bank_blob_end[];
}

// Host reference @ 48000 Hz, note 60 vel 105, 4000 frames — produced by
// pi/probe/host_ref.c and verified ARM-bit-exact under qemu-user. Regenerate
// both together if the rate or frame count changes.
struct Ref { int patch; unsigned long long hash; };
static const Ref REF[] = {
	{  0, 0x1830844881997e88ULL },
	{  5, 0x2558fb60254aa7f3ULL },
	{ 11, 0x4b9625fe72769a8bULL },
	{ 21, 0x628eeb14335f0b20ULL },
	{ 27, 0xa8bdd4933ec0d97fULL },
	{ 36, 0xc08e4247dc843b35ULL },
	{ 42, 0x17b0cf7afd4feff4ULL },
	{ 48, 0x8006dca4027b65e3ULL },
	{ 55, 0xb9473e4bcbd81b71ULL },
	{ 60, 0x6c76c2e3c41764a8ULL },
	{ 63, 0x10bda943e5ea2b8bULL },
	{  7, 0x39f57e8d318166feULL },
};
static const int NPAT = sizeof(REF) / sizeof(REF[0]);
static const int NFR  = 4000;
static const float SR = 48000.0f;

void run_juno_bitexact (void)
{
	CLogger *log = CLogger::Get ();
	int banklen = (int) (juno_bank_blob_end - juno_bank_blob);

	log->Write ("juno", LogNotice,
		    "ENGINE bit-exact gate: original port, 8 voices, no levers");
	log->Write ("juno", LogNotice,
		    "rate %.0f Hz, bank %d bytes, %d frames/patch, note 60 vel 105",
		    SR, banklen, NFR);

	float *buf = (float *) malloc (sizeof (float) * 2 * NFR);
	if (buf == 0) { log->Write ("juno", LogPanic, "probe: out of memory"); return; }

	int pass = 0;
	for (int i = 0; i < NPAT; ++i) {
		float pk = 0.0f;
		unsigned long long h = juno_probe_render_hash (
			juno_bank_blob, banklen, REF[i].patch,
			SR, 60, 105, NFR, buf, &pk);
		bool ok = (h == REF[i].hash);
		if (ok) ++pass;
		log->Write ("juno", LogNotice, "patch %2d  hash %016llx  pk %.6f  %s",
			    REF[i].patch, h, pk, ok ? "== MATCH" : "!! DIFF");
	}

	free (buf);

	log->Write ("juno", LogNotice,
		    "BIT-EXACT RESULT: %d/%d patches identical to the plugin", pass, NPAT);
	if (pass == NPAT)
		log->Write ("juno", LogNotice,
			    "FULL SYNTH BIT-EXACT ON BARE METAL — EXACT WAVEFORM MATCH");
	else
		log->Write ("juno", LogNotice,
			    "DIVERGENCE — the metal render is NOT bit-exact (see DIFF rows)");
}
