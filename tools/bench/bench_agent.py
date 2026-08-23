#!/usr/bin/env python3
"""bench_agent.py -- the unattended two-board bench.

Runs on the user's Windows PC, next to the boards. Loop, once per POLL secs:
  1. git pull the work branch.
  2. If esp32s3/flash/meas/juno_s3.bin changed (sha256), flash BOTH boards
     (esptool, both COM ports in parallel) and reopen the serial monitors.
  3. Continuously capture both boards' serial output into bench/logs/
     comX.log (rotated at 1 MB, previous kept as comX.prev.log).
  4. Every PUSH_EVERY secs, if the logs grew: git add bench/logs, commit,
     push. The remote agent reads them from the branch.

So the human plugs in the boards, runs this once, and walks away. The remote
side pushes a new build; this flashes it and pushes back what the boards
said. Ctrl+C to stop.

usage:  python tools/bench/bench_agent.py [--ports COM5,COM9] [--branch <br>]
needs:  git (repo cloned), python, esptool, pyserial  (all already in use)
"""
import argparse, hashlib, os, shutil, subprocess, sys, threading, time

HERE   = os.path.dirname(os.path.abspath(__file__))
REPO   = os.path.abspath(os.path.join(HERE, "..", ".."))
MEAS   = os.path.join(REPO, "esp32s3", "flash", "meas")
LOGDIR = os.path.join(REPO, "bench", "logs")
POLL       = 20          # s between git pulls
PUSH_EVERY = 60          # s between log pushes
ROTATE     = 1 << 20     # 1 MB per log before rotation
BAUD       = 115200

def sh(args, **kw):
    return subprocess.run(args, cwd=REPO, capture_output=True, text=True, **kw)

def bin_sha():
    p = os.path.join(MEAS, "juno_s3.bin")
    if not os.path.exists(p):
        return None
    return hashlib.sha256(open(p, "rb").read()).hexdigest()

class Monitor(threading.Thread):
    """One serial port -> one growing log file. Reopens on error forever."""
    def __init__(self, port):
        super().__init__(daemon=True)
        self.port = port
        self.path = os.path.join(LOGDIR, port.lower() + ".log")
        self.pause = threading.Event()   # set = stop reading (flash time)
        self.idle  = threading.Event()   # set by us when actually closed
        self.idle.set()

    def run(self):
        import serial
        while True:
            if self.pause.is_set():
                self.idle.set(); time.sleep(0.5); continue
            try:
                with serial.Serial(self.port, BAUD, timeout=1) as s:
                    self.idle.clear()
                    with open(self.path, "ab") as f:
                        f.write(b"\n=== monitor (re)opened %s ===\n"
                                % time.strftime("%Y-%m-%d %H:%M:%S").encode())
                        while not self.pause.is_set():
                            data = s.read(4096)
                            if data:
                                f.write(data); f.flush()
                            if f.tell() > ROTATE:
                                break
                if os.path.getsize(self.path) > ROTATE:
                    prev = self.path.replace(".log", ".prev.log")
                    if os.path.exists(prev):
                        os.remove(prev)
                    os.replace(self.path, prev)
            except Exception as e:
                self.idle.set()
                try:
                    with open(os.path.join(LOGDIR, "agent_err.log"), "a") as ef:
                        ef.write("%s %s: %r\n" % (time.strftime("%H:%M:%S"), self.port, e))
                except OSError:
                    pass
                time.sleep(2)   # port busy/unplugged: retry forever

