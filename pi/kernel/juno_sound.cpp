//
// juno_sound.cpp — real-time audio glue (PLAY mode), driven by the fork-join.
//
// The I2S DRIVER IS CIRCLE'S (CI2SSoundBaseDevice: the PCM peripheral, DMA,
// clocking — the same proven driver MiniDexed uses on this SoC). We write only
// the callback below.
//
// Core 0's GetChunk DRIVES THE FORK-JOIN: it asks CJunoForkJoin for one DMA
// block, which kicks worker cores 1-3 (voices 2-7), renders core 0's own voices
// 0-1 + master, and returns interleaved stereo. That fork-join is the SAME unit
// the split gate proves bit-identical to the single-core juno_gui_render on 4
// emulated cores (pi/kernel/juno_split.cpp), and juno_gui_render is what the
// bit-exact gate proved byte-identical to the plugin. So the 4-core audio here
// is the plugin's audio. Only silicon can exercise the physical I2S (QEMU has
// no I2S peripheral); the numeric proof is the gate's job, not this file's.
//
#include "juno_forkjoin.h"
#include <circle/sound/i2ssoundbasedevice.h>
#include <circle/interrupt.h>
#include <circle/multicore.h>
#include <circle/memory.h>
#include <circle/logger.h>
#include <circle/alloc.h>
#include <circle/timer.h>

extern "C" {
void juno_enable_hw_ftz (void);
}
int   juno_silence_check (CJunoForkJoin *fork);        // juno_silence.cpp
void *juno_panel_create (void);                        // juno_panel.cpp
void  juno_panel_poll (void *panel, CJunoForkJoin *fork);
void *juno_midi_create (CJunoForkJoin *fork);          // juno_midi.cpp (parser + sink)
void  juno_midi_feed (void *parser, const unsigned char *bytes, unsigned n);

#define JS_RATE   48000
#define JS_CHUNK  2048           // I2S DMA chunk, in words (frames*channels)

class CJunoSound : public CI2SSoundBaseDevice
{
public:
	CJunoSound (CInterruptSystem *pInterrupt, CJunoForkJoin *fork, void *panel)
	:	CI2SSoundBaseDevice (pInterrupt, JS_RATE, JS_CHUNK),
		m_fork (fork), m_panel (panel), m_scale (0.0f), m_scratch (0), m_demoBlk (0) {}

	boolean Setup (void)
	{
		m_scale   = (float) GetRangeMax ();
		m_scratch = (float *) malloc (sizeof (float) * JS_CHUNK);   // >= 2*frames
		return m_scratch != 0;
	}

	// Circle calls this on core 0 (I2S IRQ) to fill one DMA block. nChunkSize is
	// a WORD count (one word per channel). We poll the panel at the block boundary
	// (no re-entrancy vs the render), render frames = nChunkSize/channels through
	// the 4-core fork-join, and scale each float sample into the hw range.
#ifndef JUNO_NO_DEMO
	// Boot demo: prove first-power-on makes sound with NO input. On the boot
	// patch, strum an A-major chord up (A4 C#5 E5 A5), then a fast re-strum
	// (trill), then release — all through the proven fork-join. One shot; the
	// panel takes over after. Disable in production with -DJUNO_NO_DEMO.
	// Blocks are ~21.3 ms (1024 frames @ 48 kHz).
	void RunDemo (void)
	{
		if (m_demoBlk == 0xFFFFFFFFu) return;          // finished
		static const struct { unsigned blk; int note; int on; } D[] = {
			{  2, 69, 1}, {  5, 73, 1}, {  8, 76, 1}, { 11, 81, 1}, // strum up
			{ 34, 69, 0}, { 34, 73, 0}, { 34, 76, 0}, { 34, 81, 0}, // release
			{ 36, 69, 1}, { 37, 73, 1}, { 38, 76, 1}, { 39, 81, 1}, // trill re-strum
			{ 80, 69, 0}, { 80, 73, 0}, { 80, 76, 0}, { 80, 81, 0}, // final release
		};
		unsigned b = m_demoBlk++;
		for (unsigned i = 0; i < sizeof (D) / sizeof (D[0]); ++i)
			if (D[i].blk == b) {
				if (D[i].on) m_fork->NoteOn (D[i].note, 100);
				else         m_fork->NoteOff (D[i].note);
			}
		if (b >= 82) m_demoBlk = 0xFFFFFFFFu;          // done — hand over to the panel
	}
#endif

