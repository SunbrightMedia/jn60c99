#!/bin/sh
# seed_sweep.sh -- run the random full-state A/B over an UNBOUNDED number of
# seeds without ever filling the disk.
#
#   seed_sweep.sh <start> <total> [block] [workers]
#
# WHY THIS EXISTS. Reference states are 141 KB each. Accumulating 12,337 of
# them filled the session's disk allowance (1.7 GB of pickles) and killed a
# running `make verify` mid-gate. Once seedgen_fast.py made a state cost
# 0.11s instead of 3.92s, storing them stopped being worth it: a state is
# cheaper to REGENERATE than to keep. So this streams --
#     generate a block -> gate it -> DELETE it -> next block
# and peak disk is one block, not the whole campaign.
#
# ⚠ TWO-PROCESS RULE: generation (Unicorn) and the gate (ctypes libjuno.so)
# are separate PROCESSES here, never one interpreter. That is why this is a
# shell loop and not a Python driver.
set -eu
start=${1:?usage: seed_sweep.sh <start> <total> [block] [workers]}
total=${2:?missing total}
block=${3:-2000}
workers=${4:-4}
root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$root"
log=scratchpad/seed_sweep.log
: > "$log"
bad=0; done_seeds=0; s=$start
while [ "$done_seeds" -lt "$total" ]; do
    n=$block
    [ $((done_seeds + n)) -gt "$total" ] && n=$((total - done_seeds))
    per=$((n / workers + 1))
    i=0
    while [ "$i" -lt "$workers" ]; do
        python3 tools/verify/seedgen_fast.py --gen $((s + i * per)) "$per" \
            > "scratchpad/sweep_gen_$i.log" 2>&1 &
        i=$((i + 1))
    done
    wait
    out=$(python3 tools/verify/random_state_ab.py --port $((per * workers + 8)) --start "$s" 2>&1 || true)
    got=$(printf '%s' "$out" | sed -n 's/^seeds \([0-9]*\).*/\1/p' | head -1)
    if printf '%s' "$out" | grep -q '0 differing cells'; then
        echo "block $s..$((s + n))  seeds=$got  GREEN" | tee -a "$log"
    else
        bad=$((bad + 1))
        echo "block $s..$((s + n))  seeds=$got  *** RED ***" | tee -a "$log"
        printf '%s\n' "$out" | sed -n '/CELLS DIFFER/,/^$/p' | tee -a "$log"
    fi
    # stream: the block's states are regenerable, so reclaim them now
    ls scratchpad/randstate_*.pkl 2>/dev/null | awk -F'[_.]' -v a="$s" '$2>=a' | xargs -r rm -f
    done_seeds=$((done_seeds + n)); s=$((s + per * workers))
done
echo "SWEEP DONE  blocks_red=$bad  seeds=$done_seeds" | tee -a "$log"
