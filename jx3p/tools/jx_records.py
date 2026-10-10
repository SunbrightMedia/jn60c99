#!/usr/bin/env python3
"""jx_records.py -- the factory bank's patch-load records (jx3p/gen/jx_patch_records.json: what the plugin's
patch browser queues for each patch, recorded by jx_patch_records.py) and the gates' VARIANT patches, with no
Unicorn import: a port process may load it (the two-process rule).

  variant_records('34:67=3')          patch 34's records, record 67's value set to 3
  variant_records('34:+0x600120=8')   patch 34's records, then one for model id 0x600120 = 8
  pairs(recs)                         the kind-2 (engine parameter) records as (id, 32-bit value) pairs
"""
import copy
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
PATCH_RECORDS = os.path.join(os.path.dirname(HERE), 'gen', 'jx_patch_records.json')
_cache = {}


def records():
    if 'r' not in _cache:
        _cache['r'] = json.load(open(PATCH_RECORDS))
    return _cache['r']


def variant_records(spec):
    """'34:67=3' -> factory patch 34's patch-load records with record 67's value set to 3 (several 'idx=val'
    pairs may follow, comma-separated). The records stay the plugin's own; only a value changes, to one the
    plugin's host entry accepts. '+0xID=V' appends a record for a model id the patch does not carry (its GUI's
    controls, e.g. the step pattern's row 0x600120 and column 0x600128 -- jx3p/docs/HOST_LAYER.md 3e), after
    the load, as the editor sends it; V may be negative (the value travels as its 32 bits)."""
    base, _, edits = spec.partition(':')
    recs = copy.deepcopy(records()['patches'][int(base)])
    for e in filter(None, edits.split(',')):
        i, _, v = e.partition('=')
        if i.startswith('+'):
            recs.append([2, int(i[1:], 0), int(v, 0)])
        else:
            recs[int(i)][2] = int(v, 0)
    return recs


def pairs(recs):
    return [(pid, val & 0xFFFFFFFF) for kind, pid, val in recs if kind == 2]
