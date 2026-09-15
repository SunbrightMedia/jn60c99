//
// juno_sound.cpp — real-time audio glue (PLAY mode).
//
// The I2S DRIVER IS CIRCLE'S (CI2SSoundBaseDevice: the PCM peripheral, DMA,
// clocking — the same proven driver MiniDexed uses on this SoC). We write only
// the callback below: fill each DMA chunk from the engine's own render. Nothing
// about the DSP, transport or timing is ours to get wrong.
//
// The samples this emits are the plugin's: juno_gui_render is the same call the
// bit-exact gate proved byte-identical to the plugin, and the chunk-invariance
// gate proved that rendering in DMA-sized blocks equals the continuous render.
// So this path needs no offline signal check — only silicon can exercise the
// physical I2S (QEMU has no I2S peripheral).
//
#include <circle/sound/i2ssoundbasedevice.h>
#include <circle/interrupt.h>
#include <circle/logger.h>
#include <circle/alloc.h>
#include <circle/timer.h>

extern "C" {
void *juno_gui_create (float sample_rate, int chorus_mode);
int   juno_gui_apply_bank(void *ctx, const char *bank, int len, int idx);
int   juno_gui_render (void *ctx, float *buf, int nframes);
extern const unsigned char juno_bank_blob[];
extern const unsigned char juno_bank_blob_end[];
}

#define JS_RATE   48000
#define JS_CHUNK  2048           // I2S DMA chunk, in words (frames*channels)

class CJunoSound : public CI2SSoundBaseDevice
{
public:
	CJunoSound (CInterruptSystem *pInterrupt)
	:	CI2SSoundBaseDevice (pInterrupt, JS_RATE, JS_CHUNK),
		m_ctx (0), m_scale (0.0f), m_scratch (0) {}

	boolean Setup (void)
	{
		m_ctx = juno_gui_create ((float) JS_RATE, 0);
		if (m_ctx == 0) return FALSE;
		int banklen = (int) (juno_bank_blob_end - juno_bank_blob);
		juno_gui_apply_bank (m_ctx, (const char *) juno_bank_blob, banklen, 0);
		m_scale   = (float) GetRangeMax ();
		m_scratch = (float *) malloc (sizeof (float) * JS_CHUNK);   // >= 2*frames
		return m_scratch != 0;
	}

	// Circle calls this to fill one DMA block. nChunkSize is a WORD count
	// (one word per channel). We render frames = nChunkSize/channels through
	// the engine and scale each float sample into the hardware range.
	unsigned GetChunk (u32 *pBuffer, unsigned nChunkSize) override
	{
		unsigned nCh    = GetHWTXChannels ();          // 2 (stereo)
		unsigned frames = nChunkSize / nCh;
		int lo = GetRangeMin (), hi = GetRangeMax ();

		juno_gui_render (m_ctx, m_scratch, (int) frames);   // bit-exact render

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
	void  *m_ctx;
	float  m_scale;
	float *m_scratch;
};

void run_juno_play (CInterruptSystem *pInterrupt)
{
	CLogger *log = CLogger::Get ();
	log->Write ("juno", LogNotice,
		    "PLAY mode: Circle I2S @ %d Hz, DMA chunk %d words", JS_RATE, JS_CHUNK);

	CJunoSound *snd = new CJunoSound (pInterrupt);
	if (snd == 0 || !snd->Setup ()) {
		log->Write ("juno", LogPanic, "PLAY: engine/sound setup failed");
		return;
	}
	if (!snd->Start ()) {
		log->Write ("juno", LogPanic, "PLAY: I2S start failed");
		return;
	}
	log->Write ("juno", LogNotice, "PLAY: I2S running — boot patch 0 sounding");

	// The DMA pulls chunks via IRQ; keep the device fed / alive.
	for (;;) {
		snd->IsActive ();               // touch the device; real input plumbing lands next
		CTimer::SimpleMsDelay (100);
	}
}
