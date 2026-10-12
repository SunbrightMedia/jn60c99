#!/usr/bin/env python3
"""jp8_reach_scan.py -- finds the plugin code the port's lift does NOT hold, from the PORT alone (no oracle): random
host input (jp8_native_fuzz.gen_plan: block sizes, notes, parameter points, host clocks) replayed by jp8_plan_replay
until the lift traps ("indirect target not lifted" -- by design a trap, never a silent difference). Each new trap target
gets a WITNESS: the plan cut after the trapping block, then minimized (whole earlier blocks' input dropped, then line
chunks halved, then leading blocks dropped) while the SAME target still traps. The witnesses are what a drive must add
so the oracle runs that code and the lift holds it (jp8_host_seq.py's reach segments).
    python3 jp8/tools/native/jp8_reach_scan.py <replay binary> <seed> <cases> [--ids all|panel|midi] [--one-id]
        [--blocks 200] [--maxblock 4096] [--rates 48000,44100,96000] [--work DIR] [--out witnesses.json]
--one-id: each case automates ONE parameter id (with notes), so a trap names the parameter that reaches it.
exit 0 always (a report); the JSON holds {target rva: {patch, rate, maxblock, lines, case}}."""
import sys, os, re, json, random, subprocess, argparse, time
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
sys.path.insert(0, HERE)
import jp8_native_fuzz as F
t0 = time.time()
def log(m): print('[%7.1fs] %s' % (time.time() - t0, m), flush=True)
TRAP = re.compile(r'process \(block (\d+)\): -?\d+ TRAP at rva (0x[0-9a-f]+): ([^\n]*)')


class Replay:
    def __init__(self, binary, tmpl, bank, work):
        self.b, self.t, self.k, self.w, self.n = binary, tmpl, bank, work, 0

    def trap(self, patch, rate, maxblock, lines):
        """(block, target, why) of the trap, or None"""
        self.n += 1
        p = os.path.join(self.w, 'scan.plan'); open(p, 'w').write('\n'.join(lines) + '\n')
        r = subprocess.run([self.b, self.t, self.k, str(patch), p, '%r' % rate, str(maxblock), os.devnull],
                           capture_output=True, text=True)
        m = TRAP.search(r.stderr)
        if r.returncode and not m:
            raise SystemExit('the replay failed without a trap: %s' % r.stderr.strip()[-300:])
        return (int(m.group(1)), m.group(2), m.group(3)) if m else None


def blocks_of(lines):
    out = []
    for l in lines:
        if l.startswith('B '): out.append([l])
        elif l: out[-1].append(l)
    return out


def flat(bl): return [l for b in bl for l in b]


def minimize(rp, patch, rate, maxblock, lines, target):
    same = lambda ls: (lambda t: t is not None and t[1] == target)(rp.trap(patch, rate, maxblock, ls))
    t = rp.trap(patch, rate, maxblock, lines); assert t and t[1] == target
    bl = blocks_of(lines)[:t[0] + 1]                                   # cut after the trapping block
    quiet = [[b[0]] for b in bl[:-1]] + [bl[-1]]                       # every earlier block's input dropped
    if same(flat(quiet)): bl = quiet
    # line chunks (not B lines), halved: drop a chunk while the same target traps
    idx = [(i, j) for i, b in enumerate(bl) for j in range(1, len(b))]
    n = max(1, len(idx) // 2)
    while idx and n >= 1:
        k = 0; changed = False
        while k < len(idx):
            drop = set(idx[k:k + n])
            cand = [[b[0]] + [l for j, l in enumerate(b[1:], 1) if (i, j) not in drop] for i, b in enumerate(bl)]
            if same(flat(cand)):
                bl = cand; idx = [(i, j) for i, b in enumerate(bl) for j in range(1, len(b))]; changed = True
            else:
                k += n
        if not changed: n //= 2
    # leading blocks: drop as many as possible (halving)
    n = len(bl) // 2
    while n >= 1:
        if len(bl) > n and same(flat(bl[n:])): bl = bl[n:]
        else: n //= 2
    return flat(bl)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('replay'); ap.add_argument('seed', type=int); ap.add_argument('cases', type=int)
    ap.add_argument('--ids', default='all', choices=('all', 'panel', 'midi')); ap.add_argument('--one-id', action='store_true')
    ap.add_argument('--blocks', type=int, default=200); ap.add_argument('--maxblock', type=int, default=4096)
    ap.add_argument('--rates', default='48000,44100,96000')
    ap.add_argument('--work', default=os.path.join(REPO, 'build', 'jp8_reach_scan')); ap.add_argument('--out')
    a = ap.parse_args()
    os.makedirs(a.work, exist_ok=True)
    tmpl = os.path.join(a.work, 'jp8h_template.bin')
    if not os.path.exists(tmpl):
        subprocess.run('gunzip -c %s > %s' % (os.path.join(REPO, 'jp8', 'gen', 'jp8h_template.bin.gz'), tmpl), shell=True, check=True)
    rp = Replay(a.replay, tmpl, os.path.join(REPO, 'jp8', 'truth', '1_Preset.bin'), a.work)
    cen = json.load(open(os.path.join(REPO, 'jp8', 'gen', 'jp8_controller.json')))
    ids = [(p['id'], p['steps']) for p in cen['params']]
    if a.ids != 'all':
        ids = [x for x in ids if (x[0] < 0x0FFFC100) == (a.ids == 'panel')]
    title = {p['id']: p['title'] for p in cen['params']}
    rates = [float(r) for r in a.rates.split(',')]
    out = json.load(open(a.out)) if a.out and os.path.exists(a.out) else {}
    rng = random.Random(a.seed); clean = 0
    for c in range(a.cases):
        patch = rng.randrange(64); rate = rng.choice(rates); clock = rng.random() < 0.4
        maxblock = rng.choice([512, 512, a.maxblock, rng.randint(1, a.maxblock)])
        pool = [rng.choice(ids)] if a.one_id else ids
        lines = F.gen_plan(rng, a.blocks, maxblock, rate, pool, clock)
        t = rp.trap(patch, rate, maxblock, lines)
        if t is None:
            clean += 1; continue
        if t[1] in out:
            out[t[1]]['hits'] = out[t[1]].get('hits', 1) + 1; continue
        w = minimize(rp, patch, rate, maxblock, lines, t[1])
        pts = sorted(set(l.split()[1] for l in w if l.startswith('P ')))
        out[t[1]] = dict(patch=patch, rate=rate, maxblock=maxblock, clock=clock, lines=w, case=[a.seed, c], hits=1, why=t[2],
                         ids=[(p, title.get(int(p, 16), '?')) for p in pts])
        log('case %d: NEW gap at %s (%s) -- witness: patch %d at %g Hz, %d blocks, %d input lines: %s' % (
            c, t[1], t[2][:60], patch, rate, sum(1 for l in w if l.startswith('B ')), sum(1 for l in w if l[:1] in 'EPC'),
            ', '.join('%s %s' % (p, n) for p, n in out[t[1]]['ids'])))
        if a.out: json.dump(out, open(a.out, 'w'), indent=1)
    if a.out: json.dump(out, open(a.out, 'w'), indent=1)
    print('JP8 REACH SCAN (seed %d, %d cases, ids %s%s): %d ran clean, %d gaps known: %s  [%d replays]' % (
        a.seed, a.cases, a.ids, ', one id a case' if a.one_id else '', clean, len(out), ' '.join(sorted(out)), rp.n))


if __name__ == '__main__':
    main()
