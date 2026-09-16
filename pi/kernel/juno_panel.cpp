//
// juno_panel.cpp — hand-panel input over the Pi's GPIO (keys + octave).
//
// Mirrors the S3 panel law (S3L_PANEL): pull-up, ACTIVE-LOW, debounced, and
// UNWIRED-SAFE — an unconnected pin reads high (pull-up) = not pressed, so a
// board with nothing wired makes no phantom notes. Circle's CGPIOPin is the
// driver; we only read levels and translate to note-on/off + octave shift.
//
// CONCURRENCY: Poll() is called at the TOP of GetChunk (the I2S block boundary),
// NOT from the main loop. GetChunk runs in the core-0 I2S IRQ and is where the
// engine copies are mutated by the render; delivering note events there too means
// events land between blocks with no re-entrancy against the render (the same
// "control between blocks" rule the fork-join and the S3 event chain follow).
//
// PIN MAP (BCM GPIO — wire the panel to these; all inputs, internal pull-up):
//   keys  C  C#  D  D#   -> GPIO 17, 27, 22, 23
//   octave down / up     -> GPIO 5, 6
//   patch  down / up     -> GPIO 24, 25
// POTS (CUTOFF, RESONANCE): the Pi has NO on-chip ADC. Analog pots need an
// external SPI ADC (e.g. MCP3008 on Circle's CSPIMaster); that read + the
// arm-by-stillness pickup law land when the ADC part is wired. Not built here.
//
#include "juno_forkjoin.h"
#include <circle/gpiopin.h>

#define P_KEYS    4
#define BASE_NOTE 60                 // middle C at octave shift 0
#define OCT_MIN   (-4)
#define OCT_MAX   4
#define DEBOUNCE  2                  // reads a level must hold before it commits

static const unsigned KEY_GPIO[P_KEYS] = { 17, 27, 22, 23 };
static const int      KEY_SEMI[P_KEYS] = {  0,  1,  2,  3 };   // semitones over C

// One debounced active-low input: Read()==0 is pressed; commit only after the
// same raw level is seen DEBOUNCE polls running, so contact bounce cannot
// double-trigger even at a short block period.
class CDebounced
{
public:
	CDebounced (unsigned nGPIO)
	: m_pin (nGPIO, GPIOModeInputPullUp), m_state (0), m_cand (0), m_n (0) {}

	// returns +1 on a press edge, -1 on a release edge, 0 otherwise
	int Update (void)
	{
		int raw = (m_pin.Read () == 0) ? 1 : 0;      // active-low -> 1 = pressed
		if (raw != m_cand) { m_cand = raw; m_n = 0; }
		else if (m_n < DEBOUNCE) {
			if (++m_n == DEBOUNCE && m_cand != m_state) {
				m_state = m_cand;
				return m_state ? +1 : -1;
			}
		}
		return 0;
	}
private:
	CGPIOPin m_pin;
	int m_state, m_cand, m_n;
};

class CJunoPanel
{
public:
	CJunoPanel (void)
	: m_octdn (5), m_octup (6), m_patchdn (24), m_patchup (25), m_oct (0), m_patch (0)
	{
		for (int i = 0; i < P_KEYS; ++i) { m_key[i] = new CDebounced (KEY_GPIO[i]); m_note[i] = -1; }
	}

	// Poll all inputs once and apply any changes to every engine copy (lockstep).
	void Poll (CJunoForkJoin *fork)
	{
		// octave buttons: one shift per press edge, clamped
		if (m_octdn.Update () > 0 && m_oct > OCT_MIN) --m_oct;
		if (m_octup.Update () > 0 && m_oct < OCT_MAX) ++m_oct;

		// patch buttons: step the current patch, WARM (held notes keep ringing)
		if (m_patchdn.Update () > 0 && m_patch > 0)  { --m_patch; fork->ApplyPatch (m_patch); }
		if (m_patchup.Update () > 0 && m_patch < 63) { ++m_patch; fork->ApplyPatch (m_patch); }

		// keys: press -> note-on at base + octave + semitone; release -> note-off
		for (int i = 0; i < P_KEYS; ++i) {
			int e = m_key[i]->Update ();
			if (e > 0) {
				int note = BASE_NOTE + m_oct * 12 + KEY_SEMI[i];
				if (note < 0) note = 0; else if (note > 127) note = 127;
				m_note[i] = note; fork->NoteOn (note, 100);
			} else if (e < 0) {
				if (m_note[i] >= 0) fork->NoteOff (m_note[i]);
				m_note[i] = -1;
			}
		}
	}

private:
	CDebounced *m_key[P_KEYS]; int m_note[P_KEYS];
	CDebounced  m_octdn, m_octup, m_patchdn, m_patchup;
	int m_oct, m_patch;
};

// Entry points used by the PLAY driver (juno_sound.cpp): one opaque panel + poll.
// Plain C++ linkage (both TUs are C++); an opaque void* keeps CJunoPanel private.
void *juno_panel_create (void) { return new CJunoPanel; }
void  juno_panel_poll (void *panel, CJunoForkJoin *fork)
{
	if (panel) ((CJunoPanel *) panel)->Poll (fork);
}
