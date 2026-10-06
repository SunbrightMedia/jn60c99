"""wrapper_emu.py -- the JUNO-60 plugin booted the way a VST3 host boots it, under
Unicorn: LoadLibrary (DllMain, which runs the C runtime and all 844 C++ static
initializers), InitDll (the module init that reads the plugin's own data files),
GetPluginFactory / createInstance, IComponent::initialize. Built for CLAIMS B6
(what a preset load hands the engine), on top of tools/verify/e2e_emu.py.

PLUMBING ONLY. Nothing here reimplements plugin logic. It gives the plugin the
operating system it expects:
  * a TEB with a real TLS block (the PE's TLS template; _Init_thread_epoch at +24),
    without which every C++ magic static looked "already constructed" and was used
    uninitialised (the 2026-07 P112 wall: a CRT abort in a magic-static parse);
  * Win32 calls the CRT and the module init need (OS version, system info,
    InitOnceExecuteOnce, GetProcAddress -> named stubs, string conversions);
  * a read-only file system with ONE file: truth/Script.xml (the plugin's own
    "Koa Script", allowed plugin data), in the folder the plugin looks in
    (C:\\ProgramData\\Roland Cloud\\JUNO-60), plus an empty user folder;
  * the few Shell objects the plugin lists that folder with (IShellFolder,
    IEnumIDList, IMalloc) -- well-formed ITEMIDLISTs, so the plugin's own pidl
    code (size walk, combine) runs unchanged.
Everything else keeps e2e_emu's default (unknown imports return 0).
"""
import os, sys, struct, collections
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'tools', 'verify'))
import e2e_emu as E
import truth as _truth
from unicorn import UC_HOOK_CODE, UC_PROT_ALL
from unicorn.x86_const import (UC_X86_REG_RAX, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                               UC_X86_REG_R9, UC_X86_REG_RSP, UC_X86_REG_RIP, UC_X86_REG_GS_BASE)

IB = E.IB
TEB = 0x580000000                      # free: heap ends at 0x510000000
COM = 0x5A0000000                      # fake COM objects + pidls
DYN = E.STUB_BASE + 0x4000             # named stubs for GetProcAddress / COM methods
DYN_END = E.STUB_BASE + 0x7FF0
DLLMAIN, INITDLL, FACTORY = IB + 0x67697C, IB + 0x3C9740, IB + 0x348B40
CREATE_PROC = IB + 0x349CA0            # CVstProcessor::createInstance -> IAudioProcessor (class + 272)
TLS_TEMPLATE, TLS_INDEX = (0xB2C058, 0xB2C074), 0xCB6338
DATA_DIR = 'C:\\ProgramData\\Roland Cloud\\JUNO-60'
USER_DIR = 'C:\\Users\\u\\AppData\\Local\\Roland Cloud\\JUNO-60'
MODPATH = 'C:\\Program Files\\Common Files\\VST3\\JUNO-60.vst3\\Contents\\x86_64-win\\JUNO-60.vst3'
SCRIPT_DIR = MODPATH.rsplit('\\', 1)[0] + '\\Script'     # where the module init looks for Script.xml (MEASURED)
S_OK, S_FALSE, E_FAIL, E_NOINTERFACE, E_NOTFOUND = 0, 1, 0x80004005, 0x80004002, 0x80070002


