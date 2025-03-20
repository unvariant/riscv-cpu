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
    // logic   clk = 0;
    // integer counter = 0;
    // always @(posedge i_clk) begin
    //     if (counter + 1 == 2) begin
    //         counter <= 0;
    //         clk <= !clk;
    //     end else begin
    //         counter <= counter + 1;
    //     end
    // end
    // assign o_clk = clk;

    logic rst = 1;
    always @(posedge clk) begin
        rst <= i_rst;
    end

    // assign leds[0] = fetch_signals.valid == 1;
    // assign leds[1] = decode_signals.valid == 1;
    // assign leds[2] = alu_signals.valid == 1;
    // assign leds[3] = wb_signals.valid == 1;
    // assign leds[4] = wb_signals.pc == 4;
    // assign leds[3:0] = fetch_signals.pc[3:0];
    // assign leds[4]   = regs_i.registers[11] == 3;
    // assign leds[4:0] = alu_signals.pc[4:0];
    // assign leds[3:0] = wb_signals.wdata[3:0];
    // assign leds[4]   = wb_signals.wback;
    // assign leds[3:0] = wb_signals.wreg;
    logic [31:0] debug;
    assign leds[11:0] = debug[11:0];

    Signals fetch_signals;

    PC pc_i (
        .clk(clk),
        .rst(rst),
        .i_signals(wb_signals),
        .o_signals(fetch_signals)
    );

    ROM rom_i (
        .clk(clk),
        .i_signals(wb_signals),
        .o_signals(fetch_signals)
    );

    Signals decode_signals;

    Register regs_i (
        .clk(clk),
        .rst(rst),
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
        .i_signals(fetch_signals),
        .o_signals(decode_signals)
    );

    ImmGen imm_gen_i (
        .clk(clk),
        .rst(rst),
        .i_signals(fetch_signals),
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
