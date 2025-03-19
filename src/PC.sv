import Common::*;

module PC (
    input  logic   clk,
    input  logic   rst,
    input  Signals i_signals,
    output Signals o_signals
);

    logic [31:0] pc = 0;

    always @(posedge clk) begin
        if (rst) begin
            o_signals.valid <= 1;
            o_signals.pc <= 0;
        end else begin
            if (i_signals.valid) begin
                if (pc == (128 - 1) * 4) begin
                    o_signals.valid <= 0;
                    o_signals.pc <= pc;
                end else begin
                    // $display("pc = %0x", i_signals.pc);
                    pc <= i_signals.pc;

                    o_signals.valid <= i_signals.valid;
                    o_signals.pc <= i_signals.pc;
                end
            end else begin
                o_signals.valid <= 0;
                o_signals.pc <= pc;
            end
        end
    end

endmodule