	unsigned GetChunk (u32 *pBuffer, unsigned nChunkSize) override
	{
#ifndef JUNO_NO_DEMO
		RunDemo ();                                    // one-shot A-major boot flourish
#endif
		juno_panel_poll (m_panel, m_fork);             // keys/octave between blocks

		unsigned nCh    = GetHWTXChannels ();          // 2 (stereo)
		unsigned frames = nChunkSize / nCh;
		int lo = GetRangeMin (), hi = GetRangeMax ();

		m_fork->RenderBlock (m_scratch, (int) frames); // 4-core, bit-exact render

		for (unsigned f = 0; f < frames; ++f)
			for (unsigned ch = 0; ch < nCh; ++ch) {
				float s = m_scratch[2 * f + (ch & 1)];
				int v = (int) (s * m_scale);
				if (v > hi) v = hi; else if (v < lo) v = lo;
				*pBuffer++ = (u32) v;
			}
		return nChunkSize;
	}

private:
	CJunoForkJoin *m_fork;
	void  *m_panel;
	float  m_scale;
	float *m_scratch;
	unsigned m_demoBlk;            // boot-demo block counter (0xFFFFFFFF = done)
};

void run_juno_play (CInterruptSystem *pInterrupt)
{
	CLogger *log = CLogger::Get ();
	log->Write ("juno", LogNotice,
		    "PLAY mode: Circle I2S @ %d Hz, DMA chunk %d words, 4-core fork-join",
		    JS_RATE, JS_CHUNK);

	juno_enable_hw_ftz ();                   // core 0 audio FTZ (workers set their own)

	// The fork-join owns the 4 private engine copies and the worker cores.
	CJunoForkJoin *fork = new CJunoForkJoin (CMemorySystem::Get ());
	if (fork == 0 || !fork->Setup ((float) JS_RATE)) {
		log->Write ("juno", LogPanic, "PLAY: fork-join engine setup failed");
		return;
	}
	if (!fork->Initialize ()) {              // start worker cores 1-3 into Run()
		log->Write ("juno", LogPanic, "PLAY: CMultiCoreSupport init failed");
		return;
	}
	fork->BroadcastPatch (0);                // boot patch on every core copy

	// SHIP LAW: the image proves its own end state BEFORE the DAC can make a
	// sound. Quiet input on the boot bank must be SILENT, or we refuse to open
	// I2S (a stuck/self-oscillating idle would otherwise reach the speaker).
	if (!juno_silence_check (fork)) {
		log->Write ("juno", LogPanic,
			    "PLAY: SILENCE PROBE STUCK — refusing to start I2S");
		return;
	}

	void *panel = juno_panel_create ();      // GPIO keys + octave (unwired-safe)

	// MIDI parser is ready and wired to the fork's proven seams. The physical
	// TRANSPORT is the one silicon-only choice, fed via juno_midi_feed():
	//   - USB-MIDI: init CUSBHCIDevice, register the packet handler, feed its bytes;
	//   - or a 31250-baud UART (MIDI DIN) on a second serial device.
	// Left unfed here (no transport under QEMU); host-proven parser (midi_test).
	void *midi = juno_midi_create (fork);
	(void) midi;

	CJunoSound *snd = new CJunoSound (pInterrupt, fork, panel);
	if (snd == 0 || !snd->Setup ()) {
		log->Write ("juno", LogPanic, "PLAY: sound setup failed");
		return;
	}
	if (!snd->Start ()) {
		log->Write ("juno", LogPanic, "PLAY: I2S start failed");
		return;
	}
	log->Write ("juno", LogNotice,
		    "PLAY: I2S running — silence proven, boot demo + panel live, voices 0-1|2-3|4-5|6-7");

	// The DMA pulls chunks via IRQ on core 0; each pull polls the panel then
	// drives the fork-join. This loop only keeps the device alive and surfaces
	// the watchdog count (logging must stay OUT of the IRQ).
	unsigned seen = 0;
	for (;;) {
		snd->IsActive ();
		unsigned st = fork->StallCount ();
		if (st != seen) {
			log->Write ("juno", LogError,
				    "fork watchdog: %u worker stall(s) — glitch, core 0 did not hang", st);
			seen = st;
		}
		CTimer::SimpleMsDelay (100);
	}
}
