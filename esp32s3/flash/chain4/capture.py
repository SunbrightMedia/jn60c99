# capture.py -- capture all four CHAIN4 consoles into ONE tagged log.
# Usage: python capture.py COM3 COM4 COM5 COM6
# Opens each port without touching the reset lines, then pulses RTS (EN)
# once on every board so all four boot together and the boot banners land
# in the log. Sends 'r' (robot OFF) to POS1 at t=25 s. Runs 100 s, then
# exits by itself. Output: chain4_log.txt (appended; run_test.bat deletes
# the old one first).
import serial, sys, threading, time

PORTS = sys.argv[1:5]
DUR = 100            # capture seconds; reports come every 10 s
ROBOT_OFF_AT = 25    # send 'r' to POS1 after boot+recall are done

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
        sent_r = False
        buf = b""
        while time.time() - t0 < DUR:
            if idx == 0 and not sent_r and time.time() - t0 > ROBOT_OFF_AT:
                s.write(b"r")
                sent_r = True
                log(tag, "*** capture.py sent 'r' (robot off) ***")
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
