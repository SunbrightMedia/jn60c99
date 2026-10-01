#!/bin/sh
# Host gate: the real test must PASS and the tooth build must FAIL.
cd "$(dirname "$0")/.." || exit 1
O=${TMPDIR:-/tmp}
CF="-std=gnu99 -O2 -Wall -Imain"
cc $CF test/host_test.c main/msq_core.c -lm -o "$O/msq_test" || exit 1
cc $CF -DMSQ_TOOTH_NO_RUNNING_STATUS test/host_test.c main/msq_core.c -lm -o "$O/msq_tooth" || exit 1
cc $CF -DMSQ_TOOTH_FIXED_RELEASE test/host_test.c main/msq_core.c -lm -o "$O/msq_tooth2" || exit 1
"$O/msq_test"; r=$?
"$O/msq_tooth" > "$O/msq_tooth.log"; t=$?
tail -1 "$O/msq_tooth.log"
[ $t -ne 0 ] && echo "TOOTH 1 (running status) BITES" || echo "TOOTH 1 DOES NOT BITE -- gate untrusted"
"$O/msq_tooth2" > "$O/msq_tooth2.log"; t2=$?
grep FAIL "$O/msq_tooth2.log" | head -2
[ $t2 -ne 0 ] && echo "TOOTH 2 (release knob dead) BITES" || echo "TOOTH 2 DOES NOT BITE -- gate untrusted"
cc $CF -DMSQ_TOOTH_FIXED_ATTACK test/host_test.c main/msq_core.c -lm -o "$O/msq_tooth3" || exit 1
"$O/msq_tooth3" > "$O/msq_tooth3.log"; t3=$?
grep FAIL "$O/msq_tooth3.log" | head -2
[ $t3 -ne 0 ] && echo "TOOTH 3 (attack knob dead) BITES" || echo "TOOTH 3 DOES NOT BITE -- gate untrusted"
cc $CF -DMSQ_TOOTH_MONO test/host_test.c main/msq_core.c -lm -o "$O/msq_tooth4" || exit 1
"$O/msq_tooth4" > "$O/msq_tooth4.log"; t4=$?
grep FAIL "$O/msq_tooth4.log" | head -2
[ $t4 -ne 0 ] && echo "TOOTH 4 (mono allocator) BITES" || echo "TOOTH 4 DOES NOT BITE -- gate untrusted"
cc $CF test/ui_frames.c main/ui.c main/gfx.c main/panel.c main/msq_core.c -lm -o "$O/ui_frames" || exit 1
"$O/ui_frames" "$O/frames.txt"; u=$?
python3 test/frames_png.py "$O/frames.txt" "$O/frames.png" | head -1
cc $CF -DMSQ_TOOTH_NO_FOCUS_DEADBAND test/ui_frames.c main/ui.c main/gfx.c main/panel.c main/msq_core.c -lm -o "$O/ui_tooth" || exit 1
"$O/ui_tooth" "$O/frames_tooth.txt" > "$O/ui_tooth.log"; t5=$?
grep FAIL "$O/ui_tooth.log" | head -2
[ $t5 -ne 0 ] && echo "TOOTH 5 (no focus deadband) BITES" || echo "TOOTH 5 DOES NOT BITE -- gate untrusted"
cc $CF test/wave_crc.c main/msq_core.c -lm -o "$O/wave_crc" || exit 1
"$O/wave_crc" main/gen/msq_wave_check.h || exit 1
cc $CF test/render_equiv.c test/ref_render.c main/msq_core.c -lm -o "$O/req" || exit 1
"$O/req"; q=$?
cc $CF -DMSQ_TOOTH_RENDER test/render_equiv.c test/ref_render.c main/msq_core.c -lm -o "$O/req_tooth" || exit 1
"$O/req_tooth" > "$O/req_tooth.log"; t6=$?
tail -1 "$O/req_tooth.log"
[ $t6 -ne 0 ] && echo "TOOTH 6 (renderer drift) BITES" || echo "TOOTH 6 DOES NOT BITE -- gate untrusted"
cc $CF -DMSQ_TOOTH_NO_DIM test/ui_frames.c main/ui.c main/gfx.c main/panel.c main/msq_core.c -lm -o "$O/ui_tooth7" || exit 1
"$O/ui_tooth7" "$O/frames_tooth7.txt" > "$O/ui_tooth7.log"; t7=$?
grep FAIL "$O/ui_tooth7.log" | head -2
[ $t7 -ne 0 ] && echo "TOOTH 7 (screen never dims) BITES" || echo "TOOTH 7 DOES NOT BITE -- gate untrusted"
cc $CF -DMSQ_TOOTH_BAT_FLAT test/ui_frames.c main/ui.c main/gfx.c main/panel.c main/msq_core.c -lm -o "$O/ui_tooth8" || exit 1
"$O/ui_tooth8" "$O/frames_tooth8.txt" > "$O/ui_tooth8.log"; t8=$?
grep FAIL "$O/ui_tooth8.log" | head -2
[ $t8 -ne 0 ] && echo "TOOTH 8 (battery gauge frozen) BITES" || echo "TOOTH 8 DOES NOT BITE -- gate untrusted"
[ $t8 -ne 0 ] && [ $t7 -ne 0 ] && [ $q -eq 0 ] && [ $t6 -ne 0 ] && EB=../../engine_b
EBS="$EB/eb_master.c $EB/eb_master_in.c $EB/eb_master_out.c $EB/eb_delay.c $EB/eb_delay_t1.c $EB/eb_delay_t23.c $EB/eb_delay_t5.c $EB/eb_dly_t4.c $EB/eb_fx_e0.c $EB/eb_fx_e1.c $EB/eb_fx_e5.c $EB/eb_reverb.c $EB/eb_chorus.c $EB/eb_dsp.c"
OF="-m32 -msse2 -mfpmath=sse -std=gnu99 -O2 -ffp-contract=off -fno-strict-aliasing -w -Imain -I../../src -I$EB -DEB_NODELAY=1"
cc $OF test/out_test.c main/outstage.c main/fx.c main/msq_core.c $EBS -lm -o "$O/out_test" || exit 1
"$O/out_test"; og=$?
cc $OF -DMSQ_TOOTH_NO_LIMIT test/out_test.c main/outstage.c main/fx.c main/msq_core.c $EBS -lm -o "$O/out_tooth" || exit 1
"$O/out_tooth" > "$O/out_tooth.log"; t9=$?
grep FAIL "$O/out_tooth.log" | head -2
[ $t9 -ne 0 ] && echo "TOOTH 9 (no limiter) BITES" || echo "TOOTH 9 DOES NOT BITE -- gate untrusted"
[ $og -eq 0 ] && [ $t9 -ne 0 ] && [ $r -eq 0 ] && [ $t -ne 0 ] && [ $t2 -ne 0 ] && [ $t3 -ne 0 ] && [ $u -eq 0 ] && [ $t4 -ne 0 ] && [ $t5 -ne 0 ]
