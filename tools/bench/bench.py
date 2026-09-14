#!/usr/bin/env python3
# bench.py -- THE UNATTENDED BENCH (2026-09-14).
#
# Runs on the user's Windows PC, forever. Removes the user from the loop:
#   1. Every 60 s it asks GitHub for esp32s3/flash/chain4/VERSION.txt on
#      the work branch.
#   2. When the version changes, it downloads the four three-bin sets,
#      flashes all four boards (COM3..COM6, sequentially), then captures
#      all four consoles for CAP_SECS seconds -- robot ON at t=2, OFF at
#      t=60, so the silence probe judges the end state.
#   3. It uploads the combined log to the `bench-logs` branch and goes
#      back to watching. All analysis happens on the far side.
#
# DEFENSIVE BY DESIGN: pure stdlib + pyserial + esptool (both already on
# this PC). A failed cycle prints why, uploads the error if it can, and
# retries on the next poll. It never deletes anything. The GitHub token
# stays in bench_token.txt on this PC and is sent ONLY to api.github.com.
import base64, json, os, subprocess, sys, threading, time
import urllib.request, urllib.error

OWNER   = "SunbrightMedia"
REPO    = "jn60c99"
BRANCH  = "claude/session-recap-j7evnx"     # where builds appear
LOGBR   = "bench-logs"                      # where logs go back
FWDIR   = "esp32s3/flash/chain4"            # staged sets in the repo
PORTS   = ["COM3", "COM4", "COM5", "COM6"]  # pos1..pos4, in order
CAP_SECS   = 150      # capture length per cycle
ROBOT_ON   = 2        # 'r' to POS1: storm on
ROBOT_OFF  = 60       # 'r' to POS1: storm off -> silence must follow
POLL_SECS  = 60
API     = "https://api.github.com"
HERE    = os.path.dirname(os.path.abspath(__file__))

def say(msg):
    print(time.strftime("[%H:%M:%S] ") + msg, flush=True)

def token():
    p = os.path.join(HERE, "bench_token.txt")
    if not os.path.exists(p):
        say("MISSING bench_token.txt -- see README_BENCH.txt step 3")
        sys.exit(1)
    with open(p) as f:
        t = f.read().strip()
    if len(t) < 20:
        say("bench_token.txt looks empty or truncated")
        sys.exit(1)
    return t

