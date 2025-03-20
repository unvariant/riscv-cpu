import Common::*;

module Register (
    input logic          clk,
    input logic          rst,
    input Signals        i_signals,
    input logic          i_wback,
    input logic   [ 4:0] i_wreg,
    input logic   [31:0] i_wdata,

    output Signals        o_signals,
    output logic   [31:0] o_debug
);

    logic [31:0] registers[31:0];

    assign o_debug = registers[10];

    Insn insn;
    assign insn = i_signals.insn;

    always @(posedge clk) begin
        if (rst) begin
            o_signals.reg1 <= 0;
            o_signals.reg2 <= 0;
            for (int i = 0; i < 32; i = i + 1) registers[i] = 0;
        end else begin
            if (i_wback) begin
                if (i_wreg != 0) begin
                    registers[i_wreg] = i_wdata;
                end
            end

            case (32'(insn.r.opcode))
                Opcode::RegReg: begin
                    o_signals.reg1 <= registers[insn.r.rs1];
                    o_signals.reg2 <= registers[insn.r.rs2];
                end
                Opcode::RegImm: begin
                    o_signals.reg1 <= registers[insn.i.rs1];
                    o_signals.reg2 <= 0;
                end
                Opcode::Branch: begin
                    o_signals.reg1 <= registers[insn.b.rs1];
                    o_signals.reg2 <= registers[insn.b.rs2];
                end
                Opcode::Jalr: begin
                    // `log(("\tjalr rs = %d", insn.i.rs1));
                    // `log(("\trs      = %08x", registers[insn.i.rs1]));
                    o_signals.reg1 <= registers[insn.i.rs1];
                    o_signals.reg2 <= 0;
                end
                Opcode::Load: begin
                    o_signals.reg1 <= registers[insn.i.rs1];
                    o_signals.reg2 <= 0;
                end
                Opcode::Store: begin
                    o_signals.reg1 <= registers[insn.s.rs1];
                    o_signals.reg2 <= registers[insn.s.rs2];
                end
                default: begin
                    o_signals.reg1 <= 0;
                    o_signals.reg2 <= 0;
                end
            endcase
        end
    end

endmodule