def flash(ports):
    """esptool both boards in parallel, from MEAS. Returns True if all OK."""
    procs = []
    for p in ports:
        procs.append((p, subprocess.Popen(
            [sys.executable, "-m", "esptool", "--chip", "esp32s3",
             "-b", "460800", "--port", p,
             "--before", "default-reset", "--after", "hard-reset",
             "write-flash", "--flash-mode", "dio", "--flash-size", "8MB",
             "--flash-freq", "80m",
             "0x0", "bootloader.bin", "0x8000", "partitiontable.bin",
             "0x10000", "juno_s3.bin"],
            cwd=MEAS, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True)))
    ok = True
    for p, pr in procs:
        out, _ = pr.communicate()
        open(os.path.join(LOGDIR, "flash_" + p.lower() + ".log"), "w").write(out)
        print("[bench] flash %s: %s" % (p, "OK" if pr.returncode == 0 else "FAILED"))
        ok = ok and pr.returncode == 0
    return ok

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ports", default="COM5,COM9")
    ap.add_argument("--branch", default=None,
                    help="git branch to follow (default: current)")
    a = ap.parse_args()
    ports = [p.strip() for p in a.ports.split(",") if p.strip()]
    os.makedirs(LOGDIR, exist_ok=True)
    branch = a.branch or sh(["git", "rev-parse", "--abbrev-ref", "HEAD"]).stdout.strip()
    print("[bench] repo %s  branch %s  ports %s" % (REPO, branch, ports))
    lock = os.path.join(REPO, ".git", "index.lock")
    if os.path.exists(lock):
        try:
            os.remove(lock)
            print("[bench] removed stale .git/index.lock")
        except OSError as e:
            print("[bench] could not remove index.lock: %r" % e)

    mons = [Monitor(p) for p in ports]
    for m in mons:
        m.start()

    # the last sha actually FLASHED persists across self-restarts -- without
    # this, a self-update restart re-baselines on a freshly-pulled bin and a
    # pending flash is silently lost (paid twice on this bench).
    FLASHED = os.path.join(LOGDIR, "last_flashed.sha")
    last_sha = open(FLASHED).read().strip() if os.path.exists(FLASHED) else None
    last_push = 0.0
    my_sha = hashlib.sha256(open(os.path.abspath(__file__), "rb").read()).hexdigest()
    print("[bench] running. current build %s" % (last_sha or "none")[:12])
    while True:
        try:
            r = sh(["git", "pull", "--rebase", "origin", branch])
            if r.returncode != 0:
                print("[bench] git pull failed:\n" + (r.stderr or r.stdout)[-400:])
            new_me = hashlib.sha256(open(os.path.abspath(__file__), "rb").read()).hexdigest()
            if new_me != my_sha:
                print("[bench] agent updated on the branch -- restarting myself")
                os.execv(sys.executable, [sys.executable, os.path.abspath(__file__)] + sys.argv[1:])
            sha = bin_sha()
            if sha and sha != last_sha:
                print("[bench] NEW BUILD %s -- flashing %s" % (sha[:12], ports))
                for m in mons:
                    m.pause.set()
                for m in mons:
                    m.idle.wait(timeout=10)   # release the COM ports first
                flash(ports)
                for m in mons:
                    m.pause.clear()
                last_sha = sha
                open(FLASHED, "w").write(sha)
            now = time.time()
            if now - last_push > PUSH_EVERY:
                # Windows: git cannot index a file the capture thread holds
                # open for writing -- stage quiescent tail-snapshots instead.
                # WHATEVER fails, the console tails travel in the commit
                # MESSAGE, so the remote side always sees the boards.
                snap = os.path.join(LOGDIR, "push")
                os.makedirs(snap, exist_ok=True)
                diag = []
                staged = False
                for fn in sorted(os.listdir(LOGDIR)):
                    src = os.path.join(LOGDIR, fn)
                    if not (os.path.isfile(src) and fn.endswith(".log")):
                        continue
                    dst = os.path.join(snap, fn)
                    try:
                        data = open(src, "rb").read()[-65536:]
                        with open(dst, "wb") as df:
                            df.write(data)
                    except OSError as e:
                        diag.append("copy %s: %r" % (fn, e)); continue
                    ok = False
                    for attempt in range(2):
                        a = sh(["git", "add", "--", "bench/logs/push/" + fn])
                        if a.returncode == 0:
                            ok = True; break
                        time.sleep(2)
                    if ok:
                        staged = True
                    else:
                        diag.append("add %s (exists=%s size=%s): %s" %
                                    (fn, os.path.exists(dst),
                                     os.path.getsize(dst) if os.path.exists(dst) else -1,
                                     (a.stderr or a.stdout).strip()[-200:]))
                msg = "bench: serial logs " + time.strftime("%Y-%m-%d %H:%M:%S")
                if diag:
                    gv = sh(["git", "--version"]).stdout.strip()
                    msg = ("bench-diag: some staging failed (%s)\n\n" % gv
                           + "\n".join(diag))
                    import re as _re
                    KEY = _re.compile(r"LKA|LKB|LINK:|B4|HEALTH|RECALL:|bit-shift|lock=|hs=|voices allowed|^t=|MSPP: pat=(5|16|21|49) ")
                    for fn in ("com5.log", "com9.log", "agent_err.log"):
                        p = os.path.join(LOGDIR, fn)
                        if os.path.exists(p):
                            try:
                                raw = open(p, "rb").read()[-131072:]
                                txt = raw.decode("utf-8", "replace")
                                keep = [l for l in txt.splitlines() if KEY.search(l)]
                                msg += ("\n\n===== %s (key lines) =====\n" % fn) + \
                                       "\n".join(keep[-40:])
                            except OSError as e:
                                msg += "\n(tail %s failed: %r)" % (fn, e)
                c = sh(["git", "commit", "--allow-empty", "-m", msg])
                committed = c.returncode == 0
                if not committed:
                    print("[bench] commit failed: " +
                          (c.stderr or c.stdout).strip()[-300:])
                else:
                    pr = sh(["git", "push", "origin", branch])
                    if pr.returncode != 0:
                        sh(["git", "pull", "--rebase", "origin", branch])
                        pr = sh(["git", "push", "origin", branch])
                    print("[bench] pushed (staged=%s diag=%d)" % (staged, len(diag))
                          if pr.returncode == 0 else
                          "[bench] PUSH FAILED: " + (pr.stderr or pr.stdout)[-300:])
                last_push = now
            time.sleep(POLL)
        except KeyboardInterrupt:
            print("\n[bench] stopped.")
            return

if __name__ == "__main__":
    main()
