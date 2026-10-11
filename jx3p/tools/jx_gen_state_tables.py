#!/usr/bin/env python3
"""jx_gen_state_tables.py -- generate jx3p/src/jx_state_tables.h: the JX-3P's DAW state as the plugin's own code
handles it (JX-17), from the census pickle jx_state_census.py writes (scratchpad/jx_state/state_census.pkl;
Unicorn there, none here: the two-process rule).

What the census EXECUTED and this file states:
  JX_STATE_ENT[82]   the parameter list of getState / setState, in its order: the id, the model's storage law (the
                     value a setState entry takes and keeps: & 0xFF, & 0x7F, & 0xFFFF, or as given -- the one law
                     that reproduces all 14 test values, in the queued record AND in the getState after it) and the
                     default (initialize's record for the entry, the same order).
  initialize + setActive queue the 82 defaults in list order, then writePatch (0x0FFFC01D) = 1, then the
  all-sound-off MIDI record (JX_STATE_BOOT_MIDI: its three bytes; jx3p/gen/jx_patch_records.json's 'boot' list,
  another census of the same queue, must agree); setState queues writePatch = 126, the payload's known parameters in PAYLOAD order,
  writePatch = 127 (a payload with a count <= 0 queues nothing).

    python3 jx3p/tools/jx_gen_state_tables.py           write the header
    python3 jx3p/tools/jx_gen_state_tables.py --check   exit 1 if the committed header differs
"""
import hashlib
import json
import os
import pickle
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
PKL = os.path.join(REPO, 'scratchpad', 'jx_state', 'state_census.pkl')
MODEL_PKL = os.path.join(REPO, 'scratchpad', 'jx_model', 'model_census.pkl')     # jx_model_census.py (JX-18)
OUT = os.path.join(REPO, 'jx3p', 'src', 'jx_state_tables.h')
WRITEPATCH = 0x0FFFC01D
CC_BASE = 0x10000000
MASKS = (0xFF, 0x7F, 0xFFFF, 0)          # 0: the value as given


def s32(v):
    v &= 0xFFFFFFFF
    return v - (1 << 32) if v & 0x80000000 else v


def payload(state):
    n = struct.unpack('>I', state[:4])[0]
    pl = state[4:4 + n]
    return [list(struct.unpack('>Ii', pl[i:i + 8])) for i in range(0, len(pl), 8)]


def derive(r):
    ent0, npar, init = payload(r['state0']), r['npar'], r['init_queue']
    if len(init) != npar + 2 or init[npar][:3] != (2, 0, WRITEPATCH) or init[npar][3] != 1 or init[npar + 1][0] != 0:
        raise SystemExit('init queue: not the %d defaults, writePatch = 1 and one MIDI record' % npar)
    tests = [c for c in r['cases'] if c['name'].startswith('all=')]
    out = []
    for k in range(npar):
        pid = ent0[k][0]
        kind, off, qid, dflt = init[k]
        if (kind, off, qid) != (2, 0, pid):
            raise SystemExit('init queue record %d is not entry %d (0x%x)' % (k, k, pid))
        law = None
        for m in MASKS:
            ok = True
            for c in tests:
                q, st, inp = c['queue'], payload(c['state']), c['payload'][k][1]
                if q[0][2:] != (WRITEPATCH, 126) or q[-1][2:] != (WRITEPATCH, 127) or q[k + 1][2] != pid:
                    raise SystemExit('setState queue: not writePatch 126, the list, writePatch 127 (%s)' % c['name'])
                want = s32(inp & m) if m else inp
                if q[k + 1][3] != want or st[k] != [pid, want]:
                    ok = False
                    break
            if ok:
                law = m
                break
        if law is None:
            raise SystemExit('entry %d (0x%x): no storage law fits' % (k, pid))
        out.append((pid, law, dflt))
    # setState: payload order (a shuffled subset), the CC map refilled from the payload
    sh = next(c for c in r['cases'] if c['name'] == 'params only, shuffled')
    if [q[2] for q in sh['queue'][1:-1]] != [e[0] for e in sh['payload']]:
        raise SystemExit('setState does not queue in payload order')
    return out, ent0[npar:]


