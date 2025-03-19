#!/bin/sh

set -e

verilator --binary +1800-2017ext+sv CPU.h.sv "$1".sv -DSIMULATION -Isrc -o TestBench --trace -j 4
./obj_dir/TestBench