def skin_sizes(script_xml):
    """Blank-image geometry for every <bitmap> of the plugin's Script.xml: one state is as large
    as the largest control drawing it (the GUI refuses a state smaller than its draw area,
    rva 0x2C95C0), states stacked along x for <direction>1, along y otherwise. Plumbing: the
    skin images are not supplied and never reach the engine."""
    import re
    x = script_xml.decode('utf-8', 'replace')
    states = {}
    for m in re.finditer(r'<bitmap>(.*?)</bitmap>', x, re.S):
        b = m.group(1)
        nm = re.search(r'<name>(.*?)</name>', b).group(1).strip().lower()
        sc = re.search(r'<stateCount>(\d+)</stateCount>', b); d = re.search(r'<direction>(\d+)</direction>', b)
        states[nm] = (int(sc.group(1)) if sc else 1, int(d.group(1)) if d else 0)
    need, cap = {}, {}
    for m in re.finditer(r'<bitmapRef>(.*?)</bitmapRef>', x):
        nm = m.group(1).strip().lower()
        s0 = max(x.rfind('<control>', 0, m.start()), x.rfind('<panel>', 0, m.start()), x.rfind('<rootPanel>', 0, m.start()))
        e0 = min([i for i in (x.find('</control>', m.end()), x.find('</panel>', m.end()), x.find('<control>', m.end())) if i > 0])
        blk = x[s0:e0]
        sz = re.search(r'<size>(\d+),(\d+)</size>', blk)
        w, h = (int(sz.group(1)), int(sz.group(2))) if sz else (16, 16)
        if re.search(r'<type>slider', blk):      # a slider's bitmap is its KNOB: smaller than the control (rva 0x2D...)
            a, b = cap.get(nm, (1 << 30, 1 << 30)); cap[nm] = (min(a, w), min(b, h))
        else:
            a, b = need.get(nm, (16, 16)); need[nm] = (max(a, w), max(b, h))
    out = {}
    for nm, (sc, d) in states.items():
        if nm in cap:
            w, h = max(1, cap[nm][0] - 2), max(1, cap[nm][1] // 4)
        else:
            w, h = need.get(nm, (16, 16))
        out[nm] = (w * sc, h) if d == 1 else (w, h * sc)
    return out


def _norm(p):
    p = p.replace('/', '\\')
    while p.endswith('\\') and len(p) > 3:
        p = p[:-1]
    return p


class Wrapper(E.E2E):
    def __init__(self):
        super().__init__()
        uc = self.uc
        uc.mem_map(TEB, 0x10000, UC_PROT_ALL)
        tlsarr, tlsblk = TEB + 0x2000, TEB + 0x3000
        uc.mem_write(TEB + 0x30, struct.pack('<Q', TEB))
        uc.mem_write(TEB + 0x58, struct.pack('<Q', tlsarr))
        uc.mem_write(TEB + 0x60, struct.pack('<Q', TEB + 0x4000))
        uc.mem_write(tlsarr, struct.pack('<Q', tlsblk))
        uc.mem_write(tlsblk, bytes(E.IMG[TLS_TEMPLATE[0]:TLS_TEMPLATE[1]]))
        uc.mem_write(IB + TLS_INDEX, struct.pack('<I', 0))
        uc.reg_write(UC_X86_REG_GS_BASE, TEB)
        uc.mem_map(COM, 0x400000, UC_PROT_ALL)
        self.com_next = COM
        self.dyn_next, self.dyn = DYN, {}
        uc.hook_add(UC_HOOK_CODE, self._imp, begin=DYN, end=DYN_END)
        self.fls, self.fls_ctr, self.once = {}, 1, set()
        self.calls = collections.Counter()
        self.fslog, self.handles, self.finds = [], {}, {}
        self.lasterr = 0
        script = open(_truth.SCRIPT_XML, 'rb').read()
        # TextCodeTable.dat (GUI message strings; not supplied) is served EMPTY: the module init
        # requires it to open, and nothing in it reaches the engine.
        self.files = {_norm(SCRIPT_DIR + '\\Script.xml').lower(): script,
                      _norm(SCRIPT_DIR + '\\TextCodeTable.dat').lower(): b''}
        self.dirs = {_norm(DATA_DIR).lower(): [], _norm(USER_DIR).lower(): [],
                     _norm(SCRIPT_DIR).lower(): ['Script.xml', 'TextCodeTable.dat']}
        self.skin = skin_sizes(script)
        self.objs = {}                    # fake COM object address -> dict
        self.pidl_names = []              # item code -> name
        self.vt = {k: self._vtable(k, n) for k, n in (('folder', 13), ('enum', 7), ('malloc', 9), ('stream', 8), ('hostctx', 16), ('handler', 10),
                                                            ('message', 8), ('attrs', 12))}
        self.edits = []                   # IComponentHandler calls the plugin makes: (method, id, value)
        self.messages = []

    # ---------------------------------------------------------------- helpers
    def named_stub(self, nm):
        if nm not in self.dyn:
            st = self.dyn_next; self.dyn_next += 8
            assert self.dyn_next < DYN_END
            self.uc.mem_write(st, b'\xC3'); self.dyn[nm] = st; self.stub2name[st] = ('dyn', nm)
        return self.dyn[nm]

    def _vtable(self, kind, n):
        vt = self.alloc_com(8 * n)
        self.uc.mem_write(vt, b''.join(struct.pack('<Q', self.named_stub('COM:%s:%d' % (kind, i))) for i in range(n)))
        return vt

    def alloc_com(self, n):
        p = self.com_next; self.com_next += (n + 15) & ~15
        return p

    def new_obj(self, kind, **kw):
        p = self.alloc_com(16)
        self.uc.mem_write(p, struct.pack('<Q', self.vt[kind]))
        self.objs[p] = dict(kind=kind, **kw)
        return p

    def pidl(self, names):
        """a well-formed ITEMIDLIST: one 10-byte item per name (cb, 8-byte code), then cb=0"""
        body = b''
        for nm in names:
            self.pidl_names.append(nm)
            body += struct.pack('<HQ', 10, len(self.pidl_names) - 1)
        p = self.alloc_com(len(body) + 2)
        self.uc.mem_write(p, body + b'\0\0')
        return p

    def pidl_read(self, p):
        out = []
        while True:
            cb = struct.unpack('<H', self.uc.mem_read(p, 2))[0]
            if cb == 0:
                return out
            code = struct.unpack('<Q', self.uc.mem_read(p + 2, 8))[0]
            out.append(self.pidl_names[code]); p += cb

    def rstr(self, a, wide):
        b = bytes(self.uc.mem_read(a, 1200))
        if wide:
            k = 0
            while b[k:k + 2] != b'\0\0': k += 2
            return b[:k].decode('utf-16le', 'replace')
        return b.split(b'\0')[0].decode('latin1')

    def wstr(self, a, txt, wide):
        self.uc.mem_write(a, (txt.encode('utf-16le') + b'\0\0') if wide else (txt.encode('latin1') + b'\0'))

    def is_dir(self, path):
        return _norm(path).lower() in self.dirs or any(d.startswith(_norm(path).lower() + '\\') for d in self.dirs)

    def file(self, path):
        return self.files.get(_norm(path).lower())

    def stack_arg(self, k):
        """Win64 argument k (0-based) at a stub entry: [rsp + 8 + 8k]"""
        rsp = self.uc.reg_read(UC_X86_REG_RSP)
        return struct.unpack('<Q', self.uc.mem_read(rsp + 8 + 8 * k, 8))[0]

    # ---------------------------------------------------------------- imports
    def _imp(self, uc, address, size, user):
        if address not in self.stub2name:
            return
        dll, name = self.stub2name[address]
        self.calls[name] += 1
        rcx, rdx = uc.reg_read(UC_X86_REG_RCX), uc.reg_read(UC_X86_REG_RDX)
        r8, r9 = uc.reg_read(UC_X86_REG_R8), uc.reg_read(UC_X86_REG_R9)
        ret = lambda v: self._ret(uc, v)
        if name.startswith('COM:'):
            return self._com(uc, name, rcx, rdx, r8, r9)
        if name in ('EncodePointer', 'DecodePointer', 'EncodeSystemPointer', 'DecodeSystemPointer'):
            return ret(rcx)
        if name == 'IsProcessorFeaturePresent': return ret(1)
        if name == 'IsDebuggerPresent': return ret(0)
        if name == 'FlsAlloc': i = self.fls_ctr; self.fls_ctr += 1; return ret(i)
        if name == 'FlsSetValue': self.fls[rcx] = rdx; return ret(1)
        if name == 'FlsGetValue': return ret(self.fls.get(rcx, 0))
        if name == 'FlsFree': return ret(1)
        if name in ('GetModuleHandleW', 'GetModuleHandleA'): return ret(IB)
        if name in ('GetVersionExW', 'GetVersionExA'):
            uc.mem_write(rcx + 4, struct.pack('<IIII', 10, 0, 19041, 2)); return ret(1)
        if name in ('GetSystemInfo', 'GetNativeSystemInfo'):
            uc.mem_write(rcx, struct.pack('<HHIQQQIIIHH', 9, 0, 4096, 0x10000, 0x7FFFFFFEFFFF, 1, 1, 8664, 0x10000, 6, 0))
            return ret(0)
        if name == 'GetProcessAffinityMask':
            uc.mem_write(rdx, struct.pack('<Q', 1)); uc.mem_write(r8, struct.pack('<Q', 1)); return ret(1)
        if name == 'GetNumaHighestNodeNumber': uc.mem_write(rcx, struct.pack('<I', 0)); return ret(1)
        if name.startswith('Initialize') or name in ('InitCommonControlsEx', 'AcquireSRWLockExclusive',
                'ReleaseSRWLockExclusive', 'AcquireSRWLockShared', 'ReleaseSRWLockShared',
                'WakeAllConditionVariable', 'WakeConditionVariable', 'MakeSureDirectoryPathExists'):
            return ret(1)
        if name == 'InitOnceExecuteOnce':          # run the init callback once; it returns to our caller
            if rcx in self.once: return ret(1)
            self.once.add(rcx)
            uc.reg_write(UC_X86_REG_RDX, r8); uc.reg_write(UC_X86_REG_R8, r9); uc.reg_write(UC_X86_REG_RIP, rdx)
            return
        if name == 'GetProcAddress':
            if rdx < 0x10000: return ret(0)
            return ret(self.named_stub(self.rstr(rdx, False)))
        if name == 'GetLastError': return ret(self.lasterr)
        if name == 'SetLastError': self.lasterr = rcx & 0xFFFFFFFF; return ret(0)
        if name in ('GetModuleFileNameA', 'GetModuleFileNameW'):
            self.wstr(rdx, MODPATH, name.endswith('W')); return ret(len(MODPATH))
        if name in ('SHGetFolderPathA', 'SHGetFolderPathW'):
            path = {0x23: 'C:\\ProgramData', 0x1c: 'C:\\Users\\u\\AppData\\Local', 0x1a: 'C:\\Users\\u\\AppData\\Roaming',
                    0x05: 'C:\\Users\\u\\Documents', 0x2e: 'C:\\Users\\Public\\Documents'}.get(rdx & 0xFF, 'C:\\X%02x' % (rdx & 0xFF))
            self.wstr(self.stack_arg(4), path, name.endswith('W')); return ret(S_OK)
        if name == 'MultiByteToWideChar':
            outp, outn, n = self.stack_arg(4), self.stack_arg(5) & 0xFFFFFFFF, r9 & 0xFFFFFFFF
            if getattr(self, 'debug', False): print('MB2WC', hex(r8), repr(self.rstr(r8, False)[:80]), n, hex(outp), outn)
            src = (self.rstr(r8, False) + '\0') if n == 0xFFFFFFFF else bytes(uc.mem_read(r8, n)).decode('latin1')
            w = src.encode('utf-16le')
            if outn == 0: return ret(len(w) // 2)
            uc.mem_write(outp, w[:2 * outn]); return ret(min(len(w) // 2, outn))
        if name == 'WideCharToMultiByte':
            outp, outn, n = self.stack_arg(4), self.stack_arg(5) & 0xFFFFFFFF, r9 & 0xFFFFFFFF
            src = (self.rstr(r8, True) + '\0') if n == 0xFFFFFFFF else bytes(uc.mem_read(r8, 2 * n)).decode('utf-16le', 'replace')
            a = src.encode('latin1', 'replace')
            if outn == 0: return ret(len(a))
            uc.mem_write(outp, a[:outn]); return ret(min(len(a), outn))
        if name in ('GetFullPathNameA', 'GetFullPathNameW'):
            wide = name.endswith('W'); path = self.rstr(rcx, wide).replace('/', '\\')
            if (rdx & 0xFFFFFFFF) <= len(path): return ret(len(path) + 1)
            self.wstr(r8, path, wide)
            if r9: uc.mem_write(r9, struct.pack('<Q', 0))
            return ret(len(path))
        if name in ('MessageBoxA', 'MessageBoxW'):
            self.fslog.append((name, self.rstr(rdx, name.endswith('W')))); return ret(1)
        # ---- GDI+: the GUI (view manager) loads its skin images. Not supplied, not engine state:
        # every image is a blank 32bpp ARGB bitmap, every call succeeds (Status Ok).
        if name.startswith('Gdip') or name.startswith('Gdiplus'):
            return self._gdip(uc, name, rcx, rdx, r8, r9)
        # ---- GDI bitmaps the GUI copies its images into (blank memory, real geometry)
        if name == 'CreateDIBSection':
            bi = bytes(uc.mem_read(rdx, 16)); w_, h_, planes, bpp = struct.unpack('<iiHH', bi[4:16])
            stride = ((abs(w_) * bpp + 31) // 32) * 4; size_ = max(stride * abs(h_), 16)
            bits = self.bump(size_); uc.mem_write(bits, b'\0' * size_)
            hb = 0xB0000 + 0x10 * len(self.__dict__.setdefault('dibs', {}))
            self.dibs[hb] = (w_, h_, bpp, stride, bits)
            if r9: uc.mem_write(r9, struct.pack('<Q', bits))
            return ret(hb)
        if name in ('GetObjectA', 'GetObjectW'):
            d = self.__dict__.get('dibs', {}).get(rcx)
            if d is None: return ret(0)
            w_, h_, bpp, stride, bits = d
            bm = struct.pack('<iiiiHHIQ', 0, w_, abs(h_), stride, 1, bpp, 0, bits)
            if (rdx & 0xFFFFFFFF) >= 104:
                bm += struct.pack('<IiiHHIIiiII', 40, w_, h_, 1, bpp, 0, stride * abs(h_), 0, 0, 0, 0) + b'\0' * 12 + struct.pack('<QI', 0, 0)
                uc.mem_write(r8, bm[:104]); return ret(104)
            uc.mem_write(r8, bm[:32]); return ret(32)
        if name in ('SelectObject',): return ret(0x77770)
        if name in ('DeleteObject', 'DeleteDC', 'ReleaseDC'): return ret(1)
        # ---- shell: the plugin lists folders through IShellFolder
        if name == 'SHGetDesktopFolder':
            uc.mem_write(rcx, struct.pack('<Q', self.new_obj('folder', path=''))); return ret(S_OK)
        if name == 'SHGetMalloc':
            uc.mem_write(rcx, struct.pack('<Q', self.new_obj('malloc'))); return ret(S_OK)
        if name in ('SHGetPathFromIDListA', 'SHGetPathFromIDListW'):
            names = self.pidl_read(rcx)
            path = '\\'.join(names) if names else ''
            self.wstr(rdx, path, name.endswith('W')); return ret(1 if names else 0)
        if name in ('AllocateAndInitializeSid', 'FlushInstructionCache', 'LoadCursorA', 'LoadCursorW'): return ret(1)
        if name in ('RegisterClassExA', 'RegisterClassExW', 'RegisterClassA', 'RegisterClassW'): return ret(0xC001)
        if name == 'InterlockedPushEntrySList':          # the list lives on the Python side; entry->Next kept in memory
            lst = self.__dict__.setdefault('slists', {}).setdefault(rcx, [])
            old = lst[-1] if lst else 0
            uc.mem_write(rdx, struct.pack('<Q', old)); lst.append(rdx); return ret(old)
        if name == 'InterlockedPopEntrySList':
            lst = self.__dict__.setdefault('slists', {}).setdefault(rcx, [])
            return ret(lst.pop() if lst else 0)
        if name == 'InterlockedFlushSList':
            lst = self.__dict__.setdefault('slists', {}).setdefault(rcx, [])
            top = lst[-1] if lst else 0; lst.clear(); return ret(top)
        if name in ('SetEntriesInAclA', 'SetEntriesInAclW', 'SetNamedSecurityInfoA', 'SetNamedSecurityInfoW'): return ret(0)
        # ---- files
        if name in ('GetFileAttributesA', 'GetFileAttributesW'):
            path = self.rstr(rcx, name.endswith('W')); self.fslog.append((name, path))
            if self.file(path) is not None: return ret(0x80)
            if self.is_dir(path): return ret(0x10)
            self.lasterr = 2; return ret(0xFFFFFFFF)
        if name in ('GetFileAttributesExA', 'GetFileAttributesExW'):
            path = self.rstr(rcx, name.endswith('W')); self.fslog.append((name, path)); f = self.file(path)
            if f is None and not self.is_dir(path): self.lasterr = 2; return ret(0)
            uc.mem_write(r8, struct.pack('<I', 0x10 if f is None else 0x80) + b'\0' * 24 + struct.pack('<II', 0, len(f or b'')))
            return ret(1)
        if name in ('CreateFileA', 'CreateFileW'):
            path = self.rstr(rcx, name.endswith('W')); f = self.file(path); self.fslog.append((name, path, f is not None))
            if f is None: self.lasterr = 2; return ret(0xFFFFFFFFFFFFFFFF)
            h = 0x7000 + 4 * len(self.handles); self.handles[h] = [f, 0]; return ret(h)
        if name in ('FindFirstFileA', 'FindFirstFileW', 'FindFirstFileExA', 'FindFirstFileExW'):
            wide = name.endswith('W')
            pat = self.rstr(rcx, wide); d = _norm(pat.replace('/', '\\').rsplit('\\', 1)[0]).lower()
            self.fslog.append((name, pat))
            if d not in self.dirs: self.lasterr = 2; return ret(0xFFFFFFFFFFFFFFFF)
            ents = ['.', '..'] + self.dirs[d]
            h = 0x9000 + 4 * len(self.finds); self.finds[h] = [ents, 1, wide, d]
            self._fill_find(r8 if 'Ex' in name else rdx, d, ents[0], wide); return ret(h)
        if name in ('FindNextFileA', 'FindNextFileW'):
            f = self.finds.get(rcx)
            if not f or f[1] >= len(f[0]): self.lasterr = 18; return ret(0)
            self._fill_find(rdx, f[3], f[0][f[1]], f[2]); f[1] += 1; return ret(1)
        if name == 'FindClose': self.finds.pop(rcx, None); return ret(1)
        if name == 'ReadFile':
            hd = self.handles.get(rcx)
            if hd is None: return ret(0)
            data, pos = hd; n = max(0, min(r8, len(data) - pos))
            if n: uc.mem_write(rdx, data[pos:pos + n])
            hd[1] = pos + n
            if r9: uc.mem_write(r9, struct.pack('<I', n))
            return ret(1)
        if name == 'GetFileSize':
            hd = self.handles.get(rcx)
            if rdx: uc.mem_write(rdx, struct.pack('<I', 0))
            return ret(len(hd[0]) if hd else 0xFFFFFFFF)
        if name == 'GetFileSizeEx':
            hd = self.handles.get(rcx); uc.mem_write(rdx, struct.pack('<Q', len(hd[0]) if hd else 0)); return ret(1 if hd else 0)
        if name in ('SetFilePointer', 'SetFilePointerEx'):
            hd = self.handles.get(rcx)
            if hd is None: return ret(0xFFFFFFFF)
            if name == 'SetFilePointerEx':
                dist = rdx - (1 << 64) if rdx >= 1 << 63 else rdx
            else:
                dist = rdx & 0xFFFFFFFF; dist = dist - (1 << 32) if dist >= 1 << 31 else dist
            hd[1] = {0: 0, 1: hd[1], 2: len(hd[0])}[r9 & 3] + dist
            if name == 'SetFilePointerEx':
                if r8: uc.mem_write(r8, struct.pack('<Q', hd[1]))
                return ret(1)
            return ret(hd[1])
        if name == 'GetFileType': return ret(1)
        if name == 'CloseHandle': self.handles.pop(rcx, None); return ret(1)
        return super()._imp(uc, address, size, user)

    def _gdip(self, uc, name, rcx, rdx, r8, r9):
        ret = lambda v: self._ret(uc, v)
        imgs = self.__dict__.setdefault('gdip_imgs', {})
        def new_img(w=64, h=64, fmt=0x26200A):
            hnd = self.alloc_com(32); imgs[hnd] = dict(w=w, h=h, fmt=fmt); return hnd
        def out(a, v, fmt='<Q'): uc.mem_write(a, struct.pack(fmt, v))
        if name == 'GdiplusStartup': out(rcx, 1); return ret(0)
        if name == 'GdipAlloc': return ret(self.alloc_com(max(rcx, 16)))
        if name in ('GdipCreateBitmapFromFile', 'GdipCreateBitmapFromFileICM'):
            fn = self.rstr(rcx, True); w_, h_ = self.skin.get(fn.replace('\\', '/').rsplit('/', 1)[-1].lower(), (16, 16))
            self.fslog.append((name, fn, w_, h_)); out(rdx, new_img(w_, h_)); return ret(0)
        if name == 'GdipCreateBitmapFromHBITMAP': out(r8, new_img()); return ret(0)
        if name == 'GdipCreateBitmapFromScan0':
            out(self.stack_arg(5), new_img(rcx & 0xFFFFFFFF, rdx & 0xFFFFFFFF, r9 & 0xFFFFFFFF)); return ret(0)
        if name == 'GdipCloneImage':
            i = imgs.get(rcx, dict(w=64, h=64, fmt=0x26200A)); out(rdx, new_img(i['w'], i['h'], i['fmt'])); return ret(0)
        if name in ('GdipGetImageWidth', 'GdipGetImageHeight', 'GdipGetImagePixelFormat'):
            i = imgs.get(rcx, dict(w=64, h=64, fmt=0x26200A))
            out(rdx, i['w'] if 'Width' in name else i['h'] if 'Height' in name else i['fmt'], '<I'); return ret(0)
        if name == 'GdipGetImagePaletteSize': out(rdx, 8, '<i'); return ret(0)
        if name == 'GdipGetImagePalette': uc.mem_write(rdx, b'\0' * 8); return ret(0)
        if name == 'GdipBitmapLockBits':
            i = imgs.get(rcx, dict(w=64, h=64, fmt=0x26200A))
            buf = self.bump(i['w'] * i['h'] * 4 + 16); uc.mem_write(buf, b'\0' * (i['w'] * i['h'] * 4))
            data = self.stack_arg(4)
            uc.mem_write(data, struct.pack('<IIiIQQ', i['w'], i['h'], i['w'] * 4, i['fmt'], buf, 0)); return ret(0)
        if name in ('GdipGetImageGraphicsContext', 'GdipCreateFromHDC', 'GdipCreatePath', 'GdipCreateSolidFill', 'GdipCloneBrush'):
            out(rdx, self.alloc_com(32)); return ret(0)
        if name == 'GdipCreatePen1': out(self.stack_arg(3), self.alloc_com(32)); return ret(0)
        if name == 'GdipCreateLineBrushI': out(self.stack_arg(5), self.alloc_com(32)); return ret(0)
        if name == 'GdipGetSmoothingMode': out(rdx, 0, '<i'); return ret(0)
        if name == 'GdipGetImageEncodersSize': out(rcx, 0, '<I'); out(rdx, 0, '<I'); return ret(0)
        return ret(0)

    def _fill_find(self, out, d, nm, wide):
        f = self.files.get(d + '\\' + nm.lower())
        attr = 0x80 if f is not None else 0x10
        hdr = struct.pack('<I', attr) + b'\0' * 24 + struct.pack('<IIII', 0, len(f or b''), 0, 0)
        self.uc.mem_write(out, hdr + ((nm.encode('utf-16le') + b'\0\0') if wide else (nm.encode('latin1') + b'\0')))

    # ---------------------------------------------------------------- COM
    def _com(self, uc, name, this, a1, a2, a3):
        _, kind, slot = name.split(':'); slot = int(slot)
        o = self.objs.get(this, {})
        if getattr(self, 'debug', False):
            ra = struct.unpack('<Q', uc.mem_read(uc.reg_read(UC_X86_REG_RSP), 8))[0]
            print('COM %s slot %d this 0x%x (%r) ret 0x%x' % (kind, slot, this, o.get('path', o.get('names')), ra - IB))
        ret = lambda v: self._ret(uc, v)
        if slot == 0:                                        # queryInterface(iid, obj)
            iid = bytes(uc.mem_read(a1, 16))
            if (kind, iid) in (('hostctx', IID_IHOSTAPPLICATION), ('message', IID_IMESSAGE), ('attrs', IID_IATTRIBUTELIST),
                               ('handler', IID_ICOMPONENTHANDLER), ('stream', IID_IBSTREAM)):
                uc.mem_write(a2, struct.pack('<Q', this)); return ret(S_OK)
            uc.mem_write(a2, struct.pack('<Q', 0)); return ret(E_NOINTERFACE)
        if slot in (1, 2): return ret(1)
        if kind == 'malloc':
            if slot == 3:                                    # Alloc(cb)
                p = self.alloc_com(max(int(a1), 16)); return ret(p)
            if slot == 4: return ret(self.alloc_com(max(int(a2), 16)))   # Realloc
            return ret(0)                                    # Free / GetSize / DidAlloc / HeapMinimize
        if kind == 'hostctx':                                # IHostApplication
            if slot == 3:                                    # getName(String128)
                uc.mem_write(a1, 'emu'.encode('utf-16le') + b'\0\0'); return ret(S_OK)
            if slot == 4:                                    # createInstance(cid, iid, obj)
                iid = bytes(uc.mem_read(a2, 16))
                if iid == IID_IMESSAGE:
                    m = self.new_obj('message', id=0, attrs=self.new_obj('attrs', vals={}))
                    uc.mem_write(a3, struct.pack('<Q', m)); return ret(S_OK)
                if iid == IID_IATTRIBUTELIST:
                    uc.mem_write(a3, struct.pack('<Q', self.new_obj('attrs', vals={}))); return ret(S_OK)
                uc.mem_write(a3, struct.pack('<Q', 0)); return ret(E_NOINTERFACE)
            return ret(0x80004001)
        if kind == 'message':                                # IMessage
            if slot == 3: return ret(o['id'])                # getMessageID -> FIDString
            if slot == 4:                                    # setMessageID(FIDString): keep a copy
                txt = self.rstr(a1, False).encode('latin1') + b'\0'
                p = self.alloc_com(len(txt)); uc.mem_write(p, txt); o['id'] = p
                self.messages.append(('set', txt[:-1].decode('latin1'), this)); return ret(S_OK)
            if slot == 5: return ret(o['attrs'])             # getAttributes
            return ret(E_FAIL)
        if kind == 'attrs':                                  # IAttributeList
            key = self.rstr(a1, False); v = o['vals']
            if slot == 3: v[key] = ('i', a2); return ret(S_OK)                       # setInt(id, int64)
            if slot == 4:
                if key not in v: return ret(S_FALSE)
                uc.mem_write(a2, struct.pack('<Q', v[key][1] & 0xFFFFFFFFFFFFFFFF)); return ret(S_OK)
            if slot == 5:
                from unicorn.x86_const import UC_X86_REG_XMM2
                v[key] = ('f', uc.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFFFFFFFFFF); return ret(S_OK)
            if slot == 6:
                if key not in v: return ret(S_FALSE)
                uc.mem_write(a2, struct.pack('<Q', v[key][1])); return ret(S_OK)
            if slot == 7: v[key] = ('s', self.rstr(a2, True)); return ret(S_OK)
            if slot == 8:
                if key not in v: return ret(S_FALSE)
                uc.mem_write(a2, (v[key][1].encode('utf-16le') + b'\0\0')[:max(2, a3 & 0xFFFFFFFF)]); return ret(S_OK)
            if slot == 9:                                    # setBinary(id, data, size)
                n = a3 & 0xFFFFFFFF; b = bytes(uc.mem_read(a2, n)) if n else b''
                p = self.alloc_com(max(n, 16)); uc.mem_write(p, b); v[key] = ('b', p, n); return ret(S_OK)
            if slot == 10:                                   # getBinary(id, const void*&, uint32&)
                if key not in v: return ret(S_FALSE)
                uc.mem_write(a2, struct.pack('<Q', v[key][1])); uc.mem_write(a3, struct.pack('<I', v[key][2])); return ret(S_OK)
            return ret(E_FAIL)
        if kind == 'handler':                                # IComponentHandler: record, accept
            from unicorn.x86_const import UC_X86_REG_XMM2
            meth = {3: 'beginEdit', 4: 'performEdit', 5: 'endEdit', 6: 'restartComponent'}.get(slot, 'slot%d' % slot)
            val = None
            if slot == 4:                                    # performEdit(id, ParamValue in xmm2)
                val = struct.unpack('<d', struct.pack('<Q', uc.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFFFFFFFFFF))[0]
            self.edits.append((meth, a1 & 0xFFFFFFFF, val))
            return ret(0)
        if kind == 'stream':                                 # IBStream over o['data'] (bytearray), o['pos']
            if slot == 3:                                    # read(buffer, numBytes, numBytesRead*)
                n = max(0, min(a2 & 0xFFFFFFFF, len(o['data']) - o['pos']))
                uc.mem_write(a1, bytes(o['data'][o['pos']:o['pos'] + n])); o['pos'] += n
                if a3: uc.mem_write(a3, struct.pack('<i', n))
                return ret(0)
            if slot == 4:                                    # write(buffer, numBytes, numBytesWritten*)
                n = a2 & 0xFFFFFFFF; b = bytes(uc.mem_read(a1, n)) if n else b''
                o['data'][o['pos']:o['pos'] + n] = b; o['pos'] += n
                if a3: uc.mem_write(a3, struct.pack('<i', n))
                return ret(0)
            if slot == 5:                                    # seek(pos, mode, result*)
                pos = a1 - (1 << 64) if a1 >= 1 << 63 else a1
                o['pos'] = {0: 0, 1: o['pos'], 2: len(o['data'])}[a2 & 3] + pos
                if a3: uc.mem_write(a3, struct.pack('<q', o['pos']))
                return ret(0)
            if slot == 6:                                    # tell(pos*)
                uc.mem_write(a1, struct.pack('<q', o['pos'])); return ret(0)
            return ret(E_FAIL)
        if kind == 'enum':
            if slot == 3:                                    # Next(celt, rgelt, pceltFetched)
                if o['i'] >= len(o['names']):
                    if a3: uc.mem_write(a3, struct.pack('<I', 0))
                    return ret(S_FALSE)
                uc.mem_write(a2, struct.pack('<Q', self.pidl([o['names'][o['i']]]))); o['i'] += 1
                if a3: uc.mem_write(a3, struct.pack('<I', 1))
                return ret(S_OK)
            if slot == 5: o['i'] = 0; return ret(S_OK)      # Reset
            return ret(E_FAIL)
        # folder
        if slot == 3:                                        # ParseDisplayName(hwnd, pbc, name, eaten, ppidl, attrs)
            path = _norm(self.rstr(a3, True))
            if getattr(self, 'debug', False): print('PDN raw', bytes(uc.mem_read(a3, 64)))
            if not path.startswith(('C:', 'c:')) and o['path']: path = o['path'] + '\\' + path
            self.fslog.append(('ParseDisplayName', path))
            if self.file(path) is None and not self.is_dir(path): return ret(E_NOTFOUND)
            uc.mem_write(self.stack_arg(5), struct.pack('<Q', self.pidl([path])))
            return ret(S_OK)
        if slot == 4:                                        # EnumObjects(hwnd, flags, ppenum)
            uc.mem_write(a3, struct.pack('<Q', self.new_obj('enum', names=list(self.dirs.get(o['path'].lower(), [])), i=0)))
            return ret(S_OK)
        if slot == 5:                                        # BindToObject(pidl, pbc, riid, ppv)
            names = self.pidl_read(a1)
            path = '\\'.join(([o['path']] if o['path'] else []) + names)
            uc.mem_write(self.stack_arg(4), struct.pack('<Q', self.new_obj('folder', path=_norm(path))))
            return ret(S_OK)
        if slot == 9:                                        # GetAttributesOf(cidl, apidl, rgfInOut)
            nm = self.pidl_read(struct.unpack('<Q', uc.mem_read(a2, 8))[0])[-1]
            full = (o['path'] + '\\' + nm) if o['path'] else nm
            uc.mem_write(a3, struct.pack('<I', 0x40000000 | (0x20000000 if self.is_dir(full) else 0)))
            return ret(S_OK)
        if slot == 11:                                       # GetDisplayNameOf(pidl, flags, STRRET*) -> STRRET_CSTR
            names = self.pidl_read(a1)
            nm = names[-1].split('\\')[-1] if names else ''
            uc.mem_write(a3, struct.pack('<II', 2, 0) + nm.encode('latin1') + b'\0')
            return ret(S_OK)
        return ret(E_FAIL)

    def stream(self, data=b''):
        return self.new_obj('stream', data=bytearray(data), pos=0)

    # ---------------------------------------------------------------- host boot
    def boot(self, log=print):
        """LoadLibrary + InitDll + createInstance + IComponent::initialize. Returns the class base."""
        r = self.call(DLLMAIN, rcx=IB, rdx=1, r8=0, count=3_000_000_000)
        log('DllMain(PROCESS_ATTACH) -> %d' % r)
        assert r == 1, 'DllMain failed'
        r = self.call(INITDLL, rcx=IB, count=3_000_000_000) & 0xFF
        log('InitDll -> %d' % r)
        assert r == 1, 'InitDll failed: %r' % self.fslog[-3:]
        ap = self.call(CREATE_PROC, count=200_000_000)
        self.base = ap - 272                      # createInstance returns the IAudioProcessor sub-object
        self.comp = self.base + 48                # IComponent
        self.audio = ap
        self.core = self.base + 0x148             # the processor's wrapper core (vtable 0x9679C8)
        ctx = self.new_obj('hostctx')
        r = self.call(IB + 0x34A110, rcx=self.comp, rdx=ctx, count=4_000_000_000) & 0xFFFFFFFF
        log('IComponent::initialize -> 0x%x' % r)
        assert r == 0, 'initialize failed'
        return self.base

    def vcall(self, obj, slot, *args, count=2_000_000_000):
        vt = struct.unpack('<Q', self.uc.mem_read(obj, 8))[0]
        fn = struct.unpack('<Q', self.uc.mem_read(vt + 8 * slot, 8))[0]
        a = list(args) + [0] * (3 - len(args))
        return self.call(fn, rcx=obj, rdx=a[0], r8=a[1], r9=a[2], count=count)

    def get_state(self):
        st = self.stream()
        r = self.vcall(self.comp, 13, st) & 0xFFFFFFFF          # IComponent::getState (rva 0x349EA0)
        assert r == 0, 'getState -> 0x%x' % r
        return bytes(self.objs[st]['data'])

    def set_state(self, data):
        st = self.stream(data)
        return self.vcall(self.comp, 12, st) & 0xFFFFFFFF        # IComponent::setState (rva 0x34AAA0)

    def queue(self):
        """the engine event queue (core+440 vector of 24-byte records): (kind, offset, id, raw bytes)"""
        q = lambda a: struct.unpack('<Q', self.uc.mem_read(a, 8))[0]
        b, e = q(self.core + 440), q(self.core + 448)
        out = []
        for p in range(b, e, 24):
            rec = bytes(self.uc.mem_read(p, 24))
            kind, off = struct.unpack_from('<ii', rec, 0)
            out.append((kind, off, rec))
        return out


def vst_iid(l1, l2, l3, l4):
    """a VST3 interface id in the Windows (COM-compatible) byte order"""
    return (struct.pack('<I', l1) + bytes([(l2 >> 16) & 0xFF, (l2 >> 24) & 0xFF, l2 & 0xFF, (l2 >> 8) & 0xFF])
            + struct.pack('>II', l3, l4))


IID_ICOMPONENT = vst_iid(0xE831FF31, 0xF2D54301, 0x928EBBEE, 0x25697802)
IID_IEDITCONTROLLER = vst_iid(0xDCD7BBE3, 0x7742448D, 0xA874AACC, 0x979C759E)
IID_ICONNECTIONPOINT = vst_iid(0x70A4156F, 0x6E6E4026, 0x989148BF, 0xAA60D8D1)
IID_IAUDIOPROCESSOR = vst_iid(0x42043F99, 0xB7DA453C, 0xA569E79D, 0x9AAEC33D)
IID_ICOMPONENTHANDLER = vst_iid(0x93A0BEA3, 0x0BD045DB, 0x8E890B0C, 0xC1E46AC6)
IID_IHOSTAPPLICATION = vst_iid(0x58E595CC, 0xDB2D4969, 0x8B6AAF8C, 0x36A664E5)
IID_IMESSAGE = vst_iid(0x936F033B, 0xC6C047DB, 0xBB0882F8, 0x13C1E613)
IID_IATTRIBUTELIST = vst_iid(0x1E5F0AEB, 0xCC7F4533, 0xA2544011, 0x38AD5EE4)
IID_IBSTREAM = vst_iid(0xC3BF6EA2, 0x30994752, 0x9B6BF990, 0x1EE33E9B)
