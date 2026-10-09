"""patch_manager_emu.py -- the plugin's patch manager (its patch window's librarian, rva 0x330D10)
driven in the booted plugin (CLAIMS A39, docs/PATCH_MANAGER.md).

PLUMBING ONLY. Nothing here reimplements the manager: every command runs the plugin's own code --
the patch list's key handler (rva 0x3278C0) and mouse handler (rva 0x327D70) on the plugin's own
list control (its GUI template, built at the module init), the buttons' functions ManagePatch
(rva 0x322E60) and ManagePatchBank (rva 0x323FD0), the save (rva 0x336FD0), the timer tick (rva
0x32F280). The harness gives the plugin the operating system it asks:
  * a WRITABLE file system (CreateFile for writing, WriteFile, SetEndOfFile, DeleteFile, MoveFile,
    the free-space and SetupAPI disk-space calls of the save's check) on wrapper_emu's files;
  * the user's answers, scripted: the text edit service (rva 0x2AD500: the text, or a cancel), the
    menu service (its override pointer rva 0xCB21F8), the message boxes (MessageBoxA/W), the COM
    file dialogs (IFileOpenDialog / IFileSaveDialog, a shell item per path);
  * the two controls registered with the manager as their show methods do (rva 0x3308C0, 0x3308B0).
It reads the manager's state (READ layout, confirmed by executing): the banks, every state of each
history, the clipboard, the selection, the number format, the view's record image (the serializer,
rva 0x335990), the view's values (model+0x80: bank vt+0x50, patch +0x58, patchManager +0x60,
patchListMain +0x68, patchListSub +0x70; panelPatch, the list control's value ref 1). And it LOGS
the model calls the window's code makes -- a set (rva 0x283DB0: the value's id, the value, the
flag), a notify (rva 0x2853C0), a commit (rva 0x283120), a record load (rva 0x335850: the record's
hash) -- the ones whose return address is in the window's code (CODE below; the record load's own
sets are its own: the bridge's load, graded by the bank gates).
"""
import os, sys, struct, hashlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import host_process_emu as H                                  # noqa: E402
import wrapper_emu as W                                       # noqa: E402
import truth                                                  # noqa: E402
from pm_common import pick, ntfs_key                          # noqa: E402
from unicorn import UC_HOOK_CODE                              # noqa: E402
from unicorn.x86_const import (UC_X86_REG_RAX, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,  # noqa: E402
                               UC_X86_REG_R9, UC_X86_REG_RSP, UC_X86_REG_RIP)
import numpy as np                                            # noqa: E402

IB = H.IB
HEAP = (0x310000000, 0x312000000)
LIST_VT, BANKNAME_VT, MENU_OVERRIDE = 0x968D00, 0x968FE8, 0xCB21F8
KEY_ACTION, MOUSE, MP_FN, MPB_FN = 0x3278C0, 0x327D70, 0x322E60, 0x323FD0
TEXTEDIT, MESSAGE, PM_GET, SAVE_ALL, TICK = 0x2AD500, 0x292810, 0x330D10, 0x336FD0, 0x32F280
FORMAT_G, BANK_MOUSE = 0xC43B50, 0x33F0A0
SET, NOTIFY, COMMIT, RLOAD = 0x283DB0, 0x2853C0, 0x283120, 0x335850
# the window's code: the buttons' functions and tails, the list's close, key and mouse handlers, the
# manager (push .. the bank name control's commit); the record load and the serializer excluded
CODE = ((0x322E60, 0x324900), (0x3262C0, 0x326330), (0x3278C0, 0x328550), (0x32C000, 0x335850),
        (0x335990, 0x33F600))
VS_IDS = {0x0FFFC002: 'panel', 0x0FFFC004: 'manager', 0x0FFFC005: 'main', 0x0FFFC006: 'sub'}
GENERIC_WRITE = 0x40000000
PATCH_DIR = W.MODPATH.rsplit('\\', 1)[0] + '\\Patch'
SCRIPT_DIR = W.SCRIPT_DIR
DATA_DIR, OLD_DIR = W.DATA_DIR, 'C:\\ProgramData\\Roland\\JUNO-60'
CLSID_OPEN = bytes.fromhex('9c5a1cdc8ae8de4da5a160f82a20aef7')   # {DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}
CLSID_SAVE = bytes.fromhex('f3e2b4c021ba73478dba335ec946eb8b')   # {C0B4E2F3-BA21-4773-8DBA-335EC946EB8B}


