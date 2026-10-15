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

usage: jx_panel_gate.py [--exe PATH] [--seed N] [--quick] [--tooth N | --cc-tooth N | --pm-tooth N | --bridge-tooth N]
                        [--keep LOG | --log LOG]
       jx_panel_gate.py --teeth exe3-20,exe22-31,pm21,cc1-7,bridge1 [--jobs N]   (every tooth, N runs at once)
  --quick        three panel configurations (QUICK: the teeth's run)
  --tooth N      builds JX-3P.exe with -DEXE_TOOTH=N (jx3p/gui/win/jx3p_win.c) and runs it: must FAIL --
                 3 a jx3pLatchButton flips its other bit, 4 a jx3pSlider's click does not turn at the ends,
                 5 exprLatchButton's on and off pairs swapped, 6 patchSelectButton's lanes swapped,
                 7 patchBlock loads the next patch, 8 the latch family presses at the down (the plugin: at the up),
                 9 a jx3pSlider's drag steps are final sets (the plugin keeps one host edit open through a drag),
                 10 a panel's hover flag ignored (a press just outside a panel never reaches its controls);
                 the generic classes, the wheel, the editor's timer (scope row 25): 11 a patch step one too far,
                 12 the patch name's positions 16 (its Ctrl step 8), 13 its edit's chars unsigned and NULs past the
                 end, 14 it never takes the focus, 15 its edit's offer untrimmed, 16 a knob's travel 16 px a position,
                 17 an unlatchButton's function run at the press (the plugin: queued, the next idle), 18 the wheel's
                 Ctrl step not capped at 10, 19 the wheel's edit closed after 1000 ms (the plugin: 800), 20 a
                 latchButton toggles at the down; the window and the menus: 22 a window point truncated (x 100 /
                 zoom), 23 no leave, 24 a patch window button's function run at the up (the plugin: queued), 25 the
                 leave's point not inside every open panel, 26 Up's key code read as Down's, 27 no resize corner,
                 28 the option menu's "Clear" never greyed, 29 "Clear" applies the preset, 30 the wrong voice count
                 checked, 31 no separator after the CPU item
  --bridge-tooth N  builds it with -DJX_PRESET_TOOTH=N (jx3p/gui/win/jx_bridge_exe.c): 1 the preset test reads one entry of
                 a record (the plugin reads them all)
  --pm-tooth N   builds it with -DPM_TOOTH=N (gui/juno_pm.c): 21 the patch menu's half ignored
  --cc-tooth N   builds it with -DCC_TOOTH=N (cc_menu_gate.py's teeth on the JX: 1 a panel's controls searched first
                 to last -- the JX has three overlapping pairs, each in one panel --, 2 the right and bottom edges inside,
                 3 closed panels searched, 4 Shift / Ctrl / Alt ignored, 5 a greyed Forget acts, 6 labels and displays
                 searched, 7 controls with many values searched): must FAIL; 8 (the panels before the controls) cannot:
                 no overlap across panels
Wine: $WINE (default /usr/lib/wine/wine64); a private prefix in build/jx_panel_gate/wine, the program's own files
(%APPDATA%\\JX-3P) removed before each run; TMPDIR not passed to it.
"""
import collections
import glob
import multiprocessing as mp
import os
import math
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
WIN_TO_PANEL = 0x2ABFC0                        # a window point to the panel's: (v x 200 / zoom + 1) / 2 (READ)
KEY_CODE = 0x43ABE0                            # a virtual key (a signed char) to the key message's code
KEY_MSG = 0x436640                             # the key message: {type, code, mods} (WM_KEYDOWN 1, WM_KEYUP 2)
LEAVE = -2147483647                            # WM_MOUSELEAVE's point (0x80000001, 0x80000001), rva 0x3104E4
ROOT_MOUSE = 0x2AAD50                          # the root panel's own (its vt+0x48): the window's resize corner (rva
                                               # 0x2AAEF0: a press within 20 px of the bottom right corner less 20),
                                               # then the dispatch -- what the editor calls on a mouse message
OFFER, OFFER_RET = 0x2AAC35, 0x2AAC38          # its offer of the message to a control (vt+0x48) and the answer
HANDLER, SEARCH_RET = 0x31D300, 0x31D379       # the CC assign control's handler (0x31D420) and its search's return
LEARN, FORGET = 0x31A920, 0x3191C0             # (0x31AA40, 0x3192E0)
MAP_RECORD, MAP_ID = 0x3199F0, 0x319B30        # (0x319B10, 0x319C50)
CCASSIGN_VT, CCA_ATTACH = 0x981498, 0x31D690   # (0x94A4C0, 0x31D7B0)
OM_RET = 0x4155FE                              # the option menu's popup call returns here (rva 0x4147B0's)
MENU_OVERRIDE = 0xCEA428                       # (0xCB21F8)
SET, NOTIFY, COMMIT = 0x283C90, 0x2852A0, 0x283000          # (0x283DB0, 0x2853C0, 0x283120)
# the editor's 50 ms timer (its window's WM_TIMER, rva 0x3103BE): the root panel's timer message (vt+0x60; the message
# object's vtable, rva 0x97FA28) then the module's idle (the CModuleB singleton, rva 0x34D320; its vt+0x38: the
# function queue). WM_MOUSEWHEEL (rva 0x3117C8): the message the editor builds (rva 0x43E370), the root's vt+0x50
TIMER_MSG_VT, MODULE, MOUSEWHEEL_MSG = 0x97FA28, 0x34D320, 0x43E370
# the display's edit (vt+0x140, rva 0x2CF920): its call of the text edit service (rva 0x2AD3E0, answered by PlugPM's
# hook from the scripted answers), r9 the text offered -- the patch name's edit (scope row 25)
PN_EDIT_CALL = 0x2CFA19
TRIO = (0x285200, 0x2852A0, 0x283000)          # a panel control's notifies and commit
UI_DRAIN = 0x320000                            # (0x320120)
HEAP = (0x310000000, 0x320000000)              # where the module init's GUI objects live in the emulator
JX_VT = {0x99F690: 'jx3pLatchButton', 0x99F4D0: 'jx3pSlider', 0x9A0048: 'exprLatchButton',
         0x9A0F28: 'patchSelectButton', 0x9A0348: 'patchBlock'}
JX_TYPES = tuple(JX_VT.values())
# the generic classes (scope row 25): pressed on every live control, each class's own handlers -- the knob's and the
# slider's (rva 0x2D0660), the latch family's (0x2CD350), the keyboard's (0x2D40D0), the patch name's (0x33E950), the
# display's (0x2DE770); a label, a bar graph take nothing. Not yet pressed: menuButton, setupButton and the Help / About
# buttons (their menus and dialogs: the program's need a scripted answer first)
GENERIC = ('knob', 'slider', 'latchButton', 'unlatchButton', 'keyboardX', 'patchName', 'label', 'display', 'barGraphX')
GEN_N = {'knob': 10, 'slider': 8, 'latchButton': 6, 'unlatchButton': 4, 'keyboardX': 8, 'patchName': 3, 'label': 3,
         'display': 6, 'barGraphX': 2}
GEN_TAKE = ('knob', 'slider', 'latchButton', 'unlatchButton', 'keyboardX', 'patchName')   # the classes that take a down
# the patch name (row 25f): presses on its arrow (the name's edit) and elsewhere on it (the patch menu), with the
# answers -- names: plain, empty, one char, 16, past 16, chars past 0x7F (signed), spaces, a cancel; menu cells of
# both halves of the one bank, none
PN_N = 16
PN_TEXTS = (b'NEW NAME', b'', b'A', b'0123456789ABCDEF', b'0123456789ABCDEFGHIJK', b'\xe9t\xe9 \xff\x80z\x7f',
            b'  two  spaces  ', b'Brass [Brs1]', None, None)
SKIP_FN = ('Help', 'About', 'PlugOut')
WHEELS = 24                                    # wheel sequences per configuration with presses
LEAVES = 40                                    # moves then a leave (the hover flags compared)
KEYS = 24                                      # key sequences on focused controls
CORNERS = 16                                   # visits to the resize corner
OMENUS = 24                                     # the option menu's random presses (half in a quick run)
PWBTN = 16                                      # presses on the patch window's buttons (half in a quick run)
PW_IDS = (0x0FFFC002, 0x0FFFC004, 0x0FFFC005, 0x0FFFC006, 0x0FFFC010, 0x0FFFC014)   # panelPatch, patchManager, the
                                                # lists, bankId, patchId (gui/juno_pm.h)
PW_BTN = {'dec': (304, 33, 324, 48), 'inc': (304, 48, 324, 65), 'load': (1511, 553, 1559, 571)}   # Script.xml, the
                                                # plugin's own rectangles (its patch root's controls, EXECUTED)
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
        self.names, self.panels, self.tree, self.jx, self.info, self.ctl_panel = {}, [], [], [], {}, {}
        self.allc = []                                  # every control: (panel, type, rectangle)
        self.pnames = []                                # the patch name controls (their text kept: refresh_names)
        self.pn_answers = []                            # the patch menu's scripted answers: (t, s) or None
        self.om_answers = []                            # the option menu's scripted answers: an item's number or -1
        self._walk(self.root)
        for c in self.info:                             # the menu buttons' own update (vt+0xB0, rva 0x325320): the
            if self.info[c][0] == 'menuButton':         # core at +0x178, which the option menu reads its CC map by --
                h.call(self.q(self.q(c) + 0xB0), rcx=c, count=500_000_000)   # the live editor's values notify it
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
        uc.hook_add(UC_HOOK_CODE, self._pn_edit, begin=IB + PN_EDIT_CALL, end=IB + PN_EDIT_CALL)
        self.msg = h.alloc_com(0x100)
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
            self.ctl_panel[c] = p
            if tn == 'patchName':
                self.pnames.append(c)
            self.allc.append((k_self, tn, l, t, r, b))
            if q(c) - self.IB in JX_VT:
                if JX_VT[q(c) - self.IB] != tn:
                    raise SystemExit('class at vtable 0x%X names itself %r' % (q(c) - self.IB, tn))
                self.jx.append((k_self, tn, l, t, r, b))
        self.tree.append(('P', len(ctl), (pe - pb) // 8, ctl, parent))
        for k in range((pe - pb) // 8):
            self._walk(q(pb + 8 * k), k_self)

    def _popup(self, uc, addr, size, ud):
        from unicorn.x86_const import UC_X86_REG_RSP
        v = uc.reg_read(self.RDX)
        if self.q(uc.reg_read(UC_X86_REG_RSP)) == self.IB + OM_RET:     # the option menu (the menuButton's up)
            b, e = self.q(v), self.q(v + 8)
            items = [(self.sstr(it), uc.mem_read(it + 0x28, 1)[0], uc.mem_read(it + 0x29, 1)[0])
                     for it in (self.q(b + 8 * k) for k in range((e - b) // 8))]
            real = [x for x in items if x[0]]          # the popup numbers only the items with a text (rva 0x4361E0)
            ans = self.om_answers.pop(0) if self.om_answers else -1
            if not 0 <= ans < len(real) or not real[ans][1]:
                ans = -1                                # a greyed item is never the popup's answer
            self.st.setdefault('pn', []).append(('om', tuple('|' if not x[0] else x for x in items), ans))
            uc.reg_write(self.RAX, ans & 0xFFFFFFFFFFFFFFFF)
            return
        b, e = self.q(v), self.q(v + 8)
        its = [self.q(b + 8 * k) for k in range((e - b) // 8)]
        if any(self.q(it + 0x20) for it in its):    # the patch name's menu (rva 0x334590): items with submenus, the
            from unicorn.x86_const import UC_X86_REG_R8        # path in and out (a vector of two ints at r8)
            pv = uc.reg_read(UC_X86_REG_R8)
            pb, pe = self.q(pv), self.q(pv + 8)
            path = struct.unpack('<%di' % ((pe - pb) // 4), bytes(uc.mem_read(pb, pe - pb)))
            cut = lambda bs: bs.split(b'\0')[0]
            top = [cut(self.sstr(it).encode('latin1')) for it in its]
            cells = []
            for it in its:
                sv = self.q(it + 0x20)
                sb, se = self.q(sv), self.q(sv + 8)
                cells.append([cut(self.sstr(self.q(sb + 8 * k)).encode('latin1')) for k in range((se - sb) // 8)])
            ans = self.pn_answers.pop(0) if self.pn_answers else None
            self.st.setdefault('pn', []).append(('menu', tuple(path), ans, top, cells))
            if ans is None or len(path) != 2:
                uc.reg_write(self.RAX, 0xFFFFFFFFFFFFFFFF)
            else:
                uc.mem_write(pb, struct.pack('<ii', *ans))
                uc.reg_write(self.RAX, 0)
            return
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

    def _pn_edit(self, uc, addr, size, ud):
        from unicorn.x86_const import UC_X86_REG_R9
        self.st.setdefault('pn', []).append(('text', self.sstr(uc.reg_read(UC_X86_REG_R9)).encode('latin1')))

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

    def refresh_names(self):
        """the patch name controls' text as the live editor keeps it (their values' notifications reach the
        controls; the template has no live view): each control's own update, vt+0xB0 (rva 0x2CFEE0: its text
        writer's text from the values, +0x88 -> +0x108), what its edit offers"""
        for c in self.pnames:
            self.h.call(self.q(self.q(c) + 0xB0), rcx=c, count=500_000_000)

    def mouse(self, typ, x, y, flags):
        """the root panel's own dispatch on a mouse message: taken or not"""
        self.write_opens()
        self.refresh_names()
        self.st = dict(choice=-1, items=None, calls=[], pick=None, pn=[])
        self.taker = None
        self.uc.mem_write(self.msg, struct.pack('<iiii', typ, x, y, flags))
        return self.h.call(self.root_mouse, rcx=self.root, rdx=self.msg, count=4_000_000_000) & 0xFF

    def gtick(self, t):
        """the editor's timer at the GUI's clock t ms (GetTickCount): the root panel's tick, the module's idle"""
        self.write_opens()
        self.h.tick_ms = t
        self.uc.mem_write(self.msg, struct.pack('<Q', self.IB + TIMER_MSG_VT))
        self.h.call(self.q(self.q(self.root) + 0x60), rcx=self.root, rdx=self.msg, count=4_000_000_000)
        mod = self.h.call(self.IB + MODULE, count=500_000_000)
        self.h.call(self.q(self.q(mod) + 0x38), rcx=mod, count=4_000_000_000)

    def wheel(self, x, y, delta, keys):
        """WM_MOUSEWHEEL at a panel point: the editor's message (its delta, its MK_ keys), the root panel's wheel"""
        self.write_opens()
        self.refresh_names()
        self.st = dict(choice=-1, items=None, calls=[], pick=None, pn=[])
        self.taker = None
        pt, out = self.msg + 0x40, self.msg + 0x60
        self.uc.mem_write(pt, struct.pack('<ii', x, y))
        self.h.call(self.IB + MOUSEWHEEL_MSG, rcx=out, rdx=0x20A, r8=delta & 0xFFFF, r9=pt, stack=[keys & 0xFFFF],
                    count=500_000_000)
        return self.h.call(self.q(self.q(self.root) + 0x50), rcx=self.root, rdx=out, count=4_000_000_000) & 0xFF

    def conv(self, size, x, y):
        """a point of the panel window of that size converted as the plugin's mouse messages are (rva 0x2ABFC0: its
        zoom by the getter, rva 0x2AA470)"""
        pin, pout = self.msg + 0xC0, self.msg + 0xD0
        self.uc.mem_write(pin, struct.pack('<ii', x, y))
        self.h.call(self.IB + WIN_TO_PANEL, rcx=self.h.windows[size], rdx=pout, r8=pin, count=500_000_000)
        return struct.unpack('<ii', bytes(self.uc.mem_read(pout, 8)))

    def key(self, typ, vk, mods):
        """a key into the root panel's own key (vt+0x58, rva 0x2AA960): the message as the editor builds it (rva
        0x43AE20: its code by the plugin's table, rva 0x43ABE0); taken or not, and the code"""
        self.write_opens()
        self.refresh_names()
        self.st = dict(choice=-1, items=None, calls=[], pick=None, pn=[])
        self.taker = None
        code = self.h.call(self.IB + KEY_CODE, rcx=(vk if vk < 128 else vk - 256) & 0xFFFFFFFF,
                           count=10_000_000) & 0xFFFFFFFF
        code = code - (1 << 32) if code >= 1 << 31 else code
        self.h.call(self.IB + KEY_MSG, rcx=self.msg, rdx=typ, r8=code & 0xFFFFFFFF, r9=mods, count=10_000_000)
        self.last_code = code
        return self.h.call(self.q(self.q(self.root) + 0x58), rcx=self.root, rdx=self.msg, count=4_000_000_000) & 0xFF

    def value(self, pid):
        """a model value as its value object reads it (vt+0x80)"""
        o = self.obj.get(pid)
        if o is None:
            return None
        v = self.h.call(self.q(self.q(o) + 0x80), rcx=o, count=10_000_000) & 0xFFFFFFFF
        return v - (1 << 32) if v >= 1 << 31 else v

    def pw(self):
        """the plugin's patch window when it is open: its own root panel (vt 0x97FE48), which the editor opened on
        panelPatch 1 (its fit, rva 0x312750, names it) -- None when closed"""
        w = getattr(self.h, 'windows', {}).get(panel_sizes()[1])
        return w if w is not None and self.value(PW_IDS[0]) == 1 else None

    def mouse_pw(self, w, typ, x, y, flags):
        """a mouse message into the patch window's own root (its vt+0x48, rva 0x2AAD50)"""
        self.st = dict(choice=-1, items=None, calls=[], pick=None, pn=[])
        self.taker = None
        self.uc.mem_write(self.msg, struct.pack('<iiii', typ, x, y, flags))
        return self.h.call(self.q(self.q(w) + 0x48), rcx=w, rdx=self.msg, count=4_000_000_000) & 0xFF

    def hover(self):
        """each panel's hover flag (+0xDD: it was in the last message's way), in the tree's order"""
        return ''.join('1' if self.uc.mem_read(p + 0xDD, 1)[0] else '0' for p in self.panels)

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
    prects = [struct.unpack('<iiii', bytes(g.uc.mem_read(p + 0x18, 16))) for p in g.panels]   # each panel's +0x18
    return [t[:4] for t in g.tree], [t[4] for t in g.tree], g.jx, rects, prects, g.allc


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
               changed=collections.Counter(), at=collections.Counter(), zooms=set(), **{'om chosen': set()})
    g = h = None
    MAIN, PATCH = panel_sizes()
    calls = ('model_set', 'commit', 'queue_record', 'pm_set', 'pm_commit', 'pm_notify', 'keybed', 'cc_learn', 'cc_forget',
             'cc_preset')
    i, tree_done, in_event = 0, False, False
    exe_edits, e0, q_blk = [], 0, 0
    last = (0, 0)                                  # the last down's point (an up without one goes there)
    down_ctl, state_before, await_state = None, None, None
    last_kb, hover_before = None, None             # the last mouse event's kind; the hover flags last compared
    last_zoom = None
    hover_trace = []
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
            k = next((j for j in range(min(len(mine), len(exe_edits))) if mine[j] != exe_edits[j]),
                     min(len(mine), len(exe_edits)))
            fail('%s: host edits -- the plugin %d, the program %d; the first that differs, #%d: the plugin %s, the '
                 'program %s' % (where(), len(mine), len(exe_edits), k, mine[k:k + 3], exe_edits[k:k + 3]))
        res['n']['edits'] += len(mine)
        res['n']['open edits'] += bool(mine) and any(e[0] == 'beginEdit' for e in mine) and mine[-1][0] != 'endEdit'
        exe_edits = []

    def ccmap(st):
        n = struct.unpack('>I', st[:4])[0] // 8
        return {k: v for k, v in (struct.unpack('>Ii', st[4 + 8 * j: 12 + 8 * j]) for j in range(n)) if k >= 0x10000000}

    dlg = []                                       # the plugin's dialogs in the current event (the patch name's,
    boxes = []                                     # the option menu) and its message boxes (code, then type)

    def run_event(fn, *a):
        """a mouse or wheel message into the plugin: its dialogs and boxes kept for the program's '# pn' / '# om' /
        '# box' lines, then the event's unused scripted answers dropped (as the program drops them)"""
        nonlocal dlg, boxes
        if dlg:
            fail('%s: the plugin asked %d dialog(s) the program did not: %s' % (where(), len(dlg), dlg[0][:2]))
        if boxes:
            fail('%s: the plugin showed %s, the program no box' % (where(), boxes[:2]))
        w0 = len(h.wlog)
        r = fn(*a)
        dlg = list(g.st.get('pn', []))
        boxes = [e for e in h.wlog[w0:] if e[0] in ('message', 'box')]
        h.answers.clear()
        g.pn_answers.clear()
        g.om_answers.clear()
        return r

    def om_line(t):
        """the program's option menu in its event ('# om FLAGS CHOICE N' then each item =HEX:EN:CK, a separator |):
        the plugin's, its items with their enables and checks, the separators, the answer"""
        nonlocal dlg
        if not dlg or dlg[0][0] != 'om':
            fail('%s: the program showed the option menu, the plugin %s' % (where(), dlg[0][:1] if dlg else 'none'))
            return
        d = dlg.pop(0)
        mine = tuple('|' if w == '|' else (bytes.fromhex(w.split(':')[0][1:]).decode('latin1'), int(w.split(':')[1]),
                                           int(w.split(':')[2])) for w in t[5:])
        if d[1] != mine or d[2] != int(t[3]):
            k = next((j for j in range(min(len(mine), len(d[1]))) if mine[j] != d[1][j]), min(len(mine), len(d[1])))
            fail('%s: the option menu -- the plugin (%d items, answer %d, from #%d %s), the program (%d, %s, %s)'
                 % (where(), len(d[1]), d[2], k, d[1][k:k + 2], len(mine), t[3], mine[k:k + 2]))
        res['n']['om'] += 1
        res['n']['om hidden'] += len(d[1]) > 15
        if d[2] >= 0:
            res['om chosen'].add(d[2])

    def box_line(t):
        nonlocal boxes
        want = [('message', int(t[2])), ('box', int(t[3]))]
        if boxes[:2] != want:
            fail('%s: the message box -- the plugin %s, the program %s' % (where(), boxes[:2], want))
        boxes = boxes[2:]
        res['n']['boxes'] += 1

    def pn_line(t):
        """the program's patch name dialog in its event: the plugin's, in order"""
        nonlocal dlg
        if not dlg:
            fail('%s: the program asked a dialog (%s) the plugin did not' % (where(), ' '.join(t[1:4])))
            return
        d = dlg.pop(0)
        if t[2] == 'text':
            want = bytes.fromhex(t[3][1:])
            if d[0] != 'text' or d[1] != want:
                fail('%s: the name edit offered -- the plugin %r, the program %r' % (where(), d[:2], want))
            res['n']['pn text'] += 1
            res['n']['pn text set'] += t[4] != '-'
            return
        hx = lambda w: b'' if w in ('-', '=') else bytes.fromhex(w[1:])
        p_in, p_out, ntop = (int(t[3]), int(t[4])), (int(t[5]), int(t[6])), int(t[7])
        items = [hx(w) for w in t[8:]]
        top, cells = items[:ntop], [items[ntop + 32 * k: ntop + 32 * (k + 1)] for k in range(ntop)]
        ans = None if p_out[0] < 0 else p_out
        if d[0] != 'menu' or d[1] != p_in or d[2] != ans or d[3] != top or d[4] != cells:
            fail('%s: the patch menu -- the plugin (in %s, out %s, %d items: %s), the program (in %s, out %s, %d: %s)'
                 % (where(), d[1:2], d[2:3], len(d[3]) if d[0] == 'menu' else -1, d[3][:2] if d[0] == 'menu' else d,
                    p_in, ans, ntop, top[:2]))
        res['n']['pn menu'] += 1
        res['n']['pn chosen'] += ans is not None

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
        if in_event and (t[0] in calls or t[0] == 'zoomfit' or ln.startswith('# hostedit') or ln.startswith('# pm ') or
                         ln.startswith('# hit') or ln.startswith('# pn ') or ln.startswith('# key code ') or
                         ln.startswith('# om ') or ln.startswith('# box ')):
            if ln.startswith('# pn '):
                pn_line(t)
            elif ln.startswith('# om '):
                om_line(t)
            elif ln.startswith('# box '):
                box_line(t)
            elif ln.startswith('# key code '):    # the program's code for its key: the plugin's table's
                if int(t[3]) != g.last_code:
                    fail('%s: the key code -- the plugin %d, the program %s' % (where(), g.last_code, t[3]))
                res['n']['key codes'] += 1
            elif ln.startswith('# hit'):          # the program's dispatch: the control its press went to
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
        if ln.startswith('# ans '):              # the next event's scripted answers (the program's "ans" lines)
            if t[2] == 't':
                h.answers.append(('text', None if t[3] == '-' else bytes.fromhex(t[3][1:])))
            elif t[2] == 'p':
                g.pn_answers.append(None if int(t[3]) < 0 else (int(t[3]), int(t[4])))
            elif t[2] == 'o':
                g.om_answers.append(int(t[3]))
            continue
        if ln.startswith('# gtick '):          # the editor's 50 ms timer at the GUI's clock (ms)
            sync()
            g.gtick(int(t[2]))
            res['n']['gticks'] += 1
            in_event = True
            continue
        if ln.startswith('# wpt '):            # a main-window point's conversion: the plugin's own on its window
            sync()
            X, Y, PX, PY = (int(v) for v in t[2:6])
            if MAIN not in getattr(h, 'windows', {}):
                fail('%s: wpt -- the plugin has no main window open' % where())
                continue
            got = g.conv(MAIN, X, Y)
            if got != (PX, PY):
                fail('%s: the window point (%d, %d) -- the plugin %s, the program (%d, %d)' % (where(), X, Y, got, PX, PY))
            z = h.window_conv(MAIN)
            trunc = lambda v: int(v * 100 / z) if z else v          # x 100 / zoom, truncated (C's)
            res['n']['wpt'] += 1
            res['n']['wpt round'] += (trunc(X), trunc(Y)) != (PX, PY)
            res['zooms'].add(z)
            continue
        if ln.startswith('# zoom '):           # the main window's zoom (its getter, rva 0x2AA470): the plugin's
            sync()
            z = h.window_conv(MAIN)
            if z != int(t[2]):
                fail('%s: the main window\'s zoom -- the plugin %d, the program %s' % (where(), z, t[2]))
            res['n']['zooms'] += 1
            res['n']['zoom changes'] += last_zoom is not None and z != last_zoom
            last_zoom = z
            continue
        if ln.startswith('# kb key '):         # WM_KEYDOWN (1) / WM_KEYUP (2): the virtual key, Shift 1 / Ctrl 2 / Alt 8
            sync()
            typ, vk, mods = (int(v) for v in t[3:6])
            before = h.get_state()
            taken = run_event(g.key, typ, vk, mods)
            res['n']['keys'] += 1
            res['n']['keys taken'] += bool(taken)
            if taken:                           # the focused control (+0x10 -> +0x10 -> +0x18): its class
                foc = g.q(g.q(g.q(g.root + 0x10) + 0x10) + 0x18)
                res['at'][g.info.get(foc, ('?',))[0] + ' key'] += 1
            if taken and typ == 1 and h.get_state() != before:
                res['n']['key steps'] += 1
            in_event = True
            continue
        if ln.startswith('# pmv '):            # the patch window's values: the program's against the plugin's model
            sync()
            mine, got = [int(v) for v in t[2:8]], [g.value(k) for k in PW_IDS]
            if mine != got:
                fail('%s: the patch window\'s values (open, manager, lists, bankId, patchId) -- the plugin %s, the '
                     'program %s' % (where(), got, mine))
            res['n']['pmv'] += 1
            continue
        if ln.startswith('# hover '):          # each panel's hover flag (+0xDD) after the event
            mine = g.hover()
            if mine != t[2]:
                fail('%s: hover flags -- the plugin %s, the program %s' % (where(), mine, t[2]))
                if os.environ.get('JX_HOVER_TRACE') and not res.get('traced'):
                    res['traced'] = True
                    for e in hover_trace[-14:]:
                        print('  hover trace: line %d %-28s plugin %s' % e)
            res['n']['hover'] += 1
            if last_kb == 'leave' and hover_before is not None and hover_before != mine:
                res['n']['leave changed'] += 1
            hover_before = mine
            continue
        if ln.startswith('# kb wheel '):       # WM_MOUSEWHEEL: x y delta MK_ keys
            sync()
            x, y, d, kk = (int(v) for v in t[3:7])
            taken = run_event(g.wheel, x, y, d, kk)
            res['n']['wheels'] += 1
            res['n']['wheels taken'] += bool(taken)
            for k2, tn2, l2, t2, r2, b2 in g.allc:
                if g.live(k2) and l2 <= x < r2 and t2 <= y < b2:
                    res['at'][tn2 + ' wheel'] += 1
            in_event = True
            continue
        if ln.startswith('# kb '):
            sync()
            kind, a = t[2], [int(v) for v in t[3:]]
            last_kb = kind
            w = g.pw() if kind in ('down', 'dbl', 'move', 'up') else None
            if w is not None:                   # the patch window open: its own root takes the mouse -- the plugin's is
                ox, oy = (MAIN[0] - PATCH[0]) // 2, (MAIN[1] - PATCH[1]) // 2   # its own window, the program's is drawn
                if kind == 'up':                # centred in the main one (jx3p_win.c: g_patchwin)
                    x, y = (a[0], a[1]) if a[0] >= 0 else last
                    s = a[2] if len(a) > 2 else 0
                else:
                    x, y, s = a
                    if kind != 'move':
                        last = (x, y)
                taken = run_event(g.mouse_pw, w, {'down': 0, 'dbl': 2, 'move': 3, 'up': 1}[kind], x - ox, y - oy, s)
                res['n']['pw events'] += 1
                if g.taker is not None:
                    res['at']['pw ' + g.tname(g.taker)] += 1
                in_event = True
                continue
            if kind == 'leave':                 # WM_MOUSELEAVE: a move to (0x80000001, 0x80000001), flags 0
                taken = run_event(g.mouse, 3, LEAVE, LEAVE, 0)
                res['n']['leaves'] += 1
                if os.environ.get('JX_HOVER_TRACE'):
                    hover_trace.append((i, 'leave', g.hover()))
            elif kind == 'up':
                x, y = (a[0], a[1]) if a[0] >= 0 else last
                taken = run_event(g.mouse, 1, x, y, a[2] if len(a) > 2 else 0)
                if os.environ.get('JX_HOVER_TRACE'):
                    hover_trace.append((i, 'up %d %d' % (x, y), g.hover()))
                await_state = down_ctl              # the next state line: the press's effect, for the reach
            else:
                x, y, s = a                     # s: the plugin's flag bits (1 Shift, 2 Ctrl, 8 Alt)
                typ = {'down': 0, 'dbl': 2, 'move': 3}[kind]
                if kind in ('down', 'dbl'):
                    last = (x, y)
                    down_ctl = control_at(x, y)
                    state_before = h.get_state()
                    if down_ctl:
                        res['press'][down_ctl + (' dbl' if kind == 'dbl' else '')] += 1
                    for k2, tn2, l2, t2, r2, b2 in g.allc:
                        if tn2 in GENERIC and g.live(k2) and l2 <= x < r2 and t2 <= y < b2:
                            res['at'][tn2] += 1
                elif down_ctl == 'jx3pSlider':
                    res['n']['slider moves'] += 1
                taken = run_event(g.mouse, typ, x, y, s)
                if os.environ.get('JX_HOVER_TRACE'):
                    hover_trace.append((i, '%s %d %d' % (kind, x, y), g.hover()))
                if kind in ('down', 'dbl') and g.taker is not None:      # a press its panel's hover let through
                    pl, pt, pr, pb = struct.unpack('<iiii', bytes(g.uc.mem_read(g.ctl_panel[g.taker] + 0x18, 16)))
                    res['n']['outside'] += not (pl <= x < pr and pt <= y < pb)
                    tn2 = g.info[g.taker][0]
                    if tn2 not in JX_TYPES:             # a generic class: counted by the control that took it
                        down_ctl = tn2
                        res['press'][tn2 + (' dbl' if kind == 'dbl' else '')] += 1
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
            if (MAIN if t[1] == '0' else PATCH) not in getattr(h, 'windows', {}):
                res['notes'].append('zoomfit %s: the plugin has no such window open (the zoom: jx_zoom_fit_gate.py)' % t[1])
                continue
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
            res['n']['moved'] = max(res['n']['moved'], sum(1 for k in end if end[k] != boot_map.get(k)))   # at any state:
                                                    # the option menu's mappings reset the map later
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
    """the program's open flags in each configuration (and its tree first: each control's function)"""
    out = ['cctree']
    for cfg in configs:
        out += config_lines(cfg) + ['opens']
    return out


