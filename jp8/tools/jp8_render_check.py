#!/usr/bin/env python3
"""jp8_render_check.py -- grades jp8/apps/jp8_render (the JUPITER-8 render CLI on the lifted host path) against the
plugin itself: the host oracle (jp8_host_emu.JP8Host, the plugin's own code under Unicorn) boots as the template was
taken (boot_host), makes the setup the CLI's jp8h_init makes (the rate, a maximum block of 512), loads the same
factory record through the plugin's own patch load, then replays the CLI's PLAN -- every block's note events and
parameter points exactly as the CLI handed them to process() -- and every output word must equal the WAV's.
Two processes (the CLI is its own); plumbing only: the plan is replayed, never re-derived from the MIDI file.
    python3 jp8/tools/jp8_render_check.py <patch 0-63> <plan.txt> <out.wav> [rate=48000]
--write-midi <out.mid>: writes the check's MIDI script (notes over two tracks, a tempo change, CC 1 / 7 / 11 / 64,
pitch bend, channel pressure, a second channel) and exits.
exit 0 = EXACTLY 0."""
import sys, os, struct, time
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)


def vlq(v):
    out = [v & 0x7F]; v >>= 7
    while v:
        out.append(0x80 | (v & 0x7F)); v >>= 7
    return bytes(reversed(out))


def write_midi(path):
    """a format-1 file: track 0 tempo (120 bpm, then 96 at beat 4), track 1 the playing on channels 0 and 3"""
    div = 480
    t0_ = [(0, b'\xff\x51\x03' + (500000).to_bytes(3, 'big')), (4 * div, b'\xff\x51\x03' + (625000).to_bytes(3, 'big'))]
    ev = []
    def at(beat, data): ev.append((int(beat * div), data))
    for i, k in enumerate((48, 55, 60, 64)):                    # a chord, struck in a spread, released in turn
        at(0 + 0.05 * i, bytes([0x90, k, 60 + 15 * i])); at(2 + 0.1 * i, bytes([0x80, k, 64]))
    at(0.5, bytes([0xB0, 1, 0])); at(1.0, bytes([0xB0, 1, 90])); at(1.5, bytes([0xB0, 1, 0]))   # mod wheel
    at(1.2, bytes([0xB0, 7, 100])); at(1.7, bytes([0xB0, 11, 70]))                             # volume, expression
    at(2.5, bytes([0x90, 67, 100])); at(2.6, bytes([0xE0, 0x00, 0x60])); at(2.9, bytes([0xE0, 0x7F, 0x7F]))
    at(3.2, bytes([0xE0, 0x00, 0x40])); at(3.3, bytes([0xD0, 80])); at(3.6, bytes([0xD0, 0])); at(3.8, bytes([0x80, 67, 0]))
    at(4.0, bytes([0xB0, 64, 127])); at(4.1, bytes([0x93, 72, 110])); at(4.3, bytes([0x83, 72, 0]))   # sustain over a release
    at(5.0, bytes([0xB0, 64, 0])); at(5.2, bytes([0x90, 60, 0]))                                      # pedal up; a note-on of velocity 0
    at(5.5, bytes([0x90, 52, 90])); at(5.5, bytes([0x90, 59, 90])); at(6.5, bytes([0x80, 52, 0])); at(6.5, bytes([0x80, 59, 0]))
    def track(events):
        events = sorted(events, key=lambda e: e[0]); out = b''; last = 0
        for t, d in events:
            out += vlq(t - last) + d; last = t
        out += b'\x00\xff\x2f\x00'
        return b'MTrk' + struct.pack('>I', len(out)) + out
    data = b'MThd' + struct.pack('>IHHH', 6, 1, 2, div) + track(t0_) + track(ev)
    open(path, 'wb').write(data)


if len(sys.argv) > 2 and sys.argv[1] == '--write-midi':
    write_midi(sys.argv[2]); print('wrote %s' % sys.argv[2]); sys.exit(0)
if len(sys.argv) < 4:
    sys.exit(__doc__)
patch, plan_path, wav_path = int(sys.argv[1]), sys.argv[2], sys.argv[3]
rate = float(sys.argv[4]) if len(sys.argv) > 4 else 48000.0
import jp8_host_emu as X, jp8_bank as B, jp8_host_seq as Q
blocks = []
for ln in open(plan_path):
    f = ln.split()
    if not f: continue
    if f[0] == 'B': blocks.append([int(f[1]), [], []])
    elif f[0] == 'E':
        blocks[-1][1].append(('on' if f[1] == '1' else 'off', int(f[2]), int(f[3]), int(f[4]), struct.unpack('<f', struct.pack('<I', int(f[5], 16)))[0]))
    elif f[0] == 'P':
        blocks[-1][2].append((int(f[1], 16), int(f[2]), struct.unpack('<d', struct.pack('<Q', int(f[3], 16)))[0]))
    else: sys.exit('a plan line not understood: %s' % ln)
w = open(wav_path, 'rb').read()
assert w[:4] == b'RIFF' and w[8:16] == b'WAVEfmt ' and w[36:40] == b'data', 'not the CLI\'s WAV'
fmt, nch, wrate = struct.unpack('<HHI', w[20:28]); assert (fmt, nch, wrate) == (3, 2, int(rate)), 'the WAV is not stereo float at %g' % rate
data = w[44:]; frames = len(data) // 8
assert frames == sum(b[0] for b in blocks), 'the WAV holds %d frames, the plan %d' % (frames, sum(b[0] for b in blocks))
h = X.JP8Host()
h.boot_host(log=log)
h.heap_reuse_on()
h.host_setup(rate, Q.MAXBLOCK, Q.NPQ)
bank = B.bank_bytes()
log('patch %d %r; %d blocks, %d events, %d points to replay' % (patch, B.patch_name(bank, patch), len(blocks),
    sum(len(b[1]) for b in blocks), sum(len(b[2]) for b in blocks)))
h.load_patch(B.patch_blob(bank, patch))
pos = 0; bad = 0
for k, (n, evs, pars) in enumerate(blocks):
    L, R = h.process(n, events=evs, params=pars)
    for i in range(n):
        cl, cr = struct.unpack_from('<II', data, 8 * (pos + i))
        if (cl, cr) != (L[i] & 0xFFFFFFFF, R[i] & 0xFFFFFFFF):
            if bad < 5:
                log('block %d sample %d: oracle %08x %08x CLI %08x %08x' % (k, i, L[i] & 0xFFFFFFFF, R[i] & 0xFFFFFFFF, cl, cr))
            bad += 1
    pos += n
    if k % 200 == 0: log('block %d of %d, %d words differ so far' % (k, len(blocks), bad))
print('JP8 RENDER CLI (patch %d, %d frames at %g Hz, %d blocks): %s' % (patch, frames, rate, len(blocks),
      'EXACTLY 0 -- every output word is the plugin\'s' if not bad else '%d frames differ -- NOT bit-exact' % bad))
sys.exit(0 if not bad else 1)
