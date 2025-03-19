struct Thing {
  char a;
  short b;
} __attribute__((packed));

struct Thing thing;

struct Thing *_start() {
  thing.a = 0x11;
  thing.b = 0x22;
  return &thing;
}