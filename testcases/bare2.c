__attribute__((noreturn, naked)) void _start() {
  asm volatile("lui sp, 0x10\n"
               "call main\n"
               "j end\n");
}

typedef struct {
  char a;
  int b;
} Thing;

int main() {
  volatile Thing *mem = (volatile Thing *)0x1000;
  mem->a = 0xcc;
  mem->b = 0xaa;
  return mem->a + mem->b;
}

void end();