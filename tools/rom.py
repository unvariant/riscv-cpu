import log
from lief import ELF
from argparse import ArgumentParser, BooleanOptionalAction
from subprocess import run
from pathlib import Path

"""
This is a small utility to convert assembly to verilog compatible mem files
"""

parser = ArgumentParser(
    prog="rom",
)
parser.add_argument("file")
parser.add_argument("outfile")
# technically its an elf...
parser.add_argument("--mc", help="output machine code", action=BooleanOptionalAction)

args = parser.parse_args()
file = Path(args.file)
outfile = Path(args.outfile)

if not file.exists():
    log.error(f"{str(file)!r} does not exist!")

log.info("assembling to an elf file")

run(
    [
        "zig",
        "cc",
        str(file),
        "-mcpu=baseline_rv32+m-a-d-f-c-zicsr",
        "-target",
        "riscv32-freestanding",
        "-c",
        "-o",
        str(outfile),
    ],
    check=True,
)

log.info("assembling done")

if args.mc:
    log.info("stopping after machine code emitted")
    exit(0)

log.info("extracting raw machine code")

elf = ELF.parse(outfile)
if elf is None:
    log.error("failed to parse ELF file, something is very wrong")

text = elf.get_section(".text")
code = text.content

if len(code) % 4 != 0:
    log.error("code size is not a multiple of 4")

missing = 128 - len(code) // 4
code = code.tobytes() + b"\x13\x00\x00\x00" * missing
log.info("emitting verilog mem file")

start = 0
with open(outfile, "w+") as fp:
    fp.write(f"@{start:08x}\n")

    words = [int.from_bytes(code[i : i + 4], "little") for i in range(0, len(code), 4)]
    words = [f"{word:08x}" for word in words]
    words = " ".join(words)
    fp.write(words)
    fp.write("\n")

log.info("finished")
