#!/usr/bin/env python3
"""jx_exe_check.py -- JX-3P.exe (jx3p/gui/win/jx3p_win.c, built by make_native_jx.py) graded against the port's
library built for this computer from the same sources (the build the JX gates grade against the plugin). The
JUNO-60's tools/dist/native_check.py on the JX.

The program's --render mode runs its audio thread's own path (render_block -> process(): jx3p_product_note / _param
/ _tempo / _block, in the plugin's SSE FTZ / DAZ mode) on a fixed script through its own handlers -- MIDI notes,
CC 1, pitch bend, aftertouch, panel edits, a key click, the JX's own controls (the DCO switches, the CHORUS button,
the patch select buttons, a patch block, a PG-200 slide switch), the arp at the host tempo, a patch change, the CC
assign menu -- writes the raw float output and logs every engine call. This checker:
  replay    runs the logged calls, in order, through the library (no Wine there) and requires the outputs EQUAL BIT
            FOR BIT (the Windows compiler, its C library, its OS against the Linux build)
  glue      requires every block's host events and parameter points to be the host's: the MIDI the program queued
            since the block before in the DAW's mapping (note on/off -> note events, velocity v / 127; CC n ->
            the MIDI-mapping base + n, d / 127; aftertouch base + 128; bend base + 129, (lsb | msb << 7) / 16383),
            after the round trip -- every performEdit the library made since the block before (its jx3p_host_edits:
            one point per parameter, first seen first, its last value)
  controls  requires each click on a JX control to make the calls the plugin's own class makes (the rules READ from
            the JX binary, jx3p/docs/JX_PANEL.md), computed here from Script.xml and the library's model before it
  ticks     requires every meter / bar tick of the program's UI timer equal to the library's
  state     requires the program's state at the end (getState's bytes) equal to the library's
usage: python3 jx3p/tools/jx_exe_check.py [--exe PATH] [--patches 0,34] [--tooth replay|glue|controls|state|tick]
  --tooth replay    the replay drops the first panel edit after the first block: must FAIL
  --tooth glue      the expected velocity is v / 128: must FAIL
  --tooth controls  the jx3pLatchButton rule flips the other bit: must FAIL
  --tooth state     the replay loses the CC menu's learn (CC 20 then sets no parameter): must FAIL
  --tooth tick      the replay misses the first meter tick: must FAIL
Wine: $WINE (default /usr/lib/wine/wine64); a private prefix in build/jx_exe_check/wine.
exit 0 = GREEN (or the tooth bites)."""
import ctypes
import hashlib
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import jx_guest  # noqa: E402

WORK = os.path.join(REPO, 'build', 'jx_exe_check')
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/gui/jx_pm_glue.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
FLAGS = ['-std=c99', '-O2', '-ffp-contract=off', '-frounding-math', '-fsignaling-nans', '-fno-strict-aliasing',
         '-shared', '-fPIC', '-DJPM_PRODUCT="PG-JX3P"']
BANK = os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin')
SCRIPT = os.path.join(REPO, 'jx3p', 'truth', 'Script.xml')
MAINZOOM, PATCHZOOM = 0x0FFFC008, 0x0FFFC016
REC = 16 + 20207


