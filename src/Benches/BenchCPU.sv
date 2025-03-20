module CPUBench;

    bit clk;
    always #1 clk <= !clk;
    bit rst = 0;

    bit ignore;
    bit [11:0] leds;
    logic vsync;
    logic hsync;
    logic [3:0] red;
    logic [3:0] green;
    logic [3:0] blue;

    CPU cpu_i (
        .i_clk(clk),
        .i_rst(rst),
        .leds(leds),
        .o_clk(ignore),
        .vga_hsync(hsync),
        .vga_vsync(vsync),
        .vga_r(red),
        .vga_g(green),
        .vga_b(blue)
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
        $display("ram[0x00] = %08x", cpu_i.ram_i.ram[0]);
        $display("ram[0x04] = %08x", cpu_i.ram_i.ram[1]);
        $finish;
    end

endmodule
