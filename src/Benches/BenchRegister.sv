import Common::*;

module BenchRegister();
    logic stall;
    bit clk;
    bit rst;
    Signals i_signals;
    Signals o_signals;
    Signals wb_signals;
    reg [31:0] o_debug;

    Register register(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .i_buffer(i_signals),
        .i_wback(wb_signals.wback),
        .i_wreg(wb_signals.wreg),
        .i_wdata(wb_signals.wdata[31:0]),
        .o_signals(o_signals),
        .o_debug(o_debug)
    );

    initial begin
        clk <= 0;
        stall <= 0;
        forever begin
            #1
            clk <= ~clk;
        end
    end

    function void debug(logic[31:0] exp, logic[31:0] act); 
        if (exp == act) $display("pass:\t");
        else $display("fail:\t");
        $display("expected: %032b, actual: %032b\n", exp, act);
    endfunction

    initial begin
        rst <= 1;
        #2
        rst <= 0;
        for (int i = 0; i < 32; i++) register.registers[i] = i;

        i_signals.insn = 'h0094_6fb3;
        #2
        $display("or x31, x8, x9:\t");
        debug(8, o_signals.reg1);
        debug(9, o_signals.reg2);

        i_signals.insn = 'h0031_ef93;
        #2
        $display("ori x31, x3, 3:\t");
        debug(3, o_signals.reg1);
        debug(0, o_signals.reg2);

        i_signals.insn = 'h01e2_8263;
        #2
        $display("beq x5, x30, temp:\t");
        debug(5, o_signals.reg1);
        debug(30, o_signals.reg2);

        i_signals.insn = 'h000e_8067;
        #2
        $display("jalr x0, 0(x29):\t");
        debug(29, o_signals.reg1);
        debug(0, o_signals.reg2);

        rst <= 1;
        #2
        $display("reset:\t");
        debug(0, o_signals.reg1);
        debug(0, o_signals.reg2);

        rst <= 0;
        wb_signals.wback <= 1;
        wb_signals.wreg <= 10;
        wb_signals.wdata <= 6725;
        #2
        $display("wback:\t");
        debug(6725, register.registers[10]);

    end

endmodule
