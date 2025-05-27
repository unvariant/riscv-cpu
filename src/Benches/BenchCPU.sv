module BenchCPU;

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
    logic stall;
    logic [14:0] switches;
    logic [4:0] buttons;
    logic [3:0] gpio;

    CPU cpu_i (
        .i_clk(clk),
        .i_rst(rst),
        .leds(leds),
        .o_clk(ignore),
        .vga_hsync(hsync),
        .vga_vsync(vsync),
        .vga_r(red),
        .vga_g(green),
        .vga_b(blue),
        .o_stall(stall),
        .i_switches(switches),
        .i_buttons(buttons),
        .o_gpio(gpio)
    );

    int cycles = 0;
    int fp = $fopen("dump.bin", "wb+");

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars;

        #2;
        rst = 1;
        #2;
        rst = 0;
        #2;

        forever begin
            #2;

            cycles += 1;

            // $display("pc = 0x%x", cpu_i.pc_i.pc);

            if (cpu_i.pc_i.pc == 2048 * 4) begin
                for (int i = 0; i < $size(cpu_i.vga_i.vram); i++) begin
                    $fwrite(fp, "%x\n", cpu_i.vga_i.vram[i]);
                end

                for (int i = 0; i < 32; i++) begin
                    $display("x%0d = 0x%08x", i, cpu_i.regs_i.registers[i]);
                end

                $display("pc = %08x", cpu_i.pc_i.pc);

                $display("mem[0x00001000] = 0x%08x", cpu_i.ram_i.ram['h1000/4]);
                $display("mem[0x00076a00] = 0x%x", cpu_i.ram_i.ram['h0x76a00/4]);
                $display("took %d cycles", cycles);
                $finish;
            end
        end
    end

endmodule
