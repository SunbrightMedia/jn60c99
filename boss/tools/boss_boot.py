#!/usr/bin/env python3
"""boss_boot.py -- boot the BOSS plugin under the oracle (boss_emu.BossHost.boot) and save the booted process to
scratchpad/boss/boot.snap, so every later probe resumes in seconds instead of re-running InitDll (~2e9 instructions:
the plugin reads BX00_DATA.BIN one byte per std::istream::get, MEASURED 2026-10-16). Run it via tools/run_job.sh."""
import os
import sys
import time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import boss_emu as B                                                    # noqa: E402

t = time.time()


class Logged(B.BossHost):
    def _imp(self, uc, address, size, user):           # progress: one line per file the plugin opens
        nm = self.stub2name.get(address, ('', ''))[1]
        if nm in ('CreateFileA', 'CreateFileW'):
            print('[%5.0f s] open %s' % (time.time() - t, self.rstr(uc.reg_read(B.UC_X86_REG_RCX), nm.endswith('W'))),
                  flush=True)
        return super()._imp(uc, address, size, user)


h = Logged()
h.boot(log=lambda s: print(s, flush=True))
print('boot %.0f s; unhandled imports %s' % (time.time() - t, h.unhandled.most_common(40)), flush=True)
print('file accesses that missed:', [x for x in h.fslog if (len(x) > 2 and x[2] is False)], flush=True)
os.makedirs(B.SNAP_DIR, exist_ok=True)
out = os.path.join(B.SNAP_DIR, 'boot.snap')
B.save_snapshot(h, out)
print('saved', out, os.path.getsize(out), 'bytes', flush=True)
