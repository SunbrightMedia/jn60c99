#!/usr/bin/env python3
"""jx_panel_gate.py -- the JX-3P's drawn panel (jx3p/docs/SCOPE_AUDIT.md row 20, jx3p/docs/JX_PANEL.md): JX-3P.exe's
mouse on the JX's own controls and its CC assign menu against THE PLUGIN'S OWN CODE on THE PLUGIN'S OWN PANEL TREE.
The JUNO-60's tools/verify/cc_menu_gate.py method (CLAIMS A38) on the JX, widened from the CC menu to every mouse
event on the five classes only the JX has.

The plugin builds its GUI tree from Script.xml at its module init: every panel and control an object of its own
class, each rectangle from its sprite sheet's frame. The emulator's GDI+ gives each sheet its real size, read from the
PNG's own header (jx3p/truth/Script/, checksummed); nothing else of the images is used. The gate:
  1. walks that tree and requires the program's (kbscript "cctree") to give the CC search the same input
     (cc_menu_gate.compare_trees) and each of the five JX classes -- jx3pLatchButton, jx3pSlider, exprLatchButton,
     patchSelectButton, patchBlock -- the same controls with the same rectangles, panel by panel;
  2. runs the program once for each panel configuration's open flags (vm.vs.mode, vm.vs.edit, TEMPO SYNC, DELAY TYPE,
     vm.vs.setup: kbscript "opens"), then a seeded kbscript under Wine: per configuration the CC search at every
     corner and edge of every control and at random points, right presses with Shift / Ctrl / Alt, Learn / Forget with
     CCs, blocks and drains after them (as the JUNO's); and mouse events on every live JX control -- a down, moves, the
     up, double clicks; inside, on the edges, just off them (where no other live control is) -- from random values of
     what the control reads (its value, the CHORUS state's operands, the current patch); after every event the state,
     the engine's pending records and the host's edits; a block after each press;
  3. plays the log into the plugin (a worker process: Unicorn only), booted with its patch manager's files (the factory
     bank, jx3p/tools/jx_pm_emu.py): every engine call the program made OUTSIDE a mouse event (its boot, the scripted
     sets and patch loads, CCs, blocks, drains), as cc_menu_gate.py; at each CC probe the handler rva 0x31D300 on the
     plugin's own CC assign control (attached by its own attach); at each mouse event "# kb ..." THE ROOT PANEL'S OWN
     MOUSE HANDLER (its vt+0x48, rva 0x2AAD50: the window's resize corner, rva 0x2AAEF0, then the panel dispatch rva
     0x2AA9D0 = the JUNO's 0x2AAAF0) with the same message -- type 0 down, 1 up, 2 double click, 3 move; the point;
     the modifier bits (1 Shift, 2 Ctrl) -- and the program's calls after the event are NOT played:
     the plugin makes its own. The panels' open bytes are the program's (its evaluation of the open conditions,
     CLAIMS C5: the template has no live view), written before every message.
Compared: after every event and probe, getState's bytes (every state value, the CC map), the engine records pending
for the next block (kind, offset, id, value) and the host's edits (beginEdit / performEdit / endEdit, each value);
the CC probes as cc_menu_gate.py's. REACH: each class pressed on its live controls with its value changed, both patch
classes loading, a slider dragged, double clicks, the CC menu taken, a learn, a forget, the CC map moved.

usage: jx_panel_gate.py [--exe PATH] [--seed N] [--quick] [--tooth N | --cc-tooth N] [--keep LOG | --log LOG]
  --quick        three panel configurations (QUICK: the teeth's run)
  --tooth N      builds JX-3P.exe with -DEXE_TOOTH=N (jx3p/gui/win/jx3p_win.c) and runs it: must FAIL --
                 3 a jx3pLatchButton flips its other bit, 4 a jx3pSlider's click does not turn at the ends,
                 5 exprLatchButton's on and off pairs swapped, 6 patchSelectButton's lanes swapped,
                 7 patchBlock loads the next patch, 8 the latch family presses at the down (the plugin: at the up),
                 9 a jx3pSlider's drag steps are final sets (the plugin keeps one host edit open through a drag)
  --cc-tooth N   builds it with -DCC_TOOTH=N (cc_menu_gate.py's teeth on the JX: 1 a panel's controls searched first
                 to last -- the JX has three overlapping pairs, each in one panel --, 2 the right and bottom edges inside,
                 3 closed panels searched, 4 Shift / Ctrl / Alt ignored, 5 a greyed Forget acts, 6 labels and displays
                 searched, 7 controls with many values searched): must FAIL; 8 (the panels before the controls) cannot:
                 no overlap across panels
Wine: $WINE (default /usr/lib/wine/wine64); a private prefix in build/jx_panel_gate/wine, the program's own files
(%APPDATA%\\JX-3P) removed before each run.
"""
import collections
import glob
import multiprocessing as mp
import os
import random
import re
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import cc_menu_gate as CG                      # noqa: E402  (the JUNO's gate: its tree reader and comparison)

EXE = os.path.join(REPO, 'scratchpad', 'dist', 'JX-3P.exe')
WINE = os.environ.get('WINE', '/usr/lib/wine/wine64')
WORK = os.path.join(REPO, 'build', 'jx_panel_gate')
TRUTH = os.path.join(REPO, 'jx3p', 'truth')
DATA = 'C:\\ProgramData\\Roland Cloud\\JX-3P'
# the JX twins of the JUNO's addresses (jx3p/tools/fw_map.py --pair: the code equal, JX = JUNO - 0x120 here; the
# data by the twin instruction; the CC assign class by its attach in vt+0xB0)
DISPATCH = 0x2AA9D0                            # a panel's message dispatch (JUNO 0x2AAAF0)
ROOT_MOUSE = 0x2AAD50                          # the root panel's own (its vt+0x48): the window's resize corner (rva
                                               # 0x2AAEF0: a press within 20 px of the bottom right corner less 20),
                                               # then the dispatch -- what the editor calls on a mouse message
