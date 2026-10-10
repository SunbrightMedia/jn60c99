#!/usr/bin/env python3
"""jx_host_emu.py -- the JX-3P plugin as a VST3 host runs it: GetPluginFactory, createInstance,
IComponent::initialize, setupProcessing, setActive, and its own IAudioProcessor::process, under Unicorn.

The JX-3P's VST3 wrapper is the JUNO-60's machine code (jx3p/tools/fw_map.py: process(), the render
driver, the rate converter, the patch browser and the state calls map one to one), so this module runs
the JUNO's host oracle -- probes/b6/wrapper_emu.py and tools/verify/host_process_emu.py, loaded a second
time with the JX's PROFILE below -- on tools/verify/jx_emu.py's emulator. Every address in the profile is
READ from the JX image (the PE header, its exports and TLS directory, the engine vtable 0xA15B88) or mapped
from the JUNO's by fw_map.py.

THE ONE REPLACEMENT is the engine render's thread transport, as in the JUNO oracle -- but here the
plugin's own engine render (CWaveGen vt+0x38, rva 0x3F9220, READ) runs as its own code: its voice-count
sync, its assigner clock, its unit jobs, its master loop and its output gain stage (HOST+0x860..0x878:
the fade the voice-count and 0x0FFFC01D entries arm, rva 0x3F9AB9). Only its worker threads cannot run
here: the render flags each unit's job (worker+0x34 = 1) and signals the worker's condition; a worker
thread (rva 0x3F8C60, READ) runs the job -- VOICE_WRAP per sample over the block, then the done count
HOST+0x410 under its lock -- and the render waits for the count. This module stops the render where it
is about to wait (the done lock's acquire, rva 0x3F9587), runs the worker function itself, from its
entry, for every flagged unit until the worker, its job done, comes back to the top of its loop (rva
0x3F8CD0, its lock released), and resumes the render at the same instruction. No plugin logic is reimplemented: the worker, the render and process()
are the plugin's own instructions; this module only decides WHEN a worker runs.

USE (separate process from any ctypes port: two-process rule)
    import jx_host_emu as X
    h = X.JXHost(); h.start(48000.0, 512)
    L, R = h.process(512, events=[('on', 0, 0, 60, 0.8)])
"""
import importlib.util
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
import jx_emu as J                                           # noqa: E402
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RSP, UC_X86_REG_RCX, UC_X86_REG_RDX  # noqa: E402

WORKER = 0x3F8C60          # a voice unit's worker thread body (rcx = worker, edx = unit; READ)
WORKER_PARK = 0x3F8CD0     # where a worker parks between jobs: the top of its loop (the acquire of its lock),
                           # reached again after a job -- flag +0x34 cleared, the done count raised, the lock
                           # released (0x3F8DBC; READ). The first version parked at the condition wait's entry
                           # (0x3F7010) with the lock still held, and the next block's render spun on the lock
                           # forever: every second process() hung (2026-10-10). Inside the wait the plugin uses
                           # the Concurrency Runtime's semaphores; parking before it needs none of them.
JOBS_DUE = 0x3F9587        # in the engine render: the done lock's acquire before the wait (READ)
WORKER_BASE, WORKER_STRIDE = 0x460, 0x80    # worker u = HOST + 0x460 + 0x80 u (the render's r12 - 0x38)

PROFILE = dict(
    E=J, BASE=J.JX, SCRIPT_XML=os.path.join(REPO, 'jx3p', 'truth', 'Script.xml'),
    DLLMAIN=0x6ACD8C,                 # the PE entry point (READ)
    INITDLL=0x3FB630,                 # export InitDll (READ)
    FACTORY=0x348A00,                 # export GetPluginFactory (= JUNO 0x348B40, fw_map)
    CREATE_PROC=0x349B60,             # processor createInstance (= JUNO 0x349CA0, fw_map)
    TLS_TEMPLATE=(0xB62C68, 0xB62C84), TLS_INDEX=0xCEE568,      # the PE TLS directory (READ)
    DATA_DIR='C:\\ProgramData\\Roland Cloud\\JX-3P',
    USER_DIR='C:\\Users\\u\\AppData\\Local\\Roland Cloud\\JX-3P',
    MODPATH='C:\\Program Files\\Common Files\\VST3\\JX-3P.vst3\\Contents\\x86_64-win\\JX-3P.vst3',
    INITIALIZE=None,                  # the component vtable's slot 3
    PATCH_LOAD=0x335730,              # the patch browser's load (= JUNO 0x335850, fw_map)
    ENGINE_RENDER=JOBS_DUE,           # where the render service stops (see the docstring)
    ZOOM_GET=0x2AA470, WINDOW_FIT=0x312580,                     # (= JUNO 0x2AA590 / 0x312750, fw_map)
)


def _load(name, path, **inject):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    mod.__dict__.update(inject)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


W = _load('jx_wrapper_emu', os.path.join(REPO, 'probes', 'b6', 'wrapper_emu.py'), PROFILE=PROFILE)
H = _load('jx_host_process_emu', os.path.join(REPO, 'tools', 'verify', 'host_process_emu.py'), W_MODULE=W)
IB = J.IB


