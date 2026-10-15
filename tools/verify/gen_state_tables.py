#!/usr/bin/env python3
"""gen_state_tables.py -- generate src/juno_state_tables.h: how the plugin's
own preset paths hand the engine its parameters (CLAIMS B6), from executed
census pickles. Two-process rule: this script reads pickles and text only.

INPUTS (Unicorn-only probes; regenerate them from the .vst3 first)
  scratchpad/b6/state_load_census.pkl   probes/b6/state_load_census.py
      the 95 events IComponent::initialize queues (the defaults, in the
      plugin's parameter-list order) and the plugin's own getState payload
  scratchpad/b6/state_mask_census.pkl   probes/b6/state_mask_census.py
      the value each entry takes when setState sets it (14 values outside
      every range): the model's storage law per entry
  scratchpad/b6/patch_load_census.pkl   probes/b6/patch_load_census.py
      the plugin's own patch load (rva 0x335850) of all 64 factory records:
      the 87 engine events in tree order, the leaf walk (struct offsets), the
      model's own serialization at boot (the default record) and after each
      load (round trip)
  scratchpad/b6/patch_load_census_craft.pkl   ... --craft
      8 records whose bytes carry bits a nibble field does not, 3 of them
      different at every offset (decode law and offsets)
  scratchpad/b6/pid_host_map.pkl        probes/b6/pid_host_map.py
      plugin parameter id -> port host index (the plugin's id map)
  scratchpad/b6/editor_census.pkl       tools/verify/juno_model_census.py
      the EDITOR's set of every state entry (the model's set, rva 0x283DB0, as a
      panel control makes it) at 14 values: the host calls and the engine records

OUTPUT  src/juno_state_tables.h
  JUNO_STATE_ENT[95]   id, port host index (or JUNO_SE_VOICES / JUNO_SE_SRATE / JUNO_SE_NONE),
                       storage mask, default value -- list order
  JUNO_PATCH_EV[87]    id, port host index (or JUNO_SE_NONE), record offset,
                       decode -- tree order (the order a patch load sets them)
  JUNO_DEFAULT_REC[]   the model at boot, serialized by the plugin (a record:
                       16-byte name + the patch tree)
  JUNO_STATE_EDIT_HOST[95]  the editor's set of each entry: 1 the host's automation
                       round trip (beginEdit, performEdit, endEdit; no engine record),
                       0 one engine record -- every censused set checked against it

Every decode (record offset, law) is DERIVED: the one candidate inside the
event's struct that reproduces the plugin's value for all 72 records.

USAGE
    python3 tools/verify/gen_state_tables.py           write the header
    python3 tools/verify/gen_state_tables.py --check   exit 1 if it differs
"""
import os
import re
import sys
import pickle
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
B6 = os.path.join(REPO, 'scratchpad', 'b6')
OUT = os.path.join(REPO, 'src', 'juno_state_tables.h')
HEADER, STRIDE, NAME = 23, 20223, 16
VOICECOUNT_ID = 0x0FFFC00E
SRATE_ID = 0x0FFFC015        # vm.vs.sampleRate: the core's listener sets the engine rate (CLAIMS B13)
MASKS = (0xFF, 0x7F, 0xFFFF, 0)          # 0: the value as given
DEC_NAMES = ('JUNO_DEC_INT1X7', 'JUNO_DEC_INT2X4', 'JUNO_DEC_INT8X4', 'JUNO_DEC_INT4X4')


def s32(v):
    v &= 0xFFFFFFFF
    return v - (1 << 32) if v & 0x80000000 else v


def decode(rec, o, dec):
    """the model's set-from-bytes per leaf type (EXECUTED, the craft census):
    nibble fields are OR-ed shifted bytes, nothing masked"""
    if dec == 0:
        return rec[o]
    if dec == 1:
        return (rec[o] << 4) | rec[o + 1]
    if dec == 2:
        v = 0
        for i in range(8):
            v |= rec[o + i] << (4 * (7 - i))
        return s32(v)
    v = 0
    for i in range(4):
        v |= rec[o + i] << (4 * (3 - i))
    return s32(v)