def build_lib():
    h = hashlib.sha256()
    for s in SRCS + ['jx3p/src/jx_lift.c', 'jp8/src/jp8_rt.c', 'jp8/src/jp8_cpu.h']:
        h.update(open(os.path.join(REPO, s), 'rb').read())
    h.update(' '.join(FLAGS).encode())
    so = os.path.join(WORK, 'libjx_%s.so' % h.hexdigest()[:12])
    if not os.path.exists(so):
        os.makedirs(WORK, exist_ok=True)
        subprocess.check_call(['cc'] + FLAGS + ['-o', so + '.tmp'] + [os.path.join(REPO, s) for s in SRCS] + ['-lm'])
        os.replace(so + '.tmp', so)
    lib = ctypes.CDLL(so)
    I, U, D, F, P = ctypes.c_int, ctypes.c_uint32, ctypes.c_double, ctypes.c_float, ctypes.c_void_p
    for n, a, r in [('jx3p_product_init', [ctypes.c_char_p, ctypes.c_char_p, I], I),
                    ('jx3p_product_note', [I, I, I, I, F], I), ('jx3p_product_param', [U, I, D], I),
                    ('jx3p_product_tempo', [I, D], None), ('jx3p_product_block', [P, P, I, P, I], I),
                    ('jx3p_model_set', [U, ctypes.c_int32], I), ('jx3p_model_get', [U], ctypes.c_int32),
                    ('jx3p_model_set_flag', [U, ctypes.c_int32, I], I),
                    ('jx3p_model_commit', [], None), ('jx3p_value_set', [U, ctypes.c_int32], I),
                    ('jx3p_host_edits', [P, P, P, I], I), ('jx3p_state_save', [P, I], I), ('jx3p_ui_tick', [], None),
                    ('jx3p_keybed_write', [I, I], I), ('jx3p_midi_base', [], U), ('jx3p_cc_learn', [U], I),
                    ('jx3p_cc_forget', [U], I), ('jx3p_meter_tick', [I, I, I, P, I, P], I),
                    ('jx3p_bar_draw', [P, P, I, I, P, I], I), ('jx3p_lift_error', [], ctypes.c_char_p),
                    ('jx3p_set_active', [I], None), ('jx3p_setup_processing', [I], None),
                    ('juno_gui_queue_record', [P, ctypes.c_char_p, I], I),
                    ('jx_enable_hw_ftz', [], None), ('jx_set_fp_oracle_mode', [I], None)]:
        fn = getattr(lib, n)
        fn.argtypes, fn.restype = a, r
    return lib


def f32(h):
    return struct.unpack('<f', struct.pack('<I', int(h, 16)))[0]


def f64(h):
    return struct.unpack('<d', struct.pack('<Q', int(h, 16)))[0]


# ---------------------------------------------------------------- Script.xml: the value tree and the controls
class Script:
    """the value ids (the walk of gui/win's walk(): 7-bit addresses), the number tables, the controls in the
    program's tree order (panelType main, depth first, panels where they stand)"""

    def __init__(self):
        r = ET.parse(SCRIPT).getroot()
        self.r = r
        self.st = {e.findtext('type'): e for e in r.findall('structType')}
        self.leaf = {}
        for s in r.findall('struct'):
            self.walk(s.findtext('type'), self.hexaddr(s.findtext('address')), s.findtext('name'))
        self.nt = {}
        for t in r.iter('numberTable'):
            groups = [[int(x) for x in g.split('|') if x.strip()] for g in t.findtext('table').strip().split(',')]
            self.nt[t.findtext('name')] = [g for g in groups if g]
        self.pt = {p.findtext('type'): p for p in r.findall('panelType')}
        self.order = []
        self.dfs('main')

    @staticmethod
    def hexaddr(s):
        return [int(x, 16) for x in (s or '').split()][:4]

    @staticmethod
    def add7(base, off):
        o = [0] * (4 - len(off)) + list(off)
        out, carry = [0] * 4, 0
        for i in (3, 2, 1, 0):
            v = base[i] + o[i] + carry
            out[i], carry = v & 0x7F, v >> 7
        return out

    W = {'int1x7': 1, 'int2x4': 2, 'int3x4': 3, 'int4x4': 4, 'int8x4': 8}

    def walk(self, typ, base, path):
        d = self.st.get(typ)
        if d is None:
            return
        off = 0
        for c in d:
            if c.tag == 'value':
                t = c.findtext('type') or 'int1x7'
                nm = c.findtext('name')
                if nm is None:
                    continue
                a0 = c.findtext('address')
                a = self.add7(base, self.hexaddr(a0)) if a0 else self.add7(base, [0, 0, off >> 7, off & 0x7F])
                key = '%s.%s' % (path, nm)
                if key not in self.leaf:
                    rg = [int(x) for x in (c.findtext('range') or '0,0').split(',')[:2]]
                    self.leaf[key] = dict(id=(a[0] << 21) | (a[1] << 14) | (a[2] << 7) | a[3], min=rg[0], max=rg[-1],
                                          nt=c.findtext('numberTableRef'), w=self.W.get(t, 0))
                if not a0:
                    off += self.W.get(t, 0)
            elif c.tag == 'struct':
                ct, cn = c.findtext('type'), c.findtext('name')
                if not ct:
                    continue
                st = self.st.get(ct)
                tn = st.findtext('name') if st is not None else None
                if not cn:
                    cn = tn if (tn and tn != '$name') else ct
                self.walk(ct, self.add7(base, self.hexaddr(c.findtext('address'))), '%s.%s' % (path, cn))

    def dfs(self, typ):
        p = self.pt.get(typ)
        if p is None:
            return
        for e in p:
            if e.tag == 'panel':
                self.dfs(e.findtext('type'))
            elif e.tag == 'control':
                self.order.append(e)

    def control(self, typ, k):
        return [c for c in self.order if c.findtext('type') == typ][k]

    def value_of(self, ref, pos):
        L = self.leaf[ref]
        t = self.nt.get(L['nt'])
        if t:
            return t[max(0, min(pos, len(t) - 1))][0]
        return L['min'] + pos

    def eval(self, expr, get):
        st = []
        for tok in [x.strip() for x in expr.split(',')]:
            if tok in ('==', '!=', '<', '<=', '>', '>=', '&&', '||'):
                b, a = (st.pop() if st else 0), (st.pop() if st else 0)
                st.append(int({'==': a == b, '!=': a != b, '<': a < b, '<=': a <= b, '>': a > b, '>=': a >= b,
                               '&&': bool(a and b), '||': bool(a or b)}[tok]))
            elif tok.lstrip('-').isdigit():
                st.append(int(tok))
            elif tok:
                st.append(get(self.leaf[tok]['id']) if tok in self.leaf else 0)
        return bool(st and st[-1])


