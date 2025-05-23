__attribute__((noreturn, naked)) void _start() {
  asm volatile("lui sp, 0x10\n"
               "call main\n"
               "j end\n");
}

int main() {
  int r = 0;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      for (int k = 0; k < 4; k++) {
        r += 1;
      }
    }
  }
  return r;
}

void end();