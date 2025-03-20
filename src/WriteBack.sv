import Common::*;

module WriteBack (
    input logic   clk,
    input logic   rst,
    input Signals i_signals,

    output Signals o_signals
);

    logic [31:0] pc;
    logic [31:0] next;
    assign next = i_signals.pc + 4;
    always_comb begin
        case (i_signals.cond)
            Zero:     pc = (i_signals.flags.zero == 1) ? i_signals.branch : next;
            NotZero:  pc = (i_signals.flags.zero == 0) ? i_signals.branch : next;
            Carry:    pc = (i_signals.flags.carry == 1) ? i_signals.branch : next;
            NotCarry: pc = (i_signals.flags.carry == 0) ? i_signals.branch : next;
            Never:    pc = next;
            Always:   pc = i_signals.branch;
            default: begin
                pc = 0;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            o_signals.valid <= 0;
            o_signals.pc    <= 0;
            o_signals.wback <= 0;
            o_signals.wreg  <= 0;
            o_signals.wdata <= 0;
        end else begin
            o_signals.valid <= i_signals.valid;
            o_signals.pc    <= pc;
            o_signals.wback <= i_signals.wback;
            o_signals.wreg  <= i_signals.wreg;
            o_signals.wdata <= i_signals.wdata;
        end
    end

endmodule
