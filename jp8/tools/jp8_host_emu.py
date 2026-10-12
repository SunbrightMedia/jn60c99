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
import collections
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
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RSP, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8  # noqa: E402

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
    ZOOM_GET=0x2ACC30, WINDOW_FIT=0x31B790,  # the editor (jp8_fw_near.py leads, EXECUTED 2026-10-12: attach_editor's fit
                                      # fires on the 3940 x 2004 main panel window; its getter returns 37 at 1920 x 1080)
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
IID_IMIDIMAPPING = W.vst_iid(0xDF0FF9F7, 0x49B74669, 0xB63AB732, 0x7ADBF5E5)
IID_IUNITINFO = W.vst_iid(0x3D4BD6B5, 0x913A4FD2, 0xA886E768, 0xA5EB92C1)
# THE HOST'S SCRATCH AREA (host_setup; jp8_host.c the same): one block of the host-object area for every buffer a host
# call hands the plugin, at fixed offsets, cleared before each use -- (offset, size)
SCR = dict(setup=(0x0, 24), qi=(0x20, 0x40), str=(0x60, 256), text=(0x160, 256), val=(0x260, 8), info=(0x270, 792),
           unit=(0x590, 268), vec=(0x6A0, 24), patch=(0x6C0, 0x10000), edname=(0x106C0, 16), edtype=(0x106D0, 16))
SCR_SIZE = 0x106E0


class PluginNullCall(RuntimeError):
    """the plugin jumped into the zero page (a call through a null pointer): on a PC an access violation; .rva: the
    return address of the call that went there"""
    def __init__(self, rva):
        super().__init__('the plugin called into the zero page (a null pointer; from rva 0x%x)' % rva)
        self.rva = rva


