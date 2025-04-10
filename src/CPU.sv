import Common::*;

module CPU (
    input logic i_clk,
    input logic i_rst,
    output logic [11:0] leds,
    output logic o_clk,

    output logic vga_hsync,
    output logic vga_vsync,
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b
);

    logic clk;
    assign clk = i_clk;

    logic rst = 1;
    logic start = 1;

    always @(posedge clk) begin
        rst <= i_rst;
    end

    logic [31:0] debug;
    assign leds[10:0] = debug[10:0];

    logic   de_stall;
    logic   if_stall;

    Signals fetch_signals;

    PC pc_i (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stall(if_stall),
        .i_signals(wb_signals),
        .o_signals(fetch_signals)
    );

    // ROM rom_i (
    //     .clk(clk),
    //     .i_signals(wb_signals),
    //     .o_signals(fetch_signals)
    // );

    /* verilator lint_off MULTIDRIVEN */
    Signals decode_signals;

    Register regs_i (
        .clk(clk),
        .rst(rst),
        .stall(de_stall),
        .i_signals(fetch_signals),
        .i_wback(wb_signals.wback),
        .i_wreg(wb_signals.wreg),
        .i_wdata(wb_signals.wdata[31:0]),
        .o_signals(decode_signals),
        .o_debug(debug)
    );

    Control con_i (
        .clk(clk),
        .rst(rst),
        .stall(de_stall),
        .i_signals(fetch_signals),
        .o_signals(decode_signals)
    );

    ImmGen imm_gen_i (
        .clk(clk),
        .rst(rst),
        .stall(de_stall),
        .i_signals(fetch_signals),
        .o_signals(decode_signals)
    );

    Hazard hazard_i (
        .clk(clk),
        .rst(rst),
        .o_de_stall(de_stall),
        .o_if_stall(if_stall),
        .i_signals(fetch_signals),
        .decode_signals(decode_signals),
        .alu_signals(alu_signals),
        .mem_signals(mem_signals),
        .wb_signals(wb_signals),
        .o_signals(decode_signals)
    );

    Signals alu_signals;

    ALU alu_i (
        .clk(clk),
        .rst(rst),
        .i_signals(decode_signals),
        .o_signals(alu_signals)
    );

    Signals mem_signals;

    RAM ram_i (
        .clk(clk),
        .rst(rst),
        .i_signals(alu_signals),
        .o_signals(mem_signals)
    );

`ifndef SIMULATION

    VGA vga_i (
        .clk(clk),
        .clk_100m(i_clk),
        .rst(rst),
        .i_signals(alu_signals),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .r(vga_r),
        .g(vga_g),
        .b(vga_b)
    );

`endif

    Signals wb_signals;

    WriteBack write_back_i (
        .clk(clk),
        .rst(rst),
        .i_signals(mem_signals),
        .o_signals(wb_signals)
    );

endmodule
