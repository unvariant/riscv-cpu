volatile unsigned int *framebuffer = (volatile unsigned int *)0x1000000;

__attribute__((noreturn)) void _start() {
    for (int i = 0; i < 2 * 48; i++) {
        framebuffer[i] = 0xffffffff;
    }
    while (1) {
    }
}