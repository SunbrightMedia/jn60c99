#!/usr/bin/env python3
"""native_replay.py -- the oracle graded by the real CPU: the plugin's own render, run natively from the oracle's state.

Every gate in this repository compares the port with the plugin's machine code executed by Unicorn -- a model of a
CPU. Where the model is not the CPU, a gate can be green against the model and red against the plugin in a host
(playbooks 220, 226, 227). This runs the SAME machine code on THIS CPU (tools/verify/native_replay.c): the oracle
builds the scene (boot, patch recall, note, optional NaNs), its memory is written out region by region, and the
native process maps each region at its own address and runs E2E.render()'s loop -- the plugin's voice and master
render through the e2e stubs. Three renders of one scene:
  UNICORN   the oracle itself (MXCSR 0x9FC0: DAZ on; Unicorn never flushes a result -- playbook 220)
  CPU-DAZ   native, MXCSR 0x1FC0 -- the CPU doing what Unicorn's arithmetic does (no flush)
  CPU-FTZ   native, MXCSR 0x9FC0 -- the plugin in a host (JUCE's ScopedNoDenormals: FTZ + DAZ)
and, in its own process, the PORT (libjuno.so, the same recall, note and NaNs) in the oracle's mode and in the
product's (FTZ + DAZ). Compared: every output sample, and every byte of the nine units' objects (Unicorn vs CPU), or
the outputs and the live cells nan_ab.py samples (port vs CPU).

    python3 tools/verify/native_replay.py [--patch 5] [--frames 4800] [--nan none|single|multi] [--keep DIR]
exit 0 = the comparisons the scene promises hold (printed); 1 = one does not; 2 = the harness failed.
"""
import ctypes
import hashlib
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
VWIN = 84096
LOWPAGE = 0x10000          # Linux will not map below vm.mmap_min_addr: the low page is mapped from here


def scene_cells(kind, patch):
    """the NaNs of a scene: nan_ab.py's own targets and marked NaNs (one cell, or every target at once)"""
    if kind == 'none':
        return [], []
    import nan_ab as NA
    r = json.loads(subprocess.run([sys.executable, os.path.join(HERE, 'nan_ab.py'), '--oracle', str(patch), '1,2',
                                   '16', '512'], capture_output=True, text=True, check=True).stdout)
    t = r['targets']
    if kind == 'single':
        return [[t[0][0], t[0][1], NA.marked(0, 'q')]], r['cells']
    return [[u, o, NA.marked(i, 'q')] for i, (u, o) in enumerate(t)], r['cells']


def oracle_snap(d, patch, frames, inject):
    import e2e_emu as E, real_recall as R, recall_render_ab as RA
    e = RA.prepare_recall(patch, E.bank_bytes(), R.leaf_table(), E, R, RA.SR)
    e.note_on(60, 105)
    for _, o, b in inject:
        for k in range(9):
            e.uc.mem_write(e.state[k] + o, struct.pack('<I', b))
    regions = [(LOWPAGE, 0x100000 - LOWPAGE), (E.IB, E.IMGSZ), (E.HEAP_BASE, (e.heap - E.HEAP_BASE + 0xFFF) & ~0xFFF),
               (E.STUB_BASE, 0x100000), (E.BUF_BASE, E.BUF_SIZE)]
    for a, n in regions:
        open(os.path.join(d, 'region_%x.bin' % a), 'wb').write(bytes(e.uc.mem_read(a, n)))
    meta = dict(block=600, HOST=e.HOST, HOST_NVOICE=E.HOST_NVOICE, BUF_BASE=E.BUF_BASE, PB_VOICE=E.PB_VOICE,
                PB_MASTER=E.PB_MASTER, SVOICE=e.SVOICE, SMASTER=e.SMASTER, ASG_GET_COUNT=E.ASG_GET_COUNT,
                ASG_SET_COUNT=E.ASG_SET_COUNT)
    for i in range(9):
        meta['state%d' % i] = e.state[i]
        meta['assign%d' % i] = e.assign[i]
        meta['win%d' % i] = e.state[i]
        meta['wsz%d' % i] = E.STATE_SZ
    open(os.path.join(d, 'meta.txt'), 'w').write(''.join('%s = %x\n' % kv for kv in meta.items()))
    if e.uc.reg_read(__import__('unicorn').x86_const.UC_X86_REG_MXCSR) != 0x9FC0:
        raise SystemExit('REFUSE: the oracle is not in its mode (MXCSR 0x9FC0)')
    L, Rr = e.render(frames)
    with open(os.path.join(d, 'unicorn.bin'), 'wb') as f:
        for x, y in zip(L, Rr):
            f.write(struct.pack('<II', x, y))
        for i in range(9):
            f.write(bytes(e.uc.mem_read(e.state[i], E.STATE_SZ)))
    json.dump({'state_sz': E.STATE_SZ, 'rate': RA.SR}, open(os.path.join(d, 'info.json'), 'w'))