def gh(path, data=None, method="GET"):
    req = urllib.request.Request(
        API + path, data=data, method=method,
        headers={"Authorization": "Bearer " + token(),
                 "Accept": "application/vnd.github+json",
                 "User-Agent": "juno-bench"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())

def get_file(path, ref):
    """Contents API; falls back to the blob API for files over 1 MB."""
    j = gh("/repos/%s/%s/contents/%s?ref=%s" % (OWNER, REPO, path, ref))
    if j.get("encoding") == "base64" and j.get("content"):
        return base64.b64decode(j["content"])
    b = gh("/repos/%s/%s/git/blobs/%s" % (OWNER, REPO, j["sha"]))
    return base64.b64decode(b["content"])

def put_file(path, data, msg):
    url = "/repos/%s/%s/contents/%s" % (OWNER, REPO, path)
    body = {"message": msg, "branch": LOGBR,
            "content": base64.b64encode(data).decode()}
    try:
        cur = gh(url + "?ref=" + LOGBR)
        body["sha"] = cur["sha"]
    except Exception:
        pass
    gh(url, json.dumps(body).encode(), "PUT")

def upload_log(name, text):
    try:
        put_file("logs/" + name, text.encode("utf-8", "replace"),
                 "bench: " + name)
        say("log uploaded: " + name)
    except Exception as e:
        say("LOG UPLOAD FAILED (%s) -- kept locally only" % e)

def download_set(version):
    fw = os.path.join(HERE, "fw")
    for pos in (1, 2, 3, 4):
        d = os.path.join(fw, "pos%d" % pos)
        os.makedirs(d, exist_ok=True)
        for f in ("bootloader.bin", "partitiontable.bin", "juno_s3.bin"):
            data = get_file("%s/pos%d/%s" % (FWDIR, pos, f), BRANCH)
            floor = 100000 if f == "juno_s3.bin" else 1000
            if len(data) < floor:
                raise RuntimeError("%s pos%d too small (%d B)"
                                   % (f, pos, len(data)))
            with open(os.path.join(d, f), "wb") as out:
                out.write(data)
        say("downloaded pos%d (%s)" % (pos, version))

def flash_all():
    for pos, port in enumerate(PORTS, start=1):
        d = os.path.join(HERE, "fw", "pos%d" % pos)
        cmd = [sys.executable, "-m", "esptool", "--chip", "esp32s3",
               "-p", port, "-b", "460800", "--before", "default-reset",
               "--after", "hard-reset", "write-flash",
               "--flash-mode", "dio", "--flash-size", "8MB",
               "--flash-freq", "80m",
               "0x0",     os.path.join(d, "bootloader.bin"),
               "0x8000",  os.path.join(d, "partitiontable.bin"),
               "0x10000", os.path.join(d, "juno_s3.bin")]
        say("flashing pos%d on %s ..." % (pos, port))
        if subprocess.call(cmd) != 0:
            raise RuntimeError("flash FAILED on pos%d (%s)" % (pos, port))
    say("all four boards flashed")

def capture(version):
    import serial                       # pyserial, already on this PC
    lock = threading.Lock()
    lines = []
    stop = time.time() + CAP_SECS
    keys = [(ROBOT_ON, b"r"), (ROBOT_OFF, b"r")]

    def reader(idx, port):
        tag = "[POS%d] " % (idx + 1)
        try:
            s = serial.Serial(port, 115200, timeout=1)
        except Exception as e:
            with lock:
                lines.append(tag + "OPEN FAILED: %s" % e)
            return
        t0 = time.time()
        sent = []
        buf = b""
        while time.time() < stop:
            if idx == 0:
                for at, b in keys:
                    if at not in sent and time.time() - t0 >= at:
                        try:
                            s.write(b)
                        except Exception:
                            pass
                        sent.append(at)
            try:
                chunk = s.read(4096)
            except Exception:
                break
            if chunk:
                buf += chunk
                while b"\n" in buf:
                    ln, buf = buf.split(b"\n", 1)
                    with lock:
                        lines.append(tag +
                                     ln.decode("utf-8", "replace").rstrip())
        try:
            s.close()
        except Exception:
            pass

    ths = [threading.Thread(target=reader, args=(i, p), daemon=True)
           for i, p in enumerate(PORTS)]
    for t in ths:
        t.start()
    for t in ths:
        t.join(CAP_SECS + 15)
    text = ("==== BENCH version %s  %s ====\n"
            % (version, time.strftime("%Y-%m-%d %H:%M:%S"))
            + "\n".join(lines) + "\n==== BENCH END ====\n")
    name = time.strftime("%Y%m%d_%H%M%S_") + version.strip() + ".txt"
    local = os.path.join(HERE, "logs")
    os.makedirs(local, exist_ok=True)
    with open(os.path.join(local, name), "w", encoding="utf-8") as f:
        f.write(text)
    say("captured %d lines" % len(lines))
    return name, text

def selftest():
    ok = True
    say("selftest: python %s" % sys.version.split()[0])
    try:
        import serial
        say("selftest: pyserial OK")
    except Exception as e:
        say("selftest: pyserial MISSING (%s)" % e); ok = False
    r = subprocess.call([sys.executable, "-m", "esptool", "version"],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL)
    say("selftest: esptool %s" % ("OK" if r == 0 else "MISSING")); ok &= r == 0
    try:
        v = get_file(FWDIR + "/VERSION.txt", BRANCH).decode().strip()
        say("selftest: GitHub OK, current build version %s" % v)
    except Exception as e:
        say("selftest: GitHub FAILED (%s) -- check bench_token.txt" % e)
        ok = False
    say("selftest: %s" % ("ALL PASS" if ok else "FIX THE ITEMS ABOVE"))
    return ok

def main():
    if not selftest():
        sys.exit(1)
    lastf = os.path.join(HERE, "last_flashed.txt")
    last = open(lastf).read().strip() if os.path.exists(lastf) else ""
    say("watching for new builds (last flashed: %s)" % (last or "none"))
    while True:
        try:
            v = get_file(FWDIR + "/VERSION.txt", BRANCH).decode().strip()
            if v and v != last:
                say("NEW BUILD %s -- close any miniterm windows now "
                    "(20 s grace)" % v)
                time.sleep(20)
                download_set(v)
                flash_all()
                name, text = capture(v)
                upload_log(name, text)
                last = v
                with open(lastf, "w") as f:
                    f.write(v)
                say("cycle complete; boards keep playing; watching again")
        except Exception as e:
            say("CYCLE FAILED: %s -- retrying in %d s" % (e, POLL_SECS))
            try:
                upload_log(time.strftime("%Y%m%d_%H%M%S_ERROR.txt"),
                           "bench cycle failed: %s\n" % e)
            except Exception:
                pass
        time.sleep(POLL_SECS)

if __name__ == "__main__":
    main()
