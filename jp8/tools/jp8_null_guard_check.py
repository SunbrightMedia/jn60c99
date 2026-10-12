#!/usr/bin/env python3
"""jp8_null_guard_check.py -- the host oracle's zero-page guard (playbook 242), SEEN TO FAIL: boot the plugin, set the host
up, then open the editor WITHOUT the host's IPlugFrame. The JUPITER-8's view calls frame->resizeView through the null
frame (rva 0x448106); the oracle must stop with PluginNullCall naming the call's return address, rva 0x448109 (before the
guard it ran the zero page as code, 524,293 instructions, and went on).
    python3 jp8/tools/jp8_null_guard_check.py          exit 0 = stopped, named, at 0x448109"""
import sys, os, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import jp8_host_emu as X, jp8_host_seq as Q
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
h = X.JP8Host(); h.boot_host(log=log); h.heap_reuse_on(); h.host_setup(48000.0, Q.MAXBLOCK, Q.NPQ)
name = h.scratch('edname'); h.uc.mem_write(name, b'editor\0')
t = h.scratch('edtype'); h.uc.mem_write(t, b'HWND\0')
view = h.vcall(h.ctrl, 17, name, count=4_000_000_000)
log('createView("editor") -> 0x%x; attached with no setFrame' % view)
try:
    r = h.vcall(view, 4, 0x10010, t, count=4_000_000_000)
except X.PluginNullCall as e:
    ok = e.rva == 0x448109
    print('jp8_null_guard_check: %s -- %s' % (e, 'the guard stops it, named' if ok else 'stopped at an unexpected site'))
    sys.exit(0 if ok else 1)
print('jp8_null_guard_check: attached returned 0x%x -- the null frame was NOT stopped' % r)
sys.exit(1)
