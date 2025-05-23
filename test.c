#include "seabios-font.h"

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

typedef enum { None, Left, Up, Right, Down } Direction;
typedef struct {
    short x;
    short y;
} Pos;

void set_gpio(int pins) { MMIO[3] = pins; }

RAM int frame[WIDTH * HEIGHT / 32];

void put_pixel(int x, int y, int c) {
    if (c) {
        frame[y * WIDTH / 32 + x / 32] |= (1 << (x & 31));
    } else {
        frame[y * WIDTH / 32 + x / 32] &= ~(1 << (x & 31));
    }
}

void flush() {
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
    for (int i = 0; i < WIDTH * HEIGHT / 32; i += 4) {
        frame[i + 0] = c;
        frame[i + 1] = c;
        frame[i + 2] = c;
        frame[i + 3] = c;
    }
}

void putchar(int line, int col, int ch) {
    for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 8; x++) {
            int xp = col * 9 + x;
            int yp = line * 17 + y;
            int color = (seabios8x16[ch * 16 + y] >> x) & 1;
            put_pixel(xp, yp, color);
        }
    }
}

// system timer is a 10 khz clock
#define MS(x) (x * 10)

void delay(int ticks) {
    int now = TIMER;
    while (TIMER < now + MS(ticks)) {
    }
}

int min(int a, int b) {
    if (a < b) {
        return a;
    }
    return b;
}

int max(int a, int b) {
    if (a > b) {
        return a;
    }
    return b;
}

unsigned int umin(unsigned int a, unsigned int b) {
    if (a > b) {
        return a;
    }
    return b;
}

#define SIDE (10)
#define GWIDTH (WIDTH / SIDE)
#define GHEIGHT (HEIGHT / SIDE)

RAM Pos apple_pos;
RAM Pos snake_pos[GWIDTH * GHEIGHT];
RAM Direction direction;
RAM int length;
RAM int game_over;
RAM int ate_apple;

void draw_square(int x, int y, int c) {
    for (int iy = 0; iy < SIDE; iy++) {
        for (int ix = 0; ix < SIDE; ix++) {
            put_pixel(x * SIDE + ix, y * SIDE + iy, c);
        }
    }
}

void draw_apple(int x, int y) {
    for (int iy = 0; iy < SIDE; iy++) {
        for (int ix = 0; ix < SIDE; ix++) {
            int xdiff = (ix < SIDE / 2) ? ix : SIDE - 1 - ix;
            int ydiff = (iy < SIDE / 2) ? iy : SIDE - 1 - iy;
            int oob = (xdiff + ydiff) <= 1;
            if (!oob) {
                put_pixel(x * SIDE + ix, y * SIDE + iy, 1);
            }
        }
    }
}

void reset() {
    apple_pos.x = GWIDTH / 4;
    apple_pos.y = GHEIGHT / 4;
    snake_pos[0].x = GWIDTH / 2;
    snake_pos[0].y = GHEIGHT / 2;
    for (int i = 1; i < GWIDTH * GHEIGHT; i++) {
        snake_pos[i].x = 0;
        snake_pos[i].y = 0;
    }
    direction = None;
    length = 5;
    game_over = 0;

    clear(0);
    draw_square(snake_pos[0].x, snake_pos[0].y, 1);

    putchar(1, 1, 'A');

    flush();
}

Direction get_direction() {
    if (BUTTON(0) && (direction != Right)) {
        return Left;
    } else if (BUTTON(1) && (direction != Down)) {
        return Up;
    } else if (BUTTON(2) && (direction != Left)) {
        return Right;
    } else if (BUTTON(3) && (direction != Up)) {
        return Down;
    } else if (BUTTON(4) && (direction != Up)) {
        return Down;
    }
    return direction;
}

void draw() {
    if (game_over) {
        return;
    }

    clear(0);
    for (int i = 0; i < length; i++) {
        draw_square(snake_pos[i].x, snake_pos[i].y, 1);
    }
    draw_apple(apple_pos.x, apple_pos.y);
    flush();
}

void determine_new_snake_head(Pos *new_snake_head) {
    switch (direction) {
    case Left:
        new_snake_head->x -= 1;
        break;
    case Up:
        new_snake_head->y -= 1;
        break;
    case Right:
        new_snake_head->x += 1;
        break;
    case Down:
        new_snake_head->y += 1;
        break;
    default:
        break;
    }
}

int valid_head(Pos *new_snake_head) {
    if ((new_snake_head->x < 0) || (new_snake_head->x >= GWIDTH) ||
        (new_snake_head->y < 0) || (new_snake_head->y >= GHEIGHT)) {
        return 0;
    }

    return 1;
}

void update() {
    ate_apple = 0;

    Pos new_head = snake_pos[0];
    determine_new_snake_head(&new_head);
    if (!valid_head(&new_head)) {
        game_over = 1;
        return;
    }

    if (new_head.x == apple_pos.x && new_head.y == apple_pos.y) {
        length += 1;
        ate_apple = 1;

        apple_pos.x = TIMER % GWIDTH;
        apple_pos.y = TIMER % GHEIGHT;
    }

    for (int i = length - 1; i >= 0; i--) {
        if (i == 0) {
            snake_pos[0] = new_head;
        } else {
            snake_pos[i] = snake_pos[i - 1];
            if (snake_pos[i].x == new_head.x && snake_pos[i].y == new_head.y) {
                game_over = 1;
                return;
            }
        }
    }
}

int main() {
    reset();
    while (direction == None) {
        direction = get_direction();
    }
    while (!game_over) {
        update();
        draw();

        if (ate_apple) {
            set_gpio(1);
        }

        int now = TIMER;
        Direction next_direction = direction;
        while (TIMER < now + MS(125)) {
            next_direction = get_direction();
        }
        direction = next_direction;

        set_gpio(0);
    }

    return (1 << 16) - 1;
    // return (1 << 8) - 1;
    // return (1 << 4) - 1;
    // return 0x1337;
}

__attribute__((naked)) void end() { asm volatile(""); }