def port_sweep(d, patch, frames, scenes, mode, cells):
    """the port in its own process, one fresh instance per scene (a list of [unit, offset, bits]): every scene's
    output words and live cells, one JSON"""
    lib, bank, rate = port_lib(d, mode)
    out = []
    for sc in scenes:
        out.append(port_scene(lib, bank, rate, patch, frames, sc, mode, cells))
    json.dump(out, open(os.path.join(d, 'sweep_%s.json' % mode), 'w'))


def port_lib(d, mode):
    import freshlib
    import truth
    lib = ctypes.CDLL(os.environ.get('NATREP_LIB') or freshlib.check())
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_poke.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint]
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
    info = json.load(open(os.path.join(d, 'info.json')))
    return lib, open(truth.BANK, 'rb').read(), float(info['rate'])   # e2e_emu.bank_bytes(), without the emulator


def port_scene(lib, bank, rate, patch, frames, inject, mode, cells):
    ctx = lib.juno_gui_create(ctypes.c_float(rate), 0)
    if mode == 'oracle':
        lib.juno_set_fp_oracle_mode(1)            # after create, which sets the production FTZ (playbook 120)
    lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)
    lib.juno_gui_note_on(ctx, 60, 105)
    for _, o, b in inject:
        lib.juno_gui_poke(ctx, o, b)
    buf = (ctypes.c_float * (2 * frames))()
    lib.juno_gui_render(ctx, buf, frames)
    w = list(struct.unpack('<%dI' % (2 * frames), bytes(buf)))
    cv = [lib.juno_gui_peek(ctx, o) for u, o in cells]
    lib.juno_gui_destroy(ctx)
    return [w, cv]


def port_run(d, patch, frames, inject, mode, cells):
    """the port in its own process: the recall model the nan gates use, the note, the NaNs, the render"""
    lib, bank, rate = port_lib(d, mode)
    w, cv = port_scene(lib, bank, rate, patch, frames, inject, mode, cells)
    json.dump({'words': w, 'cells': cv}, open(os.path.join(d, 'port_%s.json' % mode), 'w'))


