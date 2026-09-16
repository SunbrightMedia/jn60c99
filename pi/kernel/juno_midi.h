//
// juno_midi.h — a small, PURE MIDI byte-stream parser (host-testable).
//
// The parser knows nothing about Circle or the engine: it consumes MIDI bytes
// (running-status aware) and calls an abstract sink. On silicon a sink drives
// the fork-join; in a host unit test a sink records the calls. So the parse
// logic is proven off-target, and only the physical transport (USB-MIDI or a
// 31250-baud UART) is silicon-only.
//
// Scope (uses the engine's PROVEN seams only):
//   Note On / Note Off (+velocity)      -> allocator (note on with vel 0 = off)
//   Program Change                      -> warm patch recall (0..63)
//   Control Change 74 / 71              -> VCF cutoff / resonance
//   Control Change 123                  -> all notes off
//   Pitch Bend, mod wheel, aftertouch   -> IGNORED: no verified live seam in the
//                                          engine (see docs / juno_apply.c)
//
#ifndef JUNO_MIDI_H
#define JUNO_MIDI_H

typedef unsigned char u8;

// What the parser emits. A real sink applies these to every engine copy; a test
// sink records them. Values are already decoded (note/vel/program/cc in range).
struct IJunoMidiSink
{
	virtual ~IJunoMidiSink (void) {}
	virtual void NoteOn (int note, int vel) = 0;
	virtual void NoteOff (int note) = 0;       // note < 0 => all notes off
	virtual void Program (int idx) = 0;        // warm patch change, 0..63
	virtual void Control (int cc, int value) = 0;  // raw CC (sink maps to params)
};

class CJunoMidiParser
{
public:
	explicit CJunoMidiParser (IJunoMidiSink *sink)
	: m_sink (sink), m_status (0), m_ndata (0), m_expect (0) {}

	void Feed (u8 byte);                        // one byte
	void FeedBuffer (const u8 *p, unsigned n) { for (unsigned i = 0; i < n; ++i) Feed (p[i]); }

private:
	void Dispatch (void);

	IJunoMidiSink *m_sink;
	u8  m_status;                               // running status (0 = none)
	u8  m_data[2];
	int m_ndata, m_expect;
};

#endif
