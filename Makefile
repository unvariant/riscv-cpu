rom: test.s
	python3 tools/rom.py test.s rom_file.mem

dump: test.s
	python3 tools/rom.py testcases/pipeline.s rom_file.mem --mc
	objdump -d rom_file.mem -M no-aliases

c: test.c
	zig cc test.c -march=baseline_rv32-m-a-d-f-c-zicsr -target riscv32-freestanding -Os -mno-unaligned-access -ffunction-sections -fdata-sections -flto -o test.o
	objdump -d test.o -M no-aliases
	objcopy -O binary test.o rom_file.mem
	objcopy -I binary -O verilog --verilog-data-width 4 --reverse-bytes 4 rom_file.mem