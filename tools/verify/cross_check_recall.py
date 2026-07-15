#!/usr/bin/env python3
"""cross_check_recall.py -- enumerate candidate recall discrepancies (voice-0).

Pure pickle analysis (loads saved data; runs neither engine -> no two-process issue):
  - param_cell_map.pkl  : plugin's PROVEN param_id -> cells it writes (param_cell_map.py)
  - port_state.pkl      : port's unit-0 voice-0 block per patch (port_state_dump.py)

Reports, for voice-0 cells (offset < 10512):
  A) cells the PLUGIN's recallable params can write, that the PORT never varies
     across the 64 patches  -> the port may be dropping a recalled param
     (feet 3840 / DCO RANGE is the known example).
  B) cells the PORT varies across patches, that NO plugin param writes
     -> the port may be recalling something spurious.

These are CANDIDATES. Whether the plugin actually emits a given param per patch is
the host-mediated question (handled by the recall agent); this narrows where to look.
"""
import struct, pickle

PCM  = '/home/user/jn60c99/scratchpad/param_cell_map.pkl'
PORT = '/home/user/jn60c99/scratchpad/port_state.pkl'
VOICE = 10512
STRIDE = 16


def main():
    pcm = pickle.load(open(PCM, 'rb'))       # {param_id: (idx, [cells])}
    port = pickle.load(open(PORT, 'rb'))      # {patch: bytes(VOICE)}

    # plugin voice-0 cells + which params write each
    cell_params = {}
    for pid, (idx, cells) in pcm.items():
        for off in cells:
            if off < VOICE:
                cell_params.setdefault(off, []).append((pid, idx))
    plugin_cells = set(cell_params)

    # port cells that vary across patches
    patches = sorted(port)
    port_varied = {}
    for off in range(0, VOICE, STRIDE):
        vals = {struct.unpack('<I', port[p][off:off + 4])[0] for p in patches}
        if len(vals) > 1:
            port_varied[off] = len(vals)
    port_cells = set(port_varied)

    print("=== recall cross-check (voice-0 cells, %d patches) ===" % len(patches))
    print("plugin recallable voice-0 cells: %d ; port-varied voice-0 cells: %d\n"
          % (len(plugin_cells), len(port_cells)))

    only_plugin = sorted(plugin_cells - port_cells)
    print("A) PLUGIN can write, PORT never varies  (%d) -- port may drop these:" % len(only_plugin))
    for off in only_plugin:
        who = ", ".join("param %d/idx %d" % (p, i) for (p, i) in cell_params[off][:3])
        print("   cell %5d  <- %s" % (off, who))

    only_port = sorted(port_cells - plugin_cells)
    print("\nB) PORT varies, NO plugin param writes  (%d) -- port may recall spurious:" % len(only_port))
    for off in only_port:
        print("   cell %5d  (varies over %d distinct values)" % (off, port_varied[off]))

    both = sorted(plugin_cells & port_cells)
    print("\nC) agree (plugin writes + port varies): %d cells" % len(both))
    print("   %s" % both)


if __name__ == '__main__':
    main()
