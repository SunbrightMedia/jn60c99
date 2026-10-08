#!/usr/bin/env python3
"""exe_oracle_check.py -- JUNO-60.exe against THE PLUGIN ITSELF: the official .vst3,
executed under Unicorn (tools/verify/host_process_emu.py: its own initialize, patch
browser, model set, UI-timer drain and IAudioProcessor::process).

Per seed, the program plays a seeded performance through its own inputs (--play):
MIDI through its winmm callback (any channel, note-on at 0 among the releases), the
keybed through its mouse handlers (clicks, Shift-clicks, drags inside and past the
keys), KEY HOLD and OCTAVE SHIFT from the panel, patch changes from its patch
browser, rendered by its audio thread's block function, and logs every engine
call. This checker
plays that call log into the plugin -- the same boot, the same patch loads, the
same model sets, the same drains, the same process() blocks with the same host
events and parameter points -- and requires:
  bit-exact   every sample of both channels equal, the program in the oracle's FP
              mode (--fp-oracle: DAZ without FTZ -- Unicorn has no FTZ, playbook 120)
  spectra     the magnitude spectra (4096-point frames, Hann) equal
  production  the program in its shipped FP mode (FTZ + DAZ) against the same run:
              reported (equal unless a denormal result occurred)
Harness = plumbing: the plugin side runs the logged calls; nothing is computed
here but the comparison. A keybed write is the plugin's own: the panel keyboard's
(key, value) into its note value (rva 0x2838C0, then the model's notifies -- what
its send, rva 0x2D47E0, does), which its listener queues. --tooth: the plugin side
plays the first MIDI note and the first keybed press a semitone up; every seed must
then FAIL (a velocity step was blind on 2 of 5 seeds: patches without velocity
sensitivity).

usage: exe_oracle_check.py --exe PATH [--seeds 1,2,3] [--jobs 3] [--tooth]
  exit 0: every seed bit-exact (with --tooth: every seed FAILS)
"""
import multiprocessing as mp
import os
import shutil
import struct
import subprocess
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
HEADER, STRIDE, NAME = 23, 20223, 16


def bank_file(name):
    import truth
    if name == 'Factory':
        return truth.BANK
    udir = os.path.join(REPO, 'scratchpad', 'userbanks')
    for f in os.listdir(udir):
        if f.lower().endswith('.bin') and os.path.splitext(f)[0].lstrip('~').strip() == name:
            return os.path.join(udir, f)
    raise SystemExit('bank %r not found' % name)


def f32(h):
    return struct.unpack('<f', struct.pack('<I', int(h, 16)))[0]


def f64(h):
    return struct.unpack('<d', struct.pack('<Q', int(h, 16)))[0]


