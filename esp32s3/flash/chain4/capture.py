# capture.py -- capture all four CHAIN4 consoles into ONE tagged log.
# Usage: python capture.py COM3 COM4 COM5 COM6
# Opens each port without touching the reset lines, then pulses RTS (EN)
# once on every board so all four boot together and the boot banners land
# in the log. Sends 'r' (robot OFF) to POS1 at t=25 s. Runs 100 s, then
# exits by itself. Output: chain4_log.txt (appended; run_test.bat deletes
# the old one first).
import serial, sys, threading, time

PORTS = sys.argv[1:5]
# optional argv[5] = duration seconds (default 100); argv[6] = robot-off
# second (0 = NEVER send 'r' -- the robot runs the whole capture; that is
# the SOAK configuration, CHAIN4_SOAK.md layers 1+2).
DUR = int(sys.argv[5]) if len(sys.argv) > 5 else 100
ROBOT_OFF_AT = int(sys.argv[6]) if len(sys.argv) > 6 else 25
# The split-probe keys (2026-09-13) are RETIRED: they answered their
# question (prologue 720 confirmed, core-1 voice 4,832 at patch 0) and
# then polluted the rest of that run. A probe key must be removed the
# day its answer lands.
KEYS = [(0, ROBOT_OFF_AT, b"r")] if ROBOT_OFF_AT > 0 else []

lock = threading.Lock()
f = open("chain4_log.txt", "a", encoding="utf-8", errors="replace")

def log(tag, text):
    with lock:
        f.write(tag + text + "\n")
        f.flush()

def worker(idx, port):
    tag = "[POS%d] " % (idx + 1)
    try:
        s = serial.Serial()
        s.port = port
        s.baudrate = 115200
        s.timeout = 1
        # do NOT auto-assert the control lines on open (that can reset or
        # strap the board); we reset deliberately below.
        s.dtr = False
        s.rts = False
        s.open()
        # clean reset into RUN mode: EN low pulse with IO0 left high
        s.rts = True
        time.sleep(0.2)
        s.rts = False
        t0 = time.time()
        sent = set()
        buf = b""
        while time.time() - t0 < DUR:
            for ki, (kidx, kat, kb) in enumerate(KEYS):
                if kidx == idx and ki not in sent and time.time() - t0 > kat:
                    s.write(kb)
                    sent.add(ki)
                    log(tag, "*** capture.py sent %r at t=%d ***" % (kb, kat))
            data = s.read(4096)
            if data:
                buf += data
                while b"\n" in buf:
                    line, buf = buf.split(b"\n", 1)
                    log(tag, line.decode("utf-8", "replace").rstrip("\r"))
        s.close()
        log(tag, "*** capture end ***")
    except Exception as e:
        log(tag, "CAPTURE ERROR: %r" % (e,))

threads = [threading.Thread(target=worker, args=(i, p))
           for i, p in enumerate(PORTS)]
for t in threads: t.start()
for t in threads: t.join()
f.close()
print("capture done -> chain4_log.txt")
