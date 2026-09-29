#!/bin/sh
# Host gate: the real test must PASS and the tooth build must FAIL.
cd "$(dirname "$0")/.." || exit 1
O=${TMPDIR:-/tmp}
CF="-std=c99 -O2 -Wall -Imain"
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
[ $r -eq 0 ] && [ $t -ne 0 ] && [ $t2 -ne 0 ]