def boot_midi(r):
    """initialize's one MIDI record after writePatch: its three bytes (the all-sound-off message); and the boot
    records jx_patch_records.py recorded (jx3p/gen/jx_patch_records.json 'boot', the product oracle's
    product_boot) must be these 83 kind-2 records and that one kind-0 record -- two censuses, one queue"""
    m = r.get('init_midi')
    if not m or len(m) != 1:
        raise SystemExit('init queue: not one MIDI record (%s)' % m)
    return m[0]


def check_boot_records(ents):
    rec = json.load(open(os.path.join(REPO, 'jx3p', 'gen', 'jx_patch_records.json')))['boot']
    k2 = [(pid & 0xFFFFFFFF, val) for kind, pid, val in rec if kind == 2]
    if k2 != [(pid, d) for pid, _, d in ents] + [(WRITEPATCH, 1)] or [k for k, _, _ in rec].count(0) != 1 or rec[-1][0] != 0:
        raise SystemExit('jx_patch_records.json boot: not the state defaults, writePatch = 1 and one MIDI record')


def f32(x):
    return struct.unpack('<f', struct.pack('<f', x))[0]


def editor(ents, m):
    """the editor's set of each entry (jx_model_census.py: the model's set at 14 values): 1 = the host's automation
    round trip -- beginEdit, performEdit(id, (float)(stored - min) / (float)(max - min), both unsigned 32-bit),
    endEdit, no engine record; 0 = one engine record (id, the stored value). Every set must fit one of the two, and
    the save after it must hold the stored value; writePatch (no state entry) is a record, its law found here."""
    import re
    src = open(os.path.join(REPO, 'jx3p', 'src', 'jx_midi_tables.h')).read()
    rng = {int(a, 16): (int(b), int(c)) for a, b, c, _ in re.findall(r'\{ 0x([0-9A-F]{8})u, (-?\d+), (-?\d+), (\d) \}', src)}
    law = {pid: mk for pid, mk, _ in ents}
    route = {}
    for pid in m['ids']:
        sets = [x for x in m['sets'] if x['id'] == pid]
        if pid == WRITEPATCH:
            fit = [mk for mk in MASKS if all(x['queue'] == [(2, 0, pid, s32(x['v'] & mk) if mk else x['v'])] and
                                             not x['edits'] for x in sets)]
            if not fit:
                raise SystemExit('writePatch: no law fits the editor\'s records')
            route[pid] = ('wp', fit[0])
            continue
        if pid not in law:
            raise SystemExit('editor census: 0x%x is not a state entry' % pid)
        mk = law[pid]
        kinds = set()
        for x in sets:
            st = s32(x['v'] & mk) if mk else x['v']
            if dict(payload(x['save'])).get(pid) != st:
                raise SystemExit('editor census: 0x%x = %d: the save does not hold %d' % (pid, x['v'], st))
            if x['queue'] == [(2, 0, pid, st)] and not x['edits']:
                kinds.add(0)
                continue
            mn, mx = rng[pid]
            want = f32(f32((st - mn) & 0xFFFFFFFF) / f32((mx - mn) & 0xFFFFFFFF))
            if not x['queue'] and x['edits'] == [('beginEdit', pid, None), ('performEdit', pid, want), ('endEdit', pid, None)]:
                kinds.add(1)
                continue
            raise SystemExit('editor census: 0x%x = %d fits neither a record nor the round trip: %s %s' % (
                pid, x['v'], x['queue'], x['edits']))
        if len(kinds) != 1:
            raise SystemExit('editor census: 0x%x routes both ways' % pid)
        route[pid] = kinds.pop()
    if sorted(route) != sorted([pid for pid, _, _ in ents] + [WRITEPATCH]):
        raise SystemExit('editor census: not the state entries and writePatch')
    return route


