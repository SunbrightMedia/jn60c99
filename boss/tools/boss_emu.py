#!/usr/bin/env python3
"""boss_emu.py -- the BOSS Effects Pedals plugin under Unicorn, booted as a VST3 host boots it.

THE ORACLE of the BOSS track (boss/docs/S3_STATUS.md). PLUMBING ONLY: nothing here reimplements
plugin logic. Two layers:

  Emu       a bare x86-64 Windows process: the image mapped at its ImageBase, every import a named
            stub, a stack, a bump heap, a call() with the Win64 ABI. Every address comes from the PE
            header (imports, exports, entry point, TLS directory), none is hand-typed.
  BossHost  the Roland Cloud host plumbing of probes/b6/wrapper_emu.py (TEB + TLS, the Win32 calls
            the CRT and the module init need, a read-only file system, the Shell / COM objects, the
            host objects: IHostApplication, IBStream, IMessage, IComponentHandler), loaded with a
            PROFILE on Emu -- and a boot that uses ONLY the standard VST3 calls: the TLS callbacks,
            DllMain, InitDll, GetPluginFactory, IPluginFactory::getClassInfo / createInstance,
            IPluginBase::initialize. No address inside the plugin is assumed.

The BOSS wrapper is NOT the JUNO's build (jx3p/tools/fw_map.py: 3 of 24 wrapper functions equal,
2026-10-16), so the JUNO's per-function profile does not apply; the VST3 interfaces do.

USE (a separate process from any ctypes port: the two-process rule)
    import boss_emu as B
    h = B.BossHost(); h.boot(log=print)
"""
import collections
import importlib.util
import os
import struct
import sys

import pefile
from unicorn import (Uc, UC_ARCH_X86, UC_MODE_64, UC_PROT_ALL, UC_HOOK_CODE, UC_HOOK_MEM_FETCH_UNMAPPED,
                     UC_HOOK_MEM_READ_UNMAPPED, UC_HOOK_MEM_WRITE_UNMAPPED, UC_MEM_WRITE_UNMAPPED)
from unicorn.x86_const import (UC_X86_REG_RAX, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9,
                               UC_X86_REG_RSP, UC_X86_REG_RIP, UC_X86_REG_CR0, UC_X86_REG_CR4, UC_X86_REG_MXCSR)

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import boss_truth as T                                            # noqa: E402

BIN = T.VST3
pe = pefile.PE(BIN)
IB = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()
IMGSZ = (len(IMG) + 0xFFF) & ~0xFFF
ENTRY = pe.OPTIONAL_HEADER.AddressOfEntryPoint                   # DllMain (through the CRT's entry)
EXPORTS = {e.name.decode(): e.address for e in pe.DIRECTORY_ENTRY_EXPORT.symbols if e.name}
_tls = pe.DIRECTORY_ENTRY_TLS.struct
TLS_TEMPLATE = (_tls.StartAddressOfRawData - IB, _tls.EndAddressOfRawData - IB)
TLS_INDEX = _tls.AddressOfIndex - IB
TLS_CALLBACKS = []
_p = _tls.AddressOfCallBacks - IB
while struct.unpack_from('<Q', IMG, _p)[0]:
    TLS_CALLBACKS.append(struct.unpack_from('<Q', IMG, _p)[0] - IB)
    _p += 8

IMPORTS = {}
for _e in pe.DIRECTORY_ENTRY_IMPORT:
    for _i in _e.imports:
        IMPORTS[_i.address - IB] = (_e.dll.decode(), _i.name.decode() if _i.name else 'ord%d' % _i.ordinal)

# the address space (the JUNO / JX / JP8 oracles' layout, so the wrapper plumbing's fixed regions fit:
# TEB 0x580000000, COM 0x5A0000000, stubs 0x600000000)
STACK_BASE, STACK_SIZE = 0x200000000, 0x2000000
HEAP_BASE, HEAP_SIZE = 0x310000000, 0x200000000
STUB_BASE = 0x600000000
SCRATCH = 0x100000
FAKE_HEAP = 0x4242000000
BUF_BASE, BUF_SIZE = 0x700000000, 0x400000
MAX_STRAY_PAGES = 64          # a crash-walk is stopped by COUNT (playbook: the JP8 flood guard)


