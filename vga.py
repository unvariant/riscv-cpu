from PIL import Image

dump = Image.new("RGB", (640, 480))
data = open("dump.bin", "r").readlines()
data = [int(n, 16) for n in data]
data = [n.to_bytes(4, "little") for n in data]
data = b"".join(data)

for x in range(640):
    for y in range(480):
        offset = y * 640 + x
        byte = offset // 8
        bit = offset % 8

        bit = (data[byte] >> bit) & 1
        if bit == 0:
            dump.putpixel((x, y), (0x00, 0x00, 0x00))
        else:
            dump.putpixel((x, y), (0xFF, 0xFF, 0xFF))

dump = dump.resize((1280, 960), Image.BOX)
dump.save("dump.png")
