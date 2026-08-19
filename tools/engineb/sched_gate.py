#!/usr/bin/env python3
"""sched_gate.py -- build and run O2's scheduler gate.

The budget is control logic on the audio path. It shipped once with no gate,
which is playbook defect 1 in its oldest form. This compiles the gate against
engine_b/dev/eb_sched.h -- THE HEADER THE FIRMWARE INCLUDES -- so the thing
proved is the thing flashed.
"""
import subprocess, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
OUT  = os.path.join(REPO, "build", "sched_gate")
os.makedirs(os.path.dirname(OUT), exist_ok=True)

cmd = ["cc", "-std=c99", "-O1", "-Wall", "-Wextra", "-Werror",
       "-I", os.path.join(REPO, "engine_b", "dev"),
       os.path.join(HERE, "devboot", "sched_gate.c"), "-o", OUT]
r = subprocess.run(cmd)
if r.returncode:
    print("sched_gate: COMPILE FAILED"); sys.exit(2)
sys.exit(subprocess.run([OUT]).returncode)
