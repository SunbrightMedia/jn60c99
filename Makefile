# Build + test for the JUNO-60 C99 port.
CC      ?= cc
CFLAGS  ?= -std=c99 -O2 -Wall -Wextra -Wno-unused-parameter -fno-strict-aliasing
LDLIBS  ?= -lm

SRC     := $(wildcard src/*.c)
OBJ     := $(SRC:.c=.o)

.PHONY: all test clean gui
all: $(OBJ)

# Shared library for the test GUI (gui/juno_gui.py via ctypes).
gui: libjuno.so
libjuno.so: gui/juno_bridge.c $(SRC)
	$(CC) $(CFLAGS) -shared -fPIC -o $@ $^ $(LDLIBS)

# Windows DLL for the GUI (cross-compile with mingw-w64, or native MinGW).
# -static: no MinGW runtime DLLs needed; imports only KERNEL32 + msvcrt.
# A prebuilt juno.dll is committed so Windows users can run the GUI directly.
CC_WIN ?= x86_64-w64-mingw32-gcc
dll: juno.dll
juno.dll: gui/juno_bridge.c $(SRC)
	$(CC_WIN) $(CFLAGS) -shared -static -o $@ $^ $(LDLIBS)

test: tests/test_helpers tests/test_voice_smoke tests/test_master_smoke tests/test_apply_golden tests/test_poly_consistency tests/test_delay_recall tests/test_reverb_recall tests/test_denormal tests/test_note_path
	./tests/test_helpers
	./tests/test_voice_smoke
	./tests/test_master_smoke
	./tests/test_apply_golden
	./tests/test_poly_consistency
	./tests/test_delay_recall
	./tests/test_reverb_recall
	./tests/test_denormal
	./tests/test_note_path

tests/test_helpers: tests/test_helpers.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_voice_smoke: tests/test_voice_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_master_smoke: tests/test_master_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_apply_golden: tests/test_apply_golden.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_poly_consistency: tests/test_poly_consistency.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_delay_recall: tests/test_delay_recall.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_reverb_recall: tests/test_reverb_recall.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f $(OBJ) tests/test_helpers tests/test_voice_smoke tests/test_master_smoke \
	      tests/test_apply_golden tests/test_poly_consistency tests/test_delay_recall tests/test_reverb_recall tests/test_denormal tests/test_note_path

# Validate the port's init against the live-plugin state dump (state_dump/).
validate: tests/validate_state.c $(SRC)
	gunzip -kf state_dump/state_t0.bin.gz state_dump/state_t1.bin.gz
	@python3 -c "import re;\
r=set();\
[r.update(int(m) for m in re.findall(r'a1, ?(\d+)\)',open(f).read())) for f in ('src/voice_render.c','src/master_render.c')];\
[r.update(int(m) for m in re.findall(r'a1 \+ (\d+)\b',open(f).read())) for f in ('src/voice_render.c','src/master_render.c')];\
print('\n'.join(str(o) for o in sorted(o for o in r if 0<o<=12058620)))" > state_dump/.dspreads.txt
	$(CC) $(CFLAGS) -o tests/validate_state tests/validate_state.c $(SRC) $(LDLIBS)
	./tests/validate_state state_dump/state_t0.bin state_dump/state_t1.bin state_dump/.dspreads.txt

tests/test_denormal: tests/test_denormal.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_note_path: tests/test_note_path.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)
