//
// juno_midi.cpp — the MIDI parser (see juno_midi.h) + the fork-join sink.
//
// The parser is pure C++ (no Circle, no engine) so it is unit-tested on the host
// (pi/probe/midi_test.c). CForkMidiSink is the silicon sink: it maps decoded
// MIDI to the fork-join's proven broadcast seams. The physical transport
// (USB-MIDI or a 31250-baud UART) calls juno_midi bytes in; that wiring is the
// one silicon-only piece and is chosen on the board.
//
#include "juno_midi.h"

// ---- the parser ---------------------------------------------------------- //

void CJunoMidiParser::Feed (u8 byte)
{
	if (byte & 0x80) {                           // a status byte
		if (byte >= 0xF8) return;                // system real-time: ignore, keep status
		if (byte >= 0xF0) { m_status = 0; m_ndata = 0; return; }  // system common: drop status
		m_status = byte;                         // channel voice message
		m_ndata  = 0;
		u8 type  = byte & 0xF0;
		m_expect = (type == 0xC0 || type == 0xD0) ? 1 : 2;   // PC/aftertouch = 1 data byte
		return;
	}
	// a data byte
	if (m_status == 0) return;                    // no status yet — ignore
	if (m_ndata < 2) m_data[m_ndata++] = byte;
	if (m_ndata >= m_expect) { Dispatch (); m_ndata = 0; }   // running status: keep m_status
}

void CJunoMidiParser::Dispatch (void)
{
	int type = m_status & 0xF0;
	switch (type) {
	case 0x90:                                    // note on (vel 0 = note off)
		if (m_data[1] == 0) m_sink->NoteOff (m_data[0]);
		else                m_sink->NoteOn  (m_data[0], m_data[1]);
		break;
	case 0x80:                                    // note off
		m_sink->NoteOff (m_data[0]);
		break;
	case 0xB0:                                    // control change
		if (m_data[0] == 123 || m_data[0] == 120) m_sink->NoteOff (-1);  // all notes/sound off
		else m_sink->Control (m_data[0], m_data[1]);
		break;
	case 0xC0:                                    // program change (warm patch)
		m_sink->Program (m_data[0] & 63);
		break;
	default:                                      // 0xA0 poly AT, 0xD0 chan AT, 0xE0 bend: no seam
		break;
	}
}

// ---- the silicon sink: drive the fork-join ------------------------------- //
// (compiled for the kernel; the host test uses its own recording sink instead.)
#ifndef JUNO_MIDI_HOST_TEST
#include "juno_forkjoin.h"

// VCF cutoff / resonance host-param indices (from the engine's param table).
#define HP_CUTOFF     10
#define HP_RESONANCE  12

class CForkMidiSink : public IJunoMidiSink
{
public:
	explicit CForkMidiSink (CJunoForkJoin *fork) : m_fork (fork) {}
	void NoteOn (int n, int v) override  { m_fork->NoteOn (n, v); }
	void NoteOff (int n) override        { m_fork->NoteOff (n); }
	void Program (int idx) override      { m_fork->ApplyPatch (idx); }
	void Control (int cc, int value) override
	{
		int p = value * 255 / 127;                // MIDI 7-bit -> engine 0..255
		if (cc == 74) m_fork->HostSet (HP_CUTOFF, p);
		else if (cc == 71) m_fork->HostSet (HP_RESONANCE, p);
	}
private:
	CJunoForkJoin *m_fork;
};

// Opaque handles for the PLAY driver. The transport feeds bytes via juno_midi_feed.
void *juno_midi_create (CJunoForkJoin *fork)
{
	CForkMidiSink *sink = new CForkMidiSink (fork);
	return new CJunoMidiParser (sink);
}
void juno_midi_feed (void *parser, const unsigned char *bytes, unsigned n)
{
	if (parser) ((CJunoMidiParser *) parser)->FeedBuffer (bytes, n);
}
#endif
