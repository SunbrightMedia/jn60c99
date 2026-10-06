"""Oracle-only (CLAIMS B6): which port host parameter each plugin parameter id
is, read from the plugin's own parameter map (the host entry's id -> dispatch
map, after POPULATE) joined to the port's host table exactly as
tools/verify/host_edit_gate.py oracle_params does. Writes
scratchpad/b6/pid_host_map.pkl = {id: (host index, name, dispatch, lo, hi)}.
    python3 probes/b6/pid_host_map.py      (Unicorn only)"""
import os, sys, pickle
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import recall_render_ab as RR
import seed_recall_gate as S
import host_edit_gate as HG
e = RR.build_engine(E, 44100.0)
e.call(E.IB + HG.POPULATE_RVA, count=200_000_000)
params = HG.oracle_params(e, E, S)
out = {pid: (k, name, d, lo, hi) for k, (name, d, pid, lo, hi) in params.items()}
pickle.dump(out, open(os.path.join(REPO, 'scratchpad', 'b6', 'pid_host_map.pkl'), 'wb'))
print('wrote pid_host_map.pkl:', len(out), 'host parameters')
