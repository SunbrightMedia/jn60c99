#!/usr/bin/env python3
"""jp8_native_fuzz.py -- RANDOM HOST INPUT graded against the real plugin on a CPU (the native oracle, scope row 23).
Each case is a seeded PLAN (jp8_plan_replay.c's text): blocks of random sizes up to the host maximum (512 most often,
any size, 0 and 1 and the maximum sometimes), note events (any channel, pitches 0..127, velocities as hosts send them,
a velocity 0 now and then, re-strikes and releases inside blocks), parameter queue points on ANY of the 226 controller
ids of the census (jp8/gen/jp8_controller.json: the 96 panel parameters, CC 0..127, aftertouch, bend; at most 8 ids a
block -- the queues a host hands -- each id's points in offset order; values uniform, on the parameter's grid, at the
edges, and a few a host would never send), and in some cases a running host clock (the ProcessContext: tempo, ppq,
playing, the cycle). The port (jp8_plan_replay: the lifted host path) and the plugin (jp8_native_host.exe under wine)
replay it after the same factory patch load; every output word must be equal.
Plumbing only: the generator draws host input, it never models the plugin.
    python3 jp8/tools/native/jp8_native_fuzz.py <replay binary> <seed> <cases> [--rates 48000,44100,96000]
        [--maxblock 4096] [--blocks 300] [--ids all|panel|midi] [--work DIR] [--keep DIR] [--tooth BINARY] [--control]
--tooth BINARY: a replay built on a slipped lift; its first case must DIFFER (the fuzz can see a port defect).
--control: the first case also replayed through the Unicorn oracle (jp8_render_check.py: no clock, max block 512):
           the native harness must equal the proven path on it.
exit 0 = every case EXACTLY 0 (and the tooth bites / the control holds)."""
import sys, os, struct, random, subprocess, argparse, time, json, shutil
HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(TOOLS))
sys.path.insert(0, HERE); sys.path.insert(0, TOOLS)
os.environ.setdefault('JP8_EMU_QUIET', '1')
t0 = time.time()
def log(m): print('[%7.1fs] %s' % (time.time() - t0, m), flush=True)

def fbits(x): return struct.unpack('<I', struct.pack('<f', x))[0]
def dbits(x): return struct.unpack('<Q', struct.pack('<d', x))[0]


def gen_plan(rng, nblocks, maxblock, rate, ids, clock):
    """one case's plan lines; held notes are all released before a tail of a third of the blocks"""
    lines = []; held = []
    tempo = rng.choice([60.0, 90.0, 120.0, 133.3, 140.0, 174.0, 200.0, 240.0]); ppq = rng.choice([0.0, 3.5, 16.0])
    playing = True; cyc = (0.0, 4.0) if rng.random() < 0.5 else None
    tail_from = nblocks - nblocks // 3
    for b in range(nblocks):
        r = rng.random()
        n = 512 if r < 0.45 else rng.randint(1, maxblock) if r < 0.9 else rng.choice([0, 1, 2, 3, maxblock, maxblock - 1])
        n = min(n, maxblock)
        lines.append('B %d' % n)
        if clock:
            if rng.random() < 0.03: playing = not playing
            if rng.random() < 0.02: tempo = rng.choice([70.0, 120.0, 128.0, 150.0, 180.0])
            if rng.random() < 0.01: ppq = rng.choice([0.0, 8.0, 32.25])                    # a locate
            st = 0x400 | 0x200 | (0x2 if playing else 0) | ((0x4 | 0x1000) if cyc else 0)   # tempo, ppq, playing, cycle
            lines.append('C %x %016x %016x %016x %016x' % (st, dbits(ppq), dbits(tempo), dbits(cyc[0] if cyc else 0.0),
                                                          dbits(cyc[1] if cyc else 0.0)))
            if playing:
                ppq += n / rate * tempo / 60.0
                if cyc and ppq >= cyc[1]: ppq -= cyc[1] - cyc[0]
        if n == 0:
            continue
        evs = []
        if b < tail_from:
            for _ in range(rng.choice([0, 0, 0, 1, 1, 2, 3, 6])):
                off = rng.randrange(n)
                if held and rng.random() < 0.45:
                    ch, p = held.pop(rng.randrange(len(held)))
                    v = rng.choice([0.0, 0.5, 64 / 127.0, 1.0])
                    evs.append((off, 0, ch, p, v))
                else:
                    ch = rng.choice([0, 0, 0, 0, 1, 4, 9, 15]); p = rng.choice([rng.randint(36, 96), rng.randint(0, 127)])
                    v = rng.choice([rng.randint(1, 127) / 127.0, rng.random(), 1.0, 0.0 if rng.random() < 0.1 else 0.3])
                    evs.append((off, 1, ch, p, v)); held.append((ch, p))
        elif held:
            for ch, p in held:
                evs.append((rng.randrange(n), 0, ch, p, 0.0))
            held = []
        evs.sort(key=lambda e: e[0])
        for off, on, ch, p, v in evs:
            lines.append('E %d %d %d %d %08x' % (on, off, ch, p, fbits(v)))
        if rng.random() < 0.35:
            for pid, steps in rng.sample(ids, min(len(ids), rng.randint(1, 8))):
                pts = sorted(rng.randrange(n) for _ in range(rng.choice([1, 1, 2, 4])))
                for off in pts:
                    r = rng.random()
                    if r < 0.6: v = rng.random()
                    elif r < 0.85: v = rng.randint(0, max(steps, 127)) / float(max(steps, 127))
                    elif r < 0.97: v = rng.choice([0.0, 1.0, 0.5])
                    else: v = rng.choice([1e-300, 1.0 - 1e-16, 5e-324, -0.0])
                    lines.append('P %08x %d %016x' % (pid, off, dbits(v)))
    return lines


