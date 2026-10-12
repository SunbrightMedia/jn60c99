#!/usr/bin/env python3
"""jp8_host_emu.py -- the JUPITER-8 plugin as a VST3 host runs it: DllMain, InitDll, the processor's createInstance,
IComponent::initialize, setupProcessing, setActive and its own IAudioProcessor::process, under Unicorn.

The JUPITER-8's VST3 wrapper is the Roland Cloud framework the JUNO-60 and the JX-3P share (jx3p/tools/fw_map.py on the
JUPITER-8 image: GetPluginFactory, getState, setActive, process, setupProcessing, the core setup, the render object
lookup, the rate converter, the silence object, the automatic engine rate, the engine setSampleRate and the arp init
map one to one), so this module runs the JUNO's host oracle -- probes/b6/wrapper_emu.py and
tools/verify/host_process_emu.py, loaded a second time with the PROFILE below -- on jp8/tools/jp8_emu.py's emulator,
exactly as jx3p/tools/jx_host_emu.py does for the JX-3P. Every address in the profile is READ from the JUPITER-8 image
(the PE header, its exports and TLS directory) or found by the shape of the JUNO's function (CREATE_PROC: the JUNO's
CVstProcessor::createInstance 0x349CA0 -- ALLOC, the class at +0x148 core, rax = class + 0x110).

THE ONE REPLACEMENT is the engine render's thread transport, as in the JX oracle: the plugin's own engine render
(CWaveGen vt+0x38, rva 0x445DC0, READ) flags each unit's job (job+0x34 = 1, job = HOST + 0x4D0 + 0x80 u) and signals
the worker's condition; a worker thread (rva 0x445670, READ) runs the job -- VOICE_WRAP per sample over the block, voice
0's tracker at HOST+0x460, then the done count HOST+0x480 under its lock -- and the render waits for the count. This
module stops the render where it is about to wait (the done lock's acquire, rva 0x4460E7), runs the worker function
itself, from its entry, for every flagged unit until the worker, its job done, comes back to the top of its loop
(rva 0x4456F0), and resumes the render at the same instruction. No plugin logic is reimplemented: the worker, the
render and process() are the plugin's own instructions; this module only decides WHEN a worker runs.

USE (separate process from any ctypes port: two-process rule)
    import jp8_host_emu as X
    h = X.JP8Host(); h.start(48000.0, 512)
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
sys.path.insert(0, HERE)
import jp8_emu as J                                          # noqa: E402
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RSP, UC_X86_REG_RCX, UC_X86_REG_RDX  # noqa: E402

WORKER = 0x445670          # a voice unit's worker thread body (rcx = job, edx = unit; READ)
WORKER_PARK = 0x4456F0     # where a worker parks between jobs: the top of its loop (the acquire of its lock),
                           # reached again after a job -- flag +0x34 cleared, the done count raised, the lock
                           # released (0x3F8DBC; READ). The first version parked at the condition wait's entry
                           # (0x3F7010) with the lock still held, and the next block's render spun on the lock
                           # forever: every second process() hung (2026-10-10). Inside the wait the plugin uses
                           # the Concurrency Runtime's semaphores; parking before it needs none of them.
JOBS_DUE = 0x4460E7        # in the engine render: the done lock's acquire before the wait (READ)
MISSING_PANEL_TYPES = ('edit', 'functionUpper', 'functionLower', 'bendModSens', 'origDelayTimeTsOn', 'origDelayTimeTsOff',
                       'origLfoRateTsOn', 'origLfoRateTsOff')      # used by truth/Script.xml, defined in no script of truth/
WORKER_BASE, WORKER_STRIDE = 0x4D0, 0x80    # job u = HOST + 0x4D0 + 0x80 u (the render's r13 - 0x38)

PROFILE = dict(
    E=J, BASE=J.JP8, SCRIPT_XML=os.path.join(REPO, 'jp8', 'truth', 'Script.xml'),
    DLLMAIN=0x6F726C,                 # the PE entry point (READ)
    INITDLL=0x448710,                 # export InitDll (READ)
    FACTORY=0x36A700,                 # export GetPluginFactory (= JUNO 0x348B40, fw_map)
    CREATE_PROC=0x36B860,             # processor createInstance (the JUNO 0x349CA0 shape: ALLOC 0x3A8, rax = class + 0x110)
    TLS_TEMPLATE=(0xB9E120, 0xB9E13C), TLS_INDEX=0xD278E8,      # the PE TLS directory (READ)
    DATA_DIR='C:\\ProgramData\\Roland Cloud\\JUPITER-8',
    USER_DIR='C:\\Users\\u\\AppData\\Local\\Roland Cloud\\JUPITER-8',
    MODPATH='C:\\Program Files\\Common Files\\VST3\\JUPITER-8.vst3\\Contents\\x86_64-win\\JUPITER-8.vst3',
    INITIALIZE=None,                  # the component vtable's slot 3
    PATCH_LOAD=0x355F90,              # the patch browser's load (the JUNO 0x335850's first 20 instructions, normalized)
    ENGINE_RENDER=JOBS_DUE,           # where the render service stops (see the docstring)
    ZOOM_GET=0, WINDOW_FIT=0,         # the editor: not used by this oracle yet
)


def _load(name, path, **inject):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    mod.__dict__.update(inject)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


W = _load('jp8_wrapper_emu', os.path.join(REPO, 'probes', 'b6', 'wrapper_emu.py'), PROFILE=PROFILE)
H = _load('jp8_host_process_emu', os.path.join(REPO, 'tools', 'verify', 'host_process_emu.py'), W_MODULE=W)
IB = J.IB


class JP8Host(H.HostProcess):
    def __init__(self):
        super().__init__()
        # THE JUPITER-8's SCRIPT FOLDER: its Script.xml draws on eight more script files the plugin ships (truth/:
        # ScriptResourceCmn.xml defines 43 of its bitmaps, the others the About / Auth / Browse / Header / Manage / Setup
        # / Tweak panels) and on its TextCodeTable.dat. Without them its view manager refuses the root panel ("Unable to
        # convert root panel definition", rva 0x2CB0CA) and IComponent::initialize returns E_UNEXPECTED. All of them are
        # the plugin's own files, served as they are; the blank skin images are sized from every script.
        sdir = W._norm(W.SCRIPT_DIR)
        extra = sorted(f for f in os.listdir(os.path.join(REPO, 'jp8', 'truth')) if f.startswith('Script') and f.endswith('.xml')
                       and f != 'Script.xml') + ['TextCodeTable.dat']
        for f in extra:
            self.files[(sdir + '\\' + f).lower()] = open(os.path.join(REPO, 'jp8', 'truth', f), 'rb').read()
        # EIGHT PANEL TYPES the main panel uses are defined in NO script of truth/ (the synth's own edit panels: edit,
        # functionUpper / functionLower, bendModSens, origDelayTimeTsOn / Off, origLfoRateTsOn / Off -- a script file of the
        # plugin's Script folder the truth copy lacks). The view manager refuses the root panel without them ("Unable to
        # find child panel type definition edit"), so they are served EMPTY, as a stub file named for what it is: GUI
        # scaffolding, like the blank skin images, that never reaches the engine. The real file comes from the user.
        stub = ''.join('<panelType><type>%s</type><name>%s</name><position>0,0</position><size>16,16</size></panelType>' % (t, t)
                       for t in MISSING_PANEL_TYPES)
        self.files[(sdir + '\\ScriptMissingPanelsStub.xml').lower()] = ('<?xml version="1.0" encoding="utf-8"?><script>%s</script>'
                                                                         % stub).encode()
        extra = extra + ['ScriptMissingPanelsStub.xml']
        self.dirs[sdir.lower()] = ['Script.xml'] + extra
        # (one text for the sizer; the trailing '<control>' closes the last bitmapRef of ScriptSetupCmn / ScriptTweak,
        # which no later control or panel tag ends -- the sizer's search needs one)
        self.skin = W.skin_sizes(b''.join(self.files[(sdir + '\\' + f).lower()] if f in extra else
                                          open(os.path.join(REPO, 'jp8', 'truth', f), 'rb').read()
                                          for f in ['Script.xml'] + extra if f.endswith('.xml')) + b'<control>')
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

    def setup(self, host_sr, max_block=H.MAXBLOCK, setting=None, state=None):
        """the JUNO oracle's setup (start() after boot_host: setupProcessing, setActive, the host objects), then the
        JUPITER-8's HOST layout: unit u's state / processor / assigner at HOST + 0xA0 / 0xB0 / 0xB8 + 64 u (READ,
        jp8_emu.JX.build) -- the JUNO's +80 / +96 / +104 do not apply here"""
        super().setup(host_sr, max_block, setting=setting, state=state)
        q = lambda a: struct.unpack('<Q', self.uc.mem_read(a, 8))[0]
        self.state = [q(self.HOST + 0xA0 + 64 * i) for i in range(9)]
        self.proc = [q(self.HOST + 0xB0 + 64 * i) for i in range(9)]
        self.assign = [q(self.HOST + 0xB8 + 64 * i) for i in range(9)]
        self.noteobj = None
        return self

    # ------------------------------------------------------------ the UI timer and MIDI learn
    # the core's CC records (core + 24 .. core + 32, 24 bytes each) and their functions -- the JUNO-60's, byte-equal
    # (jx3p/tools/fw_map.py: JUNO 0x319C50 / 0x31AA40 / 0x3192E0 -> 0x325870 / 0x326660 / 0x324F00); the drain is
    # the core's vtable slot 1 (EXECUTED: rva 0x33A290; the JUNO-60's 0x320120 has other bytes)
    CC_INDEX, CC_LEARN, CC_FORGET = 0x325870, 0x326660, 0x324F00

    def ui_drain(self):
        q = lambda a: struct.unpack('<Q', self.uc.mem_read(a, 8))[0]
        return self.call(q(q(self.core) + 8), rcx=self.core, count=2_000_000_000)

    def cc_index_table(self):
        """{parameter id: record index}, from the plugin's own lookup over every record, in index order"""
        q = lambda a: struct.unpack('<Q', self.uc.mem_read(a, 8))[0]
        n = (q(self.core + 32) - q(self.core + 24)) // 24
        self.cc_index = {self.call(IB + self.CC_INDEX, rcx=self.core + 24, rdx=i) & 0xFFFFFFFF: i for i in range(n)}
        return self.cc_index

    def cc_learn(self, pid):
        return self.call(IB + self.CC_LEARN, rcx=self.core + 24, rdx=self.cc_index.get(pid, 0xFFFFFFFF))

    def cc_forget(self, pid):
        if pid in self.cc_index:
            self.call(IB + self.CC_FORGET, rcx=self.core + 24, rdx=self.cc_index[pid])

    # ------------------------------------------------------------ the edit controller's own calls
    # IEditController slots (VST3): 10 getParamStringByValue(id, value, String128), 11 getParamValueByString(id,
    # TChar*, ParamValue&), 12 normalizedParamToPlain(id, value), 13 plainParamToNormalized(id, plain), 14
    # getParamNormalized(id), 15 setParamNormalized(id, value); a ParamValue argument is the third: xmm2 (its upper
    # half 0, both sides), a ParamValue result is xmm0
    def ctl(self, slot, pid, value=0.0, r8=0, r9=0):
        from unicorn.x86_const import UC_X86_REG_XMM0, UC_X86_REG_XMM2
        q = lambda a: struct.unpack('<Q', self.uc.mem_read(a, 8))[0]
        self.uc.reg_write(UC_X86_REG_XMM2, struct.unpack('<Q', struct.pack('<d', value))[0])
        r = self.call(q(q(self.ctrl) + 8 * slot), rcx=self.ctrl, rdx=pid, r8=r8, r9=r9, count=2_000_000_000)
        return r & 0xFFFFFFFF, self.uc.reg_read(UC_X86_REG_XMM0) & 0xFFFFFFFFFFFFFFFF

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
            if getattr(self, 'cxx_throw', None) is not None:     # the plugin threw: no unwinder, a named stop
                t, self.cxx_throw = self.cxx_throw, None
                raise W.PluginThrow(t)
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
    # the smoke run (jp8/logs/host_oracle_first_run.log): boot as a host does, then 12 blocks of 512, a note on at
    # block 2 and off at block 9; per block the worker jobs so far, the peak and the non-finite samples
    import math
    import time
    t0 = time.time()

    def log(m):
        print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
    h = JP8Host()
    h.start(float(sys.argv[1]) if len(sys.argv) > 1 else 48000.0, 512, log=log)
    q = lambda a: struct.unpack('<Q', h.uc.mem_read(a, 8))[0]
    log('started: HOST 0x%x vtable rva 0x%x rate %r voices %d' % (h.HOST, q(h.HOST) - IB, struct.unpack('<f', h.uc.mem_read(h.HOST + 8, 4))[0],
        struct.unpack('<i', h.uc.mem_read(h.HOST + 0x38, 4))[0]))
    for blk in range(12):
        ts = time.time()
        L, R = h.process(512, events=[('on', 0, 0, 60, 0.8)] if blk == 2 else ([('off', 0, 0, 60, 0.5)] if blk == 9 else []))
        f = [struct.unpack('<f', struct.pack('<I', x))[0] for x in L + R]
        log('block %d: jobs %d, peak %.4g, nonfinite %d  (%.1fs)' % (blk, len(h.jobs), max(abs(x) for x in f if math.isfinite(x)),
            sum(1 for x in f if not math.isfinite(x)), time.time() - ts))
