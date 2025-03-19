from pathlib import Path
from PIL import Image
import numpy as np
import sys

dim = (64, 48)
framerate = 12
seconds = 220
count = framerate * seconds
print(f"{count = }")
frames = []

for i in range(1, count + 1):
    frame = Image.open(Path("frames") / f"{i:05}.png")
    pixels = np.array(frame)
    threshold = pixels > 128
    bits = threshold.flatten()[::3]
    bits = "".join("1" if b else "0" for b in bits)
    frames.append(bits)
    new = 255 * threshold.astype(np.uint8)
    Image.fromarray(new).save(Path("pillow") / f"{i:05}.png")


def run_length_encode_assume(frame: str, bits: int):
    spans = []
    limit = (1 << bits) - 1

    span = 0
    white = True
    for bit in frame:
        if white and bit == "0":
            spans.append(span)
            white = False
            span = 1
        elif not white and bit == "1":
            spans.append(span)
            white = True
            span = 1
        else:
            span += 1

    if span > 0:
        spans.append(span)

    runs = []
    for span in spans:
        while span > limit:
            runs.append(limit)
            runs.append(0)
            span -= limit
        runs.append(span)

    return runs


# for i in range(4, 16):
#     cost = sum(len(run_length_encode_assume(f, i)) * i for f in frames)
#     baseline = dim[0] * dim[1] * len(frames)
#     print(f"compression ratio ({i: 3}): {baseline / cost:.4f}")

print(f"{dim = }")

rle = []
for frame in frames:
    enc = run_length_encode_assume(frame, 6)
    bits = "".join([f"{i:06b}"[::-1] for i in enc])
    assert len(bits) == 6 * len(enc)
    rle.append(bits)

words = [[int(f[i : i + 32], 2) for i in range(0, len(f), 32)] for f in rle]

# words = [[int(f[i : i + 32][::-1], 2) for i in range(0, len(f), 32)] for f in frames]

start = dim[0] * dim[1] // 32
size = sum(len(w) for w in words) * 4
print(f"{size:<10} b")
print(f"{size / 1024:<10} kb")

out = open("frames.bin", "w+")
out.write(f"@{start:08x}\n")
flat = []
for frame in words:
    flat.extend(frame)
out.write(" ".join(f"{w:08x}" for w in flat))
out.write("\n")
