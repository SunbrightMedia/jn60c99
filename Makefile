# Build + test for the JUNO-60 C99 port.
CC      ?= cc
CFLAGS  ?= -std=c99 -O2 -Wall -Wextra -Wno-unused-parameter -fno-strict-aliasing
LDLIBS  ?= -lm

SRC     := $(wildcard src/*.c)
OBJ     := $(SRC:.c=.o)

.PHONY: all test clean
all: $(OBJ)

test: tests/test_helpers tests/test_voice_smoke tests/test_master_smoke
	./tests/test_helpers
	./tests/test_voice_smoke
	./tests/test_master_smoke

tests/test_helpers: tests/test_helpers.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_voice_smoke: tests/test_voice_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

tests/test_master_smoke: tests/test_master_smoke.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f $(OBJ) tests/test_helpers tests/test_voice_smoke tests/test_master_smoke tests/sound_test

# Faithful sound test: run our DSP forward from the live plugin's captured state.
sound: tests/sound_test.c $(SRC)
	gunzip -kf state_dump/state_t0.bin.gz
	$(CC) $(CFLAGS) -o tests/sound_test tests/sound_test.c $(SRC) $(LDLIBS)
	./tests/sound_test state_dump/state_t0.bin /tmp/juno_sound 96000

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
