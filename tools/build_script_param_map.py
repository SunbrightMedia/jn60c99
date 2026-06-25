#!/usr/bin/env python3
"""build_script_param_map.py — the DB-index -> param-name -> engine-offset bridge,
recovered from the plugin's own shipped Script.xml (the Roland parameter-definition
resource found in the VST files), which the decompiled PE does NOT contain.

Script.xml lists the JUNO-60 patch parameters in canonical (Roland address) order,
each with name / range / default, and parenthesises the names that are NOT exposed on
the JUNO-60 panel (System-8 framework params). Its order aligns 1:1 with the factory
preset DB synth block: Script patch param i  <->  DB-index (750 + i), validated by
range+default agreement and the proven anchor DCO RANGE == DB760 (OSC1 Feet, 8').

This closes the DB->engine binding that the PE binary alone left runtime-only:
  DB-index --(Script.xml order)--> param name --(docs/PARAM_MAP.tsv registry)--> engine offset

Outputs refs/script_param_map.json. Capture-free: Script.xml is the plugin's own data.
"""
import xml.etree.ElementTree as ET, json, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
XML = os.path.join(ROOT, 'refs/plugin_resources/Script.xml')

# Script panel-name -> registry name (docs/PARAM_MAP.tsv). Only where they differ;
# exact-name matches resolve automatically.
NAME_BRIDGE = {
    'LFO RATE': 'LFO Rate', 'LFO DELAY TIME': 'LFO Delay', 'DCO LFO MOD': 'LFO Level',
    'VCF LFO MOD': 'LFO Gain', 'DCO RANGE': 'OSC1 Feet', 'DCO SAW LEVEL': 'JU OSC Saw Lev',
    'DCO SQR LEVEL': 'JU OSC Sqr Lev', 'DCO SUB LEVEL': 'JU OSC Sub Lev',
    'DCO NOISE LEVEL': 'Osc Noise Level', 'VCF CUTOFF FREQ': 'LPF Cutoff',
    'VCF RESONANCE': 'LPF Resonance', 'HPF CUTOFF FREQ': 'HPF Cutoff',
    'VCF ENV MOD': 'ENV Level', 'VCF KEY FOLLOW': 'KCV Level', 'DCO PWM LEVEL': 'PWM Level',
    'DCO PWM DEPTH': 'PWM Level', 'ENV1 ATTACK': 'ENV Attack', 'ENV1 DECAY': 'ENV Decay',
    'ENV1 SUSTAIN': 'ENV Sustain', 'ENV1 RELEASE': 'ENV Release',
}

def load_registry():
    reg = {}
    for line in open(os.path.join(ROOT, 'docs/PARAM_MAP.tsv')).read().splitlines()[1:]:
        p = line.split('\t')
        if len(p) >= 3 and p[1].isdigit():
            off = int(p[1])
            if 320 <= off < 10832:          # voice-0 block only
                reg.setdefault(p[2].upper(), off)
    return reg

def script_order():
    r = ET.parse(XML).getroot()
    sts = {}
    for st in r.iter('structType'):
        seq = []
        for ch in st:
            if ch.tag == 'value':
                seq.append(('val', ch.findtext('name'), ch.findtext('range'),
                            ch.findtext('default'), ch.findtext('type')))
            elif ch.tag == 'struct':
                seq.append(('struct', ch.findtext('type')))
        sts[st.findtext('type')] = seq
    order = []
    def walk(ty, d=0, seen=frozenset()):
        if ty in seen or ty not in sts or d > 6:
            return
        seen = seen | {ty}
        for e in sts[ty]:
            if e[0] == 'val':
                order.append((e[1], e[2], e[3], e[4]))
            else:
                walk(e[1], d + 1, seen)
    walk('patch')
    return order

def main():
    reg = load_registry()
    order = script_order()
    out = []
    for i, (nm, rng, df, ty) in enumerate(order):
        panel = not (nm and nm.startswith('('))   # parens => not on the JUNO-60 panel
        off = None; via = None
        if panel and nm and nm != '_reserve_':
            bn = NAME_BRIDGE.get(nm, nm)
            if bn.upper() in reg:
                off, via = reg[bn.upper()], bn
        out.append({
            "db_index": 750 + i, "script_index": i, "name": nm, "range": rng,
            "default": df, "type": ty, "panel_exposed": panel,
            "engine_offset": off, "offset_via": via,
        })
    meta = {
        "purpose": "DB-index -> JUNO-60 param name + range/default + panel-exposure + engine offset, "
                   "recovered from the plugin's shipped Script.xml (Roland param-definition resource).",
        "alignment": "Script patch param i <-> DB-index (750+i); validated by range+default and the "
                     "proven anchor DCO RANGE == DB760 (OSC1 Feet).",
        "exposure_marker": "Parenthesised Script names = NOT on the JUNO-60 panel (System-8 framework).",
        "offset_chain": "DB-index -> name (Script) -> engine offset (docs/PARAM_MAP.tsv registry).",
        "counts": {
            "patch_params": len(out),
            "panel_exposed": sum(1 for e in out if e["panel_exposed"] and e["name"] != "_reserve_"),
            "engine_offset_resolved": sum(1 for e in out if e["engine_offset"] is not None),
        },
    }
    json.dump({"_meta": meta, "params": out},
              open(os.path.join(ROOT, 'refs/script_param_map.json'), 'w'), indent=1)
    print("wrote refs/script_param_map.json")
    for k, v in meta["counts"].items():
        print(f"  {k}: {v}")

if __name__ == '__main__':
    main()
