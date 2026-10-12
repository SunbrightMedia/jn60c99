#!/usr/bin/env python3
"""jp8_editor_imports.py -- the census of the JUPITER-8 editor's imports (EXECUTED): boot the host oracle, open the editor
at a 1920 x 1080 screen (attach_editor: createView("editor"), IPlugView::attached) with a spy on every import call, and
print each import's calls, answers and first caller. The C runtime's GUI answers (jp8/src/jp8_host.c gui_import) cover
this list; run it again when a new editor step is added (jp8/logs/editor_imports.log).
    python3 jp8/tools/jp8_editor_imports.py"""
import sys, os, time, collections, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import jp8_host_emu as X
from unicorn.x86_const import UC_X86_REG_RAX, UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9, UC_X86_REG_RSP
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
SPY = [False]; seen = []
cls = X.JP8Host
orig = None
for k in cls.__mro__:
    if '_imp' in k.__dict__: orig = k.__dict__['_imp']; break
def spy(self, uc, address, size, user):
    if SPY[0] and address in self.stub2name:
        dll, name = self.stub2name[address]
        args = [uc.reg_read(r) for r in (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9)]
        caller = struct.unpack('<Q', bytes(uc.mem_read(uc.reg_read(UC_X86_REG_RSP), 8)))[0] - X.IB
        r = orig(self, uc, address, size, user)
        seen.append((name, caller, args, uc.reg_read(UC_X86_REG_RAX)))
        return r
    return orig(self, uc, address, size, user)
cls._imp = spy
h = X.JP8Host()
h.boot_host(log=log)
SPY[0] = True
v = h.attach_editor(1920, 1080)
SPY[0] = False
log('view 0x%x windows %s; %d import calls' % (v, {k: hex(w) for k, w in h.windows.items()}, len(seen)))
by = collections.OrderedDict()
for name, caller, args, rax in seen:
    by.setdefault(name, []).append((caller, args, rax))
for name, L in by.items():
    rets = collections.Counter(r for _, _, r in L)
    print('  %-26s %4d calls, returns %s; first from 0x%06x args %s' % (name, len(L), dict(rets.most_common(4)), L[0][0], ['0x%x' % a for a in L[0][1]]))