def bank_record(i):
    b = open(BANK, 'rb').read()
    return b[23 + i * REC: 23 + (i + 1) * REC]


def expect_click(S, lib, typ, k, tooth):
    """the calls a click on control k of type typ must make (READ rules, jx3p/docs/JX_PANEL.md): a list of
    ('model_set', id, v) / ('patch', idx)"""
    c = S.control(typ, k)
    get = lambda i: lib.jx3p_model_get(i)
    if typ == 'jx3pLatchButton':
        ref = c.findtext('valueRef')
        role = int(c.findtext('role') or 0)
        mask = (1 if role else 2) if tooth == 'controls' else (2 if role else 1)
        return [('model_set', S.leaf[ref]['id'], get(S.leaf[ref]['id']) ^ mask)]
    if typ == 'jx3pSlider':
        ref = c.findtext('valueRef')
        role = int(c.findtext('role') or 0)
        v = get(S.leaf[ref]['id'])
        p = (v >> role) & 1
        p = p + 1 if p <= 0 else p - 1                  # a click: one position on, turning at the ends
        n = (v & (2 >> role)) | (p << role)
        return [] if n == v else [('model_set', S.leaf[ref]['id'], S.value_of(ref, n))]
    if typ == 'exprLatchButton':
        on = S.eval(c.findtext('state'), get)
        kids = list(c)
        pairs, want = [], 'offValueRef' if on else 'onValueRef'
        for i, e in enumerate(kids):
            if e.tag == want:
                pairs.append(('model_set', S.leaf[e.text]['id'], int(kids[i + 1].text)))
        return pairs
    if typ == 'patchSelectButton':
        cur = get(S.leaf['vm.vs.patchId']['id'])
        lane, idx = int(c.findtext('lane') or 0) != 0, int(c.findtext('index') or 0)
        q = int(cur / 16)                                 # C division (cur >= 0)
        return [('patch', idx * 16 + cur % 16 if lane else q * 16 + idx)]
    if typ == 'patchBlock':
        return [('patch', int(c.findtext('patchId') or 0))]
    raise SystemExit('no rule for %s' % typ)