class Emu:
    def __init__(self):
        self.heap = HEAP_BASE
        self.allocs = []
        self.tls, self.tls_ctr = {}, 1
        self.unhandled = collections.Counter()
        self.faults = 0
        self.uc = uc = Uc(UC_ARCH_X86, UC_MODE_64)
        uc.mem_map(IB, IMGSZ, UC_PROT_ALL)
        uc.mem_write(IB, bytes(IMG))
        uc.mem_map(STACK_BASE, STACK_SIZE, UC_PROT_ALL)
        uc.mem_map(HEAP_BASE, HEAP_SIZE, UC_PROT_ALL)
        uc.mem_map(STUB_BASE, 0x100000, UC_PROT_ALL)
        uc.mem_map(0, 0x100000, UC_PROT_ALL)
        uc.mem_map(BUF_BASE, BUF_SIZE, UC_PROT_ALL)
        cr0 = uc.reg_read(UC_X86_REG_CR0)
        uc.reg_write(UC_X86_REG_CR0, (cr0 & ~(1 << 2)) | (1 << 1))
        uc.reg_write(UC_X86_REG_CR4, uc.reg_read(UC_X86_REG_CR4) | (1 << 9) | (1 << 10))
        uc.reg_write(UC_X86_REG_MXCSR, 0x1F80)      # a Windows thread's MXCSR (playbooks 228, 241)
        self.stub2name = {}
        for k, (rva, dn) in enumerate(sorted(IMPORTS.items())):
            stub = STUB_BASE + 8 * k
            uc.mem_write(IB + rva, struct.pack('<Q', stub))
            uc.mem_write(stub, b'\xC3')
            self.stub2name[stub] = dn
        uc.hook_add(UC_HOOK_CODE, self._imp, begin=STUB_BASE, end=STUB_BASE + 8 * len(IMPORTS) + 8)
        uc.hook_add(UC_HOOK_MEM_FETCH_UNMAPPED, self._fetch)
        uc.hook_add(UC_HOOK_MEM_READ_UNMAPPED | UC_HOOK_MEM_WRITE_UNMAPPED, self._unmapped)
        self._stray = 0

    def bump(self, sz):
        sz = (sz + 15) & ~15 or 16
        p = self.heap
        self.heap += sz
        if self.heap > HEAP_BASE + HEAP_SIZE:
            raise MemoryError('heap full')
        return p

    def _ret(self, uc, v):
        uc.reg_write(UC_X86_REG_RAX, v & (2 ** 64 - 1))

    def _imp(self, uc, address, size, user):
        """the default Win32 answers (BossHost's wrapper plumbing answers first); unknown -> 0, COUNTED"""
        if address not in self.stub2name:
            return
        dll, name = self.stub2name[address]
        rcx, rdx, r8 = (uc.reg_read(r) for r in (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8))
        ret = lambda v: self._ret(uc, v)
        if name in ('EncodePointer', 'DecodePointer', 'EncodeSystemPointer', 'DecodeSystemPointer',
                    'RtlEncodePointer', 'RtlDecodePointer'):
            return ret(rcx)                    # identity: a valid encoding (the JP8 CRT defect, 2026-09-06)
        if name == 'GetProcessHeap':
            return ret(FAKE_HEAP)
        if name in ('HeapAlloc', 'calloc'):
            n = (r8 or rdx or 16) if name == 'HeapAlloc' else max(rcx * rdx, 16)
            p = self.bump(n)
            uc.mem_write(p, b'\0' * ((n + 15) & ~15))
            self.allocs.append((p, n))
            return ret(p)
        if name == 'HeapReAlloc':
            r9 = uc.reg_read(UC_X86_REG_R9)
            p = self.bump(r9)
            old = r8
            if old:                             # keep the old contents (a real realloc copies them)
                osz = next((s for a, s in reversed(self.allocs) if a == old), 0)
                if osz:
                    uc.mem_write(p, bytes(uc.mem_read(old, min(osz, r9))))
            self.allocs.append((p, r9))
            return ret(p)
        if name == 'HeapSize':
            return ret(next((s for a, s in reversed(self.allocs) if a == r8), 0))
        if name in ('HeapFree', 'HeapDestroy', 'HeapSetInformation', 'HeapValidate'):
            return ret(1)
        if name in ('VirtualAlloc', 'VirtualAllocEx'):
            n = rdx or 0x1000
            p = self.bump(n)
            uc.mem_write(p, b'\0' * ((n + 15) & ~15))
            self.allocs.append((p, n))
            return ret(p)
        if name in ('VirtualFree', 'VirtualProtect'):
            return ret(1)
        if name == 'TlsAlloc':
            i = self.tls_ctr
            self.tls_ctr += 1
            return ret(i)
        if name == 'TlsSetValue':
            self.tls[rcx] = rdx
            return ret(1)
        if name == 'TlsGetValue':
            return ret(self.tls.get(rcx, 0))
        if name in ('TlsFree', 'EnterCriticalSection', 'LeaveCriticalSection', 'DeleteCriticalSection',
                    'TryEnterCriticalSection'):
            return ret(1)
        if name == 'CreateThread':
            return self._thread_create(uc, r8, uc.reg_read(UC_X86_REG_R9))
        if name in ('ExitThread', 'FreeLibraryAndExitThread') and getattr(self, '_nested_top', None) is not None:
            self._thread_exit = True
            uc.emu_stop()
            return
        if name == 'GetCurrentThreadId':                 # each thread its own id (the C++ mutexes compare owners)
            return ret(getattr(self, '_tid', 0x1000))
        if name == 'GetCurrentProcessId':
            return ret(0x1000)
        if name in ('GetCurrentProcess', 'GetCurrentThread'):
            return ret(0xFFFFFFFFFFFFFFFF if name.endswith('Process') else 0xFFFFFFFFFFFFFFFE)
        if name.startswith('Create') or name.startswith('Open'):
            self._hc = getattr(self, '_hc', 0x9000) + 16
            return ret(self._hc)
        self.unhandled[name] += 1
        return ret(0)

    def _fetch(self, uc, access, address, size, value, user):
        self.faults += 1
        self.fetch_fault = (address, uc.reg_read(UC_X86_REG_RSP))
        uc.emu_stop()
        return False

    def _unmapped(self, uc, access, address, size, value, user):
        self._stray += 1
        self.faults += 1
        if self._stray > MAX_STRAY_PAGES:
            uc.emu_stop()
            return True
        if self.faults <= 8 and os.environ.get('BOSS_EMU_QUIET') != '1':
            sys.stderr.write('boss_emu: UNMAPPED %s 0x%x (size %d) at rva 0x%x -- zero page mapped\n' % (
                'write' if access == UC_MEM_WRITE_UNMAPPED else 'read', address, size,
                uc.reg_read(UC_X86_REG_RIP) - IB))
        try:
            uc.mem_map(address & ~0xFFF, 0x1000, UC_PROT_ALL)
        except Exception:
            pass
        return True

    def _top(self):
        top = getattr(self, '_nested_top', None)
        return top if top is not None else (STACK_BASE + STACK_SIZE - 0x10000) & ~0xF

    # THREADS (plumbing; the JP8 worker rule: the oracle only decides WHEN a thread runs). The plugin's InitDll starts a
    # juce::Thread and waits in a loop until the thread changes its state
    # (MEASURED 2026-10-16: without it InitDll never returns). CreateThread records the start routine and returns at
    # once; call() then runs the thread from its start routine to ExitThread (or its return) on a stack 1 MB below the
    # caller's frames, restores the caller's registers and resumes it -- one valid scheduling: the new thread runs to
    # its end before its creator continues. THREAD_CAP bounds a thread that never ends (it is stopped by name).
    THREAD_CAP = 4_000_000_000

    def _thread_create(self, uc, start, param):
        """record the thread and return its handle; it runs when its creator first blocks (_block)"""
        self._hc = getattr(self, '_hc', 0x9000) + 16
        self.threads = getattr(self, 'threads', [])
        self.threads.append(dict(start=start, param=param, handle=self._hc, state='new'))
        return self._ret(uc, self._hc)

    def _block(self, uc, address):
        """the running code is about to block. On the main stack with a new thread pending: stop at this import (its
        stub runs again after the thread), so the thread runs first -- what an OS does when a thread waits. Returns
        True when it stopped."""
        if getattr(self, '_nested_top', None) is not None:
            return False
        if not any(t['state'] == 'new' for t in getattr(self, 'threads', [])):
            return False
        if self.PROGRESS:
            sys.stderr.write('boss_emu: main blocks in %s (return rva 0x%x): running its new thread(s)\n' % (
                self.stub2name[address][1], struct.unpack('<Q', bytes(uc.mem_read(uc.reg_read(UC_X86_REG_RSP), 8)))[0] - IB))
        uc.reg_write(UC_X86_REG_RIP, address)
        self._thread_due = True
        uc.emu_stop()
        return True

    def _run_threads(self, count):
        for t in getattr(self, 'threads', []):
            if t['state'] != 'new':
                continue
            t['state'] = 'running'
            t['tid'] = 0x1000 + 4 * (1 + self.threads.index(t))
            saved_tid = getattr(self, '_tid', 0x1000)
            self._tid = t['tid']
            ctx = self.uc.context_save()
            saved_top = getattr(self, '_nested_top', None)
            self._nested_top = (self.uc.reg_read(UC_X86_REG_RSP) - 0x100000) & ~0xF
            self._thread_exit = False
            try:
                t['ret'] = self.call(t['start'], rcx=t['param'], count=self.THREAD_CAP)
                t['state'] = 'returned'
            except _ThreadExit:
                t['state'] = 'exited'
            finally:
                self._nested_top = saved_top
                self._tid = saved_tid
                self.uc.context_restore(ctx)

    def call(self, fn, rcx=0, rdx=0, r8=0, r9=0, count=0, stack=()):
        uc = self.uc
        uc.reg_write(UC_X86_REG_MXCSR, getattr(self, '_mxcsr', 0x1F80))
        rsp = self._top() - 8
        RET = SCRATCH + 0x5000
        uc.reg_write(UC_X86_REG_RSP, rsp)
        for r, v in ((UC_X86_REG_RCX, rcx), (UC_X86_REG_RDX, rdx), (UC_X86_REG_R8, r8), (UC_X86_REG_R9, r9)):
            uc.reg_write(r, v & (2 ** 64 - 1))
        uc.mem_write(rsp, struct.pack('<Q', RET))
        for k, v in enumerate(stack):             # the fifth argument on
            uc.mem_write(rsp + 0x28 + 8 * k, struct.pack('<Q', v & (2 ** 64 - 1)))
        start = fn
        while True:
            self._stray = 0
            self.fetch_fault = None
            self._thread_due = False
            uc.emu_start(start, RET, count=count)
            if getattr(self, '_thread_exit', False) and getattr(self, '_nested_top', None) is not None:
                self._thread_exit = False
                raise _ThreadExit()
            if getattr(self, 'cxx_throw', None) is not None:
                t, self.cxx_throw = self.cxx_throw, None
                raise RuntimeError('the plugin threw a C++ exception (from rva 0x%x)' % t)
            if self._thread_due:
                self._run_threads(count)
                start = uc.reg_read(UC_X86_REG_RIP)
                continue
            rip = uc.reg_read(UC_X86_REG_RIP)
            if rip != RET:
                ff = self.fetch_fault
                if ff:
                    ra = struct.unpack('<Q', bytes(uc.mem_read(ff[1], 8)))[0]
                    raise RuntimeError('call to rva 0x%x: fetch from unmapped 0x%x (return address rva 0x%x)'
                                       % (fn - IB, ff[0], ra - IB))
                raise RuntimeError('call to rva 0x%x stopped at rva 0x%x (count %d)' % (fn - IB, rip - IB, count))
            return uc.reg_read(UC_X86_REG_RAX)


