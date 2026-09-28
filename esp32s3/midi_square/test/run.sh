#!/bin/sh
# Host gate: the real test must PASS and the tooth build must FAIL.
cd "$(dirname "$0")/.." || exit 1
O=${TMPDIR:-/tmp}
CF="-std=c99 -O2 -Wall -Imain"
cc $CF test/host_test.c main/msq_core.c -lm -o "$O/msq_test" || exit 1
cc $CF -DMSQ_TOOTH_NO_RUNNING_STATUS test/host_test.c main/msq_core.c -lm -o "$O/msq_tooth" || exit 1
"$O/msq_test"; r=$?
"$O/msq_tooth" > "$O/msq_tooth.log"; t=$?
tail -1 "$O/msq_tooth.log"
[ $t -ne 0 ] && echo "TOOTH BITES" || echo "TOOTH DOES NOT BITE -- gate untrusted"
[ $r -eq 0 ] && [ $t -ne 0 ]