OFFER, OFFER_RET = 0x2AAC35, 0x2AAC38          # its offer of the message to a control (vt+0x48) and the answer
HANDLER, SEARCH_RET = 0x31D300, 0x31D379       # the CC assign control's handler (0x31D420) and its search's return
LEARN, FORGET = 0x31A920, 0x3191C0             # (0x31AA40, 0x3192E0)
MAP_RECORD, MAP_ID = 0x3199F0, 0x319B30        # (0x319B10, 0x319C50)
CCASSIGN_VT, CCA_ATTACH = 0x981498, 0x31D690   # (0x94A4C0, 0x31D7B0)
MENU_OVERRIDE = 0xCEA428                       # (0xCB21F8)
SET, NOTIFY, COMMIT = 0x283C90, 0x2852A0, 0x283000          # (0x283DB0, 0x2853C0, 0x283120)
TRIO = (0x285200, 0x2852A0, 0x283000)          # a panel control's notifies and commit
UI_DRAIN = 0x320000                            # (0x320120)
HEAP = (0x310000000, 0x320000000)              # where the module init's GUI objects live in the emulator
JX_VT = {0x99F690: 'jx3pLatchButton', 0x99F4D0: 'jx3pSlider', 0x9A0048: 'exprLatchButton',
         0x9A0F28: 'patchSelectButton', 0x9A0348: 'patchBlock'}
JX_TYPES = tuple(JX_VT.values())
MODS = CG.MODS
# the panel configurations: (vm.vs.mode, vm.vs.edit, TEMPO SYNC, DELAY TYPE, vm.vs.setup) -- every open condition of
# jx3p/truth/Script.xml but the patch window's, the setup page's sub-panels and the activation's
CONFIGS = [(m, e, s, d, u) for m in (0, 1) for e in (0, 1) for s in (0, 1) for d in (0, 2, 5) for u in (0, 1)]
QUICK = [(0, 0, 0, 0, 0), (0, 1, 1, 5, 0), (1, 0, 1, 2, 1)]      # the teeth's: every JX class live in one of them
                                                                # (the SETUP page, modal, over the last)
CONFIG_REFS = ('vm.vs.mode', 'vm.vs.edit', 'fm.PATCH.CTRL.TEMPO SYNC', 'fm.PATCH.NAME3.DELAY TYPE', 'vm.vs.setup')


def panel_sizes():
    """the main and patch panels' Script.xml sizes: their windows' (the program's zoomfit lines)"""
    x = open(os.path.join(TRUTH, 'Script.xml'), encoding='utf-8', errors='replace').read()
    out = {}
    for m in re.finditer(r'<panelType>(.*?)</panelType>', x, re.S):
        t, z = re.search(r'<type>([^<]*)</type>', m.group(1)), re.search(r'<size>([^<]*)</size>', m.group(1))
        if t and z and t.group(1).strip() in ('main', 'patch'):
            out[t.group(1).strip()] = tuple(int(v) for v in z.group(1).split(','))
    return out['main'], out['patch']


def script_refs():
    """what each JX class reads, from Script.xml: the latches' and sliders' values, the CHORUS state's operands"""
    x = open(os.path.join(TRUTH, 'Script.xml'), encoding='utf-8', errors='replace').read()
    refs = collections.defaultdict(list)
    for m in re.finditer(r'<control>((?:(?!</control>).)*?)</control>', x, re.S):
        t = re.search(r'<type>([^<]*)</type>', m.group(1))
        if not t or t.group(1).strip() not in JX_TYPES:
            continue
        for r in re.findall(r'<(?:valueRef|onValueRef|offValueRef)>([^<]*)<', m.group(1)):
            if r.strip() not in refs[t.group(1).strip()] and r.strip().startswith('fm.'):
                refs[t.group(1).strip()].append(r.strip())
    return dict(refs)


def f32(hx):
    return struct.unpack('<f', struct.pack('<I', int(hx, 16)))[0]


def f64(hx):
    return struct.unpack('<d', struct.pack('<Q', int(hx, 16)))[0]


