#!/usr/bin/env python3
"""jp8_native_check.py -- THE NATIVE ORACLE (scope row 23): grades a WAV of jp8/apps/jp8_render against the REAL
plugin on a real CPU -- its own DLL in a Windows process under wine, driven by jp8_native_host.exe (a minimal VST3
host in C) -- not under Unicorn. The difference that matters: a CPU flushes a denormal RESULT inside the plugin's own
ScopedNoDenormals (FTZ) as a PC does; Unicorn 2.1.4 never does (jp8_unicorn_fp_probe.py).
Plumbing only. The module is laid out as the Unicorn oracle serves it (jp8_host_emu.JP8Host): the plugin's DLL and
its Script files from jp8/truth/ (checked against SHA256SUMS), the stub panel file and the blank skin images that
oracle serves (its own bytes and its own sizer), the data and user folders empty. The patch record is the bank's own
(jp8_bank.patch_blob); the plan is the CLI's (every block's events and points as handed to process()), replayed,
never re-derived. Two processes: the CLI is its own; the WAV and the plan are all that meet here.
    python3 jp8/tools/native/jp8_native_check.py <patch> <plan.txt> <port.wav> [rate=48000] [--maxblock N]
        [--work DIR] [--keep OUT.bin] [--against OUT.bin]
--keep: also writes the native output (per block: L then R, float32) to OUT.bin.
--against: grades against an earlier native output instead of running the plugin again (the determinism check
           compares two runs with cmp; this flag lets a tooth re-grade without a third run).
exit 0 = EXACTLY 0 (every output word of the WAV is the native plugin's)."""
import sys, os, struct, time, shutil, hashlib, subprocess, zlib, argparse, json
HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(TOOLS))
sys.path.insert(0, TOOLS)
os.environ.setdefault('JP8_EMU_QUIET', '1')
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)

WINE = os.environ.get('JP8_WINE', shutil.which('wine64') or '/usr/lib/wine/wine64')
MINGW = os.environ.get('JP8_MINGW', 'x86_64-w64-mingw32-gcc')
TRUTH = os.path.join(REPO, 'jp8', 'truth')


def truth_file(name):
    """a file of jp8/truth/, its bytes checked against SHA256SUMS"""
    sums = dict(reversed(l.split()) for l in open(os.path.join(TRUTH, 'SHA256SUMS')) if l.strip())
    data = open(os.path.join(TRUTH, name), 'rb').read()
    if hashlib.sha256(data).hexdigest() != sums[name]:
        sys.exit('jp8/truth/%s does not match SHA256SUMS' % name)
    return data


def png(w, h):
    """a blank 32-bit RGBA PNG of w x h (every byte 0, as the oracle's blank ARGB images)"""
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF)
    raw = (b'\0' * (1 + 4 * w)) * h
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


def winpath(prefix, p):
    """C:\\a\\b -> <prefix>/drive_c/a/b"""
    assert p[:3].upper() == 'C:\\', p
    return os.path.join(prefix, 'drive_c', *p[3:].split('\\'))


def layout(work):
    """the wine prefix with the module where the oracle's MODPATH puts it. Returns (prefix, info). The layout is
    recorded in <work>/layout.json with every file's sha256: a later run checks the files against it and skips the
    oracle object (5 s); any file changed or missing lays everything out again."""
    prefix = os.path.join(work, 'prefix')
    rec = os.path.join(work, 'layout.json')
    if os.path.exists(rec):
        info = json.load(open(rec))
        if all(os.path.exists(f) and hashlib.sha256(open(f, 'rb').read()).hexdigest() == h for f, h in info['files'].items()) \
                and info['dll_sha256'] == hashlib.sha256(truth_file('JUPITER-8VST3_64bit.vst3')).hexdigest():
            return prefix, info
    import jp8_host_emu as X
    W = X.W
    mod = winpath(prefix, W.MODPATH)
    sdir = os.path.join(os.path.dirname(mod), 'Script')
    os.makedirs(sdir, exist_ok=True)
    dll = truth_file('JUPITER-8VST3_64bit.vst3')
    open(mod, 'wb').write(dll)
    h = X.JP8Host()                                    # the oracle's own served files and sizes (nothing booted)
    key = W._norm(W.SCRIPT_DIR).lower()
    names = h.dirs[key]
    files = {mod: hashlib.sha256(dll).hexdigest()}
    for f in names:
        k = (key + '\\' + f).lower()
        data = h.files[k] if k in h.files else truth_file(f)
        if f in os.listdir(TRUTH):
            assert data == truth_file(f), f            # a truth file is served as it is
        open(os.path.join(sdir, f), 'wb').write(data)
        files[os.path.join(sdir, f)] = hashlib.sha256(data).hexdigest()
    for nm, (w, hh) in sorted(h.skin.items()):
        img = png(w, hh)
        open(os.path.join(sdir, nm), 'wb').write(img)
        files[os.path.join(sdir, nm)] = hashlib.sha256(img).hexdigest()
    keep = set(n.lower() for n in names) | set(h.skin)
    for f in os.listdir(sdir):                         # nothing else in the folder
        if f.lower() not in keep:
            os.remove(os.path.join(sdir, f))
    info = dict(files=files, dll_sha256=hashlib.sha256(dll).hexdigest(), modpath=W.MODPATH, data_dir=W.DATA_DIR,
                nscript=len(names), nskin=len(h.skin))
    json.dump(info, open(rec, 'w'), indent=1)
    return prefix, info


