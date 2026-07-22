#!/usr/bin/env python3
"""PILLAR 1 / Stage A — enumerate the plugin's COMPLETE value-tree leaf surface
from its own Script.xml (allowed plugin data), with struct context + dispatch
index. This is the parameter axis of COVERAGE.tsv: one row per dispatchable
leaf, sourced from the binary's own tree (NOT a curated list), so 'we forgot a
param' is impossible — every leaf appears whether or not anyone thought of it.

Dispatch index = flat <value> position + 740 (matches e2e_emu.load_leaves and
the value-tree dispatch 0x3B9A30). Emits tools/verify/coverage_leaves.tsv.
"""
import sys, re, json
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import truth

OUT = '/home/user/jn60c99/tools/verify/coverage_leaves.tsv'
x = open(truth.SCRIPT_XML, encoding='utf-8', errors='replace').read()

# Walk the document in order, tracking the enclosing <structType><type>NAME</type>
# and numbering every <value> leaf by its global appearance order (= dispatch-740).
struct_re = re.compile(r'<structType>\s*<type>(.*?)</type>\s*<name>(.*?)</name>', re.S)
# Tokenize: find each structType open (with its type) and each <value>…</value>.
events = []
for m in re.finditer(r'<structType>|<value>(.*?)</value>', x, re.S):
    if m.group(0).startswith('<structType>'):
        # capture the type that follows
        tm = re.match(r'<structType>\s*<type>(.*?)</type>', x[m.start():m.start()+400], re.S)
        events.append(('struct', tm.group(1) if tm else '?'))
    else:
        events.append(('value', m.group(1)))

rows = []
cur_struct = '?'
pos = 0
for kind, payload in events:
    if kind == 'struct':
        cur_struct = payload
        continue
    v = payload
    nm = re.search(r'<name>(.*?)</name>', v)
    ty = re.search(r'<type>(.*?)</type>', v)
    rng = re.search(r'<range>(.*?)</range>', v)
    dfl = re.search(r'<default>(.*?)</default>', v)
    nm = nm.group(1) if nm else '?'
    ty = ty.group(1) if ty else '?'
    rng = rng.group(1) if rng else ''
    dfl = dfl.group(1) if dfl else ''
    disp = pos + 740
    rows.append({'pos': pos, 'disp': disp, 'struct': cur_struct, 'name': nm,
                 'type': ty, 'range': rng, 'default': dfl})
    pos += 1

# family: original PATCH set vs extended PATCH2 (PAT2_*) vs SYSTEM/SETUP/SYNTH
def family(s):
    if s.startswith('PAT2_'): return 'PATCH2'
    if s in ('SYS_COM',): return 'SYSTEM'
    if s in ('ARP', 'SCAT'): return 'SETUP'
    if s in ('SYN_COM',): return 'SYNTH'
    if s.startswith('PAT_NAME') or s == 'name0': return 'NAME'
    return 'PATCH'

with open(OUT, 'w') as f:
    f.write("pos\tdisp\tfamily\tstruct\tname\ttype\trange\tdefault\n")
    for r in rows:
        f.write("%d\t%d\t%s\t%s\t%s\t%s\t%s\t%s\n" % (
            r['pos'], r['disp'], family(r['struct']), r['struct'],
            r['name'], r['type'], r['range'], r['default']))

from collections import Counter
fam = Counter(family(r['struct']) for r in rows)
namep = sum(1 for r in rows if family(r['struct']) == 'NAME')
print("total leaves: %d  dispatch %d..%d" % (len(rows), rows[0]['disp'], rows[-1]['disp']))
print("by family:", dict(fam))
print("non-NAME dispatchable leaves:", len(rows) - namep)
print("wrote", OUT)
