import Common::*;

module ImmGen (
    input  logic   clk,
    input  logic   rst,
    input  Signals i_signals,
    output Signals o_signals
);

    Insn insn;
    assign insn = i_signals.insn;

    always @(posedge clk) begin
        if (rst) begin
            o_signals.imm <= 0;
        end else begin
            case (32'(insn.r.opcode))
                Opcode::RegImm: begin
                    case (insn.i.funct3)
                        'h1:     o_signals.imm <= 32'(insn.i.imm[4:0]);
                        'h5:     o_signals.imm <= 32'(insn.i.imm[4:0]);
                        default: o_signals.imm <= 32'(signed'(insn.i.imm));
                    endcase
                end
                Opcode::Jal, Opcode::Jalr: begin
                    o_signals.imm <= 32'd4;
                end
                Opcode::Load: begin
                    o_signals.imm <= 32'(signed'(insn.i.imm));
                end
                Opcode::Store: begin
                    o_signals.imm <= 32'(signed'({insn.s.immhi, insn.s.immlo}));
                end
                Opcode::Lui, Opcode::Auipc: begin
                    o_signals.imm <= {insn.u.imm, 12'd0};
                end
                default: begin
                    o_signals.imm <= 0;
                end
            endcase

            case (32'(insn.r.opcode))
                Opcode::RegImm, Opcode::Jalr: begin
                    o_signals.jimm <= 32'(signed'(insn.i.imm));
                end
                Opcode::Branch: begin
                    o_signals.jimm <= 32'(signed'({
                        insn.b.imm4, insn.b.imm3, insn.b.imm2, insn.b.imm1, 1'b0
                    }));
                end
                Opcode::Jal: begin
                    o_signals.jimm <= 32'(signed'({
                        insn.j.imm4, insn.j.imm3, insn.j.imm2, insn.j.imm1, 1'b0
                    }));
                end
                default: begin
                    o_signals.jimm <= 0;
                end
            endcase
        end
    end

endmodule
