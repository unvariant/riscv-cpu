import Common::*;

module Hazard (
    input  logic   clk,
    input  logic   rst,
    input  Signals i_signals,
    input  Signals decode_signals,
    input  Signals alu_signals,
    input  Signals mem_signals,
    input  Signals wb_signals,
    output logic   o_de_stall,
    output logic   o_if_stall,
    output Signals o_signals
);

    Insn prev = 0;
    Insn insn;
    assign insn = o_de_stall ? prev : i_signals.insn;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic wback;

    always_comb begin
        `log(("b  (insn=%08x)", insn));

        case (insn.r.opcode)
            Opcode::RegReg: begin
                rs1   = insn.r.rs1;
                rs2   = insn.r.rs2;
                wback = 1;
            end
            Opcode::RegImm, Opcode::Jalr, Opcode::Load: begin
                `log(("hi rs1 is %0d", insn.i.rs1));
                rs1   = insn.i.rs1;
                rs2   = 0;
                wback = 1;
            end
            Opcode::Branch: begin
                rs1   = insn.b.rs1;
                rs2   = insn.b.rs2;
                wback = 0;
            end
            Opcode::Store: begin
                rs1   = insn.s.rs1;
                rs2   = insn.s.rs2;
                wback = 0;
            end
            Opcode::Jal, Opcode::Auipc, Opcode::Lui: begin
                rs1   = 0;
                rs2   = 0;
                wback = 1;
            end
            default: begin
                rs1   = 0;
                rs2   = 0;
                wback = 0;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            o_de_stall <= 0;
        end else begin
            if (!o_de_stall) begin
                prev <= insn;
            end

            `log(("a  (insn=%08x)", insn));
            `log(("reg(rs1=%0d, rs2=%0d)", rs1, rs2));
            `log(("dec(wback=%01b, wreg=%0d)", decode_signals.wback, decode_signals.wreg));

            if (
                (
                    decode_signals.wback &&
                    decode_signals.wreg != 0 &&
                    (rs1 == decode_signals.wreg || rs2 == decode_signals.wreg)
                )
                || (
                    alu_signals.wback &&
                    alu_signals.wreg != 0 &&
                    (rs1 == alu_signals.wreg || rs2 == alu_signals.wreg)
                )
                || (
                    mem_signals.wback &&
                    mem_signals.wreg != 0 &&
                    (rs1 == mem_signals.wreg || rs2 == mem_signals.wreg)
                )
                || (
                    wb_signals.wback &&
                    wb_signals.wreg != 0 &&
                    (rs1 == wb_signals.wreg || rs2 == wb_signals.wreg)
                )
            ) begin
                o_if_stall <= 1;
                o_de_stall <= 1;
                o_signals.wback <= 0;
            end else begin
                o_if_stall <= 0;
                o_de_stall <= 0;
                o_signals.wback <= wback;
            end
        end
    end

endmodule