class _ThreadExit(Exception):
    """a served thread called ExitThread (its end)"""


# ---------------------------------------------------------------- the host plumbing (wrapper_emu + PROFILE)
PRODUCT = 'BOSS Effects Pedals'
PROFILE = dict(
    E=sys.modules[__name__], BASE=Emu, SCRIPT_XML=T.SCRIPT_XML,
    DLLMAIN=ENTRY, INITDLL=EXPORTS['InitDll'], FACTORY=EXPORTS['GetPluginFactory'],
    CREATE_PROC=0, PATCH_LOAD=0,          # unused: BossHost boots through the factory's own class table
    TLS_TEMPLATE=TLS_TEMPLATE, TLS_INDEX=TLS_INDEX,
    DATA_DIR='C:\\ProgramData\\Roland Cloud\\' + PRODUCT,
    USER_DIR='C:\\Users\\u\\AppData\\Local\\Roland Cloud\\' + PRODUCT,
    MODPATH='C:\\Program Files\\Common Files\\VST3\\%s.vst3\\Contents\\x86_64-win\\%s.vst3' % (PRODUCT, PRODUCT),
)


def _load(name, path, **inject):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    mod.__dict__.update(inject)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


W = _load('boss_wrapper_emu', os.path.join(REPO, 'probes', 'b6', 'wrapper_emu.py'), PROFILE=PROFILE)
vst_iid = W.vst_iid
IID_IPLUGINFACTORY2 = vst_iid(0x0007B650, 0xF24B4C0B, 0xA464EDB9, 0xF00B2ABB)
IID_IAUDIOPROCESSOR = W.IID_IAUDIOPROCESSOR
IID_ICOMPONENT = W.IID_ICOMPONENT
IID_IEDITCONTROLLER = W.IID_IEDITCONTROLLER
IID_ICONNECTIONPOINT = W.IID_ICONNECTIONPOINT