# ------------------------------------------------------------------ the plugin (worker processes)
class Plugin:
    """the JX plugin booted with its patch manager's files (the factory bank) and its GUI tree; plumbing around its
    own code only"""

    def __init__(self, rate):
        import numpy as np
        import jx_pm_emu
        from unicorn import UC_HOOK_CODE
        from unicorn.x86_const import UC_X86_REG_RAX, UC_X86_REG_RCX, UC_X86_REG_RDX
        self.RAX, self.RCX, self.RDX = UC_X86_REG_RAX, UC_X86_REG_RCX, UC_X86_REG_RDX
        self.P = P = jx_pm_emu.M.PlugPM(files=[(DATA + '\\1 Preset.bin', open(os.path.join(TRUTH, 'preset_bank_1.bin'),
                                                                                 'rb').read())], rate=rate)
        h = self.h = P.h
        uc = self.uc = h.uc
        IB = self.IB = jx_pm_emu.X.IB
        top = min(HEAP[1], (getattr(h, 'heap', HEAP[1]) + 7) & ~7)
        blob = np.frombuffer(bytes(uc.mem_read(HEAP[0], top - HEAP[0])), dtype=np.uint64)
        at = np.nonzero(blob == np.uint64(IB + CCASSIGN_VT))[0]
        if len(at) != 1:
            raise SystemExit('the CC assign control: %d objects of its class' % len(at))
        self.cca = HEAP[0] + 8 * int(at[0])
        self.root = self.q(self.cca + 0x78)              # its parent: the main panel
        h.call(IB + CCA_ATTACH, rcx=self.cca, count=500_000_000)     # the plugin's own attach: +0x80 = the core
        if self.q(self.cca + 0x80) != h.core:
            raise SystemExit('the plugin\'s attach (rva 0x%X) left +0x80 = %x, not the core %x'
                             % (CCA_ATTACH, self.q(self.cca + 0x80), h.core))
        self.names, self.panels, self.tree, self.jx, self.info = {}, [], [], [], {}
        self._walk(self.root)
        mp_ = h.core + 24
        vb, ve = self.q(mp_), self.q(mp_ + 8)
        self.rec_id = [h.call(IB + MAP_ID, rcx=mp_, rdx=k) & 0xFFFFFFFF for k in range((ve - vb) // 24)]
        self.model = P.model
        self.obj = dict(P.recobj)                        # id -> the model's value object
        self.obj.update(P.vobj)
        # the menu service: the plugin's own override pointer, a popup that records and answers (over PlugPM's)
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
        self.offered = self.taker = None           # the control a mouse message went to, the one that took it
        uc.hook_add(UC_HOOK_CODE, self._offer, begin=IB + OFFER, end=IB + OFFER)
        uc.hook_add(UC_HOOK_CODE, self._answer, begin=IB + OFFER_RET, end=IB + OFFER_RET)
        self.msg = h.alloc_com(0x20)
        self.root_mouse = self.q(self.q(self.root) + 0x48)        # the root panel's mouse handler, from its vtable
        if self.root_mouse != IB + ROOT_MOUSE or self.q(self.q(self.tree_panel(1)) + 0x48) != IB + DISPATCH:
            raise SystemExit('the root panel\'s mouse handler 0x%X / a child panel\'s: not 0x%X / 0x%X'
                             % (self.root_mouse - IB, ROOT_MOUSE, DISPATCH))
        self.opens = [0] * len(self.panels)

    def q(self, a):
        return struct.unpack('<Q', bytes(self.uc.mem_read(a, 8)))[0]

    def tree_panel(self, k):
        return self.panels[k]

    def sstr(self, a):
        n, cap = self.q(a + 0x10), self.q(a + 0x18)
        return bytes(self.uc.mem_read(self.q(a) if cap >= 16 else a, n)).decode('latin1')

    def tname(self, obj):
        vt = self.q(obj)
        if vt not in self.names:
            self.names[vt] = self.sstr(self.h.call(self.q(vt + 0x108), rcx=obj))
        return self.names[vt]

    def _walk(self, p, parent=-1):
        """the tree as cc_menu_gate.PluginGUI walks it; and the JX classes' controls: (panel, type, rectangle)"""
        q = self.q
        cb, ce, pb, pe = q(p + 0x90), q(p + 0x98), q(p + 0x78), q(p + 0x80)
        k_self = len(self.panels)
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
            tn = self.tname(c)
            ctl.append((tn, l, t, r, b, nrefs, rec, pid))
            self.info[c] = (tn, l, t, r, b)
            if q(c) - self.IB in JX_VT:
                if JX_VT[q(c) - self.IB] != tn:
                    raise SystemExit('class at vtable 0x%X names itself %r' % (q(c) - self.IB, tn))
                self.jx.append((k_self, tn, l, t, r, b))
        self.tree.append(('P', len(ctl), (pe - pb) // 8, ctl, parent))
        for k in range((pe - pb) // 8):
            self._walk(q(pb + 8 * k), k_self)

    def _popup(self, uc, addr, size, ud):
        v = uc.reg_read(self.RDX)
        b, e = self.q(v), self.q(v + 8)
        items = [(self.sstr(self.q(b + 8 * k)), uc.mem_read(self.q(b + 8 * k) + 0x28, 1)[0]) for k in range((e - b) // 8)]
        self.st['items'] = items
        ch = self.st.get('choice', -1)
        if ch >= len(items) or (ch >= 0 and not items[ch][1]):
            ch = -1                             # a greyed item is never the popup's answer
        uc.reg_write(self.RAX, ch & 0xFFFFFFFFFFFFFFFF)

    def _call(self, uc, addr, size, ud):
        k = uc.reg_read(self.RDX) & 0xFFFFFFFF
        self.st.setdefault('calls', []).append(('cc_learn' if addr == self.IB + LEARN else 'cc_forget',
                                                self.rec_id[k] if k < len(self.rec_id) else -1))

    def _offer(self, uc, addr, size, ud):
        self.offered = uc.reg_read(self.RCX)

    def _answer(self, uc, addr, size, ud):
        if self.taker is None and uc.reg_read(self.RAX) & 0xFF:
            self.taker = self.offered

    def _pick(self, uc, addr, size, ud):
        r = uc.reg_read(self.RAX) & 0xFFFFFFFF
        self.st['pick'] = r - (1 << 32) if r >= 1 << 31 else r

    def write_opens(self):
        for p, f in zip(self.panels, self.opens):
            self.uc.mem_write(p + 0x70, bytes([f]))

    def cc_press(self, x, y, flags, typ=0, choice=-1):
        """the CC assign control's handler on a message: (taken, the record's id or -1, menu items, calls)"""
        self.write_opens()
        self.st = dict(choice=choice, items=None, calls=[], pick=None)
        self.uc.mem_write(self.msg, struct.pack('<iiii', typ, x, y, flags))
        taken = self.h.call(self.IB + HANDLER, rcx=self.cca, rdx=self.msg) & 0xFF
        k = self.st['pick']
        return (taken, self.rec_id[k] if k is not None and 0 <= k < len(self.rec_id) else -1,
                self.st['items'], self.st['calls'])

    def mouse(self, typ, x, y, flags):
        """the root panel's own dispatch on a mouse message: taken or not"""
        self.write_opens()
        self.st = dict(choice=-1, items=None, calls=[], pick=None)
        self.taker = None
        self.uc.mem_write(self.msg, struct.pack('<iiii', typ, x, y, flags))
        return self.h.call(self.root_mouse, rcx=self.root, rdx=self.msg, count=4_000_000_000) & 0xFF

    def live(self, k):
        """panel k and every panel above it open"""
        while k >= 0:
            if not self.opens[k]:
                return False
            k = self.tree[k][4]
        return True


def plugin_tree(_):
    """the plugin's tree, its JX controls and the rectangles of the controls a CC drives at the start (a worker:
    Unicorn only)"""
    g = Plugin(48000.0)
    st = g.h.get_state()
    n = struct.unpack('>I', st[:4])[0] // 8
    mapped = {v for k, v in (struct.unpack('>Ii', st[4 + 8 * j: 12 + 8 * j]) for j in range(n)) if k >= 0x10000000 and v >= 0}
                                                     # (the state's CC map: entries 0x10000000 + CC -> a parameter id)
    rects = sorted(set((c[1], c[2], c[3], c[4]) for t in g.tree for c in t[3] if CG.searchable(c) and c[7] in mapped))
    return [t[:4] for t in g.tree], [t[4] for t in g.tree], g.jx, rects


def jx_by_panel(items):
    out = collections.defaultdict(list)
    for k, tn, l, t, r, b in items:
        out[k].append((tn, l, t, r, b))
    return out


def edits_of_exe(t):
    """a '# hostedit ID KIND BITS' line as the host sees it (jx3p_host_edits' kinds): 0 an editor's final set with no
    edit open -- beginEdit / performEdit / endEdit; 1 a load's performEdit; the controller's one open edit (a drag):
    2 beginEdit / performEdit, 3 performEdit, 4 performEdit / endEdit"""
    pid, kind, v = int(t[2]), int(t[3]), f64(t[4])
    return (([('beginEdit', pid, None)] if kind in (0, 2) else []) + [('performEdit', pid, v)] +
            ([('endEdit', pid, None)] if kind in (0, 4) else []))


def queue_rec(kind, off, rec):
    """a plugin queue record as jx_state_gate.py compares it"""
    if kind == 0:
        return (0, off, rec[8], rec[9], rec[10])
    return (kind, off, struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0])


def pending_of_exe(t):
    """a '# pending N k,off,st,note,vel ...' line as jx_state_gate.py compares the port's"""
    out = []
    for f in t[3:]:
        r = [int(v) for v in f.split(',')]
        out.append((0, r[1], r[2] & 0xFF, r[3] & 0xFF, r[4] & 0xFF) if r[0] == 0 else
                   (r[0], r[1], r[3] & 0xFFFFFFFF, r[4]))
    return out


def oracle(log):
    """the program's log played into the plugin (a worker: Unicorn only)"""
    import gc
    res = dict(fails=[], notes=[], opens=set(), order=set(), n=collections.Counter(), press=collections.Counter(),
               changed=collections.Counter())
    g = h = None
    MAIN, PATCH = panel_sizes()
    calls = ('model_set', 'commit', 'queue_record', 'pm_set', 'pm_commit', 'pm_notify', 'keybed', 'cc_learn', 'cc_forget')
    i, tree_done, in_event = 0, False, False
    exe_edits, e0, q_blk = [], 0, 0
    last = (0, 0)                                  # the last down's point (an up without one goes there)
    down_ctl, state_before, await_state = None, None, None
    boot_map = None
    lines = log

    def fail(s):
        res['nfail'] = res.get('nfail', 0) + 1
        if len(res['fails']) < 40:
            res['fails'].append(s)

    def where():
        return 'line %d' % i

    def sync():
        """the host's edits since the last comparison: the program's, the plugin's"""
        nonlocal e0, exe_edits
        mine = [tuple(e) for e in h.edits[e0:] if e[0] in ('beginEdit', 'performEdit', 'endEdit')]
        e0 = len(h.edits)
        if mine != exe_edits:
            fail('%s: host edits -- the plugin %s, the program %s' % (where(), mine[:6], exe_edits[:6]))
        res['n']['edits'] += len(mine)
        res['n']['open edits'] += bool(mine) and any(e[0] == 'beginEdit' for e in mine) and mine[-1][0] != 'endEdit'
        exe_edits = []

    def ccmap(st):
        n = struct.unpack('>I', st[:4])[0] // 8
        return {k: v for k, v in (struct.unpack('>Ii', st[4 + 8 * j: 12 + 8 * j]) for j in range(n)) if k >= 0x10000000}

    def control_at(x, y):
        """the live JX control under a point (the plugin's tree, the program's opens), for the reach count"""
        for k, tn, l, t, r, b in g.jx:
            if g.live(k) and l <= x < r and t <= y < b:
                return tn
        return None

    while i < len(lines):
        ln = lines[i]
        i += 1
        t = ln.split()
        if not t:
            continue
        if in_event and (t[0] in calls or ln.startswith('# hostedit') or ln.startswith('# pm ') or ln.startswith('# hit')):
            if ln.startswith('# hit'):          # the program's dispatch: the control its press went to
                want = tuple([t[2]] + [int(v) for v in t[3:7]]) if len(t) >= 7 else None
                got = g.info.get(g.taker) if g.taker is not None else None
                if want != got:
                    fail('%s: the press went to -- the plugin\'s dispatch %s, the program\'s %s' % (where(), got, want or t[2]))
                res['n']['hits'] += 1
            elif ln.startswith('# hostedit'):
                exe_edits += edits_of_exe(t)
            elif t[0] in calls:
                res['n']['exe_calls'] += 1
            continue                            # the program's own calls of its event: compared, not played
        in_event = False
        if ln.startswith('# hostedit'):
            exe_edits += edits_of_exe(t)
            continue
        if ln.startswith('# kb '):
            sync()
            kind, a = t[2], [int(v) for v in t[3:]]
            if kind == 'up':
                x, y = (a[0], a[1]) if a[0] >= 0 else last
                taken = g.mouse(1, x, y, 0)
                await_state = down_ctl              # the next state line: the press's effect, for the reach
            else:
                x, y, s = a                     # s: the plugin's flag bits (1 Shift, 2 Ctrl, 8 Alt)
                typ = {'down': 0, 'dbl': 2, 'move': 3}[kind]
                if kind in ('down', 'dbl'):
                    last = (x, y)
                    down_ctl = control_at(x, y)
                    state_before = h.get_state() if down_ctl else None
                    if down_ctl:
                        res['press'][down_ctl + (' dbl' if kind == 'dbl' else '')] += 1
                elif down_ctl == 'jx3pSlider':
                    res['n']['slider moves'] += 1
                taken = g.mouse(typ, x, y, s)
            res['n']['events'] += 1
            res['n']['taken'] += bool(taken)
            in_event = True
            continue
        if ln.startswith('# cctree '):
            blk = [ln]
            while i < len(lines) and lines[i].startswith('# cctree '):
                blk.append(lines[i])
                i += 1
            for tree, opens in CG.parse_trees(blk):
                if not tree_done:
                    mine = [x[:4] for x in g.tree]
                    f, n = CG.compare_trees(mine, tree)
                    for s in f:
                        fail('tree: ' + s)
                    res['notes'] += n
                    a, b = jx_by_panel(g.jx), collections.defaultdict(list)
                    for pk, p in enumerate(tree):
                        b[pk] = [c[:5] for c in p[3] if c[0] in JX_TYPES]
                    for pk in sorted(set(a) | set(k for k in b if b[k])):
                        if a.get(pk, []) != b.get(pk, []):
                            fail('tree: panel %d, the JX controls: plugin %s, program %s' % (pk, a.get(pk, [])[:3], b.get(pk, [])[:3]))
                    res['n']['panels'], res['n']['controls'] = len(tree), sum(len(p[3]) for p in tree)
                    res['n']['searchable'] = sum(1 for p in mine for c in p[3] if CG.searchable(c))
                    res['n']['jx controls'] = len(g.jx)
                    # every panel's rectangle (the dispatch tests it) and modal byte (+0xDC): the plugin's, the program's
                    prog = [ln2.split()[3:] for ln2 in blk if ln2.startswith('# cctree P ')]
                    for pk, (pnl, f) in enumerate(zip(g.panels, prog)):
                        l, t, r, b = struct.unpack('<iiii', bytes(g.uc.mem_read(pnl + 0x18, 16)))
                        mine_r, modal = (l, t, r - l, b - t), g.uc.mem_read(pnl + 0xdc, 1)[0]
                        if len(f) < 9:
                            fail('tree: the program\'s panel line without its rectangle')
                            break
                        theirs, has, pmod = tuple(int(v) for v in f[3:7]), int(f[7]), int(f[8])
                        if modal != pmod:
                            fail('tree: panel %d modal: plugin %d, program %d' % (pk, modal, pmod))
                        if mine_r != theirs:
                            (fail if has else res['notes'].append)(
                                'tree: panel %d rectangle: plugin %s, program %s%s' % (pk, mine_r, theirs, '' if has else ' (no size)'))
                        res['n']['panel rects'] += 1
                    tree_done = True
                g.opens = list(opens)
                if tuple(opens) not in res['opens']:
                    res['opens'].add(tuple(opens))
                    res['order'] |= CG.order_pairs(tree, opens)
            continue
        if ln.startswith('# opens '):
            g.opens = [int(c) for c in t[2]]
            if len(g.opens) != len(g.panels):
                fail('%s: %d open flags, the plugin has %d panels' % (where(), len(g.opens), len(g.panels)))
            res['opens'].add(tuple(g.opens))
            continue
        if ln.startswith('# pending '):
            sync()
            want = pending_of_exe(t)
            got = [queue_rec(*r) for r in h.queue()[q_blk:]]
            if got != want:
                fail('%s: the engine records pending -- the plugin %d %s, the program %d %s'
                     % (where(), len(got), got[:4], len(want), want[:4]))
            res['n']['pending'] += 1
            res['n']['records'] += len(got)
            continue
        if ln.startswith('# ccpick '):
            x, y, want = int(t[2]), int(t[3]), int(t[4])
            for typ in (0, 2):
                taken, pid, items, cl = g.cc_press(x, y, 4, typ)
                got = pid if taken else -1
                if got != want or bool(taken) != (want >= 0) or cl:
                    fail('ccpick %d %d (type %d): plugin %s (taken %d), program %d' % (x, y, typ, got, taken, want))
            res['n']['pick'] += 1
            continue
        if ln.startswith('# ccmsg ') and len(t) == 6:
            sync()
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
                elif u.startswith('# hostedit'):
                    exe_edits += edits_of_exe(u.split())
                else:
                    fail('ccmsg %d %d %d %d: unexpected program line %r' % (x, y, mods, item, u))
            taken_exe = int(lines[i].split()[3])
            i += 1
            taken, pid, items, cl = g.cc_press(x, y, 4 | mods, 0, item if item < 2 else -1)
            ok = bool(taken) == bool(taken_exe) and cl == calls_exe
            if taken and ok:
                ok = menu is not None and menu[0] == pid and menu[2] == [(a, int(b)) for a, b in items]
            elif not taken and menu is not None:
                ok = False
            if not ok:
                fail('ccmsg %d %d %d %d: plugin taken %d id %d items %s calls %s; program taken %d menu %s calls %s'
                     % (x, y, mods, item, taken, pid, items, cl, taken_exe, menu, calls_exe))
            res['n']['msg'] += 1
            res['n']['cc taken'] += bool(taken)
            res['n']['learn'] += sum(1 for c in cl if c[0] == 'cc_learn')
            res['n']['forget'] += sum(1 for c in cl if c[0] == 'cc_forget')
            continue
        if ln.startswith('#'):
            continue
        # ---- the engine calls outside a mouse event: played (as cc_menu_gate.py)
        if t[0] == 'init':
            g = Plugin(float(t[1]))
            h = g.h
            boot_map = ccmap(h.get_state())
            e0, q_blk = len(h.edits), len(h.queue())
        elif t[0] == 'editor':
            h.attach_editor(int(t[1]), int(t[2]))
        elif t[0] == 'zoomfit':
            got = h.window_conv(MAIN if t[1] == '0' else PATCH)
            if got != int(t[2]):
                fail('zoomfit %s: the plugin %d, the program %s' % (t[1], got, t[2]))
        elif t[0] == 'queue_record':
            h.load_patch(bytes.fromhex(t[1]))
        elif t[0] in ('model_set', 'pm_set'):
            pid, v = int(t[1]), int(t[2])
            o = g.obj.get(pid)
            if o is not None:
                h.call(g.IB + SET, rcx=g.model, rdx=o, r8=v & 0xFFFFFFFF,       # the set's flag: the program's
                       r9=(int(t[3]) if len(t) > 3 else 1) if t[0] == 'model_set' else int(t[3]), count=500_000_000)
            else:
                res['notes'].append('%s 0x%X: not a value object the plugin\'s records name' % (t[0], pid))
        elif t[0] == 'pm_commit':
            h.call(g.IB + COMMIT, rcx=g.model, count=500_000_000)
        elif t[0] == 'pm_notify':
            h.call(g.IB + NOTIFY, rcx=g.model, count=500_000_000)
        elif t[0] == 'commit':
            for rva in TRIO:
                h.call(g.IB + rva, rcx=g.model, count=500_000_000)
        elif t[0] == 'ui_tick':
            h.call(g.IB + UI_DRAIN, rcx=h.core, count=2_000_000_000)
        elif t[0] in ('ftz', 'meter', 'bar', 'led', 'ledshow', 'midi'):
            pass                                # the FP mode, the UI timer's meters: not this gate's
        elif t[0] == 'process':
            sync()
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
            q_blk = len(h.queue())
            res['n']['blocks'] += 1
        elif t[0] == 'state':
            sync()
            st = h.get_state()
            res['n']['state'] += 1
            if st.hex() != t[1]:
                a, b = st.hex(), t[1]
                k = next((j for j in range(min(len(a), len(b))) if a[j] != b[j]), min(len(a), len(b)))
                fail('%s: getState differs (byte %d: the plugin %s, the program %s)' % (where(), k // 2, a[k - k % 16:k - k % 16 + 32],
                                                                                         b[k - k % 16:k - k % 16 + 32]))
            if await_state and state_before is not None and st != state_before:
                res['changed'][await_state] += 1    # the press (down ... up) changed the state
            await_state = None
            end = ccmap(st)
            res['n']['moved'] = sum(1 for k in end if end[k] != boot_map.get(k))
        else:
            fail('log: unknown call %r' % ln[:80])
    if h is not None:
        sync()
    del g
    gc.collect()
    return res


# ------------------------------------------------------------------ the scripts and the program
def config_lines(cfg):
    return ['set %d %s' % (v, r) for v, r in zip(cfg, CONFIG_REFS)]


def probe_script(configs):
    """the program's open flags in each configuration"""
    out = []
    for cfg in configs:
        out += config_lines(cfg) + ['opens']
    return out


def script(tree, parents, jx, mapped, opens_by_cfg, configs, seed, quick=False):
    """the seeded kbscript: the CC probes (cc_menu_gate.script's) and the mouse on every live JX control"""
    rnd = random.Random(seed)
    refs = script_refs()
    rects = sorted(set((c[1], c[2], c[3], c[4]) for p in tree for c in p[3] if c[3] > c[1] and c[4] > c[2]))
    edges = []
    for l, t, r, b in rects:
        edges += [((l + r) // 2, (t + b) // 2), (l, t), (r - 1, b - 1), (l - 1, t), (l, t - 1), (r, b - 1), (r - 1, b)]

    def live_fn(opens):
        def live(k):
            while k >= 0:
                if not opens[k]:
                    return False
                k = parents[k]
            return True
        return live

    out = ['block', 'cctree', 'state', 'pending']   # the boot's queue applied: both sides' pending lists empty
    press_at, seen = set(), set()                  # the mouse in the first configuration of each layout and EDIT
    for ci, cfg in enumerate(configs):             # state, and in a quarter of the others
        if cfg[:2] not in seen or quick or rnd.random() < 0.25:
            press_at.add(ci)
            seen.add(cfg[:2])
    for ci, cfg in enumerate(configs):
        opens = opens_by_cfg[ci]
        live = live_fn(opens)
        out += config_lines(cfg) + ['cctree', 'state']
        # ---- the CC menu (cc_menu_gate.script's)
        pts = edges if ci in (0, len(configs) - 1) else rnd.sample(edges, len(edges) // 6)
        out += ['ccpick %d %d' % p for p in pts]
        out += ['ccpick %d %d' % (rnd.randrange(-2, 1926), rnd.randrange(-2, 706)) for _ in range(40 if quick else 80)]
        for _ in range(20 if quick else 30):
            l, t, r, b = rnd.choice(rects)
            out.append('ccmsg %d %d %d' % (rnd.randrange(l, r), rnd.randrange(t, b), rnd.choice(MODS)))
        for _ in range(4 if quick else 6):
            if mapped and rnd.random() < 0.5:            # Forget on a control a CC drives (its menu item enabled)
                (l, t, r, b), item = rnd.choice(mapped), 1
            else:
                (l, t, r, b), item = rnd.choice(rects), rnd.choice((0, 0, 1, 1, 2))
            out.append('ccmsg %d %d 0 %d' % (rnd.randrange(l, r), rnd.randrange(t, b), item))
            if rnd.random() < 0.6:
                out += ['cc %d %d' % (rnd.randrange(0, 120), rnd.randrange(0, 128)), 'block', 'tick', 'cctree']
            out.append('state')
        out += ['cctree', 'state', 'pending']
        if ci not in press_at:
            continue
        # ---- the mouse on the live JX controls
        others = [(c[1], c[2], c[3], c[4]) for k, p in enumerate(tree) if live(k) for c in p[3]
                  if c[0] not in JX_TYPES and c[3] > c[1] and c[4] > c[2]]
        free = lambda x, y: not any(l <= x < r and t <= y < b for l, t, r, b in others)
        mine = [(k, tn, l, t, r, b) for k, tn, l, t, r, b in jx if live(k)]
        by_cls = collections.defaultdict(list)
        for m in mine:
            by_cls[m[1]].append(m)
        for tn in JX_TYPES:
            ctls = by_cls.get(tn, [])
            if not ctls:
                continue
            per = {'jx3pLatchButton': 3, 'jx3pSlider': 4, 'exprLatchButton': 10, 'patchSelectButton': 1,
                   'patchBlock': 1}[tn]
            picks = [c for c in ctls for _ in range(per)]
            if tn == 'patchBlock':
                picks = rnd.sample(ctls, min(len(ctls), 6 if quick else 24))
            elif quick:
                picks = rnd.sample(picks, min(len(picks), 12 if tn == 'jx3pSlider' else 6))
            for k, _, l, t, r, b in picks:
                # what the control reads: its value / the CHORUS state's operands / the current patch
                if tn in ('jx3pLatchButton', 'jx3pSlider'):
                    for ref in refs.get(tn, []):
                        out.append('set %d %s' % (rnd.randrange(0, 4), ref))
                elif tn == 'exprLatchButton':
                    for ref in refs.get(tn, []):
                        v = rnd.choice((0, 1, 2, 2, 3, 4, 5)) if 'TYPE' in ref else rnd.choice((0, 0, 1, 128, 255, rnd.randrange(256)))
                        out.append('set %d %s' % (v, ref))
                elif rnd.random() < 0.7:
                    out.append('patch %d 1' % rnd.randrange(64))
                out += ['opens', 'state', 'pending']             # a patch's TEMPO SYNC / DELAY TYPE open panels
                inside = [((l + r) // 2, (t + b) // 2), (l, t), (r - 1, b - 1), (l, b - 1), (r - 1, t),
                          (rnd.randrange(l, r), rnd.randrange(t, b))]
                near = [p for p in ((l - 1, t), (r, b - 1), (l, t - 1), (r - 1, b), (l - 3, (t + b) // 2), ((l + r) // 2, b + 2))
                        if free(*p) and not any(m[2] <= p[0] < m[4] and m[3] <= p[1] < m[5] for m in mine)]
                p = rnd.choice(inside) if near == [] or rnd.random() < 0.85 else rnd.choice(near)
                s = 1 if rnd.random() < 0.15 else 0
                if tn == 'jx3pSlider' and rnd.random() < 0.15:
                    s = 2                                        # Ctrl: the slider's default
                kind = rnd.random()
                after = ['opens', 'state', 'pending']           # after every event: the comparisons
                # a real mouse moves to a point before it presses there or lets go there: the move first (the panels'
                # hover flags, +0xDD, decide whether a panel offers a press outside its rectangle: rva 0x2AAA1B)
                ev = ['move %d %d 0' % p, 'down %d %d %d' % (p[0], p[1], s)] + after
                if tn == 'jx3pSlider' and kind < 0.5:            # a drag: moves up and down the travel
                    y = p[1]
                    for _ in range(rnd.randrange(1, 6)):
                        y = rnd.randrange(t - 15, b + 15)
                        ev += ['move %d %d %d' % (rnd.randrange(l - 4, r + 4), y, s)] + after
                    up = (rnd.randrange(l - 4, r + 4), y)
                elif kind < 0.25:                                # a move off and back, or off
                    q2 = rnd.choice(inside + near)
                    ev += ['move %d %d %d' % (q2[0], q2[1], s)] + after
                    up = q2
                else:
                    up = p
                last = p if not ev[-4].startswith('move') else tuple(int(v) for v in ev[-4].split()[1:3])
                if up != last:
                    ev += ['move %d %d %d' % (up[0], up[1], s)] + after
                ev += ['up %d %d' % up] + after
                if rnd.random() < 0.2:                           # a double click: down, up, double click, up
                    ev += ['dbl %d %d %d' % (up[0], up[1], 0)] + after + ['up %d %d' % up] + after
                out += ev + ['block', 'state']
        out += ['state', 'pending']
    return out


def wine_env():
    prefix = os.path.join(WORK, 'wine')
    os.makedirs(prefix, exist_ok=True)
    for d in glob.glob(os.path.join(prefix, 'drive_c', 'users', '*', 'AppData', 'Roaming', 'JX-3P')):
        shutil.rmtree(d, ignore_errors=True)          # the program's settings and banks: a first run each time
    return dict(os.environ, WINEDEBUG='-all', WINEPREFIX=prefix)


def run_exe(exe, lines, work, name):
    sp = os.path.join(work, name)
    open(sp, 'w').write('\n'.join(lines) + '\n')
    subprocess.run([WINE, os.path.basename(exe), '--kbscript', name], cwd=work, env=wine_env(), check=True,
                   timeout=3600, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return open(sp + '.log', newline=None).read().splitlines()


def build_tooth(define):
    out = os.path.join(REPO, 'scratchpad', 'dist', 'tooth', 'JX-3P_%s.exe' % define.replace('=', ''))
    subprocess.run([sys.executable, os.path.join(HERE, 'make_native_jx.py'), '--define', define, '--out', out],
                   check=True, stdout=subprocess.DEVNULL)
    return out


def main():
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    exe, seed, quick = arg('--exe', EXE), int(arg('--seed', '1')), '--quick' in sys.argv
    tooth, cctooth = int(arg('--tooth', '0')), int(arg('--cc-tooth', '0'))
    import make_native_jx
    make_native_jx.verify_truth()               # Script.xml, the art, the binary: their pinned bytes
    if (tooth or cctooth) and '--exe' not in sys.argv:
        exe = build_tooth('EXE_TOOTH=%d' % tooth if tooth else 'CC_TOOTH=%d' % cctooth)
    ctx = mp.get_context('spawn')
    with ctx.Pool(1) as pool:
        tree, parents, jx, mapped = pool.map(plugin_tree, [0])[0]
    configs = QUICK if quick else CONFIGS
    if '--log' in sys.argv:                     # a saved log (debugging): the program is not run
        log = open(arg('--log', None)).read().splitlines()
    else:
        os.makedirs(WORK, exist_ok=True)
        work = tempfile.mkdtemp(prefix='run_', dir=WORK)
        shutil.copyfile(exe, os.path.join(work, 'JX-3P.exe'))
        plog = run_exe(os.path.join(work, 'JX-3P.exe'), probe_script(configs), work, 'opens.txt')
        opens = [[int(c) for c in ln.split()[2]] for ln in plog if ln.startswith('# opens ')]
        if len(opens) != len(configs):
            raise SystemExit('the program gave %d open flag lines for %d configurations' % (len(opens), len(configs)))
        log = run_exe(os.path.join(work, 'JX-3P.exe'), script(tree, parents, jx, mapped, opens, configs, seed, quick), work,
                      'panel.txt')
        if '--keep' in sys.argv:
            shutil.copyfile(os.path.join(work, 'panel.txt.log'), arg('--keep', None))
        shutil.rmtree(work)
    with ctx.Pool(1) as pool:
        res = pool.map(oracle, [log])[0]
    n, pr, ch = res['n'], res['press'], res['changed']
    reach = {
        'every JX class pressed and changing the state': all(ch[c] > 0 for c in JX_TYPES),
        'a slider dragged': n['slider moves'] > 0,
        'a drag holding the host edit open (beginEdit, no endEdit yet)': n['open edits'] > 0,
        'double clicks': sum(v for k, v in pr.items() if k.endswith(' dbl')) > 0,
        'the CC menu taken, a learn, a forget, the CC map moved': n['cc taken'] > 0 and n['learn'] > 0
        and n['forget'] > 0 and n['moved'] > 0,
        'states, pending records, host edits compared': n['state'] > 0 and n['pending'] > 0 and n['edits'] > 0,
    }
    ok = not res['fails'] and all(reach.values())
    print('the plugin\'s tree: %d panels, %d controls, %d the CC search can stop at, %d of the five JX classes'
          % (n['panels'], n['controls'], n['searchable'], n['jx controls']))
    for s in sorted(set(res['notes']))[:12]:
        print('  note: ' + s)
    print('mouse events %d (%d taken by the plugin), presses per class %s; the state changed by %s'
          % (n['events'], n['taken'], dict(pr), dict(ch)))
    print('states %d, pending lists %d (%d records), host edits %d, blocks %d; CC probes %d (x2), right presses %d '
          '(%d taken, %d learns, %d forgets), %d CC map entries moved; %d panel configurations'
          % (n['state'], n['pending'], n['records'], n['edits'], n['blocks'], n['pick'], n['msg'], n['cc taken'],
             n['learn'], n['forget'], n['moved'], len(res['opens'])))
    for k, v in reach.items():
        if not v:
            print('  REACH: not reached -- ' + k)
    for s in res['fails'][:20]:
        print('  FAIL ' + s)
    if res.get('nfail'):
        print('  %d failures in all' % res['nfail'])
    if tooth or cctooth:
        print('jx_panel_gate --%s %d: %s' % ('tooth' if tooth else 'cc-tooth', tooth or cctooth,
                                             'BITES' if not ok else 'DID NOT BITE'))
        return 0 if not ok else 1
    print('jx_panel_gate: %s (seed %d%s)' % ('GREEN' if ok else 'RED', seed, ', quick' if quick else ''))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
