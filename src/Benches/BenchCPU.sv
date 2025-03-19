module CPUBench;

    bit clk;
    always #1 clk <= !clk;

    bit ignore;
    bit [6:0] leds;
    logic vsync;
    logic hsync;
    logic [3:0] red;
    logic [3:0] green;
    logic [3:0] blue;

    CPU cpu_i (
        .i_clk(clk),
        .leds (leds),
        .o_clk(ignore),
        .vsync(vsync),
        .hsync(hsync),
        .red  (red),
        .green(green),
        .blue (blue)
    );

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars;
        #500;
        $display("a0 = %08x", cpu_i.regs_i.registers[10]);
        $display("a0 = %032b", cpu_i.regs_i.registers[10]);
        $display("a1 = %08x", cpu_i.regs_i.registers[11]);
        $display("a2 = %08x", cpu_i.regs_i.registers[12]);
        $display("a3 = %08x", cpu_i.regs_i.registers[13]);
        $display("ra = %08x", cpu_i.regs_i.registers[1]);
        $display("pc = %08x", cpu_i.pc_i.pc);
        $finish;
    end

endmodule
