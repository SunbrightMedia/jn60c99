#!/usr/bin/env python3
"""exe_pm_check.py -- JUNO-60.exe's patch window against the PLUGIN (CLAIMS A39).

The patch manager gate's references (tools/verify/patch_manager_gate.py: the plugin's own run of a
seeded command script) are played through the PROGRAM under Wine (--pm-script): its key path
(pm_key, as WM_KEYDOWN), its list and bank name mouse paths, its buttons (action()), its Win32 file
calls on real folders, its dialogs answered by the script; after every command the program prints
the dialogs asked, the files changed, the model calls, the manager's whole state and every file
(SHA-1, 16 hex). The gate's own grade() compares each command with the plugin's run.

usage: exe_pm_check.py --exe EXE [--seeds 9:40,1:200,...] [--keep]
"""
import os
import pickle
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import patch_manager_gate as G  # noqa: E402

WINE = os.environ.get('WINE', '/usr/lib/wine/wine64')
VK = {0x20: 0x20, 0x100: 0x26, 0x101: 0x28, 0x102: 0x25, 0x103: 0x27, 0x108: 0x0D, 0x109: 0x1B, 0x10B: 0x2E}
CANON = {'DATA': G.DATA, 'PATCH': G.PATCH, 'OLD': G.OLD, 'SCRIPT': G.SCRIPT, 'DESK': G.DESK}


def hx(b):
    return '-' if b is None else '=' + bytes(b).hex()


def unhx(t):
    return None if t == '-' else bytes.fromhex(t[1:])


def parse_log(out, ops, back, watch):
    """a run's log (JUNO-60.exe's --pm-script log, or the web page's in its form) as the gate's rows: per command
    the dialogs and file changes, the manager's state, the files, the model calls, the window's values"""
    it = iter(out)
    opi = -1
    for ln in it:
        if ln == 'boot' or ln == 'op':
            log, calls, files, banks = [], [], {}, []
            fans = [v for kind, v in ops[opi][-1] if kind == 'file'] if opi >= 0 else []
            d = win_ = None
            for ln2 in it:
                t = ln2.split(' ')
                if t[0] == 'call':
                    calls.append(('load', t[2]) if t[1] == 'load' else ('set', int(t[2]), int(t[3]), int(t[4]))
                                 if t[1] == 'set' else (t[1],))
                elif t[0] in ('fw', 'fd'):
                    log.append(('write' if t[0] == 'fw' else 'delete', back(unhx(t[1]).decode('latin1'))))
                elif t[0] == 'fm':
                    log.append(('move', back(unhx(t[1]).decode('latin1')), back(unhx(t[2]).decode('latin1'))))
                elif t[0] == 'text':
                    log.append(('text', unhx(t[1]), unhx(t[2])))
                elif t[0] == 'menu':
                    log.append(('menu', [(bytes.fromhex(x[2:]), int(x[0])) for x in t[2:]], None if int(t[1]) < 0 else int(t[1])))
                elif t[0] == 'message':
                    log.append(('message', int(t[1])))
                elif t[0] == 'box':
                    log.append(('box', int(t[1])))
                elif t[0] in ('fdopen', 'fdsave'):
                    log.append(('dialog', t[0], fans.pop(0) if fans else None))
                elif t[0] == 'cur':
                    d = dict(cur=int(t[1]), cur2=int(t[2]), sel=int(t[4]), clip=t[6], fmt=int(t[8]), tick=int(t[10]),
                             view=t[12], values=(int(t[14]), int(t[15])), banks=banks)
                    win_ = tuple(int(x) for x in t[17:21])
                elif t[0] == 'bank':
                    banks.append((int(t[1]), []))
                elif t[0] == 'st':
                    banks[-1][1].append((unhx(t[1]), int(t[2]), t[3], t[4:]))
                elif t[0] == 'file':
                    files[G.norm(watch[int(t[1])] + '\\' + unhx(t[2]).decode('latin1'))] = t[3]
                elif t[0] == 'end':
                    break
            if d is None:
                return
            yield (ops[opi][:-1] if opi >= 0 else 'boot', log, d, files, calls, win_)
            opi += 1


