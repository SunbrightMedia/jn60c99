# soak.py -- CHAIN4 ONE-HOUR SOAK with LIVE monitoring.
#
# Runs on the bench PC, next to bench.py, and REUSES its GitHub upload +
# flash machinery (token, download_set, flash_all). It flashes the current
# staged build, then captures all four consoles for one hour with the robot
# storm ON, and every UPLOAD_EVERY seconds uploads a SMALL status file to the
# bench-logs branch so a remote watcher can tell "alive and healthy" from
# "the laptop died" -- without waiting the whole hour.
#
# The status file (logs/SOAK_<version>.txt) is overwritten in place each
# interval and holds: a heartbeat (elapsed / wall clock / line count), the
# CUMULATIVE fault flags for the WHOLE run so far (a MUTE 30 min ago is not
# lost from the rolling tail), the latest health line per board, and the last
# TAIL_LINES of console output. The FULL log is kept locally as
# logs/SOAK_<version>_full.txt for the final send.
#
# Robot: ON at t=2 s, OFF at t=SOAK_SECS-60 -- the last minute proves the
# storm-off end state is SILENT (SHIP LAW), on top of 59 min of worst-case
# storm (CHAIN4_SOAK.md layers 1+2).
#
# Usage on the bench PC:   python tools/bench/soak.py
#   (set the four COM ports in bench.py PORTS if they ever change.)
import os, sys, time, threading
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bench                                   # token, gh, put_file, flash...

SOAK_SECS    = 3600      # one hour
ROBOT_ON     = 2
ROBOT_OFF    = SOAK_SECS - 60   # storm off for the last minute -> SILENT
UPLOAD_EVERY = 120       # a fresh status file every 2 min (watcher polls ~10)
TAIL_LINES   = 400

def main():
    if not bench.selftest():
        sys.exit(1)
    v = bench.get_file(bench.FWDIR + "/VERSION.txt", bench.BRANCH).decode().strip()
    bench.say("SOAK build %s -- close any miniterm windows now (20 s grace)" % v)
    time.sleep(20)
    bench.download_set(v)
    bench.flash_all()

    import serial
    lock  = threading.Lock()
    lines = []
    # cumulative health, scanned as lines arrive so nothing scrolls out of view
    seen  = {"MUTE": 0, "STUCK": 0, "HALT": 0, "FLASH POS": 0}
    maxun = [0, 0, 0, 0]
    lasthealth = ["", "", "", ""]
    lastmix    = ["", "", "", ""]

    def scan(idx, ln):
        for k in seen:
            if k in ln:
                seen[k] += 1
        if "[LISTEN" in ln and "un=" in ln:
            lasthealth[idx] = ln
            try:
                u = int(ln.split("un=", 1)[1].split()[0])
                if u > maxun[idx]:
                    maxun[idx] = u
            except Exception:
                pass
        if "CHAINup" in ln and "mix=" in ln:
            lastmix[idx] = ln

    t_start = time.time()
    stop    = t_start + SOAK_SECS
    keys    = [(ROBOT_ON, b"r"), (ROBOT_OFF, b"r")]

    def reader(idx, port):
        tag = "[POS%d] " % (idx + 1)
        try:
            s = serial.Serial(port, 115200, timeout=1)
        except Exception as e:
            with lock:
                lines.append(tag + "OPEN FAILED: %s" % e)
            return
        t0, sent, buf = time.time(), [], b""
        while time.time() < stop:
            if idx == 0:
                for at, b in keys:
                    if at not in sent and time.time() - t0 >= at:
                        try: s.write(b)
                        except Exception: pass
                        sent.append(at)
            try:
                chunk = s.read(4096)
            except Exception:
                break
            if chunk:
                buf += chunk
                while b"\n" in buf:
                    raw, buf = buf.split(b"\n", 1)
                    ln = tag + raw.decode("utf-8", "replace").rstrip()
                    with lock:
                        lines.append(ln)
                        scan(idx, ln)
        try: s.close()
        except Exception: pass

    ths = [threading.Thread(target=reader, args=(i, p), daemon=True)
           for i, p in enumerate(bench.PORTS)]
    for t in ths:
        t.start()

    local = os.path.join(bench.HERE, "logs")
    os.makedirs(local, exist_ok=True)
    fullpath = os.path.join(local, "SOAK_%s_full.txt" % v)
    name = "SOAK_%s.txt" % v

    def status(done):
        with lock:
            n    = len(lines)
            tail = lines[-TAIL_LINES:]
            allc = "\n".join(lines)
        el   = int(time.time() - t_start)
        robot = "OFF (silence check)" if el >= ROBOT_OFF else "ON"
        head = [
            "==== CHAIN4 SOAK  build %s ====" % v,
            "SOAK t=%d / %d s   wall=%s   lines=%d   robot=%s   %s"
            % (el, SOAK_SECS, time.strftime("%Y-%m-%d %H:%M:%S"), n, robot,
               "COMPLETE" if done else "RUNNING"),
            "SEEN (whole run): mute=%d stuck=%d halt=%d flashfail=%d"
            % (seen["MUTE"], seen["STUCK"], seen["HALT"], seen["FLASH POS"]),
            "max un: pos1=%d pos2=%d pos3=%d pos4=%d"
            % (maxun[0], maxun[1], maxun[2], maxun[3]),
        ]
        for i in range(4):
            if lasthealth[i]: head.append("last " + lasthealth[i])
        for i in range(4):
            if lastmix[i]:    head.append("last " + lastmix[i])
        head.append("---- last %d lines ----" % len(tail))
        text = "\n".join(head) + "\n" + "\n".join(tail) + "\n"
        if done:
            text += "==== SOAK COMPLETE ====\n"
        try:
            with open(fullpath, "w", encoding="utf-8") as f:
                f.write("==== SOAK build %s ====\n" % v + allc + "\n")
        except Exception:
            pass
        bench.upload_log(name, text)

    nextup = time.time() + UPLOAD_EVERY
    status(False)                              # one immediately, so the watcher
                                               # sees the run started
    while time.time() < stop:
        time.sleep(2)
        if time.time() >= nextup:
            status(False)
            nextup += UPLOAD_EVERY
    for t in ths:
        t.join(5)
    status(True)
    bench.say("SOAK COMPLETE -- full log at %s ; status at logs/%s" % (fullpath, name))

if __name__ == "__main__":
    main()