def header(ents, ccs, sha, midi, route):
    L = ['/* jx_state_tables.h -- GENERATED by jx3p/tools/jx_gen_state_tables.py; do not edit.',
         ' *',
         ' * The JX-3P\'s DAW state (JX-17), EXECUTED through the plugin\'s own getState / setState',
         ' * (jx3p/tools/jx_state_census.py; the wrapper is the JUNO-60\'s, jx3p/tools/fw_map.py):',
         ' *   JX_STATE_ENT  the parameter list in getState\'s order: id, the model\'s storage law (the',
         ' *                 value & mask, 0 = as given: what setState queues and getState gives back),',
         ' *                 the default (initialize\'s record). %d entries; then the 128 CC map entries' % len(ents),
         ' *                 0x10000000 + n (the model id CC n drives, -1 none).',
         ' *   JX_STATE_EDIT_HOST  the editor\'s set of each entry (the model\'s set, rva 0x283C90; jx_model_census.py):',
         ' *                 1 the host\'s automation round trip (beginEdit, performEdit(id, (float)(stored - min) /',
         ' *                 (float)(max - min), unsigned 32-bit operands), endEdit -- no engine record; 0 one engine',
         ' *                 record (id, the stored value). writePatch: a record, its value & JX_STATE_WRITEPATCH_MASK.',
         ' *   setState queues writePatch (0x0FFFC01D) = 126, the payload\'s known parameters in payload',
         ' *   order, writePatch = 127; initialize queues the defaults in list order, writePatch = 1, then',
         ' *   one MIDI record, JX_STATE_BOOT_MIDI (the all-sound-off message).',
         ' */',
         '#ifndef JX_STATE_TABLES_H',
         '#define JX_STATE_TABLES_H',
         '#include <stdint.h>',
         '#define JX_STATE_SHA256 "%s"' % sha,
         'typedef struct { uint32_t id; uint32_t mask; int32_t dflt; } jx_state_ent;',
         '#define JX_STATE_N %d' % len(ents),
         '#define JX_STATE_WRITEPATCH 0x0FFFC01Du',
         '#define JX_STATE_CC_BASE 0x10000000u',
         '#define JX_STATE_BOOT_MIDI0 0x%02Xu' % midi[0],
         '#define JX_STATE_BOOT_MIDI1 0x%02Xu' % midi[1],
         '#define JX_STATE_BOOT_MIDI2 0x%02Xu' % midi[2],
         'static const jx_state_ent JX_STATE_ENT[JX_STATE_N] = {']
    for pid, law, dflt in ents:
        L.append('    { 0x%08Xu, 0x%Xu, %d },' % (pid, law, dflt))
    L.append('};')
    L.append('/* the CC map at the boot as getState gives it (the model id of CC n, -1 none) */')
    L.append('/* the editor\'s set: 1 the host\'s round trip (performEdit), 0 an engine record */')
    L.append('static const uint8_t JX_STATE_EDIT_HOST[JX_STATE_N] = {')
    for i in range(0, len(ents), 20):
        L.append('    ' + ', '.join('%d' % route[pid] for pid, _, _ in ents[i:i + 20]) + ',')
    L.append('};')
    L.append('#define JX_STATE_WRITEPATCH_MASK 0x%Xu' % route[WRITEPATCH][1])
    L.append('static const int32_t JX_STATE_CC_BOOT[128] = {')
    for i in range(0, 128, 8):
        L.append('    ' + ', '.join('%d' % v for _, v in ccs[i:i + 8]) + ',')
    L.append('};')
    L.append('#endif')
    return '\n'.join(L) + '\n'


def main():
    r = pickle.load(open(PKL, 'rb'))
    ents, ccs = derive(r)
    if [i for i, _ in ccs] != [CC_BASE + n for n in range(128)]:
        raise SystemExit('getState: the CC map entries are not 0x10000000 + 0..127 in order')
    check_boot_records(ents)
    route = editor(ents, pickle.load(open(MODEL_PKL, 'rb')))
    sha = hashlib.sha256(r['state0']).hexdigest()
    txt = header(ents, ccs, sha, boot_midi(r), route)
    if '--check' in sys.argv:
        same = os.path.exists(OUT) and open(OUT).read() == txt
        print('jx_gen_state_tables --check: %s' % ('EQUAL to the committed header' if same else 'DIFFERS -- RED'))
        return 0 if same else 1
    open(OUT, 'w').write(txt)
    print('%s: %d parameters (%s), the boot CC map (%d CCs assigned)' % (
        OUT, len(ents), ', '.join('%s %d' % (('as given' if m == 0 else '& 0x%X' % m),
                                             sum(1 for _, x, _ in ents if x == m)) for m in MASKS),
        sum(1 for _, v in ccs if v >= 0)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
