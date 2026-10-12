#!/usr/bin/env python3
"""jp8_param_positions.py -- the POSITIONS of every panel parameter of the JUPITER-8, from the plugin's own edit
controller (EXECUTED on the host oracle, jp8_host_emu.py): getParamStringByValue (IEditController slot 10) at the
normalized values k / 256 (k = 0 .. 256) for each of the controller census's panel parameters (jp8/gen/
jp8_controller.json: the ids below the MIDI mapping's). Equal strings next to each other are one position; a
parameter with few positions is a switch, one with many is continuous. The sweep of the host gate's drive
(jp8_host_seq.SWEEP) plays every position of a switch and five values of a continuous parameter.
Plumbing only: the strings are the plugin's answers; nothing is computed from them but where they change.
usage: jp8_param_positions.py [out.json=jp8/gen/jp8_param_positions.json]"""
import sys, os, json, time
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import jp8_host_emu as X, jp8_host_seq as Q
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, '..', 'gen', 'jp8_param_positions.json')
GRID = 256
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
h = X.JP8Host(); uc = h.uc
h.boot_host(log=log)
h.heap_reuse_on()
h.host_setup(Q.RATE, Q.MAXBLOCK, Q.NPQ)
ctl = json.load(open(os.path.join(HERE, '..', 'gen', 'jp8_controller.json')))
title = {p['id']: p['title'] for p in ctl['params']}
res = []
for pid in Q.PANEL:
    strs = []
    for k in range(GRID + 1):
        b = h.scratch('str')
        r, _ = h.ctl(10, pid, k / GRID, 0, b)
        raw = bytes(uc.mem_read(b, 256))
        s = raw.decode('utf-16-le').split('\0')[0]
        strs.append(s if r == 0 else '<result 0x%x>' % r)
    pos = []                                   # [first k, last k, string]
    for k, s in enumerate(strs):
        if pos and pos[-1][2] == s:
            pos[-1][1] = k
        else:
            pos.append([k, k, s])
    res.append(dict(id=pid, title=title.get(pid, ''), positions=pos, n=len(pos)))
    log('0x%07x %-22s %3d positions: %s' % (pid, title.get(pid, ''), len(pos),
        ' | '.join(p[2] for p in pos[:8]) + (' ...' if len(pos) > 8 else '')))
json.dump(dict(grid=GRID, rate=Q.RATE, source='getParamStringByValue (slot 10) on the host oracle', params=res),
          open(out, 'w'), indent=1)
log('wrote %s: %d parameters, %d switches (<= 16 positions)' % (out, len(res), sum(1 for p in res if p['n'] <= 16)))
