__attribute__((noreturn, naked)) void _start() {
  asm volatile(".extern end\n"
               "lui sp, 0x30\n"
               "call main\n"
               "j end\n");
}

__attribute__((naked)) int mul640(int x) {
  asm volatile("slli a1, a0, 2\n"
               "add  a0, a0, a1\n"
               "slli a0, a0, 7\n"
               "ret\n");
}

void putpixelw(int *fb, int x, int y) {
  int loc = y * 640 + x;
  int offset = loc / 32;
  int bit = loc % 32;
  fb[offset] = fb[offset] | (1 << bit);
}

void putpixelb(int *fb, int x, int y) {
  int loc = y * 640 + x;
  int offset = loc / 32;
  int bit = loc % 32;
  fb[offset] = fb[offset] & ~(1 << bit);
}

void flush(int *src) {
  volatile int *framebuffer = (volatile int *)(1 << 24);
  for (int i = 0; i < 640 * 480 / 32; i += 8) {
    int p0 = src[i + 0];
    int p1 = src[i + 1];
    int p2 = src[i + 2];
    int p3 = src[i + 3];
    framebuffer[i + 0] = p0;
    framebuffer[i + 1] = p1;
    framebuffer[i + 2] = p2;
    framebuffer[i + 3] = p3;

    int p4 = src[i + 4];
    int p5 = src[i + 5];
    int p6 = src[i + 6];
    int p7 = src[i + 7];
    framebuffer[i + 4] = p4;
    framebuffer[i + 5] = p5;
    framebuffer[i + 6] = p6;
    framebuffer[i + 7] = p7;
  }
}

void fillw(int *fb, int x, int y, int side) {
  int start = ((x + 31) & ~31) / 32;
  int end = (x + side) / 32;
  if (end - start <= 1) {
    for (int py = y; py < y + side; py += 1) {
      for (int px = x; px < x + side; px += 1) {
        putpixelw(fb, px, py);
      }
    }
  } else {
    for (int py = y; py < y + side; py += 1) {
      for (int px = start; px < end; px += 1) {
        fb[py * 20 + px] = 0xffffffff;
      }

      //   for (int px = x; px < start * 32; px += 1) {
      //     putpixel(fb, px, py);
      //   }

      int lshift = 32 - (start * 32 - x);
      fb[py * 20 + x / 32] |= 0xffffffff << lshift;

      // for (int px = end * 32; px < x + side; px += 1) {
      //   putpixel(fb, px, py);
      // }

      int rshift = x + side - end * 32;
      fb[py * 20 + end] |= 0xffffffff & ((1 << rshift) - 1);
    }
  }
}

void fillb(int *fb, int x, int y, int side) {
  int start = ((x + 31) & ~31) / 32;
  int end = (x + side) / 32;
  if (end - start <= 1) {
    for (int py = y; py < y + side; py += 1) {
      for (int px = x; px < x + side; px += 1) {
        putpixelb(fb, px, py);
      }
    }
  } else {
    for (int py = y; py < y + side; py += 1) {
      for (int px = start; px < end; px += 1) {
        fb[py * 20 + px] = 0;
      }

      //   for (int px = x; px < start * 32; px += 1) {
      //     putpixel(fb, px, py);
      //   }

      int lshift = start * 32 - x;
      fb[py * 20 + x / 32] &= (0xffffffff >> lshift);

      // for (int px = end * 32; px < x + side; px += 1) {
      //   putpixel(fb, px, py);
      // }

      int rshift = x + side - end * 32;
      fb[py * 20 + end] &= 0xffffffff << rshift;
    }
  }
}

void fill(int *fb, int x, int y, int side, int c) {
  if (c) {
    fillw(fb, x, y, side);
  } else {
    fillb(fb, x, y, side);
  }
}

// void square(int *fb, int x, int y, int iteration) {
//   if (iteration > 20)
//     return;

//   int side = 320 / (1 << iteration);

//   fill(fb, x, y, side, 1);
//   switch (iteration % 4) {
//   case 0:
//     square(fb, x - side / 2, y + side / 2, iteration + 1);
//     break;
//   case 1:
//     square(fb, x, y - side / 2, iteration + 1);
//     break;
//   case 2:
//     square(fb, x + side, y, iteration + 1);
//     break;
//   case 3:
//     square(fb, x + side / 2, y + side, iteration + 1);
//     break;
//   }
// }

void square(int *fb, int x, int y, int iteration) {
  if (iteration > 20)
    return;

  int side = 480 / (1 << iteration);
  if (side == 0)
    return;

  fill(fb, x, y, side, iteration & 1);
  square(fb, x + side, y, iteration + 1);
  square(fb, x, y + side, iteration + 1);
}

int main() {
  int frame[640 * 480 / 32];
  int *fb = frame;

  square(fb, 0, 0, 1);

  flush(fb);
}

void end();