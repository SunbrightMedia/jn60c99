#!/usr/bin/env python3
"""cc_menu_gate.py -- the CC assign menu (CLAIMS A38, docs/CC_MENU.md): JUNO-60.exe's right-button
press, its menu and its MIDI learn / forget against THE PLUGIN'S OWN HANDLER on THE PLUGIN'S OWN
PANEL TREE.

The plugin builds its GUI tree from Script.xml at its module init: every panel, every control an
object of its own class with its rectangle from its sprite sheet's frame. The emulator's GDI+ gives
each sheet its real size, read from the PNG's own header (truth/Script/, checksummed); nothing else
of the images is used. The gate:
  1. walks that tree (a panel: open byte +0x70, panels +0x78, controls +0x90; a control: its
     rectangle +0x18, its values +0x58 (64 bytes each), its type name vt+0x108, its first value
     vt+0xD8, that value's record in the core's CC map rva 0x319B10, the record's id rva 0x319C50)
     and requires the program's own tree (kbscript "cctree") to give the search the same input:
     the same panels in the same order, and in each the same controls the search can stop at
     (type not label / display, one value, a CC map record) with the same rectangle and record,
     in the same order among themselves; every other difference is reported;
  2. runs a seeded script through the program under Wine (kbscript: its own cc_press /
     cc_target / cc_menu; the probes press nothing): at every corner and edge of every control
     and at random points, its search alone (ccpick) and a right press with the Shift / Ctrl /
     Alt bits and the menu dismissed (ccmsg), in 24 panel configurations (vm.vs.mode, TEMPO
     SYNC, DELAY TYPE, the setup page); right presses that pick Learn or Forget (ccmsg ... ITEM)
     with CCs, blocks and UI-timer drains after them, and the state;
  3. plays the log into the plugin (a worker process: Unicorn only): its boot and every engine
     call (as tools/dist/exe_oracle_check.py), and at each probe its handler rva 0x31D420 itself
     on its own CC assign control, attached to its core by its own attach (vt+0xB0, rva
     0x31D7B0: +0x80; the template's is empty), with the message (type 0 down and type 2 double click; the point;
     flags 4 | the modifier bits), the panels' open bytes from the program's tree at that point
     (the open conditions are the program's, CLAIMS C5; written before each press: a model
     change the drain applies closes every panel of the viewless template), the menu service the
     plugin's own
     override pointer (rva 0xCB21F8 -> 0x400130) set to a popup that records the items and
     returns the scripted one (-1 for a greyed item: Windows never returns one).

Compared: taken or not; the record found (its id); the menu's labels and enabled flags; the learn
or forget made (its record's id); after every state line, the state (getState's bytes: the 95
values and the CC map). REACH: the plugin takes presses, learns, forgets, a learn takes a CC.

usage: cc_menu_gate.py [--exe PATH] [--seed N] [--tooth N] [--quick] [--keep LOG | --log LOG]
  --quick    two panel configurations, not 24 (the teeth's run)
  --tooth N  builds JUNO-60.exe with -DCC_TOOTH=N (gui/win/juno60_win.c) and runs it: must FAIL
             (with --exe: that build, made with the tooth)
  teeth: 1 a panel's controls searched first to last, 2 the right and bottom edges inside, 3 closed
  panels searched, 4 Shift / Ctrl / Alt ignored, 5 a greyed Forget acts, 6 labels and displays
  searched, 7 controls with many values searched, 8 the child panels before the controls
Wine: $WINE (default /usr/lib/wine/wine64).
"""
import multiprocessing as mp
import os
import random
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import truth  # noqa: E402

EXE = os.path.join(REPO, 'scratchpad', 'dist', 'JUNO-60.exe')
WINE = os.environ.get('WINE', '/usr/lib/wine/wine64')
HEADER, STRIDE, NAME = 23, 20223, 16
HANDLER, SEARCH_RET, LEARN, FORGET = 0x31D420, 0x31D499, 0x31AA40, 0x3192E0
MAP_RECORD, MAP_ID, MENU_OVERRIDE, CCASSIGN_VT = 0x319B10, 0x319C50, 0xCB21F8, 0x94A4C0
CCA_ATTACH = 0x31D7B0                # the CC assign control's attach (vt+0xB0)
HEAP = (0x310000000, 0x312000000)      # where the module init's GUI objects live in the emulator
RATE = 48000.0
MODS = [0, 0, 0, 0, 1, 2, 8, 3, 9, 10, 11]   # the plugin's modifier bits: 1 Shift, 2 Ctrl, 8 Alt
# panel configurations: (vm.vs.mode, TEMPO SYNC, DELAY TYPE, vm.vs.setup) -- every open condition
CONFIGS = [(m, s, d, u) for m in (0, 1) for s in (0, 1) for d in (0, 2, 5) for u in (0, 1)]