def run_seed(exe, seed, steps, keep):
    pkl = os.path.join(REPO, 'scratchpad', 'patch_manager_ref%d_%d_%d.pkl' % (G.REF_FORMAT, seed, steps))
    ref = pickle.load(open(pkl, 'rb'))
    if ref.get('fmt') != G.REF_FORMAT:
        raise SystemExit('%s: an old reference form' % pkl)
    work = tempfile.mkdtemp(prefix='exe_pm_')
    # the folders' names keep the plugin's order of their paths (the boot sorts every bank file by its
    # whole path: Patch "C:/Program Files/..." < data "C:/ProgramData/Roland Cloud/..." < old)
    sub = {'PATCH': 'a_patch', 'DATA': 'b_data', 'OLD': 'c_old', 'SCRIPT': 'd_script', 'DESK': 'e_desk'}
    win = {k: 'Z:' + os.path.join(work, sub[k]) for k in CANON}     # Wine's view of the folders
    for k in CANON:
        os.makedirs(os.path.join(work, sub[k]))
    for p, d in G.setup(seed):                                        # the gate's files, in real folders
        for k, c in CANON.items():
            if p.startswith(c + '\\'):
                open(os.path.join(work, sub[k], p[len(c) + 1:]), 'wb').write(d)
    shutil.copyfile(exe, os.path.join(work, 'JUNO-60.exe'))
    to_w = lambda p: next((win[k].replace('/', '\\') + p[len(c):] for k, c in CANON.items() if p.startswith(c + '\\')), p)
    pids, ops = ref['pids'], ref['ops']
    lines = ['dirs ' + '\t'.join(win[k] for k in ('DATA', 'PATCH', 'OLD', 'SCRIPT', 'DESK'))]
    n = len(ref['res']) - 1
    for i, op in enumerate(ops, 1):
        for kind, v in op[-1]:
            if kind == 'text':
                lines.append('ans t ' + hx(v))
            elif kind == 'menu':
                lines.append('ans m %d' % (-1 if v is None else v))
            elif kind == 'box':
                lines.append('ans b %d' % v)
            elif kind == 'file':
                ps = [] if v is None else (v if isinstance(v, list) else [v])
                lines.append('ans f %d' % (len(ps) if v is not None else -1) + ''.join('\t' + to_w(q) for q in ps))
        lines.append('full %d' % (1 if G.full_step(i, n) else 0))
        k = op[0]
        if k == 'key':
            code, fl = op[1], op[2]
            lines.append('key %d %d %d' % (VK.get(code, code), fl & 1, (fl >> 1) & 1))
        elif k == 'func':
            lines.append('func %s %s' % (op[1], op[2]))
        elif k in ('mouse', 'bank'):
            lines.append(k + ' ' + ' '.join('%d %d %d' % (t, x, y) for t, (x, y) in op[2]))
        elif k == 'set':
            lines.append('set %d %d' % (pids[op[1] % len(pids)], op[2]))
        elif k == 'save':
            lines.append('save')
        elif k == 'tick':
            lines.append('tick %d' % op[1])
    sp = os.path.join(work, 'pm.txt')
    open(sp, 'w', newline='\n').write('\n'.join(lines) + '\n')
    subprocess.run([WINE, os.path.join(work, 'JUNO-60.exe'), '--pm-script', 'pm.txt'], cwd=work,
                   env=dict(os.environ, WINEDEBUG='-all'), timeout=3600,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    out = open(sp + '.log', encoding='latin1').read().split('\n')
    # the program's paths back to the gate's: its folders' prefixes ('/' as the manager joins them)
    pre = sorted(((win[k], c.replace('\\', '/')) for k, c in CANON.items()), key=lambda x: -len(x[0]))
    back = lambda p: next((c + p[len(w):] for w, c in pre if p.startswith(w)), p)
    watch = [CANON[k] for k in ('DATA', 'PATCH', 'OLD', 'DESK')]

    rows = lambda: parse_log(out, ops, back, watch)
    nfail, fails, nops = G.grade(ref, rows())
    if keep:
        print('  kept %s' % work)
    else:
        shutil.rmtree(work)
    return nfail, fails, nops


def main():
    exe = sys.argv[sys.argv.index('--exe') + 1]
    spec = sys.argv[sys.argv.index('--seeds') + 1] if '--seeds' in sys.argv else '9:40,1:200,2:200,3:200'
    keep = '--keep' in sys.argv
    bad = 0
    for item in spec.split(','):
        seed, steps = (int(x) for x in item.split(':'))
        nfail, fails, n = run_seed(exe, seed, steps, keep)
        for f in fails:
            print('  FAIL ' + f)
        print('%s seed %d: %d of %d commands differ from the plugin' % ('ok  ' if not nfail else 'FAIL', seed, nfail, n))
        bad += nfail > 0
    print('exe_pm_check: %s (%s)' % ('GREEN' if not bad else 'RED', spec))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
