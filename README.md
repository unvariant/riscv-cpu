# RISCV CPU

## tools

Much of the tools will be written in python for cross platform consistency, and uses uv for dependency management. See [https://docs.astral.sh/uv/getting-started/installation/](https://docs.astral.sh/uv/getting-started/installation/) for installation instructions. uv manages installations of python itself, so a prior python installation is not required.

## waveform viewers

[Surfer](https://surfer-project.org) or [GTKWave](https://gtkwave.sourceforge.net) can be used to inspect `.vcd` waveform files. Otherwise use a GUI simulator like modelsim or vivado and use the built-in waveform viewer.

## automated testing

Automated testing will be done using handwritten testcases of riscv assembly to ensure proper behavior and provide a basis for regression tests. The behavior of the processor will be compared against a software emulated version of the processor using the `unicorn` package.

Simulation of the SystemVerilog code will be done using either verilator or iverilog.

## assembly to machine code

This step is done using the zig compiler. Zig is a relatively new programming language, but the important part is the compilers focus on cross platform support and cross compilation. Their website has standalone bundles for their compiler for macos, linux, and windows. The zig compiler can accept assembly as input and produce machine code for riscv. This project relies on zig version `0.13.0`. Downloads can be found at their website: [https://ziglang.org/download/](https://ziglang.org/download/).