def fresh_data_dirs(prefix, info):
    """the data and user folders exist and are EMPTY at every start (the oracle's DATA_DIR / USER_DIR); the plugin
    writes InstalledBankNames.dat there, which a later run would otherwise read"""
    users = os.path.join(prefix, 'drive_c', 'users')
    roots = [os.path.join(prefix, 'drive_c', 'ProgramData', 'Roland Cloud')]
    if os.path.isdir(users):
        roots += [os.path.join(users, u, 'AppData', 'Local', 'Roland Cloud') for u in os.listdir(users)]
    for r in roots:
        if os.path.isdir(r):
            shutil.rmtree(r)
    os.makedirs(winpath(prefix, info['data_dir']), exist_ok=True)
    os.makedirs(os.path.join(users, os.environ.get('USER', 'root'), 'AppData', 'Local', 'Roland Cloud', 'JUPITER-8'),
                exist_ok=True)


def build_host(work):
    exe = os.path.join(work, 'jp8_native_host.exe')
    src = os.path.join(HERE, 'jp8_native_host.c')
    if not os.path.exists(exe) or os.path.getmtime(exe) < os.path.getmtime(src):
        subprocess.run([MINGW, '-O1', '-Wall', '-Wextra', '-o', exe, src], check=True)
    return exe


def run_native(work, patch, plan, rate, out, maxblock):
    import jp8_bank as B
    prefix, info = layout(work)
    exe = build_host(work)
    bank = B.bank_bytes()
    open(os.path.join(work, 'rec.bin'), 'wb').write(B.patch_blob(bank, patch))
    shutil.copyfile(plan, os.path.join(work, 'plan.txt'))
    fresh_data_dirs(prefix, info)
    env = dict(os.environ, WINEPREFIX=prefix, WINEDEBUG='-all')
    log('native: patch %d %r at %g Hz, maximum block %d; %d script files, %d blank images' % (
        patch, B.patch_name(bank, patch), rate, maxblock, info['nscript'], info['nskin']))
    r = subprocess.run([WINE, exe, info['modpath'], 'rec.bin', 'plan.txt', '%r' % rate, 'out.bin', str(maxblock)],
                       cwd=work, env=env, capture_output=True, text=True, timeout=1800)
    msg = (r.stdout + r.stderr).strip().split('\n')
    if r.returncode:
        sys.exit('the native host failed (exit %d): %s' % (r.returncode, ' | '.join(msg[-5:])))
    log('native: %s' % msg[-1])
    shutil.move(os.path.join(work, 'out.bin'), out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('patch', type=int); ap.add_argument('plan'); ap.add_argument('wav')
    ap.add_argument('rate', type=float, nargs='?', default=48000.0)
    ap.add_argument('--maxblock', type=int, default=512)
    ap.add_argument('--work', default=os.path.join(REPO, 'build', 'jp8_native'))
    ap.add_argument('--keep'); ap.add_argument('--against')
    a = ap.parse_args()
    os.makedirs(a.work, exist_ok=True)
    ns = []
    for ln in open(a.plan):
        f = ln.split()
        if f and f[0] == 'B': ns.append(int(f[1]))
        elif f and f[0] not in ('E', 'P'): sys.exit('a plan line not understood: %s' % ln)
    w = open(a.wav, 'rb').read()
    assert w[:4] == b'RIFF' and w[8:16] == b'WAVEfmt ' and w[36:40] == b'data', 'not the CLI\'s WAV'
    fmt, nch, wrate = struct.unpack('<HHI', w[20:28])
    assert (fmt, nch, wrate) == (3, 2, int(a.rate)), 'the WAV is not stereo float at %g' % a.rate
    data = w[44:]; frames = len(data) // 8
    assert frames == sum(ns), 'the WAV holds %d frames, the plan %d' % (frames, sum(ns))
    if a.against:
        nat = open(a.against, 'rb').read(); log('graded against the native output %s' % a.against)
    else:
        out = a.keep or os.path.join(a.work, 'native_out.bin')
        run_native(a.work, a.patch, a.plan, a.rate, out, a.maxblock)
        nat = open(out, 'rb').read()
    assert len(nat) == 8 * frames, 'the native output holds %d bytes, the plan %d frames' % (len(nat), frames)
    pos = 0; bad = 0; o = 0
    for k, n in enumerate(ns):
        L = nat[o:o + 4 * n]; R = nat[o + 4 * n:o + 8 * n]; o += 8 * n
        for i in range(n):
            nl, nr = L[4 * i:4 * i + 4], R[4 * i:4 * i + 4]
            cl, cr = data[8 * (pos + i):8 * (pos + i) + 4], data[8 * (pos + i) + 4:8 * (pos + i) + 8]
            if (nl, nr) != (cl, cr):
                if bad < 5:
                    log('block %d sample %d: native %08x %08x CLI %08x %08x' % (
                        k, i, struct.unpack('<I', nl)[0], struct.unpack('<I', nr)[0],
                        struct.unpack('<I', cl)[0], struct.unpack('<I', cr)[0]))
                bad += 1
        pos += n
    print('JP8 NATIVE ORACLE (patch %d, %d frames at %g Hz, %d blocks, the plugin on a CPU under wine): %s' % (
        a.patch, frames, a.rate, len(ns),
        'EXACTLY 0 -- every output word is the native plugin\'s' if not bad else '%d frames differ -- NOT bit-exact' % bad))
    sys.exit(0 if not bad else 1)


if __name__ == '__main__':
    main()
