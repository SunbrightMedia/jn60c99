#!/bin/sh
# setup_oracle.sh -- fetch the acoustic oracle (MIT pyNA, pinned) into its own
# venv. pyNA needs scipy < 1.14 (it uses interpolate.interp2d, removed in 1.14),
# and pandas < 2.0 (DataFrame.append), so it NEVER shares an interpreter with the repo's own tools.
#
#   sh jetsynth/tools/setup_oracle.sh [DIR]      default DIR: $HOME/.jet_oracle
#   then: export JET_ORACLE=DIR
set -e
DIR=${1:-$HOME/.jet_oracle}
PIN=7afcfd44eae98e26300ba32daa52bc779dc319be
mkdir -p "$DIR"
if [ ! -d "$DIR/pyNA/.git" ]; then
    git clone https://github.com/MIT-LAE/pyNA "$DIR/pyNA"
fi
git -C "$DIR/pyNA" checkout -q "$PIN" 2>/dev/null || {
    git -C "$DIR/pyNA" fetch -q --depth 50 origin
    git -C "$DIR/pyNA" checkout -q "$PIN"
}
[ -x "$DIR/venv/bin/python" ] || python3 -m venv "$DIR/venv"
"$DIR/venv/bin/pip" install -q "numpy==1.26.4" "scipy==1.13.1" "pandas==1.5.3" \
    openmdao openpyxl dymos matplotlib shapely tqdm
echo "oracle ready: export JET_ORACLE=$DIR   (pyNA @ $PIN)"
