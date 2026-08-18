#!/bin/sh
# boundary_teeth.sh -- prove boundary_check.py can SEE each violation it claims
# to forbid, then prove the tree is clean.
#
# The plants are applied to a COPY of the tree (a cheap one: three files), and
# the checker is pointed at it by REPO override. Nothing under esp32s3/main or
# event/ is edited.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$HERE")")
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/esp32s3/main" "$TMP/event" "$TMP/tools/engineb"
cp "$REPO"/esp32s3/main/*.c "$TMP/esp32s3/main/"
cp "$REPO"/event/juno_event.h "$TMP/event/"
cp "$HERE/boundary_check.py" "$TMP/tools/engineb/"

run() { python3 "$TMP/tools/engineb/boundary_check.py"; }

tooth() {                        # tooth <n> <file> <sed> <what>
    n=$1; f=$2; script=$3; what=$4
    cp "$TMP/$f" "$TMP/$f.bak"
    sed -i "$script" "$TMP/$f"
    if cmp -s "$TMP/$f" "$TMP/$f.bak"; then
        echo "TOOTH $n: *** THE PLANT DID NOT APPLY. A tooth that changes"
        echo "           nothing proves nothing (playbook 55)."
        exit 1
    fi
    if run > "$TMP/out" 2>&1; then
        echo "TOOTH $n NOT CAUGHT ($what)"
        sed 's/^/    /' "$TMP/out"
        exit 1
    fi
    echo "TOOTH $n caught: $what"
    mv "$TMP/$f.bak" "$TMP/$f"
}

# 1. a back door to the engine, in the shape it would really appear: somebody
#    adds an input and calls the allocator straight from the parser.
tooth 1 esp32s3/main/juno_s3_listen.c \
    's/^static void midi_poll(void)$/static void midi_poll(void)\n{ eb_alloc_note_on(\&ALLOC, 60, 100, ALLOC_EV); }\nstatic void midi_poll_real(void)/' \
    'the allocator called from outside the queue consumer'

# 2. an input that parses and never submits -- the new-source-in-a-hurry case.
# BOTH calls must go: check 2's granularity is PER FILE, so a file that still
# submits on one path passes. That is a stated limit of the check, not a bug in
# this plant -- see boundary_check.py check 2.
tooth 2 esp32s3/main/s3_usbmidi.c \
    's/juno_event_note_o[nf]*[ ]*(JUNO_SRC_USB[^;]*;/(void)0;/' \
    'a parser that reaches input and never submits'

# 3. the boundary header growing an instrument constant.
tooth 3 event/juno_event.h \
    's/^#define JUNO_EVENT_H$/#define JUNO_EVENT_H\n#define JUNO_VCF_CUTOFF_PARAM 12/' \
    'a JUNO parameter added to the portable header'

echo
run
echo "BOUNDARY TEETH: three caught, clean tree green."