def sweep(a):
    """every nan_ab.py target alone (--all: every live float cell the oracle finds), three NaNs each (the x86
    default 0xFFC00000, a marked quiet one, a marked signalling one): the port (oracle mode vs the CPU at DAZ,
    product mode vs the CPU at FTZ + DAZ), outputs and the live cells -- one NaN source, graded by the real CPU"""
    import nan_ab as NA
    opt = lambda k, dflt: a[a.index(k) + 1] if k in a else dflt
    patch, frames = int(opt('--patch', '5')), int(opt('--frames', '1024'))
    seeds, ncell = (opt('--seeds', '1,2'), opt('--cells', '16')) if '--all' not in a else ('1', '1000000')
    d = opt('--keep', None) or tempfile.mkdtemp(prefix='natsw_')
    os.makedirs(d, exist_ok=True)
    r = json.loads(subprocess.run([sys.executable, os.path.join(HERE, 'nan_ab.py'), '--oracle', str(patch), seeds,
                                   ncell, '512'], capture_output=True, text=True, check=True).stdout)
    targets, cells = r['targets'], r['cells']
    rr = subprocess.run([sys.executable, __file__, '--oracle-snap', d, str(patch), '64', '[]'], capture_output=True,
                        text=True)
    if rr.returncode:
        print('oracle failed: %s' % rr.stderr[-1500:])
        return 2
    exe = os.path.join(d, 'native_replay')
    subprocess.run(['cc', '-O2', '-o', exe, os.path.join(HERE, 'native_replay.c')], check=True)
    cf = os.path.join(d, 'cells.txt')
    open(cf, 'w').write(''.join('%d %d\n' % (0 if u == 0 else 8, o) for u, o in cells))
    scenes = [[]]                               # scene 0: no NaN (the reach control)
    for i, (u, o) in enumerate(targets):
        for b in (NA.NAN_BITS, NA.marked(i, 'q'), NA.marked(i, 's')):
            scenes.append([[u, o, b]])
    sf = os.path.join(d, 'scenes.json')
    json.dump(scenes, open(sf, 'w'))
    bf = os.path.join(d, 'batch.txt')
    open(bf, 'w').write(''.join(' '.join('%d:%d' % (o, b) for _, o, b in sc) + '\n' for sc in scenes))
    tooth = '--tooth' in a
    env = dict(os.environ)
    if tooth:                       # nan_ab.py's tooth: the decompile's ordered form back at a reached clamp
        env['NATREP_LIB'] = NA.tooth_lib(d)
    bad = 0
    reach = {}
    rec = 2 * frames + len(cells)
    for mode, mx in (('oracle', '0x1FC0'), ('product', '0x9FC0')):
        pr = subprocess.run([sys.executable, __file__, '--port-sweep', d, str(patch), str(frames), sf, mode,
                             json.dumps(cells)], capture_output=True, text=True, env=env)
        if pr.returncode:
            print('port failed: %s' % pr.stderr[-800:])
            return 2
        P = json.load(open(os.path.join(d, 'sweep_%s.json' % mode)))
        out = os.path.join(d, 'cpu_%s.bin' % mode)
        x = subprocess.run(['bash', '-c', 'ulimit -s unlimited; exec "$@"', '_', exe, d, str(frames), mx, out, cf,
                            '--batch', bf], capture_output=True, text=True)
        if x.returncode:
            print('native failed (rc %d): %s' % (x.returncode, x.stderr[-500:]))
            return 2
        b = open(out, 'rb').read()
        if len(b) != 4 * rec * len(scenes):
            print('native batch: %d bytes for %d scenes -- REFUSE' % (len(b), len(scenes)))
            return 2
        W = struct.unpack('<%dI' % (rec * len(scenes)), b)
        cpu = [list(W[k * rec:(k + 1) * rec]) for k in range(len(scenes))]
        reach[mode] = sum(1 for k in range(1, len(scenes)) if cpu[k] != cpu[0])
        diff = []
        for k, sc in enumerate(scenes):
            if cpu[k][:2 * frames] != P[k][0] or cpu[k][2 * frames:] != P[k][1]:
                diff.append((sc[0] if sc else (-1, -1, 0), 'output' if cpu[k][:2 * frames] != P[k][0] else 'cells %d' % sum(
                    1 for p_, q in zip(cpu[k][2 * frames:], P[k][1]) if p_ != q)))
        print('  PORT (%s mode) vs the CPU (MXCSR %s): %d targets x 3 NaNs, %d frames (%d of %d scenes change the '
              'output or a live cell): %s' % (mode, mx, len(targets), frames, reach[mode], len(scenes) - 1,
                                               'EQUAL' if not diff else '%d DIFFER' % len(diff)))
        for (u, o, b_), what in diff[:12]:
            print('    %s +%d, NaN %08X: the %s differs' % ('master' if u == 8 else 'voice 0', o, b_, what))
        bad |= bool(diff)
    if '--keep' not in a:
        shutil.rmtree(d, ignore_errors=True)
    if tooth:
        print('native_replay --sweep --tooth: %s' % ('BITES' if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    if min(reach.values()) < 8:
        print('native_replay --sweep: fewer than 8 scenes reach the output or a live cell -- REFUSE')
        return 2
    print('native_replay --sweep: %s' % ('every single-source NaN scene equal on the real CPU' if not bad else
                                         'A SCENE DIFFERS'))
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle-snap']:
        oracle_snap(a[1], int(a[2]), int(a[3]), json.loads(a[4]))
        return 0
    if a[:1] == ['--port']:
        port_run(a[1], int(a[2]), int(a[3]), json.loads(a[4]), a[5], json.loads(a[6]))
        return 0
    if a[:1] == ['--port-sweep']:
        port_sweep(a[1], int(a[2]), int(a[3]), json.load(open(a[4])), a[5], json.loads(a[6]))
        return 0
    if '--sweep' in a:
        return sweep(a)
    opt = lambda k, dflt: a[a.index(k) + 1] if k in a else dflt
    patch, frames, kind = int(opt('--patch', '5')), int(opt('--frames', '4800')), opt('--nan', 'none')
    d = opt('--keep', None) or tempfile.mkdtemp(prefix='natrep_')
    os.makedirs(d, exist_ok=True)
    inject, cells = scene_cells(kind, patch)
    r = subprocess.run([sys.executable, __file__, '--oracle-snap', d, str(patch), str(frames), json.dumps(inject)],
                       capture_output=True, text=True)
    if r.returncode:
        print('oracle failed: %s' % r.stderr[-1500:])
        return 2
    exe = os.path.join(d, 'native_replay')
    subprocess.run(['cc', '-O2', '-o', exe, os.path.join(HERE, 'native_replay.c')], check=True)
    info = json.load(open(os.path.join(d, 'info.json')))
    sz = info['state_sz']
    res = {}
    for name, mx in (('CPU-DAZ', '0x1FC0'), ('CPU-FTZ', '0x9FC0')):
        out = os.path.join(d, name + '.bin')
        rr = subprocess.run(['bash', '-c', 'ulimit -s unlimited; exec "$@"', '_', exe, d, str(frames), mx, out],
                            capture_output=True, text=True)
        if rr.returncode:
            print('native %s failed (rc %d): %s' % (name, rr.returncode, rr.stderr[-800:]))
            return 2
        res[name] = open(out, 'rb').read()
    res['UNICORN'] = open(os.path.join(d, 'unicorn.bin'), 'rb').read()
    no = 8 * frames

    def split(b):
        return b[:no], [b[no + i * sz:no + (i + 1) * sz] for i in range(9)]
    U = split(res['UNICORN'])
    bad = 0
    print('patch %d, %d frames, scene %s (%d NaN cells)' % (patch, frames, kind, len(inject)))
    for name in ('CPU-DAZ', 'CPU-FTZ'):
        C = split(res[name])
        units = [i for i in range(9) if C[1][i] != U[1][i]]
        nd = sum(1 for k in range(0, no, 4) if C[0][k:k + 4] != U[0][k:k + 4])
        print('  UNICORN vs %s: output %s, unit objects differing: %s' % (
            name, 'EQUAL' if not nd else '%d of %d words differ' % (nd, no // 4), units or 'none'))
        for i in units[:3]:
            x, y = U[1][i], C[1][i]
            diffs = [k for k in range(0, sz, 4) if x[k:k + 4] != y[k:k + 4]]
            print('    unit %d: %d words differ, first at +%d: unicorn %08X cpu %08X' % (
                i, len(diffs), diffs[0], *struct.unpack('<II', x[diffs[0]:diffs[0] + 4] + y[diffs[0]:diffs[0] + 4])))
        res[name + '_diff'] = (nd, units)
    if kind == 'none' and (res['CPU-DAZ_diff'][0] or res['CPU-DAZ_diff'][1]):
        bad = 1                         # with no NaN the model must BE the CPU in its own mode
    for mode, ref in (('oracle', 'CPU-DAZ'), ('product', 'CPU-FTZ')):
        rr = subprocess.run([sys.executable, __file__, '--port', d, str(patch), str(frames), json.dumps(inject), mode,
                             json.dumps(cells)], capture_output=True, text=True)
        if rr.returncode:
            print('port failed: %s' % rr.stderr[-800:])
            return 2
        p = json.load(open(os.path.join(d, 'port_%s.json' % mode)))
        C = split(res[ref])
        cw = list(struct.unpack('<%dI' % (no // 4), C[0]))
        nd = sum(1 for x, y in zip(cw, p['words']) if x != y)
        cvc = [struct.unpack('<I', (C[1][0] if u == 0 else C[1][8])[o:o + 4])[0] for u, o in cells]
        ncd = sum(1 for x, y in zip(cvc, p['cells']) if x != y)
        print('  PORT (%s mode) vs %s: output %s%s' % (mode, ref, 'EQUAL' if not nd else '%d words differ' % nd,
                                                      '' if not cells else ', live cells %s' % (
                                                          'EQUAL' if not ncd else '%d of %d differ' % (ncd, len(cells)))))
        if nd or ncd:
            bad = 1
    if '--keep' not in a:
        shutil.rmtree(d, ignore_errors=True)
    print('native_replay: %s' % ('the comparisons hold' if not bad else 'A COMPARISON FAILS'))
    return bad


if __name__ == '__main__':
    sys.exit(main())
