#!/bin/bash
# Regenerate main/gen/msq_fx.h from the proven recall and prove the firmware FX
# path against it. Run from anywhere. Needs gcc-multilib (-m32).
#   * fxgen is built 32-bit (-m32 -msse2 -mfpmath=sse): eb_master_state holds
#     ring POINTERS, so its layout is ILP32-specific, and the ESP32-S3 is ILP32.
#     The 64-bit build must give the same coefficient image and tables (checked).
#   * fx_gate: firmware path == recall path, bit for bit; the tooth build MUST fail.
set -e
cd "$(dirname "$0")/../../.."
O=${TMPDIR:-/tmp}
SRCS=$(ls src/*.c engine_b/*.c | grep -v -E "test_|engineb_stub")
FL="-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -w -Iesp32s3/midi_square/tools -Iesp32s3/midi_square/main -Itools/engineb/devboot -Isrc -Iengine_b -Iengine_b/dev"
M32="-m32 -msse2 -mfpmath=sse"
BANK=$(python3 -c "import sys;sys.path.insert(0,'tools/verify');import truth;truth.require();print(truth.BANK)")
cc $FL -o "$O/fxgen64" esp32s3/midi_square/tools/fxgen.c $SRCS -lm
cc $M32 $FL -o "$O/fxgen32" esp32s3/midi_square/tools/fxgen.c $SRCS -lm
"$O/fxgen64" "$BANK" "$O/msq_fx64.h" | tail -1
"$O/fxgen32" "$BANK" esp32s3/midi_square/main/gen/msq_fx.h | tail -3
if diff <(grep -v "STATE\|SEED\|{[0-9]*,0x" "$O/msq_fx64.h") <(grep -v "STATE\|SEED\|{[0-9]*,0x" esp32s3/midi_square/main/gen/msq_fx.h) >/dev/null
then echo "64-bit vs 32-bit recall: coefficient image and tables IDENTICAL"
else echo "FAIL: 64-bit and 32-bit recall disagree"; exit 1; fi
cc $M32 $FL -o "$O/fx_gate" esp32s3/midi_square/tools/fx_gate.c esp32s3/midi_square/main/fx.c esp32s3/midi_square/main/msq_core.c $SRCS -lm
cc $M32 $FL -DMSQ_FX_TOOTH -o "$O/fx_gate_tooth" esp32s3/midi_square/tools/fx_gate.c esp32s3/midi_square/main/fx.c esp32s3/midi_square/main/msq_core.c $SRCS -lm
"$O/fx_gate" "$BANK"
EB="engine_b/eb_master.c engine_b/eb_master_in.c engine_b/eb_master_out.c engine_b/eb_delay.c engine_b/eb_delay_t1.c engine_b/eb_delay_t23.c engine_b/eb_delay_t5.c engine_b/eb_dly_t4.c engine_b/eb_fx_e0.c engine_b/eb_fx_e1.c engine_b/eb_fx_e5.c engine_b/eb_reverb.c engine_b/eb_chorus.c engine_b/eb_dsp.c"
cc $M32 $FL -o "$O/fx_crc" esp32s3/midi_square/tools/fx_crc.c esp32s3/midi_square/main/fx.c $EB -lm
"$O/fx_crc" esp32s3/midi_square/main/gen/msq_fx_check.h
if "$O/fx_gate_tooth" "$BANK" > "$O/fx_tooth.log"; then echo "FX TOOTH DOES NOT BITE -- gate untrusted"; exit 1; fi
grep DIFF "$O/fx_tooth.log" | head -1; echo "FX TOOTH BITES"
