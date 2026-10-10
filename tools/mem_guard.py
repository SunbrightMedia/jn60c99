#!/usr/bin/env python3
"""mem_guard.py -- run a side job beside a memory-heavy one (a parallel make verify) without
risking the heavy one (playbook 195: the kernel's OOM killer takes the LARGEST process, which is
the verify section, not the side job that tipped the machine over).

The command runs as a child; every half second MemAvailable (/proc/meminfo) is read, and when it
falls below the floor the CHILD is killed (its exact pid, never a pattern) and the guard exits 137
with a MEMGUARD line. Otherwise the guard exits with the child's code.

  python3 tools/mem_guard.py FLOOR_GIB -- command args...
  python3 tools/mem_guard.py --tooth      a floor above the machine's memory must kill a sleep
"""
import os
import subprocess
import sys
import time


def avail_gib():
    with open('/proc/meminfo') as fh:
        for line in fh:
            if line.startswith('MemAvailable:'):
                return int(line.split()[1]) / 1048576.0
    raise SystemExit('mem_guard: no MemAvailable in /proc/meminfo')


def guard(floor, cmd):
    child = subprocess.Popen(cmd)
    low = None
    while child.poll() is None:
        a = avail_gib()
        if a < floor:
            low = a
            child.kill()
            child.wait()
            break
        time.sleep(0.5)
    if low is not None:
        print('MEMGUARD: killed pid %d -- MemAvailable %.2f GiB < floor %.2f GiB' % (child.pid, low, floor),
              flush=True)
        return 137
    return child.returncode


def main():
    a = sys.argv[1:]
    if a == ['--tooth']:
        rc = guard(avail_gib() + 1024.0, ['sleep', '30'])
        print('mem_guard --tooth: %s' % ('BITES' if rc == 137 else 'DID NOT BITE (exit %s)' % rc))
        return 0 if rc == 137 else 1
    if len(a) < 3 or a[1] != '--':
        raise SystemExit(__doc__)
    return guard(float(a[0]), a[2:])


if __name__ == '__main__':
    sys.exit(main())
