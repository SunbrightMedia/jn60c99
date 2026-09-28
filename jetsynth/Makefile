# jetsynth -- build from the repo root:  make -C jetsynth
CC     ?= cc
CFLAGS  = -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -Wall -Wno-unused-function
INC     = -I../engine_b -Isrc -Igen
FX      = ../engine_b/eb_chorus.c ../engine_b/eb_delay.c ../engine_b/eb_reverb.c
SRC     = src/jet.c src/jet_libc.c $(FX)
DEPS    = $(SRC) src/jet.h src/jet_math.h gen/jet_tables.h gen/jet_fx_coefs.h

all: build/render_wav build/test_fmodf web/jetsynth.html

build/render_wav: tools/render_wav.c $(DEPS)
	@mkdir -p build
	$(CC) $(CFLAGS) $(INC) -o $@ tools/render_wav.c $(SRC) -lm

build/test_fmodf: tests/test_fmodf.c src/jet_libc.c
	@mkdir -p build
	$(CC) $(CFLAGS) -o $@ tests/test_fmodf.c src/jet_libc.c -lm

# wasm32 with clang + wasm-ld, no emscripten, no libc
web/jet.wasm: $(DEPS) src/jet_wasm.c
	clang --target=wasm32 -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
	  -nostdlib -DJET_WASM -Iwasm/include $(INC) \
	  -Wl,--no-entry -Wl,--export-dynamic -Wl,--initial-memory=16777216 \
	  -o $@ src/jet_wasm.c $(SRC)

test: build/test_fmodf build/render_wav
	./build/test_fmodf
	./build/render_wav build/smoke.wav 3 throttle=0.8 space=0.5 >/dev/null

clean:
	rm -rf build web/jet.wasm
.PHONY: all test clean

# single self-contained page: wasm embedded as base64
web/jetsynth.html: web/index.template.html web/jet.wasm
	python3 -c "import base64,sys;t=open('web/index.template.html').read();w=base64.b64encode(open('web/jet.wasm','rb').read()).decode();open('$@','w').write(t.replace('__WASM_B64__',w))"
web: web/jetsynth.html
.PHONY: web
