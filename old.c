__attribute__((noreturn, naked, section(".entry"))) void _start() {
    asm volatile(".extern end\n"
                 "lui sp, 0x20\n"
                 "call main\n"
                 "j .\n");
}

#define UPSCALE (1)
#define WIDTH (640 / UPSCALE)
#define HEIGHT (480 / UPSCALE)
#define VRAM ((volatile int *)(1 << 24))
#define MMIO ((volatile int *)(1 << 25))
#define SWITCH(i) ((MMIO[0] >> i) & 1)
#define TIMER (MMIO[1])
#define BUTTON(i) ((MMIO[2] >> i) & 1)
#define RAM __attribute__((section(".initram")))

void putpixel(int x, int y, int c) {
    int *frame = (int *)0x1000;
    if (c) {
        frame[y * WIDTH / 32 + x / 32] |= (1 << (x & 31));
    } else {
        frame[y * WIDTH / 32 + x / 32] &= ~(1 << (x & 31));
    }
}

void flush() {
    int *frame = (int *)0x1000;
    volatile int *vram = VRAM;
    for (int i = 0; i < WIDTH * HEIGHT / 32; i += 4) {
        int p0 = frame[i + 0];
        int p1 = frame[i + 1];
        int p2 = frame[i + 2];
        int p3 = frame[i + 3];
        vram[i + 0] = p0;
        vram[i + 1] = p1;
        vram[i + 2] = p2;
        vram[i + 3] = p3;
    }
}

void clear(int c) {
    int *frame = (int *)0x1000;
    for (int i = 0; i < WIDTH * HEIGHT / 32; i += 4) {
        frame[i + 0] = c;
        frame[i + 1] = c;
        frame[i + 2] = c;
        frame[i + 3] = c;
    }
}

void delay(int ms) {
    int now = TIMER;
    while (TIMER < now + ms * 10) {
    }
}

RAM int color = 0xffffffff;

int main() {
    while (1) {
        if (BUTTON(0)) {
            clear(0);
        } else {
            clear(color);
        }
        flush();
    }
}