import Common::*;

module Control (
    input logic   clk,
    input logic   rst,
    input Signals i_signals,

    output Signals o_signals
);

    Insn insn;
    assign insn = i_signals.insn;

    always @(posedge clk) begin
        if (rst || !i_signals.valid) begin
            o_signals.valid <= 0;
            o_signals.pc    <= 0;
            o_signals.op    <= Op::Add;
            o_signals.wreg  <= 0;
            o_signals.wback <= 0;
            o_signals.asel  <= Register;
            o_signals.bsel  <= Register;
            o_signals.pcsel <= 0;
            o_signals.cond  <= Never;
            o_signals.memr  <= 0;
            o_signals.memw  <= 0;
            o_signals.memt  <= LoadByte;
        end else begin
            o_signals.valid <= i_signals.valid;
            o_signals.pc    <= i_signals.pc;
            o_signals.pcsel <= 32'(insn.r.opcode) == Opcode::Jalr;
            o_signals.op    <= Op::Add;

            case (32'(insn.r.opcode))
                Opcode::RegReg: begin
                    case (insn.r.funct3)
                        'h0: begin
                            case (insn.r.funct7)
                                'h00: o_signals.op <= Op::Add;
                                'h20: o_signals.op <= Op::Sub;
                            endcase
                        end
                        'h4: o_signals.op <= Op::Xor;
                        'h1: o_signals.op <= Op::Shl;
                        'h5: begin
                            case (insn.r.funct7)
                                'h00: o_signals.op <= Op::Shr;
                                'h20: o_signals.op <= Op::Asr;
                            endcase
                        end
                        'h6: o_signals.op <= Op::Or;
                        'h7: o_signals.op <= Op::And;
                    endcase

                    o_signals.wreg  <= insn.r.rd;
                    o_signals.wback <= 1;
                    o_signals.asel  <= Register;
                    o_signals.bsel  <= Register;
                end
                Opcode::RegImm: begin
                    case (insn.i.funct3)
                        'h0: o_signals.op <= Op::Add;
                        'h4: o_signals.op <= Op::Xor;
                        'h1: o_signals.op <= Op::Shl;
                        'h5: begin
                            case (insn.i.imm[11:5])
                                'h00: o_signals.op <= Op::Shr;
                                'h20: o_signals.op <= Op::Asr;
                            endcase
                        end
                        'h6: o_signals.op <= Op::Or;
                        'h7: o_signals.op <= Op::And;
                    endcase

                    o_signals.wreg  <= insn.i.rd;
                    o_signals.wback <= 1;
                    o_signals.asel  <= Register;
                    o_signals.bsel  <= Immediate;
                end
                Opcode::Branch: begin
                    case (insn.b.funct3)
                        'h0, 'h1, 'h4, 'h5: o_signals.op <= Op::Sub;
                        'h6, 'h7: o_signals.op <= Op::USub;
                    endcase

                    o_signals.wreg  <= 0;
                    o_signals.wback <= 0;
                    o_signals.asel  <= Register;
                    o_signals.bsel  <= Register;
                end
                Opcode::Jal: begin
                    o_signals.op    <= Op::Add;
                    o_signals.wreg  <= insn.j.rd;
                    o_signals.wback <= 1;
                    o_signals.asel  <= ProgramCounter;
                    o_signals.bsel  <= Immediate;
                end
                Opcode::Jalr: begin
                    o_signals.op    <= Op::Add;
                    o_signals.wreg  <= insn.i.rd;
                    o_signals.wback <= 1;
                    o_signals.asel  <= ProgramCounter;
                    o_signals.bsel  <= Immediate;
                end
                Opcode::Load: begin
                    o_signals.op    <= Op::Add;
                    o_signals.wreg  <= insn.i.rd;
                    o_signals.wback <= 1;
                    o_signals.asel  <= Register;
                    o_signals.bsel  <= Immediate;
                end
                Opcode::Store: begin
                    o_signals.op    <= Op::Add;
                    o_signals.wreg  <= 0;
                    o_signals.wback <= 0;
                    o_signals.asel  <= Register;
                    o_signals.bsel  <= Immediate;
                end
                Opcode::Lui: begin
                    o_signals.op    <= Op::Add;
                    o_signals.wreg  <= insn.u.rd;
                    o_signals.wback <= 1;
                    o_signals.asel  <= Register;
                    o_signals.bsel  <= Immediate;
                end
                Opcode::Auipc: begin
                    o_signals.op    <= Op::Add;
                    o_signals.wreg  <= insn.u.rd;
                    o_signals.wback <= 1;
                    o_signals.asel  <= ProgramCounter;
                    o_signals.bsel  <= Immediate;
                end
                default: begin
                    o_signals.op    <= Op::Add;
                    o_signals.wreg  <= 0;
                    o_signals.wback <= 0;
                    o_signals.asel  <= Register;
                    o_signals.bsel  <= Register;
                end
            endcase

            case (32'(insn.r.opcode))
                Opcode::Load: begin
                    o_signals.memr <= 1;
                    o_signals.memw <= 0;
                    case (insn.i.funct3)
                        'h0: o_signals.memt <= LoadByte;
                        'h1: o_signals.memt <= LoadHalf;
                        'h2: o_signals.memt <= LoadWord;
                        'h4: o_signals.memt <= ULoadByte;
                        'h5: o_signals.memt <= ULoadHalf;
                    endcase
                end
                Opcode::Store: begin
                    `log(
                        ("found store (valid = %d, funct3 = %01x)", i_signals.valid, insn.s.funct3));
                    o_signals.memr <= 0;
                    o_signals.memw <= 1;
                    case (insn.s.funct3)
                        'h0: o_signals.memt <= StoreByte;
                        'h1: o_signals.memt <= StoreHalf;
                        'h2: o_signals.memt <= StoreWord;
                        default: begin
                            `err(("invalid store funct3: %01x", insn.s.funct3));
                        end
                    endcase
                end
                default: begin
                    o_signals.memr <= 0;
                    o_signals.memw <= 0;
                    o_signals.memt <= LoadByte;
                end
            endcase

            case (32'(insn.r.opcode))
                Opcode::Branch: begin
                    case (insn.b.funct3)
                        // beq
                        'h0: o_signals.cond <= Zero;
                        // bne
                        'h1: o_signals.cond <= NotZero;
                        // blt
                        'h4: o_signals.cond <= Carry;
                        // bge
                        'h5: o_signals.cond <= NotCarry;
                        // bltu
                        'h6: o_signals.cond <= Carry;
                        // bgeu
                        'h7: o_signals.cond <= NotCarry;
                    endcase
                end
                Opcode::Jal: begin
                    o_signals.cond <= Always;
                end
                Opcode::Jalr: begin
                    o_signals.cond <= Always;
                end
                default: begin
                    o_signals.cond <= Never;
                end
            endcase
        end
    end

endmodule