WIDTH = (1, 2, 8, 4)


def load(name):
    p = os.path.join(B6, name)
    if not os.path.exists(p):
        raise SystemExit('MISSING %s -- run its probe first (see the docstring)' % os.path.relpath(p, REPO))
    return pickle.load(open(p, 'rb'))


def host_rows():
    src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
    return [(m.group(1).strip(), int(m.group(2)), int(m.group(3))) for m in
            re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),', src)]


def state_entries(slc, smc, hmap):
    init = slc['init_queue']
    if len(init) != 95 or any(k != 2 or o != 0 for k, o, _, _ in init):
        raise SystemExit('init queue: not 95 kind-2 events at offset 0')
    tests = [c for c in smc['cases'] if c['name'].startswith('all=')]
    out = []
    for k, (_, _, pid, dflt) in enumerate(init):
        mask = None
        for m in MASKS:
            ok = True
            for c in tests:
                inp = c['payload'][k][1]
                got = c['queue'][k][3]
                if c['payload'][k][0] != pid or c['queue'][k][2] != pid:
                    raise SystemExit('mask census: entry %d is not id 0x%x' % (k, pid))
                want = s32(inp & m) if m else inp
                if got != want:
                    ok = False
                    break
            if ok:
                mask = m
                break
        if mask is None:
            raise SystemExit('entry %d (id 0x%x): no storage mask fits' % (k, pid))
        if pid == VOICECOUNT_ID:
            hi = 'JUNO_SE_VOICES'
        elif pid == SRATE_ID:
            hi = 'JUNO_SE_SRATE'
        elif pid in hmap:
            hi = hmap[pid][0]
        else:
            hi = 'JUNO_SE_NONE'
        out.append((pid, hi, mask, dflt))
    return out


def patch_events(plc, craft, hmap, bank):
    loads = plc['loads']
    order = [p for _, _, p, _ in loads[0]['queue']]
    recs = []
    for L in loads:
        if [p for _, _, p, _ in L['queue']] != order:
            raise SystemExit('patch %d: event order differs' % L['patch'])
        if L['saved'] != bank[HEADER + L['patch'] * STRIDE + NAME: HEADER + (L['patch'] + 1) * STRIDE]:
            raise SystemExit('patch %d: the model does not round-trip the record' % L['patch'])
        recs.append((bank[HEADER + L['patch'] * STRIDE: HEADER + (L['patch'] + 1) * STRIDE], [v for _, _, _, v in L['queue']]))
    base = bytearray(bank[HEADER:HEADER + STRIDE])
    crafted = []
    for pat in (0x10, 0x30, 0x70, 0xF0, 0x80):
        r = bytearray(base)
        for i in range(NAME, STRIDE):
            r[i] |= pat
        crafted.append(('0x%02x' % pat, r))
    for mul, add in ((29, 7), (53, 101), (197, 3)):
        r = bytearray(base)
        for i in range(NAME, STRIDE):
            r[i] = (i * mul + add + (i >> 8) * 17) & 0xFF
        crafted.append(('i*%d+%d' % (mul, add), r))
    if len(craft['loads']) != len(crafted):
        raise SystemExit('craft census: %d loads, expected %d' % (len(craft['loads']), len(crafted)))
    for (pat, r), L in zip(crafted, craft['loads']):
        if [p for _, _, p, _ in L['queue']] != order:
            raise SystemExit('craft %s: event order differs' % pat)
        recs.append((bytes(r), [v for _, _, _, v in L['queue']]))
    # each event's struct (the walk entry whose set queued it)
    span = {}
    for o, wd, hx, a, b in loads[0]['walk']:
        for k in range(a, b if b is not None else a):
            span[k] = (o + NAME, wd)
    out = []
    for k, pid in enumerate(order):
        o0, wd = span[k]
        fits = []
        for o in range(o0, o0 + wd):
            for dec in range(4):
                if o + WIDTH[dec] > o0 + wd:
                    continue
                if all(decode(r, o, dec) == vals[k] for r, vals in recs):
                    fits.append((o, dec))
        hi = hmap[pid][0] if pid in hmap else 'JUNO_SE_NONE'
        if len(fits) != 1:
            raise SystemExit('event %d (id 0x%x): %d decodes fit (%s)' % (k, pid, len(fits), fits[:4]))
        out.append((pid, hi, fits[0][0], fits[0][1]))
    return out


