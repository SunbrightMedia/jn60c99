#!/usr/bin/env python3
"""jn_zoom_ref.py -- L5's editor + window-zoom drive, ORACLE side (jn_zoom_seq.py): per scenario a host oracle booted
and set up as junoh_init does (48 kHz, 512), its editor opened by host_process_emu.attach_editor, the steps run with the
plugin's own calls; after every step the zoom the window's getter returned, mainZoom / patchZoom from getState and the
end-state digest. Unicorn only (two-process rule).  usage: python3 tools/lift/jn_zoom_ref.py <out.json>"""
import os
import sys
import json
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
import truth                                                       # noqa: E402
import jn_zoom_seq as Z                                            # noqa: E402
import jn_ops                                                      # noqa: E402


def run(scn, panel, lay):
    h = H.HostProcess()
    h.start(48000.0, 512)
    ops = jn_ops.OracleOps(h, open(truth.BANK, 'rb').read())
    lay.update(ops.layout())
    q = lambda a: struct.unpack('<Q', h.uc.mem_read(a, 8))[0]

    def call(target, rcx, absolute=False):
        return h.call(target if absolute else H.IB + target, rcx=rcx, count=500_000_000)
    model = q(q(h.core + 8))
    obj = Z.value_objects(q, call, model)
    rows, zoom = [], None
    for st in Z.steps(scn):
        if st[0] == 'attach':
            h.attach_editor(st[1], st[2])
        elif st[0] == 'screen':
            h.screen = {0x4E: st[1], 0x4F: st[2]}
        elif st[0] == 'mset':
            h.call(H.IB + Z.MODEL_SET, rcx=model, rdx=obj[st[1]], r8=st[2] & 0xFFFFFFFF, r9=1, count=500_000_000)
            for rva in Z.TRIO:
                h.call(H.IB + rva, rcx=model, count=500_000_000)
        elif st[0] == 'conv':
            zoom = h.window_conv(panel[st[1]])
        elif st[0] == 'mark':
            d, ht, cn = ops.digest()
            rows.append(dict(label=st[1], zoom=zoom, zooms=Z.zooms_of(h.get_state()), digest=d, heap_top=ht, com_next=cn))
            zoom = None
    return rows


def main():
    panel = Z.panel_sizes()
    out = dict(panel={k: list(v) for k, v in panel.items()}, runs=[], layout={})
    for scn in Z.SCENARIOS:
        out['runs'].append(dict(scenario=scn, rows=run(scn, panel, out['layout'])))
        sys.stderr.write('scenario %s: %d steps\n' % (scn, len(out['runs'][-1]['rows'])))
    os.makedirs(os.path.dirname(os.path.abspath(sys.argv[1])), exist_ok=True)
    json.dump(out, open(sys.argv[1] + '.partial', 'w'))
    os.replace(sys.argv[1] + '.partial', sys.argv[1])


if __name__ == '__main__':
    main()
