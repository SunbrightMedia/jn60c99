#!/usr/bin/env python3
"""jn_proc_ref.py -- L5 (process) ORACLE side: the JUNO host oracle (host_process_emu) booted, then the shared process
drive (jn_proc_seq.steps). Writes every output word (L then R, per block) the lifted side must reproduce exactly, plus
the performEdit calls and the render count. Unicorn only (two-process rule). usage: jn_proc_ref.py <outdir>"""
import sys
import os
import json
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, os.path.join(REPO, 'tools', 'lift'))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
import jn_proc_seq                                                 # noqa: E402


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    h = H.HostProcess()
    h.start(48000.0, 512)
    words = bytearray()
    for st in jn_proc_seq.steps():
        L, R = h.process(st['n'], events=list(st['events']), params=list(st['params']), ctx=jn_proc_seq.oracle_ctx(st['ctx']))
        if st['n']:
            words += struct.pack('<%dI' % len(L), *L) + struct.pack('<%dI' % len(R), *R)
    open(os.path.join(out, 'words.bin'), 'wb').write(bytes(words))
    edits = [[e[1], struct.unpack('<Q', struct.pack('<d', e[2]))[0]] for e in h.edits if e[0] == 'performEdit']
    json.dump(dict(nsteps=len(jn_proc_seq.steps()), nwords=len(words) // 4, edits=edits), open(os.path.join(out, 'meta.json'), 'w'))
    print('oracle process ref: %d output words, %d performEdits -> %s' % (len(words) // 4, len(edits), out))


if __name__ == '__main__':
    main()
