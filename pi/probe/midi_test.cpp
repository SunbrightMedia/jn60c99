// midi_test.cpp — host proof of the MIDI parser (juno_midi.cpp), no hardware.
// Compile with -DJUNO_MIDI_HOST_TEST so the Circle fork-sink is excluded, feed
// byte streams through the parser, and check the decoded calls. Running status,
// vel-0 = note off, program clamp, CC map, all-notes-off, and ignored messages.
#include "../kernel/juno_midi.h"
#include <stdio.h>
#include <string.h>

struct Rec { char kind; int a, b; };
class RecSink : public IJunoMidiSink {
public:
	Rec ev[64]; int n;
	RecSink() : n(0) {}
	void NoteOn (int note,int vel) override { put('N',note,vel); }
	void NoteOff(int note)         override { put('F',note,0);   }
	void Program(int idx)          override { put('P',idx,0);    }
	void Control(int cc,int value) override { put('C',cc,value); }
	void put(char k,int a,int b){ if(n<64){ev[n].kind=k;ev[n].a=a;ev[n].b=b;++n;} }
};

static int fails = 0;
static void expect(const char *name, int got, int want) {
	if (got != want) { printf("FAIL %s: got %d want %d\n", name, got, want); ++fails; }
}

int main(void)
{
	{ // 1. note on
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0x90,0x3C,0x64}; p.FeedBuffer(b,3);
		expect("noteon n",s.n,1); expect("noteon k",s.ev[0].kind,'N');
		expect("noteon note",s.ev[0].a,60); expect("noteon vel",s.ev[0].b,100);
	}
	{ // 2. note on with velocity 0 == note off
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0x90,0x3C,0x00}; p.FeedBuffer(b,3);
		expect("vel0 k",s.ev[0].kind,'F'); expect("vel0 note",s.ev[0].a,60);
	}
	{ // 3. running status: two notes after one 0x90
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0x90,0x3C,0x64, 0x40,0x64}; p.FeedBuffer(b,5);
		expect("run n",s.n,2);
		expect("run1 note",s.ev[0].a,60); expect("run2 note",s.ev[1].a,64);
		expect("run2 k",s.ev[1].kind,'N');
	}
	{ // 4. program change, clamped to 0..63
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0xC0,0x7F}; p.FeedBuffer(b,2);
		expect("pc k",s.ev[0].kind,'P'); expect("pc idx",s.ev[0].a,63);
	}
	{ // 5. CC74 cutoff passes through raw
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0xB0,0x4A,0x7F}; p.FeedBuffer(b,3);
		expect("cc k",s.ev[0].kind,'C'); expect("cc num",s.ev[0].a,74); expect("cc val",s.ev[0].b,127);
	}
	{ // 6. CC123 all-notes-off -> NoteOff(-1)
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0xB0,0x7B,0x00}; p.FeedBuffer(b,3);
		expect("anoff k",s.ev[0].kind,'F'); expect("anoff note",s.ev[0].a,-1);
	}
	{ // 7. pitch bend is ignored (no seam)
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0xE0,0x00,0x40}; p.FeedBuffer(b,3);
		expect("bend ignored",s.n,0);
	}
	{ // 8. real-time byte (clock 0xF8) mid-message does NOT break running status
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0x90,0xF8,0x3C,0x64}; p.FeedBuffer(b,4);
		expect("rt n",s.n,1); expect("rt note",s.ev[0].a,60); expect("rt vel",s.ev[0].b,100);
	}
	{ // 9. note off status
		RecSink s; CJunoMidiParser p(&s);
		u8 b[]={0x80,0x3C,0x40}; p.FeedBuffer(b,3);
		expect("off k",s.ev[0].kind,'F'); expect("off note",s.ev[0].a,60);
	}

	if (fails == 0) { printf("MIDI PARSER OK (9 cases, running status + vel0 + PC clamp + CC + all-off + bend ignored)\n"); return 0; }
	printf("MIDI PARSER FAILED (%d)\n", fails); return 1;
}