class JXHost(H.HostProcess):
    def __init__(self):
        super().__init__()
        self._skip = None              # (rip, rsp) the render resumes at: its stop fires once
        self._in_job = False
        self.jobs = []                 # (unit, block) of every worker job run, in order
        self._job_w = None             # the worker object of the job running
        self.uc.hook_add(H.UC_HOOK_CODE, self._on_park, begin=IB + WORKER_PARK, end=IB + WORKER_PARK)

    # ------------------------------------------------------------ the render's stop and the workers
    def _on_render(self, uc, addr, size, ud):
        here = (addr, uc.reg_read(UC_X86_REG_RSP))
        if self._skip == here:
            self._skip = None
            return
        self._req = dict(kind='jobs', ctx=uc.context_save(), rip=addr, rsp=here[1],
                         engine=self.HOST if hasattr(self, 'HOST') else None)
        uc.emu_stop()

    def _on_park(self, uc, addr, size, ud):
        # the first pass (flag 1: the job is due) runs on; the pass after the job (flag 0) parks
        if self._in_job and struct.unpack('<i', uc.mem_read(self._job_w + 0x34, 4))[0] == 0:
            uc.emu_stop()

    def _run_jobs(self, req):
        uc = self.uc
        q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
        i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
        host = q(self.core + 272)
        self._nested_top = (req['rsp'] - 0x100000) & ~0xF
        try:
            for u in range(8):
                w = host + WORKER_BASE + WORKER_STRIDE * u
                if i32(w + 0x34) != 1:
                    continue
                self.jobs.append((u, i32(w + 0x30)))
                rsp = self._top() - 8
                uc.reg_write(UC_X86_REG_RSP, rsp)
                uc.reg_write(UC_X86_REG_RCX, w)
                uc.reg_write(UC_X86_REG_RDX, u)
                uc.mem_write(rsp, struct.pack('<Q', J.SCRATCH + 0x5000))
                self._in_job, self._job_w = True, w
                try:
                    uc.emu_start(IB + WORKER, J.SCRATCH + 0x5000, count=0)
                finally:
                    self._in_job, self._job_w = False, None
                rip = uc.reg_read(UC_X86_REG_RIP)
                if rip != IB + WORKER_PARK or i32(w + 0x34) != 0:
                    raise RuntimeError('worker %d did not finish its job (stopped at rva 0x%x, flag %d)'
                                       % (u, rip - IB, i32(w + 0x34)))
        finally:
            self._nested_top = None

    def call(self, fn, rcx=0, rdx=0, r8=0, r9=0, count=0):
        uc = self.uc
        rsp = self._top() - 8
        RET = J.SCRATCH + 0x5000
        uc.reg_write(UC_X86_REG_RSP, rsp)
        for r, v in ((UC_X86_REG_RCX, rcx), (UC_X86_REG_RDX, rdx), (H.UC_X86_REG_R8, r8), (H.UC_X86_REG_R9, r9)):
            uc.reg_write(r, v & (2 ** 64 - 1))
        uc.mem_write(rsp, struct.pack('<Q', RET))
        start = fn
        while True:
            self._req = None
            uc.emu_start(start, RET, count=count)
            req = self._req
            if req is None:
                rip = uc.reg_read(UC_X86_REG_RIP)
                if rip != RET:
                    raise RuntimeError('call to 0x%x stopped at rva 0x%x' % (fn - IB, rip - IB))
                return uc.reg_read(H.UC_X86_REG_RAX)
            if self._nested_top is not None:
                raise RuntimeError('engine render reached from inside a worker job')
            self._run_jobs(req)
            uc.context_restore(req['ctx'])
            self._skip = (req['rip'], req['rsp'])
            start = req['rip']


if __name__ == '__main__':
    h = JXHost()
    h.start(float(sys.argv[1]) if len(sys.argv) > 1 else 48000.0, 512, log=print)
    print('booted: HOST 0x%x, voices %d, engine rate %r, fade gain %r' % (
        h.HOST, struct.unpack('<i', h.uc.mem_read(h.HOST + 0x38, 4))[0],
        struct.unpack('<f', h.uc.mem_read(h.HOST + 8, 4))[0], struct.unpack('<f', h.uc.mem_read(h.HOST + 0x860, 4))[0]))
    q = h.queue()
    print('queue after start: %d records' % len(q))
    import math
    for blk in range(6):
        L, R = h.process(512, events=[('on', 0, 0, 60, 0.8)] if blk == 2 else [])
        f = [struct.unpack('<f', struct.pack('<I', x))[0] for x in L]
        print('block %d: jobs so far %d, max |L| %.4g, non-finite %d, gain %r' % (
            blk, len(h.jobs), max(abs(x) for x in f if math.isfinite(x)) if f else 0,
            sum(1 for x in f if not math.isfinite(x)), struct.unpack('<f', h.uc.mem_read(h.HOST + 0x860, 4))[0]))
