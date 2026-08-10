#!/bin/sh
# lastmile_run.sh — one control-rate variant through the sonic gate.
#
# The AUDIBLE build's own flag set is the BASE, verbatim from the firmware
# that measured 6,723 cycles on the board (esp32s3 CMakeCache S3_EXTRA_DEFS
# plus the CMakeLists constants). A variant is BASE plus its own flag, so the
# number this prints is the variant's cost ON TOP of what the user already
# holds, and nothing else moved.
#
# usage: lastmile_run.sh <tag> [extra -D flags ...]
set -e
cd "$(dirname "$0")/../.."
TAG="$1"; shift
BASE="-DEB_FORK_S3 -DEB_DCO_WT=1 -DEB_LFO_SHARED=1 -DEB_VCF_DEADCOEF=1 \
-DEB_VCF_RES_LUT=256 -DEB_ATREST_O1=1 -DEB_ATREST_O1_MIN=1 -DEB_ZEROCOEF=1 \
-DEB_EXP_MEMO=1 -DEB_HALF_OS_VCF=1"
export EB_FORK_FLAGS="$BASE $*"
echo "TAG $TAG"
echo "FLAGS $EB_FORK_FLAGS"
exec python3 tools/engineb/sonic_gate.py 2>&1
