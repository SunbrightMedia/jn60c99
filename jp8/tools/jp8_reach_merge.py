#!/usr/bin/env python3
"""jp8_reach_merge.py -- the UNION of dynamic reach files of the JUPITER-8's host path (jp8_host_dynreach.py), for a
lift that must hold more than one drive: e.g. the 64-patch reach at the first rate 48000 and short reaches of the
same drive set up first at 44100 and 96000. Executed instructions, indirect targets, stub names and the roots (the
entries each drive called) are united -- one root name at two addresses stops it; the drives are listed. Plumbing
only.
usage: jp8_reach_merge.py <out.json> <reach.json> <reach.json> [...]"""
import sys
import json
import collections
out, ins = sys.argv[1], sys.argv[2:]
if len(ins) < 2:
    raise SystemExit(__doc__)
executed, stubs, roots, drives = set(), collections.Counter(), None, []
indirect = collections.defaultdict(set)
for path in ins:
    d = json.load(open(path))
    if roots is None:
        roots = dict(d['roots'])
    for k, v in d['roots'].items():               # the roots united; one name at two addresses is not the same plugin
        if roots.setdefault(k, v) != v:
            raise SystemExit('%s: root %s at 0x%x, %s has it at 0x%x' % (path, k, v, ins[0], roots[k]))
    executed.update(int(a, 16) for a in d['executed'])
    for s, ts in d['indirect'].items():
        indirect[int(s, 16)].update(int(t, 16) for t in ts)
    stubs.update(d['stubs'])
    drives.append(dict(file=path, rate=d.get('rate'), patches=d.get('patches'), drive=d.get('drive'), merged=d.get('merged')))
json.dump(dict(drive='union', merged=drives, roots=roots, rate=json.load(open(ins[0])).get('rate'),
               executed=sorted('%x' % a for a in executed),
               indirect={'%x' % s: sorted('%x' % t for t in ts) for s, ts in indirect.items()}, stubs=dict(stubs)),
          open(out, 'w'))
print('%s: %d executed, %d indirect sites, %d stub names from %d reaches' % (out, len(executed), len(indirect), len(stubs), len(ins)))
