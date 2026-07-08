#!/usr/bin/env python3
"""patch_state_oracle.py — THE exhaustive per-patch recall oracle.

For each factory patch, drive the plugin's OWN value-tree dispatch (sub_7FF91E019A30,
executed under Unicorn via the unit2 VT harness) for EVERY leaf of the patch record,
in record (document) order, with the patch's decoded bytes. Collect every engine
write (paramIdx -> exact float bits) the plugin's own code produces, mapped to engine
offsets via the descriptor registry.

The result is the plugin's complete recall output for that patch — the ground truth
list of (engine_offset -> bits) that loading the patch writes. Diffing this against
our juno_bank_apply output finds EVERY missing/wrong recall at once.

Leaf -> dispatch mapping: dispatch_index = Script.xml document-order position + 740,
PROVEN uniform on 14 independent anchors (VCF CUTOFF 779, EFFECT DEPTH 794,
PORTAMENTO/LEGATO/ASSIGN/BEND RANGE 798-801, TEMPO SYNC 803, VCA MODE 855,
BEND/MOD SENS 858-861, EFFECT TYPE/TONE 873/874).

Record positions (verified previously vs patch names + oracle):
  front-panel leaf (myleaf 19..71):  blob byte = 2*myleaf - 4   (nibble-pair value)
  extended leaf   (myleaf 88..135):  blob byte = 8*myleaf - 430 (nibble-pair value)
  (myleaf = docpos - 2; PATCH NAME leaves 72..87 skipped)

Usage: python3 patch_state_oracle.py <patch_idx> [<patch_idx2> ...]  (or 'all')
Writes scratchpad/oracle/patch_state/patch_NN.json  {offset: bits, ...} + write order.
"""
import importlib.util, sys, os, re, struct, json

UNIT2 = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/unit2'
SCRIPT = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/7c621d41-Script.xml'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
OUT = '/home/user/jn60c99/scratchpad/oracle/patch_state'

spec = importlib.util.spec_from_file_location('evt', UNIT2 + '/emu_valuetree.py')
m = importlib.util.module_from_spec(spec); sys.modules['evt'] = m; spec.loader.exec_module(m)

HEADER, STRIDE, BLOB_OFF, N = 23, 20223, 16, 64
bank = open(BANK, 'rb').read()

# ---- leaf table from Script.xml document order --------------------------------
xml = open(SCRIPT, encoding='utf-8', errors='replace').read()
vals = re.findall(r'<value>(.*?)</value>', xml, re.S)
leaves = []   # (docpos, name, dispatch, blob_byte or None)
for p, v in enumerate(vals):
    nm = re.search(r'<name>(.*?)</name>', v)
    nm = nm.group(1) if nm else '?'
    ml = p - 2                       # myleaf
    if 19 <= ml <= 71:
        bb = 2 * ml - 4
    elif 88 <= ml <= 135:
        bb = 8 * ml - 430
    else:
        continue                     # pre-record leaves, PATCH NAME chars, PAT2 blocks
    if nm.startswith('PATCH NAME'):
        continue
    leaves.append((p, nm, p + 740, bb))
sys.stderr.write("record leaves: %d (docpos %d..%d)\n" % (len(leaves), leaves[0][0], leaves[-1][0]))

def blob_of(idx):
    return bank[HEADER + idx * STRIDE + BLOB_OFF: HEADER + (idx + 1) * STRIDE]

def dec(blob, b):                    # verified nibble-pair byte decode
    return ((blob[b] & 0xF) << 4) | (blob[b + 1] & 0xF)

reg = m._reg
def off_of(pid):
    return reg[pid][0] if 0 <= pid < len(reg) else None
def name_of_pid(pid):
    return reg[pid][1] if 0 <= pid < len(reg) else None

# voice-0 pids are 0..109; globals start where offsets jump past voice regions.
def keep_pid(pid):
    o = off_of(pid)
    if o is None: return False
    return (176 <= o < 10688) or (o >= 84272)   # voice0 block + shared/master

def apply_patch(vt, idx):
    """Dispatch every record leaf of patch idx; return (writes{off:bits}, log[])."""
    blob = blob_of(idx)
    writes = {}
    log = []
    for (p, nm, disp, bb) in leaves:
        val = dec(blob, bb)
        r, d = vt.set_param(disp, val)
        if r[0] != 'OK':
            log.append((disp, nm, val, 'ERR', str(r)))
            continue
        w = {}
        for pid, bits in d.items():
            if keep_pid(pid):
                writes[off_of(pid)] = bits
                w[off_of(pid)] = bits
        log.append((disp, nm, val, 'ok', w))
    return writes, log

def main():
    os.makedirs(OUT, exist_ok=True)
    args = sys.argv[1:]
    if args and args[0] == 'all':
        want = list(range(N))
    else:
        want = [int(a) for a in args] or [1]
    vt = m.VT()
    r = vt.construct()
    assert r[0] == 'OK', r
    for idx in want:
        writes, log = apply_patch(vt, idx)
        nm16 = bank[HEADER + idx * STRIDE: HEADER + idx * STRIDE + 16]
        pname = bytes(c if 32 <= c < 127 else 32 for c in nm16).decode().strip()
        json.dump({'patch': idx, 'name': pname,
                   'writes': {str(k): v for k, v in sorted(writes.items())},
                   'log': [[d, n, v, s, (w if isinstance(w, dict) and len(w) < 20 else str(w)[:100])]
                           for (d, n, v, s, w) in log]},
                  open(OUT + '/patch_%02d.json' % idx, 'w'))
        errs = sum(1 for e in log if e[3] == 'ERR')
        sys.stderr.write("patch %2d %-18s offsets_written=%3d dispatch_errors=%d\n"
                         % (idx, pname, len(writes), errs))

if __name__ == '__main__':
    main()