class JP8Host(H.HostProcess):
    def __init__(self):
        super().__init__()
        # THE ZERO PAGE IS NEVER CODE (playbook 242): the oracle maps the low 1 MB (jp8_emu: data the plugin reads near
        # null), so a call through a null pointer would run its zeros as `add [rax], al` up to a RET -- a stop by name
        # instead (PluginNullCall), as a PC faults
        self.null_exec = None

        def _null_exec(uc_, addr, size, ud):
            if self.null_exec is None:
                self.null_exec = struct.unpack('<Q', bytes(uc_.mem_read(uc_.reg_read(UC_X86_REG_RSP), 8)))[0] - IB
            uc_.emu_stop()
        self.uc.hook_add(H.UC_HOOK_CODE, _null_exec, begin=0, end=0xFFFFF)
        # v8 (E1): THE HOST'S IPlugFrame. A host sets one on every view before attached (VST3: createView, setFrame,
        # attached); the JUPITER-8's view calls frame->resizeView with no null check (rva 0x448106; without a frame the
        # oracle ran the zero page at address 0 as code, 524,293 instructions, where a PC faults), then its own onSize.
        # Made with the host's other objects, so the template holds the vtable and the one frame (fact 'frame').
        self.vt['frame'] = self._vtable('frame', 4)
        self.frame = self.new_obj('frame')
        self.frame_sizes = []                     # every resizeView's new size: (left, top, right, bottom)
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
        self._live = None              # the heap's reuse layer (heap_reuse_on): block -> size; free lists by size
        self._freel = None
        self.scr = None                # the scratch area and the one stream object (host_setup)
        self._stream1 = None
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

    # ------------------------------------------------------------ the host's heap: freed blocks reused (v6)
    # PLUMBING: the plugin's malloc / free end in the host's HeapAlloc / HeapFree, which this oracle answers (jp8_emu
    # JX.bump: a bump pointer, HeapFree a no-op). With nothing ever reused, a long session runs out of heap: every patch
    # load took 1.32 MB, every process() block 8 KB (MEASURED 2026-10-12). From heap_reuse_on() a block the plugin frees
    # (HeapFree's r8; free / operator delete's rcx) goes on the free list of its rounded size, and the next allocation of
    # that size takes the last one back (LIFO), zero-filled as a new block; a block allocated before (the boot) is never
    # reused. jp8_rt.c (jp8_heap_reuse) has the same rule: the two sides keep the same addresses. MEASURED with it: 160
    # patch loads cycling the 64 factory patches grow the heap 31 MB and then stop (the plugin keeps 259 blocks).
    def heap_reuse_on(self):
        self._live, self._freel = {}, collections.defaultdict(list)

    def bump(self, sz):
        if self._live is None:
            return super().bump(sz)
        r = (sz + 15) & ~15 or 16
        if r > 0x2000000:
            r = 0x2000000
        fl = self._freel.get(r)
        if fl:
            p = fl.pop()
            self.uc.mem_write(p, b'\0' * r)
        else:
            p = super().bump(sz)
        self._live[p] = r
        return p

    def _imp(self, uc, address, size, user):
        if self._live is not None:
            nm = self.stub2name.get(address)
            if nm is not None and nm[1] in ('HeapFree', 'free', '??3@YAXPEAX@Z'):
                if self._in_job:
                    raise RuntimeError('a worker job frees a block (the threaded transport assumes none does)')
                r = self._live.pop(uc.reg_read(UC_X86_REG_R8 if nm[1] == 'HeapFree' else UC_X86_REG_RCX), None)
                if r is not None:
                    self._freel[r].append(uc.reg_read(UC_X86_REG_R8 if nm[1] == 'HeapFree' else UC_X86_REG_RCX))
        return super()._imp(uc, address, size, user)

    # ------------------------------------------------------------ the host's setup and its scratch (v6)
    def scratch(self, name):
        """the address of a scratch slot, cleared"""
        off, n = SCR[name]
        self.uc.mem_write(self.scr + off, b'\0' * n)
        return self.scr + off

    def _qi(self, iid):
        b = self.scratch('qi')
        self.uc.mem_write(b, iid)
        r = self.vcall(self.ctrl, 0, b, b + 0x30) & 0xFFFFFFFF
        if r:
            raise RuntimeError('the controller does not answer an interface (0x%x)' % r)
        return struct.unpack('<Q', self.uc.mem_read(b + 0x30, 8))[0]

    def host_setup(self, host_sr, max_block, npq):
        """the host's setup as jp8h_init makes it (jp8_host.c, in this order): setup() (setupProcessing, setActive(1), the
        blocks' objects), npq parameter queues, the CC records' ids (the plugin's own lookup), the scratch area, the
        controller's IMidiMapping and IUnitInfo (queryInterface), its parameter and unit counts, the one stream object
        every state call reuses"""
        self.setup(host_sr, max_block)
        while len(self._pq) < npq:
            self._pq.append(self.new_obj('pqueue', id=0, points=[]))
        self.cc_index_table()
        self.scr = self.alloc_com(SCR_SIZE)
        self.mm = self._qi(IID_IMIDIMAPPING)
        self.ui = self._qi(IID_IUNITINFO)
        self.nparam = self.vcall(self.ctrl, 8) & 0xFFFFFFFF       # the bounds jp8h_param_info / _unit_info check (an
        self.nunit = self.vcall(self.ui, 3) & 0xFFFFFFFF          # index past them makes the plugin throw)
        self._stream1 = self.new_obj('stream', data=bytearray(), pos=0)
        return self

    def stream(self, data=b''):
        if self._stream1 is None:
            return super().stream(data)
        o = self.objs[self._stream1]
        o['data'], o['pos'] = bytearray(data), 0
        return self._stream1

    def load_patch(self, rec_tail):
        """the plugin's own patch load (wrapper_emu.load_patch), the record in the scratch area once host_setup ran"""
        if self.scr is None:
            return super().load_patch(rec_tail)
        q = lambda a: struct.unpack('<Q', self.uc.mem_read(a, 8))[0]
        if len(rec_tail) + 16 > SCR['patch'][1]:
            raise ValueError('a record of %d bytes: above the scratch area' % len(rec_tail))
        data, vec = self.scratch('patch'), self.scratch('vec')
        self.uc.mem_write(data, rec_tail)
        self.uc.mem_write(vec, struct.pack('<QQQ', data, data + len(rec_tail), data + len(rec_tail)))
        n0 = len(self.queue())
        self.call(W.PATCH_LOAD, rcx=vec, rdx=q(self.comp + 280 + 8), r8=0, r9=0, count=4_000_000_000)
        return self.queue()[n0:]

    def setup_processing(self, host_sr, max_block=None):
        """host_process_emu.setup_processing, the ProcessSetup in the scratch area once host_setup ran"""
        if self.scr is None:
            return super().setup_processing(host_sr, max_block)
        mb = self.max_block if max_block is None else max_block
        if mb > self.max_block:
            raise ValueError('max block %d above the %d start() allocated' % (mb, self.max_block))
        setup = self.scratch('setup')
        self.uc.mem_write(setup, struct.pack('<iii4xd', 0, 0, mb, float(host_sr)))
        r = self.vcall(self.audio, 7, setup, count=4_000_000_000) & 0xFFFFFFFF
        if r != 0:
            raise RuntimeError('setupProcessing -> 0x%x' % r)
        self.host_sr = float(host_sr)

    # ------------------------------------------------------------ the editor (v8, E1)
    def editor_attach(self):
        """the host opens the plugin's editor: IEditController::createView("editor"), IPlugView::attached on a parent
        window -- host_process_emu.attach_editor's calls, the two strings in the scratch (the host-object area grows only
        by what the plugin itself asks for). Each window the plugin lays out is found by its fit's call (WINDOW_FIT):
        self.windows[(w, h)] = the window (w x h: its panel's Script.xml size). The screen is self.screen."""
        uc = self.uc
        if not hasattr(self, 'windows'):
            self.windows = {}

            def on_fit(uc_, addr, size, ud):
                this = uc_.reg_read(UC_X86_REG_RCX)
                r = struct.unpack('<4i', uc_.mem_read(this + 0x18, 16))
                self.windows[(r[2] - r[0], r[3] - r[1])] = this
            uc.hook_add(H.UC_HOOK_CODE, on_fit, begin=H.WINDOW_FIT, end=H.WINDOW_FIT)
        name = self.scratch('edname'); uc.mem_write(name, b'editor\0')
        t = self.scratch('edtype'); uc.mem_write(t, b'HWND\0')
        view = self.vcall(self.ctrl, 17, name, count=4_000_000_000)          # IEditController::createView
        if not view:
            raise RuntimeError('createView("editor") gave no view')
        if self.vcall(view, 12, self.frame, count=4_000_000_000) & 0xFFFFFFFF:  # IPlugView::setFrame (the host's frame)
            raise RuntimeError('setFrame refused')
        r = self.vcall(view, 4, 0x10010, t, count=4_000_000_000) & 0xFFFFFFFF   # IPlugView::attached
        self.view = view
        return view, r

    def gui_state(self):
        """the oracle's own answers the GUI's imports keep between calls (wrapper_emu / jp8_emu), for the template:
        the DIB sections (CreateDIBSection / GetObjectA), the interlocked singly linked lists, the GDI+ images, the
        skin images' sizes by file name (GdipCreateBitmapFromFile), the last error"""
        return dict(dibs=sorted(self.__dict__.get('dibs', {}).items()),
                    slists=sorted((k, list(v)) for k, v in self.__dict__.get('slists', {}).items()),
                    gdip=sorted((k, (v['w'], v['h'], v['fmt'])) for k, v in self.__dict__.get('gdip_imgs', {}).items()),
                    skin=sorted(self.skin.items()), lasterr=getattr(self, 'lasterr', 0))

    def _com(self, uc, name, this, a1, a2, a3):
        """v8 (E1): the host's IPlugFrame -- resizeView(view, newSize) is taken (the size recorded, kResultTrue); the
        plugin then calls its own onSize. QueryInterface, addRef, release: the wrapper's (E_NOINTERFACE, 1, 1)."""
        if name.startswith('COM:frame:') and int(name.rsplit(':', 1)[1]) >= 3:
            if int(name.rsplit(':', 1)[1]) == 3:
                self.frame_sizes.append(struct.unpack('<4i', uc.mem_read(a2, 16)))
                return self._ret(uc, 0)
            return self._ret(uc, 0x80004001)      # E_NOTIMPL (IPlugFrame has three methods past IUnknown's)
        return super()._com(uc, name, this, a1, a2, a3)

    # ------------------------------------------------------------ one step of the host gate's drive (jp8_host_seq)
    def run_step(self, st, blob, variant, states, cstates):
        """one step as the host makes it (jp8_host_seq.steps; jp8_host_c.py makes the same through the C API): blob(p)
        a patch's record, variant(bytes, how) the drive's state edits, states / cstates the component's / controller's
        states kept by key; returns (the result row, the output words, the state bytes) -- shared by the references
        and the reach"""
        uc = self.uc
        k = st[0]; words = b''; sbytes = b''
        u32 = lambda v: v & 0xFFFFFFFF
        if k == 'patch':
            self.load_patch(blob(st[1])); row = [k, st[1], 0]
        elif k == 'block':
            _, n, evs, pars, ctx = st
            L, R = self.process(n, events=evs, params=pars, ctx=ctx)
            words = struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R); row = [k, n, 0]
        elif k == 'getstate':
            sbytes = self.get_state(); states[st[1]] = sbytes; row = [k, st[1], len(sbytes)]
        elif k == 'setstate':
            row = [k, '%s/%s' % (st[1], st[2]), self.set_state(variant(states[st[1]], st[2]))]
        elif k == 'rate':
            self.set_active(0); self.setup_processing(st[1]); self.set_active(1); row = [k, st[1], 0]
        elif k == 'active':
            self.set_active(st[1]); row = [k, st[1], 0]
        elif k == 'ctl':
            _, op, pid, arg = st
            if op == 'str':
                b = self.scratch('str'); r, x = self.ctl(10, pid, arg, 0, b); x = 0; extra = bytes(uc.mem_read(b, 256)).hex()
            elif op == 'parse':
                t = arg.encode('utf-16-le') + b'\0\0'
                if len(t) > SCR['text'][1]:
                    raise ValueError('a text of %d characters' % len(arg))
                sp = self.scratch('text'); uc.mem_write(sp, t); vp = self.scratch('val')
                r, x = self.ctl(11, pid, 0.0, sp, vp); x = 0; extra = bytes(uc.mem_read(vp, 8)).hex()   # (xmm0: not a result)
            else:
                r, x = self.ctl({'get': 14, 'set': 15, 'plain': 12, 'norm': 13}[op], pid, arg); extra = ''
            row = [k, '%s/%x/%r' % (op, pid, arg), r, x, extra]
        elif k == 'drain':
            self.ui_drain(); row = [k, 0, 0]
        elif k == 'learn':
            self.cc_learn(st[1]); row = [k, st[1], 0]
        elif k == 'forget':
            self.cc_forget(st[1]); row = [k, st[1], 0]
        elif k == 'compstate':
            r = u32(self.vcall(self.ctrl, 5, self.stream(variant(states[st[1]], st[2])), count=4_000_000_000))
            row = [k, '%s/%s' % (st[1], st[2]), r]
        elif k == 'info':
            row = self.info_step(st[1:], cstates)
        elif k == 'screen':                       # v8: the machine's virtual screen (GetSystemMetrics 78 / 79)
            self.screen = {0x4E: st[1], 0x4F: st[2]}; row = [k, '%dx%d' % (st[1], st[2]), 0]
        elif k == 'editor':                       # v8: the editor opened (E1)
            view, r = self.editor_attach()
            fs = self.frame_sizes[-1] if self.frame_sizes else (0, 0, 0, 0)
            row = [k, ' '.join('%dx%d' % wh for wh in sorted(self.windows)), r, view, '%dx%d' % (fs[2] - fs[0], fs[3] - fs[1]),
                   len(self.frame_sizes)]
        elif k == 'zoomconv':                     # v8: a coordinate conversion of a panel window: its zoom getter
            row = [k, '%dx%d' % (st[1], st[2]), self.window_conv((st[1], st[2]))]
        else:
            raise SystemExit('unknown step %r' % (st,))
        return row, words, sbytes

    def info_step(self, a, cstates):
        """the controller's information calls (jp8_host_seq: 'info'); the row the C driver makes too"""
        uc = self.uc
        u32 = lambda v: v & 0xFFFFFFFF
        what = a[0]; tag = '/'.join(str(x) for x in a)
        if what == 'count':
            return ['info', tag, u32(self.vcall(self.ctrl, 8)), '']
        if what == 'param':
            b = self.scratch('info'); r = u32(self.vcall(self.ctrl, 9, a[1], b))
            return ['info', tag, r, bytes(uc.mem_read(b, 792)).hex()]
        if what == 'midi':
            # getMidiControllerAssignment(bus, channel, number, ParamID&): the fourth argument at [rsp + 0x28] at entry
            b = self.scratch('val'); fn = struct.unpack('<Q', uc.mem_read(struct.unpack('<Q', uc.mem_read(self.mm, 8))[0] + 24, 8))[0]
            uc.mem_write(self._top() - 8 + 0x28, struct.pack('<Q', b))
            r = u32(self.call(fn, rcx=self.mm, rdx=a[1], r8=a[2], r9=a[3], count=2_000_000_000))
            return ['info', tag, r, bytes(uc.mem_read(b, 4)).hex()]
        if what == 'units':
            return ['info', tag, u32(self.vcall(self.ui, 3)), '']
        if what == 'unit':
            b = self.scratch('unit'); r = u32(self.vcall(self.ui, 4, a[1], b))
            return ['info', tag, r, bytes(uc.mem_read(b, 268)).hex()]
        if what == 'lists':
            return ['info', tag, u32(self.vcall(self.ui, 5)), '']
        if what == 'selected':
            return ['info', tag, u32(self.vcall(self.ui, 11)), '']
        if what == 'select':
            return ['info', tag, u32(self.vcall(self.ui, 12, a[1])), '']
        if what == 'cgetstate':
            st = self.stream(); r = u32(self.vcall(self.ctrl, 7, st)); cstates[a[1]] = bytes(self.objs[st]['data'])
            return ['info', tag, r, cstates[a[1]].hex()]
        if what == 'csetstate':
            return ['info', tag, u32(self.vcall(self.ctrl, 6, self.stream(cstates[a[1]]))), '']
        raise SystemExit('unknown info step %r' % (a,))

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
            if self.null_exec is not None:                        # a call through a null pointer: a named stop
                t, self.null_exec = self.null_exec, None
                raise PluginNullCall(t)
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
