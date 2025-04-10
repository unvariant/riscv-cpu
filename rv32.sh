#!/usr/bin/env bash
set -ex

SRC="./src"
BUILD="./build"
CONSTRAINTS="${SRC}/constraints.xdc"
FILES=$(fd '\.sv' ${SRC} --print0 -E Benches | xargs -0)
echo "compiling $FILES"

export XRAY_DIR="${PWD}/../nextpnr-xilinx/xilinx/external/prjxray/"

mkdir -p "${BUILD}"

../synlig/build/release/synlig/synlig \
    -p "read_systemverilog ${FILES}; synth_xilinx -family xc7 -flatten -nowidelut -abc9 -arch xc7 -top CPU; write_json ${BUILD}/test.json" \

# yosys \
#     -p "synth_xilinx -flatten -nowidelut -abc9 -arch xc7 -top top; write_json -noscopeinfo ${BUILD}/test.json" \
#     $FILES

echo "yosys done"

../nextpnr-xilinx/nextpnr-xilinx \
    --chipdb ../nextpnr-xilinx/xilinx/xc7a35t.bin \
    --xdc "${CONSTRAINTS}" \
    --json "${BUILD}/test.json" \
    --write "${BUILD}/test_routed.json" \
    --fasm "${BUILD}/test.fasm" \
    --placer-heap-cell-placement-timeout 0

source "${XRAY_DIR}/utils/environment.sh"
export XRAY_DATABASE_DIR="${XRAY_DIR}/../prjxray-db/"

"${XRAY_UTILS_DIR}/fasm2frames.py" \
    --db-root "${XRAY_DATABASE_DIR}/artix7" \
    --part xc7a35tcpg236-1 "${BUILD}/test.fasm" \
    > "${BUILD}/test.frames"

"${XRAY_TOOLS_DIR}/xc7frames2bit" \
    --part_file "${XRAY_DATABASE_DIR}/artix7/xc7a35tcpg236-1/part.yaml" \
    --part_name xc7a35tcpg236-1 \
    --frm_file "${BUILD}/test.frames" \
    --output_file "${BUILD}/test.bit"
