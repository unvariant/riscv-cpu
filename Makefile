rom: test.s
	python3 tools/rom.py test.s rom_file.mem

dump: test.s
	python3 tools/rom.py testcases/mem3.s rom_file.mem --mc
	objdump -d rom_file.mem -M no-aliases

c: test.c
	zig cc test.c -march=baseline_rv32-m-a-d-f-c-zicsr -target riscv32-freestanding -Os -mno-unaligned-access -ffunction-sections -fdata-sections -flto -o test.o
	objdump -d test.o -M no-aliases
	objcopy -O binary test.o rom_file.mem
	objcopy -I binary -O verilog --verilog-data-width 4 --reverse-bytes 4 rom_file.mem

crom: test.c
	CFLAGS="-fno-builtin -mno-unaligned-access -fno-unroll-loops -O1 -Wl,-T,linker.ld" python3 tools/rom.py test.c rom_file.mem ram_file.mem
	./rv32.sh
	openFPGALoader -b arty ./build/test.bit

cdump: test.c
	CFLAGS="-fno-builtin -mno-unaligned-access -fno-unroll-loops -O1 -Wl,-T,linker.ld" python3 tools/rom.py test.c rom_file.mem ram_file.mem --elf
	objdump -d -M no-aliases rom_file.mem
	# readelf -SW rom_file.mem