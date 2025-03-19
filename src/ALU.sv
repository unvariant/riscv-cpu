import Common::*;

module ALU (
    input  logic   clk,
    input  logic   rst,
    input  Signals i_signals,
    output Signals o_signals
);

    logic [31:0] a;
    logic [31:0] b;
    always_comb begin
        case (i_signals.asel)
            Register:       a = i_signals.reg1;
            ProgramCounter: a = i_signals.pc;
            default:        a = 0;
        endcase

        case (i_signals.bsel)
            Register:  b = i_signals.reg2;
            Immediate: b = i_signals.imm;
            default:   b = 0;
        endcase
    end

    logic [32:0] result;

    always @(posedge clk) begin
        logic [32:0] s_a = 33'(signed'(a));
        logic [32:0] s_b = 33'(signed'(b));
        logic [32:0] u_a = 33'(unsigned'(a));
        logic [32:0] u_b = 33'(unsigned'(b));

        if (rst) begin
            o_signals.valid       <= 0;
            o_signals.pc          <= 0;
            o_signals.reg2        <= 0;
            o_signals.wback       <= 0;
            o_signals.wreg        <= 0;
            o_signals.wdata       <= 0;
            o_signals.branch      <= 0;
            o_signals.flags.zero  <= 0;
            o_signals.flags.carry <= 0;
            o_signals.cond        <= Never;
            o_signals.memr        <= 0;
            o_signals.memw        <= 0;
            o_signals.memt        <= LoadByte;
        end else begin
            o_signals.valid <= i_signals.valid;
            o_signals.pc    <= i_signals.pc;
            o_signals.reg2  <= i_signals.reg2;
            o_signals.wback <= i_signals.wback;
            o_signals.wreg  <= i_signals.wreg;
            o_signals.cond  <= i_signals.cond;
            o_signals.memr  <= i_signals.memr;
            o_signals.memw  <= i_signals.memw;
            o_signals.memt  <= i_signals.memt;

            case (i_signals.op)
                Op::Add: begin
                    result = s_a + s_b;
                end
                Op::Sub: begin
                    result = s_a - s_b;
                end
                Op::USub: begin
                    result = u_a - u_b;
                end
                Op::Xor: begin
                    result = u_a ^ u_b;
                end
                Op::Or: begin
                    result = u_a | u_b;
                end
                Op::And: begin
                    result = u_a & u_b;
                end
                Op::Shl: begin
                    result = u_a << u_b;
                end
                Op::Shr: begin
                    result = u_a >> u_b;
                end
                Op::Asr: begin
                    result = s_a >>> u_b;
                end
                default: begin
                    result = 0;
                end
            endcase
            o_signals.wdata <= result;
            o_signals.branch <= ((i_signals.pcsel == 0) ? i_signals.pc : i_signals.reg1) + i_signals.jimm;
            o_signals.flags.zero <= result[31:0] == 0;
            o_signals.flags.carry <= result[31];
        end
    end

endmodule
