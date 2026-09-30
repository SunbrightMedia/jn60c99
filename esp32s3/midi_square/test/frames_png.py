#!/usr/bin/env python3
"""frames.txt (from ui_frames) -> one contact-sheet PNG, OLED look, 3x scale."""
import sys, zlib, struct
src, dst = sys.argv[1], sys.argv[2]
frames, cur, lab = [], None, None
for line in open(src):
    line = line.rstrip("\n")
    if line and line[0] not in ".#":
        if cur: frames.append((lab, cur))
        lab, cur = line, []
    else:
        cur.append(line)
if cur: frames.append((lab, cur))
S, PAD, COLS = 3, 6, 2
fw, fh = 128 * S, 32 * S
cols = COLS; rows = (len(frames) + cols - 1) // cols
W, H = cols * (fw + PAD) + PAD, rows * (fh + PAD) + PAD
img = [[(40, 40, 46)] * W for _ in range(H)]
for i, (lab, fr) in enumerate(frames):
    ox, oy = PAD + (i % cols) * (fw + PAD), PAD + (i // cols) * (fh + PAD)
    for y in range(32):
        for x in range(128):
            c = (150, 230, 255) if fr[y][x] == "#" else (0, 0, 0)
            for dy in range(S):
                row = img[oy + y * S + dy]
                for dx in range(S): row[ox + x * S + dx] = c
raw = b"".join(b"\x00" + bytes(v for p in r for v in p) for r in img)
def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
open(dst, "wb").write(png)
print(f"{len(frames)} frames -> {dst} ({W}x{H})")
for i, (lab, _) in enumerate(frames): print(f"  {i:2d} {lab}")