def oracle(args):
    """the call log through the plugin (a worker process: Unicorn only)"""
    log, tooth = args
    import gc
    import host_process_emu as H
    lines = [ln.split() for ln in log.splitlines() if ln and not ln.startswith('#')]
    h = None
    q = None
    index, banks = {}, {}
    PL, PR = [], []
    skipped, toothed, ktoothed = [], False, False
    i = 0
    while i < len(lines):
        t = lines[i]
        i += 1
        if t[0] == 'create':
            h = H.HostProcess()
            h.start(float(t[1]), 4096)                       # raw: no prelude, no settle (boot_gate.py)
            uc = h.uc
            q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
            model = q(q(h.core + 8))
            note_value = h.vcall(q(model + 128), 6)          # ms.ch[vm.ks.ch].note (the ring's slot 6)
            kbuf = h.alloc_com(16)
            vb, ve = q(h.core + 24), q(h.core + 32)
            for k in range((ve - vb) // 24):
                index[h.call(H.IB + 0x319C50, rcx=h.core + 24, rdx=k) & 0xFFFFFFFF] = q(vb + 24 * k)
        elif t[0] == 'plugin_init':
            pass                                             # HostProcess.start is the plugin's boot
        elif t[0] == 'queue_patch':
            name = ' '.join(t[2:])
            if name not in banks:
                banks[name] = open(bank_file(name), 'rb').read()
            b, p = banks[name], int(t[1])
            h.load_patch(b[HEADER + p * STRIDE + NAME: HEADER + (p + 1) * STRIDE])
        elif t[0] == 'model_set':
            pid, v = int(t[1]), int(t[2])
            if pid in index:
                h.call(H.IB + 0x283DB0, rcx=q(q(h.core + 8)), rdx=index[pid], r8=v & 0xFFFFFFFF, r9=1)
            else:
                skipped.append(pid)
        elif t[0] == 'ui_tick':
            h.call(H.IB + 0x320120, rcx=h.core, count=2_000_000_000)
        elif t[0] == 'commit':                               # a panel control's notifies and commit
            for rva in (0x285320, 0x2853C0, 0x283120):
                h.call(H.IB + rva, rcx=model, count=500_000_000)
        elif t[0] == 'keybed':
            key, val = int(t[1]), int(t[2])
            if tooth and not ktoothed and val > 0:
                key = min(127, key + 1)                      # TOOTH: the first press a semitone up
                ktoothed = True
            uc.mem_write(kbuf, struct.pack('<ii', key, val))
            h.call(H.IB + 0x2838C0, rcx=model, rdx=note_value, r8=kbuf, count=500_000_000)
            for rva in (0x285320, 0x2853C0, 0x283120):
                h.call(H.IB + rva, rcx=model, count=500_000_000)
        elif t[0] == 'midi':
            pass                                             # the program's own input log
        elif t[0] == 'process':
            n, tempo, nev, npar = int(t[1]), f64(t[2]), int(t[3]), int(t[4])
            evs, par = [], []
            for k in range(nev):
                e = lines[i + k]
                vel, pitch = f32(e[5]), int(e[4])
                if tooth and not toothed and int(e[2]) == 0 and vel > 0:
                    pitch = min(127, pitch + 1)              # TOOTH: the first MIDI note a semitone up
                    toothed = True
                evs.append(('on' if int(e[2]) == 0 else 'off', int(e[1]), int(e[3]), pitch, vel))
            i += nev
            for k in range(npar):
                p = lines[i + k]
                par.append((int(p[1]), int(p[2]), f64(p[3])))
            i += npar
            l, r = h.process(n, events=evs, params=par, ctx=dict(tempo=tempo, playing=True))
            PL += l
            PR += r
        else:
            raise SystemExit('log: unknown call %r' % (t,))
    del h
    gc.collect()                                             # Unicorn's native memory (playbook 161)
    return PL, PR, sorted(set(skipped))


def run_exe(exe, work, seed, fp_oracle):
    tag = 's%d_%s' % (seed, 'oracle' if fp_oracle else 'prod')
    raw = os.path.join(work, tag + '.raw')
    args = [os.environ.get('WINE', '/usr/lib/wine/wine64'), exe, '--play', os.path.basename(raw), '--seed', str(seed)]
    if fp_oracle:
        args.append('--fp-oracle')
    subprocess.run(args, cwd=work, env=dict(os.environ, WINEDEBUG='-all'), check=True, timeout=600,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    a = np.fromfile(raw, np.float32)
    return a, open(raw + '.log').read()


def spectra(x):
    """magnitude spectra of 4096-sample Hann frames, hop 2048, per channel"""
    w = np.hanning(4096).astype(np.float64)
    out = []
    for ch in (0, 1):
        s = x[ch::2].astype(np.float64)
        fr = [np.abs(np.fft.rfft(s[k:k + 4096] * w)) for k in range(0, len(s) - 4096 + 1, 2048)]
        out.append(np.array(fr))
    return out


def main():
    exe = sys.argv[sys.argv.index('--exe') + 1]
    seeds = [int(x) for x in (sys.argv[sys.argv.index('--seeds') + 1] if '--seeds' in sys.argv else '1,2,3').split(',')]
    jobs = int(sys.argv[sys.argv.index('--jobs') + 1]) if '--jobs' in sys.argv else 3
    tooth = '--tooth' in sys.argv
    import truth
    truth.verify()
    work = tempfile.mkdtemp(prefix='exe_oracle_')
    shutil.copyfile(exe, os.path.join(work, 'JUNO-60.exe'))
    exe = os.path.join(work, 'JUNO-60.exe')
    runs = {}
    for s in seeds:
        runs[s] = (run_exe(exe, work, s, True), run_exe(exe, work, s, False))
    with mp.get_context('spawn').Pool(jobs) as pool:
        refs = pool.map(oracle, [(runs[s][0][1], tooth) for s in seeds], chunksize=1)
    fails = 0
    for s, (PL, PR, skipped) in zip(seeds, refs):
        (ex, log), (prod, _) = runs[s]
        ref = np.empty(2 * len(PL), np.uint32)
        ref[0::2] = PL
        ref[1::2] = PR
        exb = ex.view(np.uint32)
        same = exb.shape == ref.shape and np.array_equal(exb, ref)
        first = -1 if same or exb.shape != ref.shape else int(np.argmax(exb != ref))
        sa, sb = spectra(ex), spectra(ref.view(np.float32))
        spec_same = all(np.array_equal(a, b) for a, b in zip(sa, sb))
        dbmax = max(float(np.max(np.abs(20 * np.log10(a + 1e-12) - 20 * np.log10(b + 1e-12)))) for a, b in zip(sa, sb))
        prod_same = np.array_equal(prod.view(np.uint32), exb)
        name = [ln for ln in log.splitlines() if ln.startswith('queue_patch')][0].split(None, 2)
        nkeys = sum(1 for ln in log.splitlines() if ln.startswith('ev ') and ln.split()[2] == '0')
        kbw = [ln.split() for ln in log.splitlines() if ln.startswith('keybed ')]
        npress = sum(1 for t in kbw if int(t[2]) > 0)
        nhold = sum(1 for ln in log.splitlines() if ln.startswith('model_set %d ' % 0x00600138))
        nload = sum(1 for ln in log.splitlines() if ln.startswith('queue_patch')) - 1
        ndrain = sum(1 for ln in log.splitlines() if ln == 'ui_tick')
        ok = same and spec_same and exb.size > 0 and float(np.max(np.abs(ex))) > 0.01
        fails += not ok
        print('%s seed %d: %s patch %d, %d host notes, %d keybed writes (%d presses), %d KEY HOLD sets, %d patch '
              'changes, %d drains, %d samples: %s; spectra %s (max %.3g dB); production FP mode %s%s' % (
            'ok  ' if ok else 'FAIL', s, name[2], int(name[1]) + 1, nkeys, len(kbw), npress, nhold, nload, ndrain, ex.size // 2,
            'BIT-EXACT' if same else 'DIFFER from sample %d' % (first // 2), 'IDENTICAL' if spec_same else 'DIFFER',
            dbmax, 'equal' if prod_same else 'differs (denormals: FTZ)',
            ('; model ids not in the plugin\'s record list: %s' % skipped) if skipped else ''))
    shutil.rmtree(work)
    if tooth:                                 # the tooth must bite on every seed
        print('exe_oracle_check --tooth: %s (%d of %d seeds FAIL)' % (
            'BITES' if fails == len(seeds) else 'DID NOT BITE', fails, len(seeds)))
        return 0 if fails == len(seeds) else 1
    print('exe_oracle_check: %s (%d seeds)' % ('GREEN' if not fails else 'RED', len(seeds)))
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