def raw_to_wav(raw, plan_lines, rate, path):
    """the per-block L / R output as the CLI's interleaved float WAV (for jp8_render_check.py, the Unicorn control)"""
    ns = [int(l.split()[1]) for l in plan_lines if l.startswith('B ')]
    out = bytearray(); o = 0
    for n in ns:
        L = raw[o:o + 4 * n]; R = raw[o + 4 * n:o + 8 * n]; o += 8 * n
        for i in range(n):
            out += L[4 * i:4 * i + 4] + R[4 * i:4 * i + 4]
    hdr = b'RIFF' + struct.pack('<I', 36 + len(out)) + b'WAVEfmt ' + struct.pack('<IHHIIHH', 16, 3, 2, int(rate), int(rate) * 8, 8, 32) \
        + b'data' + struct.pack('<I', len(out))
    open(path, 'wb').write(hdr + bytes(out))


def first_diff(a, b, plan_lines):
    ns = [int(l.split()[1]) for l in plan_lines if l.startswith('B ')]
    o = 0
    for k, n in enumerate(ns):
        for ch in (0, 1):
            x, y = a[o + 4 * n * ch:o + 4 * n * (ch + 1)], b[o + 4 * n * ch:o + 4 * n * (ch + 1)]
            if x != y:
                i = next(i for i in range(n) if x[4 * i:4 * i + 4] != y[4 * i:4 * i + 4])
                return 'block %d (%d samples) %s sample %d: port %08x native %08x' % (
                    k, n, 'LR'[ch], i, struct.unpack_from('<I', x, 4 * i)[0], struct.unpack_from('<I', y, 4 * i)[0])
        o += 8 * n
    return 'lengths differ (%d / %d bytes)' % (len(a), len(b))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('replay'); ap.add_argument('seed', type=int); ap.add_argument('cases', type=int)
    ap.add_argument('--rates', default='48000,44100,96000'); ap.add_argument('--maxblock', type=int, default=4096)
    ap.add_argument('--blocks', type=int, default=300); ap.add_argument('--work', default=os.path.join(REPO, 'build', 'jp8_fuzz'))
    ap.add_argument('--keep'); ap.add_argument('--tooth'); ap.add_argument('--control', action='store_true')
    ap.add_argument('--ids', default='all', choices=('all', 'panel', 'midi'),
                    help='the parameter ids drawn: all 226, the 96 panel parameters, or the 130 MIDI ones (CC, aftertouch, bend)')
    a = ap.parse_args()
    import jp8_native_check as N
    os.makedirs(a.work, exist_ok=True)
    tmpl = os.path.join(a.work, 'jp8h_template.bin')
    if not os.path.exists(tmpl):
        subprocess.run('gunzip -c %s > %s' % (os.path.join(REPO, 'jp8', 'gen', 'jp8h_template.bin.gz'), tmpl), shell=True, check=True)
    bank = os.path.join(REPO, 'jp8', 'truth', '1_Preset.bin')
    cen = json.load(open(os.path.join(REPO, 'jp8', 'gen', 'jp8_controller.json')))
    ids = [(p['id'], p['steps']) for p in cen['params']]
    assert len(ids) == cen['count'] == 226, 'the census is not the 226 controller parameters'
    if a.ids != 'all':
        ids = [x for x in ids if (x[0] < 0x0FFFC100) == (a.ids == 'panel')]
    rates = [float(r) for r in a.rates.split(',')]
    rng = random.Random(a.seed); bad = 0; frames = 0
    for c in range(a.cases):
        patch = rng.randrange(64); rate = rng.choice(rates); clock = rng.random() < 0.4
        maxblock = rng.choice([512, 512, a.maxblock, rng.randint(1, a.maxblock)])
        if c == 0 and a.control:
            clock = False; maxblock = 512
        lines = gen_plan(rng, a.blocks, maxblock, rate, ids, clock)
        tag = 's%d_c%d' % (a.seed, c)
        plan = os.path.join(a.work, tag + '.plan'); open(plan, 'w').write('\n'.join(lines) + '\n')
        port = os.path.join(a.work, tag + '.port'); nat = os.path.join(a.work, tag + '.native')
        r = subprocess.run([a.replay, tmpl, bank, str(patch), plan, '%r' % rate, str(maxblock), port], capture_output=True, text=True)
        json.dump(dict(patch=patch, rate=rate, maxblock=maxblock, clock=clock), open(os.path.join(a.work, tag + '.json'), 'w'))
        if r.returncode:
            log('case %d: patch %d at %g Hz, max block %d: the port replay failed: %s' % (
                c, patch, rate, maxblock, (r.stdout + r.stderr).strip()[-300:])); bad += 1
            if a.keep:
                os.makedirs(a.keep, exist_ok=True); shutil.copy(plan, a.keep); shutil.copy(os.path.join(a.work, tag + '.json'), a.keep)
            continue
        N.run_native(os.path.join(a.work, 'native'), patch, plan, rate, nat, maxblock)
        x, y = open(port, 'rb').read(), open(nat, 'rb').read()
        nb = sum(1 for l in lines if l.startswith('B ')); fr = sum(int(l.split()[1]) for l in lines if l.startswith('B '))
        frames += fr
        what = '%d blocks, %d frames, max block %d, %s, %d events, %d points' % (nb, fr, maxblock, 'a host clock' if clock else 'no clock',
               sum(1 for l in lines if l.startswith('E ')), sum(1 for l in lines if l.startswith('P ')))
        if x == y:
            log('case %d: patch %d at %g Hz (%s): EXACTLY 0' % (c, patch, rate, what))
        else:
            bad += 1; log('case %d: patch %d at %g Hz (%s): DIFFERS -- %s' % (c, patch, rate, what, first_diff(x, y, lines)))
            if a.keep:
                os.makedirs(a.keep, exist_ok=True); shutil.copy(plan, a.keep); shutil.copy(os.path.join(a.work, tag + '.json'), a.keep)
        if c == 0 and a.control:
            wav = os.path.join(a.work, tag + '.wav'); raw_to_wav(x, lines, rate, wav)
            env = dict(os.environ, JP8_HOST_MAXBLOCK=str(maxblock))
            log('control: case 0 through the Unicorn oracle (jp8_render_check.py) ...')
            r = subprocess.run([sys.executable, os.path.join(TOOLS, 'jp8_render_check.py'), str(patch), plan, wav, '%r' % rate],
                               capture_output=True, text=True, env=env)
            last = (r.stdout + r.stderr).strip().split('\n')[-1]
            log('control: %s' % last)
            if r.returncode: log('*** THE CONTROL FAILED: the native harness and the Unicorn oracle disagree, or the oracle failed ***'); bad += 1
        if c == 0 and a.tooth:
            tp = os.path.join(a.work, tag + '.tooth')
            r = subprocess.run([a.tooth, tmpl, bank, str(patch), plan, '%r' % rate, str(maxblock), tp], capture_output=True, text=True)
            if r.returncode == 0 and open(tp, 'rb').read() != y:
                log('tooth bites: the slipped port DIFFERS -- %s' % first_diff(open(tp, 'rb').read(), y, lines))
            else:
                log('*** THE FUZZ TOOTH DID NOT BITE (rc %d) ***' % r.returncode); bad += 1
    print('JP8 NATIVE FUZZ (seed %d, %d cases, %d frames, rates %s): %s' % (a.seed, a.cases, frames, a.rates,
          'EXACTLY 0 -- every case\'s every output word is the native plugin\'s' if not bad else '%d FAILED' % bad))
    sys.exit(0 if not bad else 1)


if __name__ == '__main__':
    main()
