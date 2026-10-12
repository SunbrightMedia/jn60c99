#!/usr/bin/env python3
"""jp8_controller_census.py -- the JUPITER-8's EDIT CONTROLLER surface, on the host oracle (jp8_host_emu.JP8Host after
boot_host: the controller created from the factory, initialized, connected, its handler set, setComponentState):
getParameterCount, every getParameterInfo (id, title, short title, units, step count, default, unit, flags), and
IMidiMapping::getMidiControllerAssignment for every controller number 0..129 on channels 0 and 15 (the ids a host
sends through process() for a MIDI CC, aftertouch (128) or pitch bend (129)). Oracle only (Unicorn), plumbing only.
Writes jp8/gen/jp8_controller.json (the data a C API needs to name the parameters) and prints a summary.
usage: python3 jp8/tools/jp8_controller_census.py [out.json]"""
import os
import sys
import json
import struct
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import jp8_host_emu as X            # noqa: E402
W = X.W
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, 'jp8', 'gen', 'jp8_controller.json')
IID_IMIDIMAPPING = W.vst_iid(0xDF0FF9F7, 0x49B74669, 0xB63AB732, 0x7ADBF5E5)
h = X.JP8Host()
h.boot_host(log=lambda m: None)
uc = h.uc
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
u32 = lambda r: r & 0xFFFFFFFF
ctrl = h.ctrl
n = u32(h.vcall(ctrl, 8))                                     # IEditController::getParameterCount
info = h.alloc_com(792)
s16 = lambda a: bytes(uc.mem_read(a, 256)).decode('utf-16-le', 'replace').split('\0')[0]
params = []
for i in range(n):
    uc.mem_write(info, b'\0' * 792)
    r = u32(h.vcall(ctrl, 9, i, info))                        # getParameterInfo(index, ParameterInfo&)
    pid, = struct.unpack('<I', uc.mem_read(info, 4))
    steps, = struct.unpack('<i', uc.mem_read(info + 772, 4))
    dflt, = struct.unpack('<d', uc.mem_read(info + 776, 8))
    unit, flags = struct.unpack('<ii', uc.mem_read(info + 784, 8))
    params.append(dict(index=i, result=r, id=pid, title=s16(info + 4), short=s16(info + 260), units=s16(info + 516),
                       steps=steps, default=dflt, unit=unit, flags=flags))
buf = h.alloc_com(0x40)
uc.mem_write(buf, IID_IMIDIMAPPING)
r = u32(h.vcall(ctrl, 0, buf, buf + 0x30))                    # queryInterface(IMidiMapping)
mm = q(buf + 0x30) if r == 0 else 0
cc = {}
if mm:
    for ch in (0, 15):
        for k in range(130):
            uc.mem_write(buf, b'\0' * 8)
            # getMidiControllerAssignment(bus 0, channel, cc, ParamID&): Win64, the fourth argument at [rsp + 0x28]
            # at entry (the oracle's call puts the return address at [top - 8] and starts there)
            uc.mem_write(h._top() - 8 + 0x28, struct.pack('<Q', buf))
            rr = u32(h.call(q(q(mm) + 8 * 3), rcx=mm, rdx=0, r8=ch, r9=k, count=2_000_000_000))
            cc['%d:%d' % (ch, k)] = [rr, struct.unpack('<I', uc.mem_read(buf, 4))[0]]
json.dump(dict(count=n, params=params, midi_mapping=bool(mm), cc=cc), open(out, 'w'), indent=0)
print('parameters: %d (getParameterInfo results %s)' % (n, sorted(set(p['result'] for p in params))))
for p in params[:6] + params[-4:]:
    print('  %4d id 0x%08x %-24r steps %3d default %.6f flags 0x%x units %r' % (p['index'], p['id'], p['title'][:24], p['steps'], p['default'], p['flags'], p['units']))
print('IMidiMapping: %s' % ('answered' if mm else 'NOT answered (0x%x)' % r))
if mm:
    for k in (0, 1, 7, 64, 120, 123, 127, 128, 129):
        print('  cc %3d ch 0 -> result 0x%x id 0x%x; ch 15 -> 0x%x id 0x%x' % ((k,) + tuple(cc['0:%d' % k]) + tuple(cc['15:%d' % k])))
print('wrote %s' % out)