# ---------------------------------------------------------------- the replay
def replay(lib, log, tooth):
    S = Script()
    base = lib.jx3p_midi_base()
    out, errs, pending, blk = [], [], [], 0
    rt = []                                               # the round trip: [id, value] in first-seen order
    ids = (ctypes.c_uint32 * 512)()
    vals = (ctypes.c_double * 512)()
    rect, fill = (ctypes.c_int * 4)(), (ctypes.c_int * 4)()
    blits = (ctypes.c_int * (7 * 64))()
    states, clicks, dropped, skipped_tick, dropped_cc = 0, [], False, False, False
    click = None                                          # (label, expected calls, calls seen)

    def edits():
        n = lib.jx3p_host_edits(ids, vals, None, 512)
        for i in range(n):
            for e in rt:
                if e[0] == ids[i]:
                    e[1] = vals[i]
                    break
            else:
                rt.append([ids[i], vals[i]])

    def close_click():
        nonlocal click
        if click:
            label, want, seen = click
            ok = seen[:len(want)] == want and all(s[0] != 'model_set' for s in seen[len(want):])
            clicks.append((label, ok))
            if not ok:
                errs.append('click %s: the calls %s, the rule %s' % (label, seen[:6], want))
        click = None

    lines = [ln.split() for ln in log.splitlines() if ln]
    i = 0
    while i < len(lines):
        t = lines[i]
        i += 1
        if t[0] == '#':
            if len(t) >= 4 and t[1] == 'click':
                close_click()
                click = ('%s %s' % (t[2], t[3]), expect_click(S, lib, t[2], int(t[3]), tooth), [])
            continue
        if t[0] in ('meter', 'bar'):
            if t[0] == 'meter' and tooth == 'tick' and not skipped_tick:
                skipped_tick = True                       # TOOTH: the first meter tick is lost
                continue
            if t[0] == 'meter':
                for k in range(4):
                    rect[k] = int(t[4 + k])
                st = lib.jx3p_meter_tick(int(t[1]), int(t[2]), int(t[3]), rect, int(t[8]), fill)
                got, want = [st] + list(fill), [int(x) for x in t[9:14]]
            else:
                nb = min(lib.jx3p_bar_draw(rect, fill, 1, int(t[1]), blits, 64), 64)
                got, want = [nb] + list(blits[:7 * nb]), [int(x) for x in t[2:]]
            if got != want:
                errs.append('tick %s: the library %s, the program %s' % (' '.join(t[:3]), got[:8], want[:8]))
            continue
        if t[0] == 'init':
            if lib.jx3p_product_init(jx_guest.path(96).encode(), BANK.encode(), int(t[1])) < 0:
                raise SystemExit('jx3p_product_init failed: %s' % lib.jx3p_lift_error())
        elif t[0] == 'ftz':
            if t[1] == '1':
                lib.jx_enable_hw_ftz()
            else:
                lib.jx_set_fp_oracle_mode(1)
        elif t[0] == 'queue_record':
            b = bytes.fromhex(t[1])
            if click:
                click[2].append(('patch', next((k for k in range(64) if bank_record(k)[16:] == b), -1)))
            lib.juno_gui_queue_record(None, b, len(b))
            edits()
        elif t[0] in ('model_set', 'pm_set'):
            if t[0] == 'model_set' and tooth == 'replay' and blk > 0 and not dropped:
                dropped = True                            # TOOTH: the first panel edit is lost
                continue
            if click and t[0] == 'model_set':
                click[2].append(('model_set', int(t[1]), int(t[2])))
            if len(t) > 3 and t[0] == 'model_set':           # a drag's step: the set's flag (the one open edit)
                lib.jx3p_model_set_flag(int(t[1]), int(t[2]), int(t[3]))
            else:
                lib.jx3p_model_set(int(t[1]), int(t[2]))
            edits()
        elif t[0] in ('commit', 'pm_commit'):
            lib.jx3p_model_commit()
        elif t[0] in ('pm_notify', 'editor'):
            pass
        elif t[0] == 'zoomfit':
            lib.jx3p_value_set(PATCHZOOM if t[1] == '1' else MAINZOOM, int(t[2]))
        elif t[0] == 'ui_tick':
            lib.jx3p_ui_tick()
        elif t[0] == 'keybed':
            lib.jx3p_keybed_write(int(t[1]), int(t[2]))
        elif t[0] == 'cc_learn':
            if tooth == 'state' and not dropped_cc:
                dropped_cc = True                         # TOOTH: the learn is lost
                continue
            lib.jx3p_cc_learn(int(t[1]))
        elif t[0] == 'cc_forget':
            lib.jx3p_cc_forget(int(t[1]))
        elif t[0] == 'rerate':
            lib.jx3p_set_active(0)
            lib.jx3p_setup_processing(int(t[1]))
            lib.jx3p_set_active(1)
        elif t[0] == 'state':
            buf = ctypes.create_string_buffer(4 + 8 * 256)
            n = lib.jx3p_state_save(buf, len(buf))
            states += 1
            if n < 0 or buf.raw[:n].hex() != t[1]:
                errs.append('state: the library %s.., the program %s..' % (buf.raw[:max(n, 0)].hex()[:48], t[1][:48]))
        elif t[0] == 'midi':
            pending.append(int(t[1], 16))
        elif t[0] == 'process':
            close_click()
            n, tempo, nev, npar = int(t[1]), f64(t[2]), int(t[3]), int(t[4])
            evs = [lines[i + k] for k in range(nev)]
            i += nev
            pars = [lines[i + k] for k in range(npar)]
            i += npar
            got_ev = [(int(e[1]), int(e[2]), int(e[3]), int(e[4]), int(e[5], 16)) for e in evs]
            got_par = [(int(p[1]), int(p[2]), f64(p[3])) for p in pars]
            want_ev, want_par = [], [(e[0], 0, e[1]) for e in rt]
            for m in pending:
                st, ch, d1, d2 = m & 0xF0, m & 0x0F, (m >> 8) & 0x7F, (m >> 16) & 0x7F
                if st == 0x90 and d2:
                    v = np.float32(d2) / np.float32(128.0 if tooth == 'glue' else 127.0)
                    want_ev.append((0, 0, ch, d1, struct.unpack('<I', struct.pack('<f', v))[0]))
                elif st in (0x80, 0x90):
                    want_ev.append((0, 1, ch, d1, struct.unpack('<I', struct.pack('<f', 0.5))[0]))
                elif st == 0xB0:
                    want_par.append((base + d1, 0, d2 / 127.0))
                elif st == 0xD0:
                    want_par.append((base + 128, 0, d1 / 127.0))
                elif st == 0xE0:
                    want_par.append((base + 129, 0, (d1 | (d2 << 7)) / 16383.0))
            if got_ev != want_ev or got_par != want_par:
                errs.append('block %d: events %s params %s, the host\'s %s %s' % (blk, got_ev[:4], got_par[:4],
                                                                                     want_ev[:4], want_par[:4]))
            pending, rt = [], []
            for e in got_ev:
                lib.jx3p_product_note(e[1], e[0], e[2], e[3], f32('%08x' % e[4]))
            for p in got_par:
                lib.jx3p_product_param(p[0], p[1], p[2])
            lib.jx3p_product_tempo(1, tempo)
            L, R = (ctypes.c_float * n)(), (ctypes.c_float * n)()
            lib.jx3p_product_block(L, R, n, None, 0)
            o = np.empty(2 * n, np.float32)
            o[0::2] = np.frombuffer(L, np.float32)
            o[1::2] = np.frombuffer(R, np.float32)
            out.append(o)
            blk += 1
        else:
            raise SystemExit('log line %d: unknown call %r' % (i, t))
    close_click()
    reach = dict((k, sum(1 for t in lines if t[0] == k)) for k in ('cc_learn', 'cc_forget', 'queue_record', 'keybed'))
    for k, least in (('cc_learn', 1), ('cc_forget', 1), ('queue_record', 4), ('keybed', 2)):
        if reach[k] < least:                              # REACH: the script's paths ran
            errs.append('reach: %d %s calls, at least %d expected' % (reach[k], k, least))
    if lib.jx3p_lift_error():
        errs.append('the library trapped: %s' % lib.jx3p_lift_error().decode())
    if states != 1:
        errs.append('the program logged %d end states (1 expected)' % states)
    return (np.concatenate(out) if out else np.zeros(0, np.float32)), errs, clicks