def _cstr(b):
    return b.split(b'\0')[0].decode('latin1')


class BossHost(W.Wrapper):
    """the plugin as a VST3 host loads it. Every file of boss/truth/Script/ is served in the plugin's
    Script folder (next to the module, MEASURED on the JUNO); every file the plugin asks for is in
    self.fslog, a miss included."""

    def __init__(self):
        super().__init__()
        sd = W._norm(W.SCRIPT_DIR).lower()
        names = sorted(os.listdir(T.SCRIPT_DIR))
        for nm in names:
            with open(os.path.join(T.SCRIPT_DIR, nm), 'rb') as f:
                self.files[sd + '\\' + nm.lower()] = f.read()
        self.dirs[sd] = names

    def q(self, a):
        return struct.unpack('<Q', bytes(self.uc.mem_read(a, 8)))[0]

    # ------------------------------------------------------------ the OS's events and clock (plumbing)
    # A single-threaded process: an event has a state (CreateEvent's manual / initial flags, SetEvent, ResetEvent); a
    # wait on a signaled event returns WAIT_OBJECT_0 (an auto-reset event is then reset); a wait on an unsignaled one
    # can only time out: the clock advances by the timeout and the wait returns WAIT_TIMEOUT; an INFINITE wait that can
    # never be satisfied stops the run by name (a deadlock, never a silent spin). A thread handle is signaled once its
    # thread ended. One virtual clock in ms serves timeGetTime / GetTickCount(64) / QueryPerformanceCounter (10 MHz) /
    # GetSystemTimeAsFileTime; waits and Sleep advance it, and each read advances it by one tick so a polling loop
    # always moves forward (MEASURED 2026-10-16: a plugin thread polls timeGetTime; a clock stuck at 0 spun it
    # 161,839 times).
    WAIT_OBJECT_0, WAIT_TIMEOUT, INFINITE = 0, 0x102, 0xFFFFFFFF
    QPF = 10_000_000

    def _os(self, uc, name, rcx, rdx, r8, r9):
        ret = lambda v: self._ret(uc, v)
        ev = self.__dict__.setdefault('events', {})
        if name in ('CreateEventW', 'CreateEventA'):
            self._hc = getattr(self, '_hc', 0x9000) + 16
            ev[self._hc] = dict(manual=bool(rdx & 0xFFFFFFFF), state=bool(r8 & 0xFFFFFFFF))
            return ret(self._hc)
        if name in ('CreateEventExW', 'CreateEventExA'):          # flags: 1 manual reset, 2 initial set
            self._hc = getattr(self, '_hc', 0x9000) + 16
            ev[self._hc] = dict(manual=bool(r8 & 1), state=bool(r8 & 2))
            return ret(self._hc)
        if name in ('SetEvent', 'ResetEvent'):
            if rcx in ev:
                ev[rcx]['state'] = name == 'SetEvent'
            return ret(1)
        if name in ('WaitForSingleObject', 'WaitForSingleObjectEx'):
            ms = rdx & 0xFFFFFFFF
            th = {t['handle']: t for t in getattr(self, 'threads', [])}
            if rcx in ev:
                e = ev[rcx]
                if e['state']:
                    if not e['manual']:
                        e['state'] = False
                    return ret(self.WAIT_OBJECT_0)
            elif rcx in th:
                if th[rcx]['state'] in ('returned', 'exited'):
                    return ret(self.WAIT_OBJECT_0)
            else:
                self.unhandled['WaitForSingleObject(unknown handle)'] += 1
                return ret(self.WAIT_OBJECT_0)
            if self._block(uc, self._addr):
                return
            if ms == self.INFINITE:
                raise RuntimeError('deadlock: an INFINITE wait on handle 0x%x that nothing can signal' % rcx)
            self.clock_ms = getattr(self, 'clock_ms', 0) + ms
            return ret(self.WAIT_TIMEOUT)
        if name == 'SleepConditionVariableSRW':         # (cv, srw, ms, flags): the caller released its lock first
            if self._block(uc, self._addr):
                return
            ms = r8 & 0xFFFFFFFF
            if ms == self.INFINITE:
                raise RuntimeError('deadlock: an INFINITE condition-variable wait that nothing can wake')
            self.clock_ms = getattr(self, 'clock_ms', 0) + ms
            self.lasterr = 1460                         # ERROR_TIMEOUT
            return ret(0)
        if name == 'TryAcquireSRWLockExclusive':        # one thread runs at a time: never contended
            return ret(1)
        if name in ('Sleep', 'SleepEx'):
            if self._block(uc, self._addr):
                return
            self.clock_ms = getattr(self, 'clock_ms', 0) + (rcx & 0xFFFFFFFF)
            return ret(0)
        CLOCK = ('timeGetTime', 'GetTickCount', 'GetTickCount64', 'QueryPerformanceCounter', 'QueryPerformanceFrequency',
                 'GetSystemTimeAsFileTime', 'GetSystemTimePreciseAsFileTime')
        if name in CLOCK:
            self.clock_ms = getattr(self, 'clock_ms', 0) + 1
        c = getattr(self, 'clock_ms', 0)
        if name in ('timeGetTime', 'GetTickCount'):
            return ret(c & 0xFFFFFFFF)
        if name == 'GetTickCount64':
            return ret(c)
        if name == 'QueryPerformanceCounter':
            uc.mem_write(rcx, struct.pack('<q', c * (self.QPF // 1000)))
            return ret(1)
        if name == 'QueryPerformanceFrequency':
            uc.mem_write(rcx, struct.pack('<q', self.QPF))
            return ret(1)
        if name in ('GetSystemTimeAsFileTime', 'GetSystemTimePreciseAsFileTime'):
            uc.mem_write(rcx, struct.pack('<Q', 133_000_000_000_000_000 + c * 10_000))   # a fixed 2022 epoch + clock
            return ret(0)
        if name in ('RegOpenKeyExA', 'RegOpenKeyExW', 'RegOpenKeyA', 'RegOpenKeyW', 'RegQueryValueExA', 'RegQueryValueExW',
                    'RegCreateKeyExA', 'RegCreateKeyExW', 'RegGetValueA', 'RegGetValueW', 'RegEnumKeyExW', 'RegEnumValueW'):
            return ret(2)                                   # ERROR_FILE_NOT_FOUND: a machine with no such key
        if name == 'RegCloseKey':
            return ret(0)
        if name in ('GetCurrentDirectoryW', 'GetCurrentDirectoryA'):
            d = 'C:\\Users\\u'
            if (rcx & 0xFFFFFFFF) <= len(d):
                return ret(len(d) + 1)
            self.wstr(rdx, d, name.endswith('W'))
            return ret(len(d))
        if name in ('SHGetSpecialFolderPathW', 'SHGetSpecialFolderPathA'):
            path = {0x23: 'C:\\ProgramData', 0x1c: 'C:\\Users\\u\\AppData\\Local', 0x1a: 'C:\\Users\\u\\AppData\\Roaming',
                    0x05: 'C:\\Users\\u\\Documents', 0x2e: 'C:\\Users\\Public\\Documents', 0x28: 'C:\\Users\\u',
                    0x26: 'C:\\Program Files', 0x2b: 'C:\\Program Files\\Common Files', 0x24: 'C:\\Windows',
                    0x25: 'C:\\Windows\\System32', 0x10: 'C:\\Users\\u\\Desktop'}.get(r8 & 0xFF)
            if path is None:
                self.unhandled['SHGetSpecialFolderPath(csidl 0x%x)' % (r8 & 0xFF)] += 1
                return ret(0)
            self.wstr(rdx, path, name.endswith('W'))
            return ret(1)
        if name in ('GetModuleHandleExW', 'GetModuleHandleExA'):
            if r8:
                uc.mem_write(r8, struct.pack('<Q', IB))
            return ret(1)
        return None

    OS_NAMES = frozenset(('SleepConditionVariableSRW', 'TryAcquireSRWLockExclusive', 'RegOpenKeyExA', 'RegOpenKeyExW', 'RegOpenKeyA', 'RegOpenKeyW', 'RegQueryValueExA', 'RegQueryValueExW',
                          'RegCreateKeyExA', 'RegCreateKeyExW', 'RegGetValueA', 'RegGetValueW', 'RegEnumKeyExW',
                          'RegEnumValueW', 'RegCloseKey', 'GetCurrentDirectoryW', 'GetCurrentDirectoryA',
                          'SHGetSpecialFolderPathW', 'SHGetSpecialFolderPathA', 'GetModuleHandleExW', 'GetModuleHandleExA','CreateEventW', 'CreateEventA', 'CreateEventExW', 'CreateEventExA', 'SetEvent', 'ResetEvent',
                          'WaitForSingleObject', 'WaitForSingleObjectEx', 'Sleep', 'SleepEx', 'timeGetTime',
                          'GetTickCount', 'GetTickCount64', 'QueryPerformanceCounter', 'QueryPerformanceFrequency',
                          'GetSystemTimeAsFileTime', 'GetSystemTimePreciseAsFileTime'))

    PROGRESS = int(os.environ.get('BOSS_PROGRESS', '0'))       # >0: a progress line every N import calls

    def _imp(self, uc, address, size, user):
        dn = self.stub2name.get(address)
        if self.PROGRESS:
            self._nimp = getattr(self, '_nimp', 0) + 1
            if self._nimp % self.PROGRESS == 0:
                sys.stderr.write('boss_emu: %d imports, clock %d ms, %s, threads %s, last %s at rva 0x%x\n' % (
                    self._nimp, getattr(self, 'clock_ms', 0), 'thread' if getattr(self, '_nested_top', None) else 'main',
                    [t['state'] for t in getattr(self, 'threads', [])], dn[1] if dn else '?',
                    struct.unpack('<Q', bytes(uc.mem_read(uc.reg_read(UC_X86_REG_RSP), 8)))[0] - IB))
                sys.stderr.flush()
        if dn is not None and dn[1] in self.OS_NAMES:
            self.calls[dn[1]] += 1
            self._addr = address
            return self._os(uc, dn[1], *(uc.reg_read(r) for r in (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                                                                   UC_X86_REG_R9)))
        return super()._imp(uc, address, size, user)

    def vcall(self, obj, slot, *args, count=4_000_000_000):
        fn = self.q(self.q(obj) + 8 * slot)
        a = list(args) + [0] * (3 - len(args))
        return self.call(fn, rcx=obj, rdx=a[0], r8=a[1], r9=a[2], count=count, stack=tuple(args[3:]))

    def load_library(self, log=print):
        """what LoadLibrary runs: the TLS callbacks then DllMain(PROCESS_ATTACH)"""
        for cb in TLS_CALLBACKS:
            self.call(IB + cb, rcx=IB, rdx=1, r8=0, count=3_000_000_000)
            log('TLS callback rva 0x%x (PROCESS_ATTACH) ran' % cb)
        r = self.call(IB + ENTRY, rcx=IB, rdx=1, r8=0, count=3_000_000_000) & 0xFFFFFFFF
        log('DllMain(PROCESS_ATTACH) -> %d' % r)
        if r != 1:
            raise RuntimeError('DllMain failed')

    def classes(self):
        """IPluginFactory::countClasses / getClassInfo: [(cid, cardinality, category, name)]"""
        n = self.vcall(self.factory, 4) & 0xFFFFFFFF
        buf = self.alloc_com(16 + 4 + 32 + 64)
        out = []
        for i in range(n):
            self.uc.mem_write(buf, b'\0' * 116)
            r = self.vcall(self.factory, 5, i, buf) & 0xFFFFFFFF
            if r:
                raise RuntimeError('getClassInfo(%d) -> 0x%x' % (i, r))
            b = bytes(self.uc.mem_read(buf, 116))
            out.append((b[:16], struct.unpack_from('<i', b, 16)[0], _cstr(b[20:52]), _cstr(b[52:116])))
        return out

    def create(self, cid, iid):
        buf = self.alloc_com(0x40)
        self.uc.mem_write(buf, cid + iid)
        r = self.vcall(self.factory, 6, buf, buf + 16, buf + 0x30) & 0xFFFFFFFF
        if r:
            raise RuntimeError('createInstance -> 0x%x' % r)
        return self.q(buf + 0x30)

    def qi(self, obj, iid):
        buf = self.alloc_com(0x40)
        self.uc.mem_write(buf, iid)
        r = self.vcall(obj, 0, buf, buf + 0x30) & 0xFFFFFFFF
        return self.q(buf + 0x30) if r == 0 else 0

    def boot(self, log=print):
        """LoadLibrary, InitDll, GetPluginFactory, the processor class created and initialized"""
        self.load_library(log=log)
        # InitDll parses every Script file one byte per std::istream::get (MEASURED: Script.xml ~570 instructions a
        # byte), so it runs well past 3e9 instructions (a 3e9 cap stopped it, 2026-10-16); 4e10 bounds a real hang
        r = self.call(IB + EXPORTS['InitDll'], count=40_000_000_000) & 0xFF
        log('InitDll -> %d' % r)
        if r != 1:
            raise RuntimeError('InitDll failed: %r' % self.fslog[-5:])
        self.factory = self.call(IB + EXPORTS['GetPluginFactory'], count=100_000_000)
        log('GetPluginFactory -> 0x%x' % self.factory)
        self.cls = self.classes()
        for cid, card, cat, nm in self.cls:
            log('  class %s  %-24s %s (cardinality %d)' % (cid.hex(), cat, nm, card))
        proc = [c for c in self.cls if c[2] == 'Audio Module Class']
        if len(proc) != 1:
            raise RuntimeError('%d audio module classes' % len(proc))
        self.comp = self.create(proc[0][0], IID_ICOMPONENT)
        self.audio = self.qi(self.comp, IID_IAUDIOPROCESSOR)
        log('component 0x%x, audio processor 0x%x' % (self.comp, self.audio))
        r = self.vcall(self.comp, 3, self.new_obj('hostctx')) & 0xFFFFFFFF
        log('IComponent::initialize -> 0x%x' % r)
        if r:
            raise RuntimeError('initialize failed')
        return self.comp


# ---------------------------------------------------------------- snapshots (plumbing: a booted process, saved)
SNAP_DIR = os.path.join(REPO, 'scratchpad', 'boss')
_SKIP_ATTRS = ('uc',)


def save_snapshot(h, path):
    """every mapped byte the process can have written (the heap and the host arena only up to their bump
    pointers) + every Python attribute of the host object -- enough to resume exactly where it stopped"""
    import pickle
    regs = []
    for b, e, perm in h.uc.mem_regions():
        hi = e + 1
        if b == HEAP_BASE:
            hi = h.heap
        elif b == W.COM:
            hi = h.com_next
        regs.append((b, e + 1, perm, bytes(h.uc.mem_read(b, hi - b)) if hi > b else b''))
    attrs = {k: v for k, v in h.__dict__.items() if k not in _SKIP_ATTRS}
    with open(path, 'wb') as f:
        pickle.dump(dict(cls=type(h).__name__, regs=regs, attrs=attrs, bin_sha=T._sha256(BIN)), f, protocol=4)


def load_snapshot(path, cls=None):
    import pickle
    with open(path, 'rb') as f:
        d = pickle.load(f)
    if d['bin_sha'] != T._sha256(BIN):
        raise RuntimeError('snapshot %s was taken on another binary' % path)
    h = (cls or globals()[d['cls']])()
    have = {(b, e + 1) for b, e, _ in h.uc.mem_regions()}
    for b, e, perm, data in d['regs']:
        if (b, e) not in have:
            h.uc.mem_map(b, e - b, perm)
        if data:
            h.uc.mem_write(b, data)
    h.__dict__.update(d['attrs'])
    return h


if __name__ == '__main__':
    import time
    t = time.time()
    h = BossHost()
    h.boot()
    print('files asked:', [x for x in h.fslog][:40])
    print('unhandled imports:', h.unhandled.most_common(30))
    print('faults %d, %.1f s' % (h.faults, time.time() - t))
