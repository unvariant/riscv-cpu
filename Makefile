rom: test.s
	python3 tools/rom.py test.s rom_file.mem

dump: test.s
	python3 tools/rom.py test.s rom_file.mem --mc
	gobjdump -d rom_file.mem