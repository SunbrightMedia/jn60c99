#!/bin/sh
# jn_l5_full.sh -- the full re-verification of the lifted JUNO host: the build (jn_build.sh: imports list, lift,
# template, libjunohost.so) and then every L5 gate with its teeth (jn_l5_all.sh). Run it with tools/run_job.sh.
# usage: sh tools/lift/jn_l5_full.sh            (run from the repo root)
set -e
R=${REPO:-.}
sh "$R/tools/lift/jn_build.sh"
sh "$R/tools/lift/jn_l5_all.sh"