def png_sizes():
    d = os.path.join(truth.TRUTH_DIR, 'Script')
    out = {}
    for f in os.listdir(d):
        if f.lower().endswith('.png'):
            b = open(os.path.join(d, f), 'rb').read(24)
            out[f.lower()] = struct.unpack('>II', b[16:24])
    return out


def norm(path):
    return W._norm(path).lower()


class PMHost(H.HostProcess):
    """the booted plugin with a writable file system and scripted dialogs"""
    def __init__(self):
        super().__init__()
        self.wlog = []              # every file change and dialog, in order
        self.answers = []           # the next dialog answers (popped in order), see PlugPM.run
        self.dsl = {}

    def _key(self, path): return norm(path)

    def put(self, path, data):
        k = norm(path); self.files[k] = bytes(data)
        d, nm = k.rsplit('\\', 1)
        lst = self.dirs.setdefault(d, [])
        real = W._norm(path).rsplit('\\', 1)[1]
        if not any(x.lower() == nm for x in lst):
            lst.append(real)
            lst.sort(key=ntfs_key)                # FindFirstFile on NTFS: the names by their upper case

    def rm(self, path):
        k = norm(path); self.files.pop(k, None)
        d, nm = k.rsplit('\\', 1)
        if d in self.dirs: self.dirs[d] = [x for x in self.dirs[d] if x.lower() != nm]

    def answer(self, kind):
        """the next scripted answer of `kind`; a missing one is a cancel"""
        for i, (k, v) in enumerate(self.answers):
            if k == kind:
                del self.answers[i]; return v
        return None

    def _imp(self, uc, address, size, user):
        if address not in self.stub2name:
            return
        dll, name = self.stub2name[address]
        rcx, rdx = uc.reg_read(UC_X86_REG_RCX), uc.reg_read(UC_X86_REG_RDX)
        r8, r9 = uc.reg_read(UC_X86_REG_R8), uc.reg_read(UC_X86_REG_R9)
        ret = lambda v: self._ret(uc, v)
        if name in ('GetDiskFreeSpaceExA', 'GetDiskFreeSpaceExW'):
            for a in (rdx, r8, r9):
                if a: uc.mem_write(a, struct.pack('<Q', 1 << 40))
            return ret(1)
        if name in ('SetupCreateDiskSpaceListA', 'SetupCreateDiskSpaceListW'):
            hd = 0xD5000 + 16 * len(self.dsl); self.dsl[hd] = 0; return ret(hd)
        if name in ('SetupAddToDiskSpaceListA', 'SetupAddToDiskSpaceListW'):
            self.dsl[rcx] = self.dsl.get(rcx, 0) + r8; return ret(1)
        if name in ('SetupQuerySpaceRequiredOnDriveA', 'SetupQuerySpaceRequiredOnDriveW'):
            uc.mem_write(r8, struct.pack('<q', self.dsl.get(rcx, 0))); return ret(1)
        if name == 'SetupDestroyDiskSpaceList':
            self.dsl.pop(rcx, None); return ret(1)
        if name in ('CreateFileA', 'CreateFileW') and (rdx & GENERIC_WRITE):
            path = self.rstr(rcx, name.endswith('W')); disp = self.stack_arg(4) & 0xFFFFFFFF
            old = self.file(path)
            if disp == 1 and old is not None: self.lasterr = 80; return ret(0xFFFFFFFFFFFFFFFF)
            if disp in (3, 5) and old is None: self.lasterr = 2; return ret(0xFFFFFFFFFFFFFFFF)
            data = bytearray(b'' if disp in (1, 2, 5) or old is None else old)
            self.wlog.append(('write', path))
            h = 0x107000
            while h in self.handles: h += 4
            self.handles[h] = [data, 0, path]
            self.put(path, data)
            return ret(h)
        if name == 'WriteFile':
            hd = self.handles.get(rcx)
            if hd is None or len(hd) < 3: return ret(0)
            buf = bytes(uc.mem_read(rdx, r8 & 0xFFFFFFFF)); data, pos = hd[0], hd[1]
            data[pos:pos + len(buf)] = buf; hd[1] = pos + len(buf)
            if r9: uc.mem_write(r9, struct.pack('<I', len(buf)))
            return ret(1)
        if name == 'SetEndOfFile':
            hd = self.handles.get(rcx)
            if hd is not None and len(hd) >= 3: del hd[0][hd[1]:]
            return ret(1)
        if name == 'FlushFileBuffers': return ret(1)
        if name == 'CloseHandle':
            hd = self.handles.get(rcx)
            if hd is not None and len(hd) >= 3: self.put(hd[2], hd[0])
            self.handles.pop(rcx, None); return ret(1)
        if name == 'DeleteFileW':
            path = self.rstr(rcx, True); self.wlog.append(('delete', path))
            if self.file(path) is None: self.lasterr = 2; return ret(0)
            self.rm(path); return ret(1)
        if name in ('MoveFileExW', 'MoveFileW'):
            src, dst = self.rstr(rcx, True), self.rstr(rdx, True)
            fl = (r8 & 0xFFFFFFFF) if name == 'MoveFileExW' else 0
            self.wlog.append(('move', src, dst))
            data = self.file(src)
            if data is None: self.lasterr = 2; return ret(0)
            if self.file(dst) is not None and not (fl & 1): self.lasterr = 183; return ret(0)
            self.rm(src); self.put(dst, data); return ret(1)
        if name in ('MessageBoxA', 'MessageBoxW'):
            a = self.answer('box')
            self.wlog.append(('box', r9 & 0xFFFFFFFF))
            return ret(1 if a is None else a)
        if name == 'CoCreateInstance' and bytes(uc.mem_read(rcx, 16)) in (CLSID_OPEN, CLSID_SAVE):
            kind = 'fdopen' if bytes(uc.mem_read(rcx, 16)) == CLSID_OPEN else 'fdsave'
            o = self.new_obj_any(kind, picks=None, opts=0)
            uc.mem_write(self.stack_arg(4), struct.pack('<Q', o)); return ret(0)
        if name == 'SHCreateItemFromParsingName':
            p = self.rstr(rcx, True)
            uc.mem_write(r9, struct.pack('<Q', self.new_obj_any('item', path=p)))
            return ret(0)
        if name == 'CoTaskMemFree': return ret(0)
        return super()._imp(uc, address, size, user)

    def new_obj_any(self, kind, **kw):
        if kind not in self.vt:
            self.vt[kind] = self._vtable(kind, 40)
        return self.new_obj(kind, **kw)

    def _com(self, uc, name, this, a1, a2, a3):
        _, kind, slot = name.split(':'); slot = int(slot)
        if kind not in ('fdopen', 'fdsave', 'item', 'items'):
            return super()._com(uc, name, this, a1, a2, a3)
        o = self.objs.get(this, {})
        ret = lambda v: self._ret(uc, v)
        if slot == 0:
            uc.mem_write(a2, struct.pack('<Q', this)); return ret(0)
        if slot in (1, 2): return ret(1)
        if kind in ('fdopen', 'fdsave'):
            if slot == 3:                                    # Show(hwnd): the scripted pick, or a cancel
                p = self.answer('file')
                self.wlog.append(('dialog', kind, p))
                if p is None: return ret(0x800704C7)         # HRESULT_FROM_WIN32(ERROR_CANCELLED)
                o['picks'] = p if isinstance(p, list) else [p]
                return ret(0)
            if slot == 20:                                   # GetResult(IShellItem**)
                uc.mem_write(a1, struct.pack('<Q', self.new_obj_any('item', path=o['picks'][0]))); return ret(0)
            if kind == 'fdopen' and slot in (27, 28):        # GetResults(IShellItemArray**)
                uc.mem_write(a1, struct.pack('<Q', self.new_obj_any('items', paths=o['picks']))); return ret(0)
            if slot == 10:                                   # GetOptions(DWORD*)
                uc.mem_write(a1, struct.pack('<I', o.get('opts', 0))); return ret(0)
            if slot == 9: o['opts'] = a1 & 0xFFFFFFFF; return ret(0)
            return ret(0)                                    # the rest (types, title, folder, ...): S_OK
        if kind == 'item':
            if slot == 5:                                    # GetDisplayName(sigdn, LPWSTR*): SIGDN_NORMALDISPLAY
                p = o['path']                                # (0) the file's name, its extension shown (as
                if (a1 & 0xFFFFFFFF) == 0:                   # Explorer shows .bin); else the path. The plugin
                    p = p.replace('/', '\\').rsplit('\\', 1)[-1]   # asks 0 for a second pick (2026-10-09: the
                s = p.encode('utf-16le') + b'\0\0'               # fake gave the path, the import failed)
                p = self.alloc_com(len(s)); uc.mem_write(p, s); uc.mem_write(a2, struct.pack('<Q', p)); return ret(0)
            return ret(0x80004001)
        if kind == 'items':
            if slot == 7:                                    # GetCount(DWORD*)
                uc.mem_write(a1, struct.pack('<I', len(o['paths']))); return ret(0)
            if slot == 8:                                    # GetItemAt(i, IShellItem**)
                uc.mem_write(a2, struct.pack('<Q', self.new_obj_any('item', path=o['paths'][a1 & 0xFFFFFFFF]))); return ret(0)
            return ret(0x80004001)


