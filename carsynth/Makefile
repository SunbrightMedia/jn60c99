# carsynth -- build from the repo root:  make -C carsynth
CC     ?= cc
CFLAGS  = -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -Wall -Wno-unused-function -Wno-misleading-indentation
INC     = -I../engine_b -Isrc -Igen
FX      = ../engine_b/eb_chorus.c ../engine_b/eb_delay.c ../engine_b/eb_reverb.c
ES      = src/es_math.c src/es_gas.c src/es_func.c src/es_engine.c src/es_synth.c src/es_fftconv.c src/es_presets.c
SRC     = src/car.c $(ES) $(FX)
DEPS    = $(SRC) $(wildcard src/*.h) gen/es_ir.h gen/car_fx_coefs.h

all: build/render_wav web/carsynth.html

build/render_wav: tools/render_wav.c $(DEPS)
	@mkdir -p build
	$(CC) $(CFLAGS) $(INC) -o $@ tools/render_wav.c $(SRC) -lm

web/car.wasm: $(DEPS) src/car_wasm.c ../jetsynth/src/jet_libc.c
	clang --target=wasm32 -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing \
	  -nostdlib -DJET_WASM -DES_NO_LIBM -I../jetsynth/wasm/include $(INC) \
	  -Wl,--no-entry -Wl,--export-dynamic -Wl,--initial-memory=33554432 -Wl,-z,stack-size=1048576 \
	  -o $@ src/car_wasm.c $(SRC) ../jetsynth/src/jet_libc.c

web/carsynth.html: web/index.template.html web/car.wasm
	python3 -c "import base64;t=open('web/index.template.html').read();w=base64.b64encode(open('web/car.wasm','rb').read()).decode();open('$@','w').write(t.replace('__WASM_B64__',w))"

clean:
	rm -rf build web/car.wasm
.PHONY: all clean