def f32(x):
    return struct.unpack('<f', struct.pack('<f', x))[0]


def save_entries(b):
    """getState's payload: a big-endian byte count, then (id, value) pairs"""
    n = struct.unpack('>I', b[:4])[0]
    return dict(struct.unpack('>Ii', b[4 + j: 12 + j]) for j in range(0, n, 8))


def editor(ents, m):
    """the editor's set of each entry (juno_model_census.py: the model's set at 14 values, final): 1 = the host's
    automation round trip -- beginEdit, performEdit(id, (float)(stored - min) / (float)(max - min), both unsigned
    32-bit, the range the plugin's MIDI table gives), endEdit, no engine record; 0 = one engine record (kind 2, the
    id, the stored value). Every set must fit one of the two and the save after it must hold the stored value (the
    JX-3P's jx3p/tools/jx_gen_state_tables.py rule, its code the twin: jx3p/tools/fw_map.py --pair 0x283DB0 0x283C90)"""
    src = open(os.path.join(REPO, 'src', 'midi_tables.h')).read()
    rng = {int(a, 16): (int(b), int(c)) for a, b, c in
           re.findall(r'\{ 0x([0-9A-F]{8})u, (-?\d+), (-?\d+), \d+, -?\d+ \}', src)}
    law = {pid: mk for pid, _, mk, _ in ents}
    route = {}
    for pid in m['ids']:
        if pid not in law:
            raise SystemExit('editor census: 0x%x is not a state entry' % pid)
        mk, kinds = law[pid], set()
        for x in (x for x in m['sets'] if x['id'] == pid):
            st = s32(x['v'] & mk) if mk else x['v']
            if save_entries(x['save']).get(pid) != st:
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
    if sorted(route) != sorted(pid for pid, _, _, _ in ents):
        raise SystemExit('editor census: not the state entries')
    return route


