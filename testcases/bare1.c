__attribute__((noreturn, naked)) void _start() {
  asm volatile("lui sp, 0x10\n"
               "call main\n"
               "j end\n");
}

int main() {
  volatile int *mem = (volatile int *)0x1000;
  mem[0] = 0x1337;
  return 90;
}

void end();