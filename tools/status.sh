#!/bin/sh
# status.sh -- one command that answers "is it working, and is it done?"
# Run:  sh tools/status.sh
cd "$(dirname "$0")/.." || exit 1
echo "=============================================================="
echo " AM I WORKING?   (new commits = work landed; each says why)"
echo "=============================================================="
git log --oneline -8 --date=format:'%m-%d %H:%M' --pretty='  %ad  %s'
echo
last=$(git log -1 --format=%ct)
now=$(date +%s)
mins=$(( (now - last) / 60 ))
echo "  last commit was ${mins} minute(s) ago"
echo
echo "=============================================================="
echo " WHAT IS RUNNING RIGHT NOW"
echo "=============================================================="
found=0
for p in jx_verify confirm.sh mutation_gate census_exhaustive fxsweep nan_ab "make verify"; do
  if pgrep -f "$p" >/dev/null 2>&1; then echo "  RUNNING: $p"; found=1; fi
done
[ "$found" = 0 ] && echo "  (nothing running -- either idle or between steps)"
echo
echo "=============================================================="
echo " AM I DONE?   done is defined by docs/PORT_COMPLETENESS_CHARTER.md"
echo "=============================================================="
echo "  A port is DONE only when ALL of these are true:"
echo "    1. census matches the host's own parameter count"
echo "    2. mutation reach has ZERO confirmed survivors"
echo "    3. every row of the scope audit is CLOSED or accepted in writing"
echo
echo "  OPEN scope rows (JX-3P) -- these are what 'not done' means today:"
grep -E '^\| *[0-9]+ \|' jx3p/docs/SCOPE_AUDIT.md 2>/dev/null \
  | grep -viE 'CLOSED|\| OK \|' \
  | sed -E 's/\|([^|]*)\|([^|]*)\|([^|]*)\|.*/  row\1-\2:\3/' \
  | cut -c1-110
echo
echo "  If that list is empty and nothing is running, the JX-3P port is done."
