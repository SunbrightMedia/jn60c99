#!/usr/bin/env python3
"""fork_tab_input.py -- the input of gen_fork_tab.py, read from the plugin's own image (task #62: the
first input file, a dump of the plugin's doubles, is not in the repository).

The plugin's pitch polynomial table: 29 rows of 26 doubles at rva 0x9894E0 (src/juno_tables.h
juno_pitch_table, checked against the image by tools/repro/rdata_check.py); the evaluator reads the
even entries, v3[2k] for k = 0..12 (src/juno_dsp.c juno_pitch_poly). One line per coefficient:
"row k hex", the hex the double's big-endian bytes -- the format gen_fork_tab.py parses.
usage: python3 tools/engineb/fork_tab_input.py > FILE; python3 tools/engineb/gen_fork_tab.py FILE
"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
RVA, ROWS, ROW_DOUBLES = 0x9894E0, 29, 26


def main():
    import pefile
    import truth
    img = bytes(pefile.PE(truth.VST3).get_memory_mapped_image())
    for r in range(ROWS):
        row = struct.unpack_from('<%dd' % ROW_DOUBLES, img, RVA + 8 * ROW_DOUBLES * r)
        for k in range(13):
            print('%d %d %s' % (r, k, struct.pack('>d', row[2 * k]).hex()))


if __name__ == '__main__':
    main()