def script(tree, parents, jx, mapped, opens_by_cfg, configs, seed, quick=False, prects=(), allc=(), skip=frozenset()):
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
    clock = [0]                                    # the GUI's clock (ms), the editor's timer every 50

    def ticks(n):
        o = []
        for _ in range(n):
            clock[0] += 50
            o.append('gtick %d' % clock[0])
        return o
    last_gen = (None, {}, [])
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
        if quick and mapped:                             # the quick run: one Learn for sure (then a CC learns it)
            l, t, r, b = rnd.choice(mapped)
            out += ['ccmsg %d %d 0 0' % (rnd.randrange(l, r), rnd.randrange(t, b)),
                    'cc %d %d' % (rnd.randrange(0, 120), rnd.randrange(0, 128)), 'block', 'tick', 'cctree', 'state']
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
        # a JX control standing out of its panel (the patch select row: 2 rows below it), pressed as a hand does: a
        # down inside, the mouse out to the part that stands out, the up there (the control held the mouse: its panel
        # was in the way), then a double click there -- it reaches the control only through the panel's hover flag
        # (+0xDD); the choice is fixed (no draw from the seeded stream: the rest of the script stays the same)
        out_of = []
        for k, tn, l, t, r, b in jx:
            if not live(k) or k >= len(prects):
                continue
            pl, pt, pr, pb = prects[k]
            if b > pb and l < r and t < pb:
                out_of.append(((l + r) // 2, (t + pb) // 2, (l + r) // 2, pb))
        if out_of:
            cx, cy, sx, sy = out_of[ci % len(out_of)]
            after = ['opens', 'state', 'pending']
            out += (['move %d %d 0' % (cx, cy), 'down %d %d 0' % (cx, cy)] + after + ['move %d %d 0' % (sx, sy)] + after +
                    ['up %d %d' % (sx, sy)] + after + ['dbl %d %d 0' % (sx, sy)] + after + ['up %d %d' % (sx, sy)] + after +
                    ['block', 'state'])
        # ---- the mouse on the live controls of the generic classes (scope row 25), from a stream of its own (the
        # draws above stay as they were): a down, drags, the up, double clicks; Shift / Ctrl; inside, on the edges,
        # just off them; a patch loaded first for the values the control reads
        rg = random.Random(seed * 7919 + ci)
        gen = collections.defaultdict(list)
        for k, tn, l, t, r, b in allc:
            if tn in GENERIC and live(k) and r > l and b > t and (l, t, r, b) not in skip:
                gen[tn].append((k, tn, l, t, r, b))
        if not cfg[4]:                                 # the keys' controls (below): a configuration without the
            last_gen = (cfg, gen, [c for c in jx if c[1] == 'jx3pSlider' and live(c[0])])   # SETUP page (modal: it
                                                       # takes every press outside it); its JX switches
        livec = [(c[1], c[2], c[3], c[4]) for k, p in enumerate(tree) if live(k) for c in p[3] if c[3] > c[1] and c[4] > c[2]]
        after = ['opens', 'state', 'pending']
        for tn in GENERIC:
            ctls = gen.get(tn, [])
            if not ctls:
                continue
            want = GEN_N[tn] if not quick else max(1, GEN_N[tn] // 2)
            picks = [rg.choice(ctls) for _ in range(want)] if len(ctls) < want else rg.sample(ctls, want)
            for k, _, l, t, r, b in picks:
                if rg.random() < 0.5:
                    out += ['patch %d 1' % rg.randrange(64), 'opens', 'state', 'pending']
                inside = [((l + r) // 2, (t + b) // 2), (l, t), (r - 1, b - 1), (l, b - 1), (r - 1, t),
                          (rg.randrange(l, r), rg.randrange(t, b)), (rg.randrange(l, r), rg.randrange(t, b))]
                near = [q for q in ((l - 1, t), (r, b - 1), (l, t - 1), (r - 1, b), (l - 3, (t + b) // 2), ((l + r) // 2, b + 2))
                        if not any(L <= q[0] < R and T <= q[1] < B for L, T, R, B in livec)]
                p = rg.choice(inside) if not near or rg.random() < 0.85 else rg.choice(near)
                u = rg.random()
                s = 0 if u < 0.7 else 1 if u < 0.85 else 2
                ev = ['move %d %d 0' % p, 'down %d %d %d' % (p[0], p[1], s)] + after
                x, y = p
                if tn in ('knob', 'slider', 'keyboardX') and rg.random() < 0.6:     # a drag
                    for _ in range(rg.randrange(1, 7)):
                        if tn == 'keyboardX':
                            x, y = rg.randrange(l - 12, r + 12), rg.randrange(t - 12, b + 12)
                        else:
                            x, y = x + rg.randrange(-25, 26), y + rg.randrange(-70, 71)
                        ev += ['move %d %d %d' % (x, y, s)] + after
                elif rg.random() < 0.25:                                           # off and back, or off
                    x, y = rg.choice(inside + near)
                    ev += ['move %d %d %d' % (x, y, s)] + after
                ev += ['up %d %d' % (x, y)] + after
                if rg.random() < 0.25:                                             # a double click there
                    ev += ['dbl %d %d %d' % (x, y, 0)] + after + ['up %d %d' % (x, y)] + after
                out += ev + ticks(rg.randrange(1, 3)) + after + ['block', 'state']  # the timer: queued functions
                if tn == 'latchButton':          # PATCH, SETUP, EDIT are latch buttons: the configuration back (the
                    out += ['set 0 vm.vs.panelPatch'] + config_lines(cfg) + after     # patch window: its own gate)
        # ---- the patch name: its arrow (20 x 32 at the control's corner: the name's edit) and the rest of it (the
        # patch menu), answered; a double click too (the same as a down: rva 0x2DE770, 0x33E950)
        pns = gen.get('patchName', [])
        for _ in range(PN_N if not quick else PN_N // 2):
            if not pns:
                break
            k, tn, l, t, r, b = rg.choice(pns)
            if rg.random() < 0.4:
                out += ['patch %d 1' % rg.randrange(64), 'opens', 'state', 'pending']
            if rg.random() < 0.5:
                p = (rg.randrange(l, min(l + 20, r)), rg.randrange(t, b))
                a = rg.choice(PN_TEXTS)
                ans = 'ans t -' if a is None else 'ans t =' + a.hex()
            else:
                p = (rg.randrange(min(l + 20, r - 1), r), rg.randrange(t, b))
                ans = 'ans p %d %d' % (rg.randrange(2), rg.randrange(32)) if rg.random() < 0.75 else 'ans p -1'
            kind = 'dbl' if rg.random() < 0.2 else 'down'      # (the answers just before their press: an event drops
            out += ['move %d %d 0' % p, ans, '%s %d %d 0' % (kind, p[0], p[1])] + after + ['up %d %d' % p] + after
                                                               # the unused ones)
            out += ticks(rg.randrange(0, 3)) + after + ['block', 'state']
        # ---- the wheel (WM_MOUSEWHEEL as the editor takes it) and the editor's timer: notches (deltas of a notch, of
        # less, of several; Shift, Ctrl), ticks between them, the edit closed by the timer (800 ms) or by a press on
        # another control (the focus), on knobs, sliders, the JX switches, the keyboard, displays, labels
        wh = [c for tn in ('knob', 'slider', 'keyboardX', 'display', 'label', 'patchName') for c in gen.get(tn, [])]
        wh += [(k, tn, l, t, r, b) for k, tn, l, t, r, b in jx if tn == 'jx3pSlider' and live(k)]
        presses = [c for tn in ('knob', 'slider', 'latchButton', 'patchName') for c in gen.get(tn, [])]
        firsts = []
        for tn in ('knob', 'slider', 'jx3pSlider', 'keyboardX', 'patchName'):
            cs = [c for c in wh if c[1] == tn]
            if cs:
                firsts.append(rg.choice(cs))
        for wi in range(len(firsts) + (WHEELS if not quick else WHEELS // 2)):
            if not wh:
                break
            k, tn, l, t, r, b = firsts[wi] if wi < len(firsts) else rg.choice(wh)
            if rg.random() < 0.4:
                out += ['patch %d 1' % rg.randrange(64), 'opens', 'state', 'pending']
            q = (rg.randrange(l, r), rg.randrange(t, b)) if rg.random() < 0.9 else (l - 2, t)
            for _ in range(rg.randrange(1, 5)):
                d = rg.choice((120, -120, 120, -120, 240, -240, 360, 60, -60, 1, -1, 119, -119, 121))
                kk = rg.choice((0, 0, 0, 4, 8, 12))
                out += ['wheel %d %d %d %d' % (q[0], q[1], d, kk)] + after + ticks(rg.randrange(0, 4)) + after
            if presses and rg.random() < 0.3:              # a press elsewhere: the focus moves
                k2, tn2, l2, t2, r2, b2 = rg.choice(presses)
                px, py = (l2 + r2) // 2, (t2 + b2) // 2
                out.append('move %d %d 0' % (px, py))
                if tn2 == 'patchName':                     # the patch name takes the focus, its menu answered: none
                    out.append('ans p -1')
                out += ['down %d %d 0' % (px, py)] + after + ['up %d %d' % (px, py)] + after
                if tn2 == 'latchButton':
                    out += ['set 0 vm.vs.panelPatch'] + config_lines(cfg) + after
            out += ticks(rg.randrange(0, 80)) + after + ['block', 'state']
        # a fixed sequence (no draw): a knob's wheel, then a press on the patch name's menu part within the 800 ms (the
        # focus moves: the knob's open edit closes at the press), then the patch name's Ctrl wheel (a step of 10) and
        # a plain one
        knobs, pn1 = gen.get('knob', []), gen.get('patchName', [])
        if knobs and pn1:
            k, tn, l, t, r, b = knobs[0]
            kx, ky = (l + r) // 2, (t + b) // 2
            k, tn, l, t, r, b = pn1[0]
            px, py = min(l + 100, r - 1), (t + b) // 2
            out += (['wheel %d %d 120 0' % (kx, ky)] + after + ticks(2) + after +
                    ['move %d %d 0' % (px, py), 'ans p -1', 'down %d %d 0' % (px, py)] + after + ['up %d %d' % (px, py)] +
                    after + ['wheel %d %d 120 8' % (px, py)] + after + ['wheel %d %d -120 0' % (px, py)] + after +
                    ticks(20) + after + ['block', 'state'])
        out += ['state', 'pending']
    # ---- the window's points (every WM_ mouse message's conversion, rva 0x2ABFC0) at zooms below the screen's fit and
    # above it (clamped), negative and off the panel too; and the mouse's leave (WM_MOUSELEAVE: a move to (0x80000001,
    # 0x80000001)) after moves in and near panels -- each panel's hover flag compared before and after
    zr = random.Random(seed * 7919 + 13)
    for z in (25, 26, 30, 33, 37, 40, 41, 45, 50, 55, 57, 59, 60, 62, 67, 75, 100, 150, 200):
        out += ['set %d vm.vs.mainZoom' % z]
        out += ['wpt %d %d' % (zr.randrange(-40, 1760), zr.randrange(-40, 760)) for _ in range(6 if quick else 16)]
        out += ['wpt %d %d' % (v, -v) for v in (-3, -1, 0, 1, 2, 3, 5)]
    out += ['set 75 vm.vs.mainZoom']
    # ---- the keys (WM_KEYDOWN / WM_KEYUP): every virtual key's code, then the arrows on a focused control -- a knob, a
    # slider, a JX switch, the patch name (its menu answered: none) -- held through the repeats (200 ms, then every 50),
    # Shift, let go (800 ms: the step 0), the focus's 3200 ms; keys with no focus
    out += ['key %d %d %d' % (1 + (vk & 1), vk, 0) for vk in range(256)] + ['opens', 'state']   # (lines ending the event:
                                                    # the sets below are not the key's -- playbook 265)
    kr = random.Random(seed * 104729 + 7)
    kcfg, gen_last, jxs_last = last_gen
    if kcfg is not None:
        out += config_lines(kcfg) + ['opens', 'state', 'pending']
    keyctl = [c for tn in ('knob', 'slider', 'patchName') for c in gen_last.get(tn, [])] + list(jxs_last)
    firsts_k = []
    for tn in ('knob', 'slider', 'jx3pSlider', 'patchName'):
        cs = [c for c in keyctl if c[1] == tn]
        if cs:
            firsts_k.append(kr.choice(cs))
    ARROWS = (0x25, 0x26, 0x27, 0x28)
    for ki in range(len(firsts_k) + (KEYS // 2 if quick else KEYS)):
        if not keyctl:
            break
        k, tn, l, t, r, b = firsts_k[ki] if ki < len(firsts_k) else kr.choice(keyctl)
        px, py = (l + r) // 2, (t + b) // 2
        if tn == 'patchName':
            px = min(l + 100, r - 1)
        out.append('move %d %d 0' % (px, py))
        if tn == 'patchName':
            out.append('ans p -1')
        out += ['down %d %d 0' % (px, py), 'up %d %d' % (px, py), 'state']
        for _ in range(kr.randrange(1, 4)):
            vk = kr.choice(ARROWS + ARROWS + (0x41, 0x20, 0x0D, 0x24))
            mods = kr.choice((0, 0, 1, 2))
            out += ['key 1 %d %d' % (vk, mods), 'opens', 'state', 'pending']
            out += ticks(kr.randrange(0, 12)) + ['opens', 'state', 'pending']
            out += ['key 2 %d %d' % (vk, mods), 'state'] + ticks(kr.randrange(0, 20)) + ['opens', 'state', 'pending']
        if kr.random() < 0.3:                          # the focus's 3200 ms: let go, then a key does nothing
            out += ticks(70) + ['key 1 38 0', 'opens', 'state', 'key 2 38 0', 'opens', 'state']
    # ---- the resize corner (the root's own mouse, before its dispatch: rva 0x2AAEF0): a point in its 20 px circle and
    # on its edge, a down there (a control focused by the wheel first, sometimes: the root takes the focus), drags out
    # and back (the zoom), the up; the zoom, converted points, the hover flags and the state after them
    if prects:
        rl, rt, rr, rb = prects[0]
        ccx, ccy = rr - 20, rb - 20
        cr = random.Random(seed * 15485863 + 3)
        knobs_c = gen_last.get('knob', [])
        for _ in range(CORNERS // 2 if quick else CORNERS):
            ang, rad = cr.uniform(0, 6.2832), cr.choice((0, 5, 14, 19, 20, 20, 21, 23))
            px, py = ccx + int(rad * math.cos(ang)), ccy + int(rad * math.sin(ang))
            if knobs_c and cr.random() < 0.3:
                k, tn, l, t, r, b = cr.choice(knobs_c)
                out += ['move %d %d 0' % ((l + r) // 2, (t + b) // 2), 'wheel %d %d 120 0' % ((l + r) // 2, (t + b) // 2),
                        'state'] + ticks(cr.randrange(0, 3))
            out += ['move %d %d 0' % (px, py), 'opens', 'hover', 'zoom']
            if cr.random() < 0.75:
                out += ['down %d %d 0' % (px, py), 'opens', 'state', 'zoom', 'hover']
                qx, qy = px, py
                for _ in range(cr.randrange(1, 6)):
                    qx, qy = px + cr.randrange(-500, 300), py + cr.randrange(-300, 200)
                    out += ['move %d %d 0' % (qx, qy), 'opens', 'zoom']
                out += ['up %d %d' % (qx, qy), 'opens', 'zoom', 'hover', 'state', 'pending']
                out += ['wpt %d %d' % (cr.randrange(-20, 1950), cr.randrange(-20, 720)) for _ in range(3)]
            else:
                out += ['move %d %d 0' % (ccx - 40, ccy - 40), 'opens', 'hover', 'zoom']
        out += ['set 75 vm.vs.mainZoom', 'zoom']
    for _ in range(LEAVES // 2 if quick else LEAVES):
        l, t, r, b = zr.choice(rects)
        x, y = zr.randrange(l - 3, r + 3), zr.randrange(t - 3, b + 3)
        out += ['move %d %d 0' % (x, y), 'opens', 'hover', 'leave', 'opens', 'hover']
        if zr.random() < 0.5:                          # back in at another point, then a press and its up there
            l, t, r, b = zr.choice(rects)
            x, y = zr.randrange(l - 3, r + 3), zr.randrange(t - 3, b + 3)
            out += ['move %d %d 0' % (x, y), 'opens', 'hover']
    # ---- the patch window's buttons (unlatchButtons: ManagePatchBank dec / inc, ManagePatch load): pressed at the down,
    # the function QUEUED at the up when the up is on the button (rva 0x2CD7E0; the registry, rva 0x296120) and run at
    # the next idle; an up off the button runs nothing. Each press into the plugin's own patch window (its root), at the
    # program's point less the window's place; compared at the down, right after the up (nothing run yet) and after the
    # editor's timer: the patch window's values, the state, the pending records
    pr = random.Random(seed * 31337 + 5)
    (mw_, mh_), (pw_, ph_) = panel_sizes()
    pox, poy = (mw_ - pw_) // 2, (mh_ - ph_) // 2
    out += ['set 1 vm.vs.panelPatch', 'opens', 'pmv', 'state', 'pending'] + ticks(2) + ['pmv', 'state', 'pending']
    for j in range(PWBTN // 2 if quick else PWBTN):
        l, t, r, b = PW_BTN[pr.choice(('dec', 'inc', 'load', 'load'))]
        px, py = pox + (l + r) // 2, poy + (t + b) // 2
        ux, uy = (px + 70, py - 30) if pr.random() < 0.25 else (px, py)
        out += ['set 0 vm.vs.panelPatch', 'set 1 vm.vs.panelPatch', 'opens', 'pmv', 'state', 'pending']   # (a load
        out += ['down %d %d 0' % (px, py), 'pmv', 'state', 'pending',                                  # closes it)
                'up %d %d' % (ux, uy), 'pmv', 'state', 'pending']
        out += ticks(pr.randrange(1, 3)) + ['pmv', 'state', 'pending']
    out += ['set 0 vm.vs.panelPatch', 'opens', 'pmv', 'state', 'pending']
    # ---- the option menu (the menuButton's up with its action, rva 0x3251C0 -> 0x4147B0): each choice the program
    # takes -- the mappings (set, cleared, set again), the four voice counts, the CPU item both ways, the Roland Cloud
    # box, the SYSTEM-8 layout (then the JX-3P's again: the panel's other controls are another layout's), none --
    # then random ones; the up's flags 7 (the right button, Shift, Ctrl) show the developer items (none taken: not
    # ported), 4 or 3 do not; a greyed answer is none. The items, enables, checks, separators and the answer compared,
    # then the state, the pending records, the CC map (in the state)
    mbs = [c for c in allc if c[1] == 'menuButton']
    if mbs:
        k, tn, l, t, r, b = mbs[0]
        mx, my = (l + r) // 2, (t + b) // 2
        orr = random.Random(seed * 7919 + 13)
        plan = [3, 2, 3, 3, 2, 4, 5, 6, 7, 8, 8, 9, -1, 1]
        plan += [orr.choice((-1, 0, 2, 3, 4, 5, 6, 7, 8, 9, 1)) for _ in range(OMENUS // 2 if quick else OMENUS)]
        for j, ch in enumerate(plan):
            fl = 7 if j in (3, 12) else orr.choice((0, 0, 0, 7, 4, 3, 5))
            out += ['move %d %d 0' % (mx, my), 'down %d %d %d' % (mx, my, fl), 'ans o %d' % ch,
                    'up %d %d %d' % (mx, my, fl), 'opens', 'state', 'pending']
            if ch == 1:                                  # the SYSTEM-8 layout: back to the JX-3P's at once
                out += ['down %d %d 0' % (mx, my), 'ans o 0', 'up %d %d 0' % (mx, my), 'opens', 'state', 'pending']
        out += ticks(3) + ['opens', 'state', 'pending']
    out += ['state', 'pending']
    return out


def wine_env():
    prefix = os.path.join(WORK, 'wine')
    os.makedirs(prefix, exist_ok=True)
    for d in glob.glob(os.path.join(prefix, 'drive_c', 'users', '*', 'AppData', 'Roaming', 'JX-3P')):
        shutil.rmtree(d, ignore_errors=True)          # the program's settings and banks: a first run each time
    env = dict(os.environ, WINEDEBUG='-all', WINEPREFIX=prefix)
    env.pop('TMPDIR', None)     # this Wine (Ubuntu 9.0) aborts, "free(): invalid pointer", when TMPDIR is set (playbook 269)
    return env


def run_exe(exe, lines, work, name):
    """the program under Wine on a kbscript; one run at a time holds the prefix (its start empties the program's
    files there: two runs at once spoiled each other's, playbook 263)"""
    import fcntl
    sp = os.path.join(work, name)
    open(sp, 'w').write('\n'.join(lines) + '\n')
    os.makedirs(WORK, exist_ok=True)
    with open(os.path.join(WORK, 'wine.lock'), 'w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        subprocess.run([WINE, os.path.basename(exe), '--kbscript', name], cwd=work, env=wine_env(), check=True,
                       timeout=3600, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return open(sp + '.log', newline=None).read().splitlines()


def build_tooth(define):
    out = os.path.join(REPO, 'scratchpad', 'dist', 'tooth', 'JX-3P_%s.exe' % define.replace('=', ''))
    subprocess.run([sys.executable, os.path.join(HERE, 'make_native_jx.py'), '--define', define, '--out', out],
                   check=True, stdout=subprocess.DEVNULL)
    return out


def teeth_main(spec, jobs):
    """the teeth (--teeth exe3-20,pm21,cc1-7,bridge1 --jobs N): every program built first, one at a time (they share
    one build folder), then N quick gate runs at once (the program under Wine one at a time: run_exe's lock). A tooth
    BITES when its run fails on a compared line (a FAIL), not on reach alone; exit 1 unless every tooth bites"""
    kinds = {'exe': ('EXE_TOOTH', '--tooth'), 'pm': ('PM_TOOTH', '--pm-tooth'), 'cc': ('CC_TOOTH', '--cc-tooth'),
             'bridge': ('JX_PRESET_TOOTH', '--bridge-tooth')}
    todo = []
    for part in spec.split(','):
        m = re.match(r'([a-z]+)(\d+)(?:-(\d+))?$', part.strip())
        if not m or m.group(1) not in kinds:
            raise SystemExit('--teeth: %r is not KIND N or KIND N-M (kinds: %s)' % (part, ', '.join(kinds)))
        for n in range(int(m.group(2)), int(m.group(3) or m.group(2)) + 1):
            todo.append((kinds[m.group(1)], n))
    built = [(opt, n, build_tooth('%s=%d' % (macro, n))) for (macro, opt), n in todo]

    def run(item):
        opt, n, exe = item
        r = subprocess.run([sys.executable, os.path.abspath(__file__), '--quick', opt, str(n), '--exe', exe],
                           capture_output=True, text=True)
        out = r.stdout.splitlines()
        return opt, n, r.returncode, sum(1 for ln in out if ln.startswith('  FAIL ')), (out or ['(no output)'])[-1], r
    import concurrent.futures
    bad = 0
    with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
        for opt, n, rc, nfail, last, r in ex.map(run, built):
            ok = rc == 0 and nfail > 0
            bad += not ok
            print('%s %d: %d FAIL lines -- %s%s' % (opt, n, nfail, last, '' if ok else '  <-- DOES NOT BITE'), flush=True)
            if not ok:
                print(r.stdout[-4000:] + r.stderr[-2000:])
    print('jx_panel_gate --teeth: %d of %d bite' % (len(built) - bad, len(built)))
    return 1 if bad else 0


def main():
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if '--teeth' in sys.argv:
        return teeth_main(arg('--teeth', ''), int(arg('--jobs', '3')))
    exe, seed, quick = arg('--exe', EXE), int(arg('--seed', '1')), '--quick' in sys.argv
    tooth, cctooth, pmtooth = int(arg('--tooth', '0')), int(arg('--cc-tooth', '0')), int(arg('--pm-tooth', '0'))
    btooth = int(arg('--bridge-tooth', '0'))         # the option menu's preset test (JX_PRESET_TOOTH, jx_bridge_exe.c)
    import make_native_jx
    make_native_jx.verify_truth()               # Script.xml, the art, the binary: their pinned bytes
    if (tooth or cctooth or pmtooth or btooth) and '--exe' not in sys.argv:
        exe = build_tooth('EXE_TOOTH=%d' % tooth if tooth else 'CC_TOOTH=%d' % cctooth if cctooth else
                          'PM_TOOTH=%d' % pmtooth if pmtooth else 'JX_PRESET_TOOTH=%d' % btooth)
    ctx = mp.get_context('spawn')
    with ctx.Pool(1) as pool:
        tree, parents, jx, mapped, prects, allc = pool.map(plugin_tree, [0])[0]
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
        skip = set()                            # the buttons whose dialogs the program cannot yet answer in a script
        for ln in plog:
            f = ln.split()
            if ln.startswith('# cctree C ') and len(f) >= 12 and f[3] == 'unlatchButton' and f[11] in SKIP_FN:
                x0, y0, w0, h0 = (int(v) for v in f[4:8])
                skip.add((x0, y0, x0 + w0, y0 + h0))
        log = run_exe(os.path.join(work, 'JX-3P.exe'), script(tree, parents, jx, mapped, opens, configs, seed, quick, prects, allc,
                                                             frozenset(skip)), work, 'panel.txt')
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
        'a press outside its panel that the panel\'s hover let through': n['outside'] > 0,
        'double clicks': sum(v for k, v in pr.items() if k.endswith(' dbl')) > 0,
        'the CC menu taken, a learn, a forget, the CC map moved': n['cc taken'] > 0 and n['learn'] > 0
        and n['forget'] > 0 and n['moved'] > 0,
        'states, pending records, host edits compared': n['state'] > 0 and n['pending'] > 0 and n['edits'] > 0,
        'every generic class that takes a down pressed (%s)' % ', '.join(GEN_TAKE): all(pr[c] > 0 for c in GEN_TAKE),
        'knobs, sliders, latch buttons changing the state': all(ch[c] > 0 for c in ('knob', 'slider', 'latchButton')),
        'labels, displays, bar graphs pressed at': all(res['at'][c] > 0 for c in ('label', 'display', 'barGraphX')),
        'the wheel on knobs, sliders, the JX switches, the keyboard (taken), the editor\'s timer': all(
            res['at'][c + ' wheel'] > 0 for c in ('knob', 'slider', 'jx3pSlider', 'keyboardX')) and n['wheels taken'] > 0
        and n['gticks'] > 0,
        'the resize corner: the zoom compared, changed by its drags': n['zooms'] > 0 and n['zoom changes'] > 0,
        'every virtual key\'s code; arrows taken on a knob, a slider, a JX switch, the patch name, stepping':
            n['key codes'] >= 256 and n['keys taken'] > 0 and n['key steps'] > 0
            and all(res['at'][c + ' key'] > 0 for c in ('knob', 'slider', 'jx3pSlider', 'patchName')),
        'the window\'s points converted at zooms (where a truncation would differ too), the leave changing a hover flag':
            n['wpt'] > 0 and n['wpt round'] > 0 and len(res['zooms']) >= 4 and n['leaves'] > 0 and n['hover'] > 0
            and n['leave changed'] > 0,
        'the patch window\'s buttons pressed in the plugin\'s own patch window, its values compared':
            n['pw events'] > 0 and res['at']['pw unlatchButton'] > 0 and n['pmv'] > 0,
        'the option menu: its items compared (the developer items shown too), every choice the program takes chosen, '
        'the Roland Cloud box': n['om'] > 0 and n['om hidden'] > 0 and n['boxes'] > 0
            and {0, 1, 2, 3, 4, 5, 6, 7, 8, 9} <= res['om chosen'],
        'the patch name: its edit set and cancelled, its menu chosen and not, the wheel on it':
            n['pn text set'] > 0 and n['pn text'] > n['pn text set'] and n['pn chosen'] > 0
            and n['pn menu'] > n['pn chosen'] and res['at']['patchName wheel'] > 0,
    }
    ok = not res['fails'] and all(reach.values())
    print('the plugin\'s tree: %d panels, %d controls, %d the CC search can stop at, %d of the five JX classes'
          % (n['panels'], n['controls'], n['searchable'], n['jx controls']))
    for s in sorted(set(res['notes']))[:12]:
        print('  note: ' + s)
    print('mouse events %d (%d taken by the plugin), presses per class %s; the state changed by %s; downs on the generic '
          'classes %s' % (n['events'], n['taken'], dict(pr), dict(ch), dict(res['at'])))
    print('wheels %d (%d taken), editor timer ticks %d; the patch name: edits %d (%d set), menus %d (%d chosen)'
          % (n['wheels'], n['wheels taken'], n['gticks'], n['pn text'], n['pn text set'], n['pn menu'], n['pn chosen']))
    print('zooms compared %d (%d changes)' % (n['zooms'], n['zoom changes']))
    print('option menus %d (%d with the developer items), chosen %s, boxes %d' % (n['om'], n['om hidden'],
                                                                              sorted(res['om chosen']), n['boxes']))
    print('patch window events %d (on %s), its values compared %d' % (
        n['pw events'], {k[3:]: v for k, v in res['at'].items() if k.startswith('pw ')}, n['pmv']))
    print('keys %d (%d taken, %d stepping), codes compared %d; on %s' % (n['keys'], n['keys taken'], n['key steps'],
          n['key codes'], {k: v for k, v in res['at'].items() if k.endswith(' key')}))
    print('window points %d (%d where x 100 / zoom truncated differs) at zooms %s; leaves %d (%d changing a hover flag), '
          'hover comparisons %d' % (n['wpt'], n['wpt round'], sorted(res['zooms']), n['leaves'], n['leave changed'], n['hover']))
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
    if tooth or cctooth or pmtooth or btooth:
        print('jx_panel_gate --%s %d: %s' % ('tooth' if tooth else 'cc-tooth' if cctooth else 'pm-tooth' if pmtooth
                                             else 'bridge-tooth', tooth or cctooth or pmtooth or btooth,
                                             'BITES' if not ok else 'DID NOT BITE'))
        return 0 if not ok else 1
    print('jx_panel_gate: %s (seed %d%s)' % ('GREEN' if ok else 'RED', seed, ', quick' if quick else ''))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
