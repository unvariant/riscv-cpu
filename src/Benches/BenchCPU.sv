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

        forever begin
            #2;

            if (cpu_i.pc_i.pc == 128 * 4) begin
                for (int i = 0; i < 32; i++) begin
                    $display("x%0d = 0x%08x", i, cpu_i.regs_i.registers[i]);
                end

                $display("pc = %08x", cpu_i.pc_i.pc);

                $display("mem[0x1000] = 0x%08x", cpu_i.ram_i.ram['h1000/4]);
                $finish;
            end
        end
    end

endmodule
