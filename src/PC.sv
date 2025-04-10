import Common::*;

module PC (
    input  logic   clk,
    input  logic   rst,
    input  logic   start,
    input  logic   stall,
    input  Signals i_signals,
    output Signals o_signals
);

    // support 128 instructions
    logic [31:0] mem[0:127];
    initial $readmemh("rom_file.mem", mem);

    logic [31:0] pc = -4;
    logic started = 0;

    always_latch @(posedge clk) begin
        if (rst) begin
            o_signals.valid <= 0;
            o_signals.pc <= 0;
        end else if (start && !started) begin
            o_signals.valid <= 1;
            o_signals.pc <= 0;
            started <= 1;
        end else begin
            /* NO PIPELINING */
            // if (i_signals.valid) begin
            //     // $display("pc = %0x", i_signals.pc);
            //     pc <= i_signals.pc;
            //     o_signals.valid <= i_signals.valid;
            //     o_signals.pc <= i_signals.pc;
            // end else begin
            //     o_signals.valid <= 0;
            //     o_signals.pc <= pc;
            // end

            `log(("pc = %08x", pc));

            if (!stall) begin
                pc = pc + 4;
            end

            o_signals.valid <= 1;
            o_signals.pc <= pc;

            `log(("fetching insn (pc %08x) = %08x", pc, mem[pc>>2]));

            o_signals.insn <= mem[pc>>2];
        end
    end

endmodule