def header(ents, evs, default, route):
    lines = ['/* juno_state_tables.h -- GENERATED by tools/verify/gen_state_tables.py; do not edit.',
             ' *',
             ' * How the plugin\'s own preset paths hand the engine its parameters (CLAIMS B6),',
             ' * EXECUTED in the booted plugin (probes/b6/): every path queues engine events',
             ' * (id, value) that the render driver applies through the host entry (rva',
             ' * 0x3C7AE0, flag 0) at the start of the next block, in queue order.',
             ' *   JUNO_STATE_ENT  IComponent::setState / initialize: the parameter list, in',
             ' *                   order; the value a payload entry takes (& mask, 0 = as',
             ' *                   given), the default initialize queues. 95 entries.',
             ' *   JUNO_PATCH_EV   the plugin\'s patch load (its patch browser: rva 0x335850):',
             ' *                   the tree order, each value decoded from the record at its',
             ' *                   offset (derived: the one decode reproducing all 72 censused',
             ' *                   records). %d events.' % len(evs),
             ' *   JUNO_DEFAULT_REC  the model at boot as the plugin serializes it (rva',
             ' *                   0x335990), behind a 16-byte name: the record whose values',
             ' *                   the engine has never been sent beyond the defaults.',
             ' *   JUNO_STATE_EDIT_HOST  the editor\'s set of each entry (the model\'s set, rva',
             ' *                   0x283DB0, as a panel control makes it; tools/verify/',
             ' *                   juno_model_census.py): 1 the host\'s automation round trip --',
             ' *                   beginEdit, performEdit(id, (float)(stored - min) / (float)(max',
             ' *                   - min)), endEdit, no engine record --, 0 one engine record.',
             ' */',
             '#ifndef JUNO_STATE_TABLES_H',
             '#define JUNO_STATE_TABLES_H',
             '#include <stdint.h>',
             'enum { JUNO_SE_NONE = -1, JUNO_SE_VOICES = -2, JUNO_SE_SRATE = -3 };',
             'enum { JUNO_DEC_INT1X7 = 0, JUNO_DEC_INT2X4 = 1, JUNO_DEC_INT8X4 = 2, JUNO_DEC_INT4X4 = 3 };',
             'typedef struct { uint32_t id; int16_t host; uint32_t mask; int32_t dflt; } juno_state_ent;',
             'typedef struct { uint32_t id; int16_t host; uint16_t roff; uint8_t dec; } juno_patch_ev;',
             '#define JUNO_STATE_N %d' % len(ents),
             '#define JUNO_PATCH_EV_N %d' % len(evs),
             '#define JUNO_REC_BYTES %d' % STRIDE,
             'static const juno_state_ent JUNO_STATE_ENT[JUNO_STATE_N] = {']
    for pid, hi, mask, dflt in ents:
        lines.append('    { 0x%08Xu, %s, 0x%Xu, %d },' % (pid, hi, mask, dflt))
    lines.append('};')
    lines.append('static const juno_patch_ev JUNO_PATCH_EV[JUNO_PATCH_EV_N] = {')
    for pid, hi, o, dec in evs:
        lines.append('    { 0x%08Xu, %s, %du, %s },' % (pid, hi, o, DEC_NAMES[dec]))
    lines.append('};')
    lines.append('static const uint8_t JUNO_STATE_EDIT_HOST[JUNO_STATE_N] = {   /* the editor\'s set: 1 the host round trip */')
    for k in range(0, len(ents), 24):
        lines.append('    ' + ' '.join('%d,' % route[pid] for pid, _, _, _ in ents[k:k + 24]))
    lines.append('};')
    lines.append('static const unsigned char JUNO_DEFAULT_REC[JUNO_REC_BYTES] = {')
    for k in range(0, len(default), 24):
        lines.append('    ' + ''.join('%d,' % b for b in default[k:k + 24]))
    lines.append('};')
    lines.append('#endif /* JUNO_STATE_TABLES_H */')
    return '\n'.join(lines) + '\n'


def main():
    sys.path.insert(0, HERE)
    import truth
    bank = open(truth.BANK, 'rb').read()
    slc, smc = load('state_load_census.pkl'), load('state_mask_census.pkl')
    plc, craft, hmap = load('patch_load_census.pkl'), load('patch_load_census_craft.pkl'), load('pid_host_map.pkl')
    rows = host_rows()
    for pid, (k, name, d, lo, hi) in hmap.items():
        if rows[k][0] != name:
            raise SystemExit('host map: index %d is %s, not %s' % (k, rows[k][0], name))
    ents = state_entries(slc, smc, hmap)
    evs = patch_events(plc, craft, hmap, bank)
    default = b'-' * NAME + plc['default_bytes']
    if len(default) != STRIDE:
        raise SystemExit('default record: %d bytes' % len(default))
    # the port's own host table must agree with every derived record offset
    for pid, hi, o, dec in evs:
        if hi == 'JUNO_SE_NONE':
            continue
        name, roff, typ = rows[hi]
        want = {0: (roff, 0), 1: (roff, 1), 2: (roff - 6, 2), 3: (roff - 6, 2)}.get(typ)
        if typ == 4:
            print('NOTE: %s (context-held) decodes at record offset %d (%s)' % (name, o, DEC_NAMES[dec]))
        elif want != (o, dec):
            print('NOTE: %s: host table roff %d type %d, the plugin\'s patch load reads %d %s' % (name, roff, typ, o, DEC_NAMES[dec]))
    route = editor(ents, load('editor_census.pkl'))
    text = header(ents, evs, default, route)
    if '--check' in sys.argv[1:]:
        old = open(OUT).read() if os.path.exists(OUT) else None
        print('same: src/juno_state_tables.h' if old == text else 'DIFFERS: src/juno_state_tables.h')
        return 0 if old == text else 1
    open(OUT, 'w').write(text)
    print('wrote src/juno_state_tables.h: %d state entries, %d patch events, %d-byte default record'
          % (len(ents), len(evs), len(default)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