def run_exe(exe, work, patch):
    raw = os.path.join(work, 'r_%d.raw' % patch)
    args = [exe, '--render', os.path.basename(raw), '--patch', str(patch)]
    if os.name != 'nt':
        args = [os.environ.get('WINE', '/usr/lib/wine/wine64')] + args
    prefix = os.path.join(WORK, 'wine')
    os.makedirs(prefix, exist_ok=True)
    env = dict(os.environ, WINEDEBUG='-all', WINEPREFIX=prefix)
    r = subprocess.run(args, cwd=work, env=env, timeout=1800, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if r.returncode or not os.path.exists(raw + '.log'):
        raise SystemExit('the program failed (%d): %s' % (r.returncode, r.stdout.decode(errors='replace')[-600:]))
    return np.fromfile(raw, np.float32), open(raw + '.log', newline=None).read()


def main():
    a = sys.argv
    exe = a[a.index('--exe') + 1] if '--exe' in a else os.path.join(REPO, 'scratchpad', 'dist', 'JX-3P.exe')
    tooth = a[a.index('--tooth') + 1] if '--tooth' in a else None
    patches = [int(x) for x in (a[a.index('--patches') + 1] if '--patches' in a else '0,34').split(',')]
    os.makedirs(WORK, exist_ok=True)
    work = tempfile.mkdtemp(prefix='run_', dir=WORK)
    shutil.copyfile(exe, os.path.join(work, 'JX-3P.exe'))
    fails = 0
    for patch in patches:
        lib = build_lib()           # a fresh process state per case: one library per process -- run each in a child
        got, log = run_exe(os.path.join(work, 'JX-3P.exe'), work, patch)
        ref, errs, clicks = child_replay(log, tooth)
        same = got.shape == ref.shape and np.array_equal(got.view(np.uint32), ref.view(np.uint32))
        nz = int(np.count_nonzero(ref))
        diff = 'EXACT' if same else 'DIFFER at sample %d of %d' % (
            int(np.argmax(got.view(np.uint32) != ref.view(np.uint32))) if got.shape == ref.shape else -1, ref.size)
        speed = [ln for ln in log.splitlines() if ln.startswith('# rendered')]
        ok = same and not errs and nz > ref.size // 4 and len(clicks) >= 8
        fails += not ok
        print('%s patch %2d: replay %s, %d clicks (%d by the rules), glue / ticks / state %s, %d / %d samples '
              'non-zero, peak %.3f; %s' % ('ok  ' if ok else 'FAIL', patch + 1, diff, len(clicks),
                                           sum(1 for c in clicks if c[1]), 'ok' if not errs else '%d ERRORS' % len(errs),
                                           nz, ref.size, float(np.max(np.abs(ref))) if ref.size else 0.0,
                                           speed[0][2:] if speed else ''))
        for e in errs[:4]:
            print('      ' + e)
        del lib
    shutil.rmtree(work, ignore_errors=True)
    print('jx_exe_check: %s (%d cases%s)' % ('GREEN' if not fails else 'RED', len(patches),
                                             ', tooth ' + tooth if tooth else ''))
    if tooth:
        print('the tooth %s' % ('BITES' if fails else 'DID NOT BITE'))
        return 0 if fails else 1
    return 1 if fails else 0


def child_replay(log, tooth):
    """the replay in a child process: the library holds one instance per process (jx_bridge.c)"""
    fd, path = tempfile.mkstemp(suffix='.log', dir=WORK)
    os.write(fd, log.encode())
    os.close(fd)
    r = subprocess.run([sys.executable, os.path.abspath(__file__), '--child', path, tooth or '-'],
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    os.remove(path)
    if r.returncode:
        raise SystemExit('the replay failed: %s' % r.stderr.decode(errors='replace')[-800:])
    import pickle
    return pickle.loads(r.stdout)


if __name__ == '__main__':
    if sys.argv[1:2] == ['--child']:
        import pickle
        ref, errs, clicks = replay(build_lib(), open(sys.argv[2]).read(), None if sys.argv[3] == '-' else sys.argv[3])
        sys.stdout.buffer.write(pickle.dumps((ref, errs, clicks)))
        sys.exit(0)
    sys.exit(main())
