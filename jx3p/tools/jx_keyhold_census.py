#!/usr/bin/env python3
"""jx_keyhold_census.py -- oracle-only census (JX-17b): what the JX-3P plugin's own code does with the keys its UI
timer has seen, when KEY HOLD (0x00600138) reads 0 -- the JUNO-60's mechanism (CLAIMS A36, gui/juno_bridge.c
ks_release; the JX's UI timer handler 0x320000 == the JUNO's 0x320120, fw_map --pair) on the JX.

The plugin booted as a host boots it (jx_host_emu.JXHost), its first block run; then per case: note-ons through
process() (the push queues them for the UI timer too), the UI timer's handler (the core's slot 1, rva 0x320000)
draining that queue into the keyboard's note value, and a step -- a patch browser load (every factory patch has
KEY HOLD = 0), a setState holding KEY HOLD (0 / 1, first / last / alone) -- after which the queue's new records
(kind 0 = a MIDI note-off the release made, kind 2 = a parameter record) are recorded in order.
Writes scratchpad/jx_state/keyhold_census.pkl.     python3 jx3p/tools/jx_keyhold_census.py   (Unicorn only)
"""
import os
import pickle
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_host_emu as X                               # noqa: E402
import jx_bank as B                                   # noqa: E402

OUT = os.path.join(REPO, 'scratchpad', 'jx_state', 'keyhold_census.pkl')
UI_DRAIN = 0x320000
KEY_HOLD = 0x00600138


def payload(entries):
    pl = b''.join(struct.pack('>Ii', a, v) for a, v in entries)
    return struct.pack('>I', len(pl)) + pl


def rec(q):
    kind, off, raw = q
    if kind == 0:
        return (0, off, raw[8], raw[9], raw[10])          # a MIDI message's three bytes (core queue record +8)
    return (kind, off, struct.unpack_from('<I', raw, 12)[0], struct.unpack_from('<i', raw, 20)[0])


def main():
    t0 = time.time()
    bank = B.bank_bytes()
    h = X.JXHost()
    h.start(48000.0, 512)
    h.process(256)
    res = []

    def case(name, step):
        h.process(256, events=[('on', 0, 0, 60, 0.8), ('on', 7, 0, 64, 0.5), ('on', 9, 0, 67, 0.3)])
        h.call(X.IB + UI_DRAIN, rcx=h.core, count=2_000_000_000)
        n0 = len(h.queue())
        step()
        new = [rec(q) for q in h.queue()[n0:]]
        res.append(dict(name=name, queue=new))
        print('%-34s %d records, %d MIDI (positions %s)' % (name, len(new), sum(1 for r in new if r[0] == 0),
                                                         [i for i, r in enumerate(new) if r[0] == 0]), flush=True)
        h.process(256, events=[('off', 0, 0, 60, 0.0), ('off', 0, 0, 64, 0.0), ('off', 0, 0, 67, 0.0)])
        h.process(256)
    case('patch 5', lambda: h.load_patch(B.patch_blob(bank, 5)))
    case('setState KEY HOLD 0 alone', lambda: h.set_state(payload([(KEY_HOLD, 0)])))
    case('setState KEY HOLD 0 middle', lambda: h.set_state(payload([(0x0060003A, 40), (KEY_HOLD, 0), (0x00600004, 9)])))
    case('setState KEY HOLD 1', lambda: h.set_state(payload([(KEY_HOLD, 1)])))
    case('setState KEY HOLD 1 then 0', lambda: h.set_state(payload([(KEY_HOLD, 1), (0x0060003E, 7), (KEY_HOLD, 0)])))
    case('setState no KEY HOLD', lambda: h.set_state(payload([(0x0060003A, 41)])))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    pickle.dump(res, open(OUT, 'wb'))
    print('wrote %s (%.0fs)' % (OUT, time.time() - t0))


if __name__ == '__main__':
    main()
