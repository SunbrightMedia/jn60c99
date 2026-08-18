#!/bin/sh
# teeth.sh -- plant each defect in juno_event.c and require the gate to CATCH it.
#
# A gate that has never gone red is an untested detector (playbook defect 1).
# This script is what makes "the O1 gate is green" mean anything: it first
# proves the gate FAILS on six specific defects, then that it PASSES clean.
#
# The teeth are applied with sed to a COPY. juno_event.c is never edited.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
CC=${CC:-cc}
CFLAGS="-std=c99 -Wall -Wextra -O1 -I$HERE"

tooth() {                       # tooth <n> <sed script> <what it breaks>
    n=$1; script=$2; what=$3
    sed "$script" "$HERE/juno_event.c" > "$TMP/j.c"
    if cmp -s "$TMP/j.c" "$HERE/juno_event.c"; then
        echo "TOOTH $n: *** THE PLANT DID NOT APPLY -- the sed matched nothing."
        echo "           A tooth that changes nothing proves nothing."
        exit 1
    fi
    $CC $CFLAGS -DTOOTH=$n "$TMP/j.c" "$HERE/test_juno_event.c" -o "$TMP/t"
    if "$TMP/t" > "$TMP/out" 2>&1; then
        echo "TOOTH $n NOT CAUGHT ($what) -- the gate is blind to it."
        sed 's/^/    /' "$TMP/out"
        exit 1
    fi
    echo "TOOTH $n caught: $what"
}

tooth 1 's/while (n < max && rd != wr)/while (rd != wr)/' \
        'drain ignores the cap'
tooth 2 's/if ((unsigned)(wr - rd) < (unsigned)QMASK) {/if (1) {/' \
        'a full queue overwrites instead of refusing'
tooth 3 's/Q\[wr \& QMASK\].src  = (unsigned char)src;/Q[wr \& QMASK].src = 0;/' \
        'the source tag is dropped'
tooth 4 's/if (velocity == 0) return ev_submit(JUNO_EV_NOTE_OFF, src, note, 64);//' \
        'note-on velocity 0 stays a note-on'
tooth 5 's/if (note > 127)     note = 127;//' \
        'the note range clamp is removed'
tooth 6 's/^    QRD = rd;.*$/    (void)rd;/' \
        'drain does not advance the read index'

echo
$CC $CFLAGS "$HERE/juno_event.c" "$HERE/test_juno_event.c" -o "$TMP/clean"
"$TMP/clean"
echo "O1 GATE: six teeth caught, clean run green."