def png_sizes():
    """each sprite sheet's size from its own PNG header (IHDR): what GDI+ reports for the file"""
    d = os.path.join(truth.TRUTH_DIR, 'Script')
    out = {}
    for f in os.listdir(d):
        if f.lower().endswith('.png'):
            b = open(os.path.join(d, f), 'rb').read(24)
            if b[:8] != b'\x89PNG\r\n\x1a\n' or b[12:16] != b'IHDR':
                raise SystemExit('not a PNG: %s' % f)
            out[f.lower()] = struct.unpack('>II', b[16:24])
    return out


def bank_file(name):
    if name == 'Factory':
        return truth.BANK
    udir = os.path.join(REPO, 'scratchpad', 'userbanks')
    for f in os.listdir(udir):
        if f.lower().endswith('.bin') and os.path.splitext(f)[0].lstrip('~').strip() == name:
            return os.path.join(udir, f)
    raise SystemExit('bank %r not found' % name)


def f32(hx):
    return struct.unpack('<f', struct.pack('<I', int(hx, 16)))[0]


def f64(hx):
    return struct.unpack('<d', struct.pack('<Q', int(hx, 16)))[0]


# ------------------------------------------------------------------ the plugin (worker processes)
class PluginGUI:
    """the plugin booted with its GUI tree; plumbing around its own code only"""

    def __init__(self, rate):
        import numpy as np
        import host_process_emu as H
        from unicorn import UC_HOOK_CODE
        from unicorn.x86_const import UC_X86_REG_RAX, UC_X86_REG_RDX
        self.H, self.RAX, self.RDX = H, UC_X86_REG_RAX, UC_X86_REG_RDX
        h = self.h = H.HostProcess()
        h.skin = png_sizes()                    # the real sheet sizes (the default is a blank guess)
        h.start(rate, 4096)
        uc = self.uc = h.uc
        IB = self.IB = H.IB
        blob = np.frombuffer(bytes(uc.mem_read(HEAP[0], HEAP[1] - HEAP[0])), dtype=np.uint64)
        at = np.nonzero(blob == np.uint64(IB + CCASSIGN_VT))[0]
        if len(at) != 1:
            raise SystemExit('the CC assign control: %d objects of its class' % len(at))
        self.cca = HEAP[0] + 8 * int(at[0])
        self.root = self.q(self.cca + 0x78)     # its parent (vt+0x18 = rva 0x28C020); the main panel's is 0
        self.map = h.core + 24
        # attached by the plugin's own attach (vt+0xB0, rva 0x31D7B0): it sets +0x80 to the core
        h.call(IB + CCA_ATTACH, rcx=self.cca, count=500_000_000)
        if self.q(self.cca + 0x80) != h.core:
            raise SystemExit('the plugin\'s attach (rva 0x31D7B0) left +0x80 = %x, not the core %x'
                             % (self.q(self.cca + 0x80), h.core))
        self.names, self.panels, self.tree = {}, [], []
        self._walk(self.root)
        # the record list: record k -> parameter id (rva 0x319C50), for model sets and the comparison
        vb, ve = self.q(self.map), self.q(self.map + 8)
        self.rec_id, self.rec_obj, self.kidx = [], [], {}
        for k in range((ve - vb) // 24):
            pid = h.call(IB + MAP_ID, rcx=self.map, rdx=k) & 0xFFFFFFFF
            self.rec_id.append(pid)
            self.rec_obj.append(self.q(vb + 24 * k))
            self.kidx[pid] = k
        # the menu service: the plugin's own override pointer, a popup that records and answers
        svc, svt, stub = h.alloc_com(0x40), h.alloc_com(0x100), h.alloc_com(0x10)
        uc.mem_write(stub, b'\xC3')
        uc.mem_write(svc, struct.pack('<Q', svt))
        uc.mem_write(svt, struct.pack('<Q', stub) * 32)
        uc.mem_write(IB + MENU_OVERRIDE, struct.pack('<Q', svc))
        self.st = {}
        uc.hook_add(UC_HOOK_CODE, self._popup, begin=stub, end=stub)
        uc.hook_add(UC_HOOK_CODE, self._call, begin=IB + LEARN, end=IB + LEARN)
        uc.hook_add(UC_HOOK_CODE, self._call, begin=IB + FORGET, end=IB + FORGET)
        uc.hook_add(UC_HOOK_CODE, self._pick, begin=IB + SEARCH_RET, end=IB + SEARCH_RET)
        self.msg = h.alloc_com(0x20)
        self.opens = [0] * len(self.panels)

    def q(self, a):
        return struct.unpack('<Q', bytes(self.uc.mem_read(a, 8)))[0]

    def sstr(self, a):
        n, cap = self.q(a + 0x10), self.q(a + 0x18)
        return bytes(self.uc.mem_read(self.q(a) if cap >= 16 else a, n)).decode('latin1')

    def tname(self, obj):
        vt = self.q(obj)
        if vt not in self.names:
            self.names[vt] = self.sstr(self.h.call(self.q(vt + 0x108), rcx=obj))
        return self.names[vt]

    def _walk(self, p):
        q = self.q
        cb, ce, pb, pe = q(p + 0x90), q(p + 0x98), q(p + 0x78), q(p + 0x80)
        self.panels.append(p)
        ctl = []
        for k in range((ce - cb) // 8):
            c = q(cb + 8 * k)
            l, t, r, b = struct.unpack('<iiii', bytes(self.uc.mem_read(c + 0x18, 16)))
            nrefs = (q(c + 0x60) - q(c + 0x58)) // 64
            rec = pid = -1
            if nrefs >= 1:
                node = self.h.call(q(q(c) + 0xD8), rcx=c, rdx=0xFFFFFFFF)
                rec = self.h.call(self.IB + MAP_RECORD, rcx=self.h.core + 24, rdx=node) & 0xFFFFFFFF
                rec = rec - (1 << 32) if rec >= 1 << 31 else rec
                if rec >= 0:
                    pid = self.h.call(self.IB + MAP_ID, rcx=self.h.core + 24, rdx=rec) & 0xFFFFFFFF
            ctl.append((self.tname(c), l, t, r, b, nrefs, rec, pid))
        self.tree.append(('P', len(ctl), (pe - pb) // 8, ctl))
        for k in range((pe - pb) // 8):
            self._walk(q(pb + 8 * k))

    def _popup(self, uc, addr, size, ud):
        v = uc.reg_read(self.RDX)
        b, e = self.q(v), self.q(v + 8)
        items = [(self.sstr(self.q(b + 8 * k)), uc.mem_read(self.q(b + 8 * k) + 0x28, 1)[0]) for k in range((e - b) // 8)]
        self.st['items'] = items
        ch = self.st['choice']
        if ch >= len(items) or (ch >= 0 and not items[ch][1]):
            ch = -1                             # a greyed item is never the popup's answer
        uc.reg_write(self.RAX, ch & 0xFFFFFFFFFFFFFFFF)

    def _call(self, uc, addr, size, ud):
        k = uc.reg_read(self.RDX) & 0xFFFFFFFF
        self.st['calls'].append(('cc_learn' if addr == self.IB + LEARN else 'cc_forget',
                                 self.rec_id[k] if k < len(self.rec_id) else -1))

    def _pick(self, uc, addr, size, ud):
        r = uc.reg_read(self.RAX) & 0xFFFFFFFF
        self.st['pick'] = r - (1 << 32) if r >= 1 << 31 else r

    def set_open(self, flags):
        self.opens = list(flags)

    def press(self, x, y, flags, typ=0, choice=-1):
        """the handler on a message: (taken, the found record's id or -1, menu items, calls).
        The panels' open bytes are written first, every time: the template tree has no live view,
        and a model change the drain applies closes all of them (MEASURED: a mapped CC's drain)"""
        for p, f in zip(self.panels, self.opens):
            self.uc.mem_write(p + 0x70, bytes([f]))
        self.st = dict(choice=choice, items=None, calls=[], pick=None)
        self.uc.mem_write(self.msg, struct.pack('<iiii', typ, x, y, flags))
        taken = self.h.call(self.IB + HANDLER, rcx=self.cca, rdx=self.msg) & 0xFF
        k = self.st['pick']
        return (taken, self.rec_id[k] if k is not None and 0 <= k < len(self.rec_id) else -1,
                self.st['items'], self.st['calls'])


def plugin_tree(_):
    """the plugin's tree (a worker: Unicorn only)"""
    g = PluginGUI(RATE)
    out = g.tree
    del g
    return out


def searchable(c):
    """a control the search can stop at (rva 0x31D7F0 and 0x319B10): not a label or a display,
    exactly one value, a CC map record"""
    return c[0] not in ('label', 'display') and c[5] == 1 and c[6] >= 0


def parse_trees(log):
    """the program's cctree blocks: each a pre-order list like PluginGUI.tree, with its open flags"""
    lines = [ln[len('# cctree '):].split() for ln in log if ln.startswith('# cctree ')]
    out, i = [], 0
    while i < len(lines):
        tree, opens = [], []

        def panel():
            nonlocal i
            t = lines[i]
            i += 1
            assert t[0] == 'P', t
            opn, nc, npn = int(t[1]), int(t[2]), int(t[3])
            ctl = []
            for _ in range(nc):
                c = lines[i]
                i += 1
                x, y, w, h = (int(v) for v in c[2:6])
                l, tp, r, b = (0, 0, 0, 0) if w < 0 else (x, y, x + w, y + h)
                ctl.append((c[1], l, tp, r, b, int(c[6]), int(c[8]), int(c[7]) if int(c[8]) >= 0 else -1))
            tree.append(('P', nc, npn, ctl))
            opens.append(opn)
            for _ in range(npn):
                panel()
        panel()
        out.append((tree, opens))
    return out


def order_pairs(tree, opens):
    """the search's ORDER is observable only where two controls it can stop at, of different
    parameters, overlap while both are live (their panel and its ancestors open): those pairs"""
    par, live, out = {}, [], set()

    def walk(k, parent):
        par[k] = parent
        j = k + 1
        for _ in range(tree[k][2]):
            j = walk(j, k)
        return j
    walk(0, None)
    for k in range(len(tree)):
        a = k
        while a not in (None, 0) and opens[a]:
            a = par[a]
        if a in (None, 0):
            live += [(k, c) for c in tree[k][3] if searchable(c)]
    for i in range(len(live)):
        for j in range(i + 1, len(live)):
            (k1, a), (k2, b) = live[i], live[j]
            if a[7] != b[7] and a[1] < b[3] and b[1] < a[3] and a[2] < b[4] and b[2] < a[4]:
                out.add((k1, a[:5], k2, b[:5]))
    return out


def compare_trees(plugin, exe):
    """(failures, notes): the search's input must be equal; other differences are notes"""
    fails, notes = [], []
    if len(plugin) != len(exe) or any(a[2] != b[2] for a, b in zip(plugin, exe)):
        return ['panel structure: plugin %d panels, program %d' % (len(plugin), len(exe))], notes
    key = lambda c: (c[0], c[1], c[2], c[3], c[4], c[5], c[7])   # type, rectangle, values, the record's id
    for pi, (a, b) in enumerate(zip(plugin, exe)):
        sa, sb = [key(c) for c in a[3] if searchable(c)], [key(c) for c in b[3] if searchable(c)]
        if sa != sb:
            for k in range(max(len(sa), len(sb))):
                ca, cb = (sa[k] if k < len(sa) else None), (sb[k] if k < len(sb) else None)
                if ca != cb:
                    fails.append('panel %d, searchable control %d: plugin %s, program %s' % (pi, k, ca, cb))
                    break
        oa = [c for c in a[3] if not searchable(c)]
        ob = [c for c in b[3] if not searchable(c)]
        for c in oa:
            if c not in ob:
                notes.append('panel %d: the plugin\'s %s at (%d,%d)-(%d,%d), %d values: not in the program\'s tree as is'
                             % (pi, c[0], c[1], c[2], c[3], c[4], c[5]))
        for c in ob:
            if c not in oa:
                notes.append('panel %d: the program\'s %s at (%d,%d)-(%d,%d), %d values: not in the plugin\'s tree as is'
                             % (pi, c[0], c[1], c[2], c[3], c[4], c[5]))
    return fails, notes


def oracle(log):
    """the program's log played into the plugin; the handler at every probe (a worker: Unicorn only)"""
    import gc
    lines = log
    g = None
    H = None
    res = dict(fails=[], notes=[], opens=set(), order=set(), n=dict(pick=0, msg=0, taken=0, learn=0, forget=0, state=0))
    banks = {}
    tree_done = False
    i = 0
    model = note_value = kbuf = None
    boot_map = None

    def fail(s):
        if len(res['fails']) < 40:
            res['fails'].append(s)
        res.setdefault('nfail', 0)
        res['nfail'] = res.get('nfail', 0) + 1

    def ccmap(st):
        n = struct.unpack('>I', st[:4])[0] // 8
        return {k: v for k, v in (struct.unpack('>Ii', st[4 + 8 * j: 12 + 8 * j]) for j in range(n)) if k >= 0x10000000}

    while i < len(lines):
        ln = lines[i]
        i += 1
        t = ln.split()
        if not t:
            continue
        if ln.startswith('# cctree '):
            blk = [ln]                          # the program's tree now: the search's input
            while i < len(lines) and lines[i].startswith('# cctree '):
                blk.append(lines[i])
                i += 1
            for tree, opens in parse_trees(blk):
                if not tree_done:
                    f, n = compare_trees(g.tree, tree)
                    for s in f:
                        fail('tree: ' + s)
                    res['notes'] += n
                    res['n']['panels'], res['n']['controls'] = len(tree), sum(len(p[3]) for p in tree)
                    res['n']['searchable'] = sum(1 for p in g.tree for c in p[3] if searchable(c))
                    tree_done = True
                g.set_open(opens)
                if tuple(opens) not in res['opens']:
                    res['opens'].add(tuple(opens))
                    res['order'] |= order_pairs(tree, opens)
            continue
        if ln.startswith('# ccpick '):
            x, y, want = int(t[2]), int(t[3]), int(t[4])
            for typ in (0, 2):
                taken, pid, items, calls = g.press(x, y, 4, typ)
                got = pid if taken else -1
                if got != want or bool(taken) != (want >= 0) or calls:
                    fail('ccpick %d %d (type %d): plugin %s (taken %d), program %d' % (x, y, typ, got, taken, want))
            res['n']['pick'] += 1
            continue
        if ln.startswith('# ccmsg ') and len(t) == 6:
            x, y, mods, item = int(t[2]), int(t[3]), int(t[4]), int(t[5])
            menu, calls_exe = None, []
            while i < len(lines) and not lines[i].startswith('# ccmsg taken'):
                u = lines[i]
                i += 1
                if u.startswith('# ccmenu '):
                    a = u[len('# ccmenu '):].split(' ', 2)
                    lab = a[2].split('|')
                    menu = (int(a[0]), int(a[1]), [(lab[0], int(lab[1])), (lab[2], int(lab[3]))])
                elif u.startswith('cc_learn ') or u.startswith('cc_forget '):
                    calls_exe.append((u.split()[0], int(u.split()[1])))
                else:
                    fail('ccmsg %d %d %d %d: unexpected program line %r' % (x, y, mods, item, u))
            taken_exe = int(lines[i].split()[3])
            i += 1
            taken, pid, items, calls = g.press(x, y, 4 | mods, 0, item if item < 2 else -1)
            ok = bool(taken) == bool(taken_exe) and calls == calls_exe
            if taken and ok:
                ok = menu is not None and menu[0] == pid and menu[2] == [(a, int(b)) for a, b in items]
            elif not taken and menu is not None:
                ok = False
            if not ok:
                fail('ccmsg %d %d %d %d: plugin taken %d id %d items %s calls %s; program taken %d menu %s calls %s'
                     % (x, y, mods, item, taken, pid, items, calls, taken_exe, menu, calls_exe))
            res['n']['msg'] += 1
            res['n']['taken'] += bool(taken)
            res['n']['learn'] += sum(1 for c in calls if c[0] == 'cc_learn')
            res['n']['forget'] += sum(1 for c in calls if c[0] == 'cc_forget')
            continue
        if ln.startswith('#'):
            continue
        # the engine calls (as tools/dist/exe_oracle_check.py)
        if t[0] == 'create':
            g = PluginGUI(float(t[1]))
            h, H = g.h, g.H
            uc = h.uc
            q = g.q
            model = q(q(h.core + 8))
            note_value = h.vcall(q(model + 128), 6)
            kbuf = h.alloc_com(16)
            boot_map = ccmap(h.get_state())
        elif t[0] == 'plugin_init':
            pass
        elif t[0] == 'queue_patch':
            name = ' '.join(t[2:])
            if name not in banks:
                banks[name] = open(bank_file(name), 'rb').read()
            b, p = banks[name], int(t[1])
            h.load_patch(b[HEADER + p * STRIDE + NAME: HEADER + (p + 1) * STRIDE])
        elif t[0] == 'model_set':
            pid, v = int(t[1]), int(t[2])
            if pid in g.kidx:
                h.call(H.IB + 0x283DB0, rcx=model, rdx=g.rec_obj[g.kidx[pid]], r8=v & 0xFFFFFFFF, r9=1)
            else:
                res['notes'].append('model_set %d: not in the plugin\'s record list' % pid)
        elif t[0] == 'ui_tick':
            h.call(H.IB + 0x320120, rcx=h.core, count=2_000_000_000)
        elif t[0] == 'commit':
            for rva in (0x285320, 0x2853C0, 0x283120):
                h.call(H.IB + rva, rcx=model, count=500_000_000)
        elif t[0] == 'keybed':
            uc.mem_write(kbuf, struct.pack('<ii', int(t[1]), int(t[2])))
            h.call(H.IB + 0x2838C0, rcx=model, rdx=note_value, r8=kbuf, count=500_000_000)
            for rva in (0x285320, 0x2853C0, 0x283120):
                h.call(H.IB + rva, rcx=model, count=500_000_000)
        elif t[0] in ('midi', 'led', 'meter', 'bar'):
            pass                                # the program's input log; the UI timer's LED / meters
        elif t[0] == 'process':
            n, tempo, nev, npar = int(t[1]), f64(t[2]), int(t[3]), int(t[4])
            evs, par = [], []
            for k in range(nev):
                e = lines[i + k].split()
                evs.append(('on' if int(e[2]) == 0 else 'off', int(e[1]), int(e[3]), int(e[4]), f32(e[5])))
            i += nev
            for k in range(npar):
                p = lines[i + k].split()
                par.append((int(p[1]), int(p[2]), f64(p[3])))
            i += npar
            h.process(n, events=evs, params=par, ctx=dict(tempo=tempo, playing=True))
        elif t[0] == 'state':
            st = h.get_state()
            res['n']['state'] += 1
            if st.hex() != t[1]:
                fail('state %d: the plugin\'s getState differs from the program\'s' % res['n']['state'])
            end = ccmap(st)
            res['n']['moved'] = sum(1 for k in end if end[k] != boot_map.get(k))
        elif t[0] in ('cc_learn', 'cc_forget'):
            fail('a %s outside a menu: %r' % (t[0], ln))
        else:
            fail('log: unknown call %r' % ln)
    del g
    gc.collect()
    return res


# ------------------------------------------------------------------ the script and the program
def script(tree, seed, quick=False):
    """a seeded kbscript over the plugin's own rectangles (quick: two configurations, mode 0 and
    mode 1 with every other condition flipped -- the teeth's run)"""
    rnd = random.Random(seed)
    rects = [(c[1], c[2], c[3], c[4]) for p in tree for c in p[3] if c[3] > c[1] and c[4] > c[2]]
    rects = sorted(set(rects))
    edges = []
    for l, t, r, b in rects:
        edges += [((l + r) // 2, (t + b) // 2), (l, t), (r - 1, b - 1), (l - 1, t), (l, t - 1), (r, b - 1), (r - 1, b)]
    out = ['cctree', 'state']
    configs = [CONFIGS[0], CONFIGS[-1]] if quick else CONFIGS
    for ci, (mode, sync, dtype, setup) in enumerate(configs):
        out += ['set %d vm.vs.mode' % mode, 'set %d fm.PATCH.CTRL.TEMPO SYNC' % sync,
                'set %d fm.PATCH.NAME3.DELAY TYPE' % dtype, 'set %d vm.vs.setup' % setup, 'cctree']
        pts = edges if ci in (0, len(configs) - 1) else rnd.sample(edges, len(edges) // 4)
        out += ['ccpick %d %d' % p for p in pts]
        out += ['ccpick %d %d' % (rnd.randrange(-2, 1926), rnd.randrange(-2, 742)) for _ in range(120)]
        for _ in range(60):                     # presses with modifiers, the menu dismissed
            l, t, r, b = rnd.choice(rects)
            out.append('ccmsg %d %d %d' % (rnd.randrange(l, r), rnd.randrange(t, b), rnd.choice(MODS)))
        for _ in range(8):                      # Learn / Forget / nothing; a CC and a drain after
            l, t, r, b = rnd.choice(rects)
            out.append('ccmsg %d %d 0 %d' % (rnd.randrange(l, r), rnd.randrange(t, b), rnd.choice((0, 0, 1, 1, 2))))
            if rnd.random() < 0.6:
                n = rnd.choice((rnd.randrange(0, 120), rnd.randrange(0, 128)))
                out += ['cc %d %d' % (n, rnd.randrange(0, 128)), 'block', 'tick', 'cctree']   # a mapped CC can
                                                                                           # open or close a panel
            if rnd.random() < 0.3:
                out.append('state')
        out.append('state')
    return out


def run_exe(exe, lines, work):
    sp = os.path.join(work, 'cc.txt')
    open(sp, 'w').write('\n'.join(lines) + '\n')
    subprocess.run([WINE, exe, '--kbscript', os.path.basename(sp)], cwd=work, env=dict(os.environ, WINEDEBUG='-all'),
                   check=True, timeout=1800, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return open(sp + '.log', newline=None).read().splitlines()


def build_tooth(n):
    out = os.path.join(REPO, 'scratchpad', 'dist', 'tooth', 'JUNO-60_cc%d.exe' % n)
    subprocess.run([sys.executable, os.path.join(REPO, 'tools', 'dist', 'make_native.py'), '--define', 'CC_TOOTH=%d' % n,
                    '--out', out], check=True, stdout=subprocess.DEVNULL)
    return out


def main():
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    exe, seed = arg('--exe', EXE), int(arg('--seed', '1'))
    tooth = int(arg('--tooth', '0'))
    truth.verify()
    if tooth and '--exe' not in sys.argv:       # a tooth build unless one is given
        exe = build_tooth(tooth)
    ctx = mp.get_context('spawn')
    with ctx.Pool(1) as pool:
        tree = pool.map(plugin_tree, [0])[0]
    lines = script(tree, seed, '--quick' in sys.argv)
    if '--log' in sys.argv:                     # a saved log (debugging): the program is not run
        log = open(arg('--log', None)).read().splitlines()
    else:
        work = tempfile.mkdtemp(prefix='cc_menu_')
        shutil.copyfile(exe, os.path.join(work, 'JUNO-60.exe'))
        log = run_exe(os.path.join(work, 'JUNO-60.exe'), lines, work)
        if '--keep' in sys.argv:
            shutil.copyfile(os.path.join(work, 'cc.txt.log'), arg('--keep', None))
        shutil.rmtree(work)
    with ctx.Pool(1) as pool:
        res = pool.map(oracle, [log])[0]
    n = res['n']
    reach = n['taken'] > 0 and n['learn'] > 0 and n['forget'] > 0 and n.get('moved', 0) > 0 and n['state'] > 0
    ok = not res['fails'] and reach
    print('the plugin\'s tree: %d panels, %d controls, %d the search can stop at; the program\'s the same input to the search'
          % (n.get('panels', 0), n.get('controls', 0), n.get('searchable', 0)) if not any(f.startswith('tree') for f in res['fails'])
          else 'the trees differ')
    for s in sorted(set(res['notes']))[:12]:
        print('  note: ' + s)
    print('%d probes of the search (x2: down, double click), %d right presses (%d taken, %d learns, %d forgets), '
          '%d states, %d CC map entries moved at the end, %d panel configurations'
          % (n['pick'], n['msg'], n['taken'], n['learn'], n['forget'], n['state'], n.get('moved', 0), len(res['opens'])))
    print('the search\'s order (a panel\'s controls from the last, then its open panels from the last): %s'
          % ('observable at %d pairs of overlapping live controls' % len(res['order']) if res['order'] else
             'NOT observable on this panel -- no two live controls it can stop at overlap in any configuration; '
             'teeth 1 and 8 cannot bite, the order is READ only'))
    for s in res['fails'][:20]:
        print('  FAIL ' + s)
    if res.get('nfail'):
        print('  %d failures in all' % res['nfail'])
    if not reach:
        print('  REACH: not every path ran')
    if tooth:
        print('cc_menu_gate --tooth %d: %s' % (tooth, 'BITES' if not ok else 'DID NOT BITE'))
        return 0 if not ok else 1
    print('cc_menu_gate: %s (seed %d)' % ('GREEN' if ok else 'RED', seed))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