class PlugPM:
    """the plugin's manager, its list control registered, the dialogs scripted"""
    def __init__(self, files=(), rate=48000.0):
        h = self.h = PMHost()
        h.skin = png_sizes()
        for path, data in files:
            h.put(path, data)
        h.start(rate, 4096)
        uc = self.uc = h.uc
        self.pm = h.call(IB + PM_GET)
        blob = np.frombuffer(bytes(uc.mem_read(HEAP[0], HEAP[1] - HEAP[0])), dtype=np.uint64)
        self.lst = HEAP[0] + 8 * int(np.nonzero(blob == np.uint64(IB + LIST_VT))[0][0])
        self.bnc = HEAP[0] + 8 * int(np.nonzero(blob == np.uint64(IB + BANKNAME_VT))[0][0])
        self.view = self.q(self.lst + 0x10)
        h.call(IB + 0x3308C0, rcx=self.pm, rdx=self.lst, r8=0, r9=0, count=500_000_000)
        h.call(IB + 0x3308B0, rcx=self.pm, rdx=self.bnc, r8=0, count=500_000_000)
        svc, svt, stub = h.alloc_com(0x40), h.alloc_com(0x100), h.alloc_com(0x10)
        uc.mem_write(stub, b'\xC3'); uc.mem_write(svc, struct.pack('<Q', svt)); uc.mem_write(svt, struct.pack('<Q', stub) * 32)
        uc.mem_write(IB + MENU_OVERRIDE, struct.pack('<Q', svc))
        uc.hook_add(UC_HOOK_CODE, self._popup, begin=stub, end=stub)
        uc.hook_add(UC_HOOK_CODE, self._textedit, begin=IB + TEXTEDIT, end=IB + TEXTEDIT)
        uc.hook_add(UC_HOOK_CODE, self._message, begin=IB + MESSAGE, end=IB + MESSAGE)
        self.msg = h.alloc_com(0x20)
        self.strs = [h.alloc_com(0x40) for _ in range(4)]
        self.textbuf = h.alloc_com(0x1000)
        self.ser_vec = h.alloc_com(0x20)
        vb, ve = self.q(h.core + 24), self.q(h.core + 32)
        self.recobj = {}
        for k in range((ve - vb) // 24):
            self.recobj[h.call(IB + 0x319C50, rcx=h.core + 24, rdx=k) & 0xFFFFFFFF] = self.q(vb + 24 * k)
        self.model = self.q(self.q(h.core + 8))
        # the view's value objects (model+0x80, rva 0x34E170) and the vs record they point into
        vo = h.call(IB + 0x34E170, rcx=self.model)
        slot = lambda k: h.call(self.q(self.q(vo) + k), rcx=vo)
        self.vobj = {0x0FFFC010: slot(0x50), 0x0FFFC014: slot(0x58), 0x0FFFC004: slot(0x60),
                     0x0FFFC005: slot(0x68), 0x0FFFC006: slot(0x70)}
        self.vsbase = self.q(self.vobj[0x0FFFC010] + 0x18) - 0x10
        panel = self.vobj[0x0FFFC004] - 2 * 0x28                 # the vs value objects lie in vs order
        assert self.q(panel + 0x18) == self.vsbase + 2, 'panelPatch value object not found'
        self.vobj[0x0FFFC002] = panel
        self.byobj = {v: k for k, v in self.recobj.items()}
        self.calls = []
        for name, rva in (('set', SET), ('notify', NOTIFY), ('commit', COMMIT), ('load', RLOAD)):
            uc.hook_add(UC_HOOK_CODE, self._call_hook(name), begin=IB + rva, end=IB + rva)

    def q(self, a): return struct.unpack('<Q', bytes(self.uc.mem_read(a, 8)))[0]

    def i4(self, a): return struct.unpack('<i', bytes(self.uc.mem_read(a, 4)))[0]

    def sstr(self, a):
        n, cap = self.q(a + 0x10), self.q(a + 0x18)
        return bytes(self.uc.mem_read(self.q(a) if cap >= 16 else a, n))

    def wstr(self, a, b, buf=None):
        if len(b) < 16:
            self.uc.mem_write(a, b + b'\0' * (16 - len(b))); self.uc.mem_write(a + 0x10, struct.pack('<QQ', len(b), 15))
        else:
            buf = buf or self.h.alloc_com(len(b) + 16)
            self.uc.mem_write(buf, b + b'\0'); self.uc.mem_write(a, struct.pack('<QQ', buf, 0))
            self.uc.mem_write(a + 0x10, struct.pack('<QQ', len(b), len(b)))

    # ---- the model calls of the window's code
    def ident(self, o):
        if o in self.byobj: return self.byobj[o]
        p = self.q(o + 0x18)
        return 0x0FFFC000 + (p - self.vsbase) if 0 <= p - self.vsbase < 0x40 else -1

    def _call_hook(self, name):
        def f(uc, addr, size, ud):
            ra = self.q(uc.reg_read(UC_X86_REG_RSP)) - IB
            if not any(a <= ra < b for a, b in CODE):
                return
            if name == 'set':
                v = uc.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF
                self.calls.append(('set', self.ident(uc.reg_read(UC_X86_REG_RDX)), v - (1 << 32) if v >> 31 else v,
                                   uc.reg_read(UC_X86_REG_R9) & 0xFF))
            elif name == 'load':
                vec = uc.reg_read(UC_X86_REG_RCX)
                self.calls.append(('load', hashlib.sha1(self.vbytes(vec)).hexdigest()[:16]))
            else:
                self.calls.append((name,))
        return f

    def value(self, vid):
        o = self.vobj[vid]
        return self.h.call(self.q(self.q(o) + 0x80), rcx=o) & 0xFFFFFFFF

    def window(self):
        """the window's values: panelPatch, patchManager, patchListMain, patchListSub"""
        return tuple(self.value(k) for k in (0x0FFFC002, 0x0FFFC004, 0x0FFFC005, 0x0FFFC006))

    def open_window(self):
        """the user's PATCH button when the window is closed: the latch's model set (r9 1) and the
        panel control's commit (rva 0x285320, 0x2853C0, 0x283120), as every panel control makes them"""
        if self.value(0x0FFFC002):
            return 0
        self.h.call(IB + SET, rcx=self.model, rdx=self.vobj[0x0FFFC002], r8=1, r9=1)
        for rva in (0x285320, 0x2853C0, 0x283120):
            self.h.call(IB + rva, rcx=self.model, count=500_000_000)
        return 1

    # ---- the scripted services
    def _popup(self, uc, addr, size, ud):
        v = uc.reg_read(UC_X86_REG_RDX)
        b, e = self.q(v), self.q(v + 8)
        items = [(self.sstr(self.q(b + 8 * k)), uc.mem_read(self.q(b + 8 * k) + 0x29, 1)[0]) for k in range((e - b) // 8)]
        ch = pick(self.h.answer('menu'), len(items))
        self.h.wlog.append(('menu', items, ch))
        uc.reg_write(UC_X86_REG_RAX, (-1 if ch is None else ch) & 0xFFFFFFFFFFFFFFFF)

    def _textedit(self, uc, addr, size, ud):
        rsp = uc.reg_read(UC_X86_REG_RSP)
        ra, out = self.q(rsp), self.q(rsp + 0x28)
        t = self.h.answer('text')
        self.h.wlog.append(('text', self.sstr(uc.reg_read(UC_X86_REG_R9)), t))
        if t is None:
            uc.reg_write(UC_X86_REG_RAX, 0)
        else:
            self.wstr(out, t, self.textbuf); uc.reg_write(UC_X86_REG_RAX, 1)
        uc.reg_write(UC_X86_REG_RSP, rsp + 8); uc.reg_write(UC_X86_REG_RIP, ra)

    def _message(self, uc, addr, size, ud):
        self.h.wlog.append(('message', uc.reg_read(UC_X86_REG_RCX) & 0xFFFFFFFF))

    # ---- commands
    def refresh(self):
        """the bank name control shows the current bank's name, as the live editor keeps it: the
        control's own update (vt+0xB0, rva 0x33F530); the template never draws"""
        self.h.call(IB + 0x33F530, rcx=self.bnc, count=500_000_000)

    def key(self, code, flags):
        self.refresh()
        self.uc.mem_write(self.msg, struct.pack('<iii', 1, code, flags))
        return self.h.call(IB + KEY_ACTION, rcx=self.lst, rdx=self.msg, count=8_000_000_000) & 0xFF

    def mouse(self, typ, x, y, flags=0):
        self.uc.mem_write(self.msg, struct.pack('<iiii', typ, x, y, flags))
        return self.h.call(IB + MOUSE, rcx=self.lst, rdx=self.msg, count=8_000_000_000) & 0xFF

    def bank_mouse(self, typ, x, y, flags=0):
        """the bank name control's mouse handler (its slot 9, rva 0x33F0A0)"""
        self.uc.mem_write(self.msg, struct.pack('<iiii', typ, x, y, flags))
        return self.h.call(IB + BANK_MOUSE, rcx=self.bnc, rdx=self.msg, count=8_000_000_000) & 0xFF

    def func(self, which, args):
        out, a = self.strs[0], self.strs[1]
        self.wstr(out, b''); self.wstr(a, args.encode())
        self.refresh()
        fn = MP_FN if which == 'ManagePatch' else MPB_FN
        self.h.call(IB + fn, rcx=self.strs[3], rdx=out, r8=a, r9=self.view, count=8_000_000_000)

    def model_set(self, pid, v):
        self.h.call(IB + 0x283DB0, rcx=self.model, rdx=self.recobj[pid], r8=v & 0xFFFFFFFF, r9=1)

    def save_all(self): return self.h.call(IB + SAVE_ALL, rcx=self.pm, count=8_000_000_000) & 0xFF

    def tick(self): self.h.call(IB + TICK, rcx=self.pm, count=8_000_000_000)

    # ---- the state
    def serialize(self):
        self.uc.mem_write(self.ser_vec, b'\0' * 24)
        self.h.call(IB + 0x335990, rcx=self.view, rdx=self.ser_vec, r8=0, r9=0, count=4_000_000_000)
        b, e = self.q(self.ser_vec), self.q(self.ser_vec + 8)
        return bytes(self.uc.mem_read(b, e - b))

    def view_values(self):
        o = self.q(self.q(self.view) + 0x80)
        out = []
        for slot in (0x50, 0x58):
            rec = self.h.call(self.q(self.q(o) + slot), rcx=o)
            out.append(self.h.call(self.q(self.q(rec) + 0x80), rcx=rec) & 0xFFFFFFFF if rec else None)
        return tuple(out)

    def vbytes(self, a):
        b, e = self.q(a), self.q(a + 8)
        return bytes(self.uc.mem_read(b, e - b)) if e > b else b''

    def snapshot(self, full=True):
        """the whole manager: every bank's every state (name, view given, edit image, records; with
        full=False the records of the current states only), the cursors, the selection, the
        clipboard, the format, the view's image and values"""
        pm = self.pm
        bb, be = self.q(pm + 0x38), self.q(pm + 0x40)
        banks = []
        for ent in range(bb, be, 48):
            mp, msz, off, size, cur = self.q(ent + 8), self.q(ent + 0x10), self.q(ent + 0x18), self.q(ent + 0x20), self.i4(ent + 0x28)
            states = []
            for i in range(size):
                st = self.q(mp + 8 * ((off + i) & (msz - 1)))
                gb, ge = self.q(st + 8), self.q(st + 0x10)
                recs = []
                if ge > gb and (full or i == cur):
                    rb, re_ = self.q(gb), self.q(gb + 8)
                    recs = [self.vbytes(r) for r in range(rb, re_, 24)]
                states.append((self.sstr(st + 0x20), 1 if self.q(st) else 0, self.vbytes(st + 0x40), recs))
            banks.append((cur, states))
        return dict(cur=self.i4(pm + 8), cur2=self.i4(pm + 0xC), sel=self.i4(pm + 0x10), clip=self.vbytes(pm + 0x50),
                    fmt=self.i4(IB + FORMAT_G), tick=self.i4(pm + 0x6C), banks=banks,
                    view=self.serialize(), values=self.view_values())


def digest(snap):
    """a compact, comparable form of a snapshot (record bytes as hashes)"""
    H_ = lambda b: hashlib.sha1(b).hexdigest()[:16]
    return dict(cur=snap['cur'], cur2=snap['cur2'], sel=snap['sel'], clip=H_(snap['clip']), fmt=snap['fmt'], tick=snap['tick'],
                view=H_(snap['view']), values=snap['values'],
                banks=[(c, [(n, v, H_(e), [H_(r) for r in recs]) for n, v, e, recs in sts]) for c, sts in snap['banks']])
