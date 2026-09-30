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
[ $r -eq 0 ] && [ $t -ne 0 ] && [ $t2 -ne 0 ] && [ $t3 -ne 0 ] && [ $u -eq 0 ] && [ $t4 -ne 0 ] && [ $t5 -ne 0 ]
