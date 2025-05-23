import Common::*;
import Op::*;

module BenchALU();

    bit clk;
    bit rst;
    Signals i_signals;
    Signals o_signals;

    ALU alu_i(
        .clk(clk),
        .rst(rst),
        .i_signals(i_signals),
        .o_signals(o_signals)
    );

    initial begin
        clk <= 0;
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

    Operation ops[11] = '{Add,
        Sub,
        USub,
        Xor,
        Or,
        And,
        Shl,
        Shr,
        Asr,
        Slt,
        USlt};
    logic signed [32:0] s_a = signed'(968);
    logic signed [32:0] s_b = signed'(-1234);
    logic unsigned [32:0] u_a = unsigned'(s_a);
    logic unsigned [32:0] u_b = unsigned'(s_b);
    
    initial begin
        $display("s_a:%d, s_b:%d", s_a, s_b);
        rst <= 1;
        #2;
        rst <= 0;
        foreach (ops[i]) begin
            i_signals.reg1 <= s_a;
            i_signals.reg2 <= s_b;
            i_signals.asel <= Register;
            i_signals.bsel <= Register;
            i_signals.op <= ops[i];
            #2;
            case (ops[i])
                Add: begin
                    $display("Add:\t");
                    debug(s_a + s_b, o_signals.wdata);
                end
                Sub: begin
                    $display("Sub:\t");
                    debug(s_a - s_b, o_signals.wdata);
                end
                USub: begin
                    $display("USub:\t");
                    debug(u_a - u_b, o_signals.wdata);
                end
                Xor: begin
                    $display("Xor:\t");
                    debug(u_a ^ u_b, o_signals.wdata);
                end
                Or: begin
                    $display("Or:\t");
                    debug(u_a | u_b, o_signals.wdata);
                end
                And: begin
                    $display("And:\t");
                    debug(u_a & u_b, o_signals.wdata);
                end
                Shl: begin
                    $display("Shl:\t");
                    debug(u_a << u_b[4:0], o_signals.wdata);
                end
                Shr: begin
                    $display("Shr\t");
                    debug(u_a >> u_b[4:0], o_signals.wdata);
                end
                Asr: begin
                    $display("Asr\t");
                    debug(s_a >>> u_b[4:0], o_signals.wdata);
                end
                Slt: begin
                    $display("Slt\t");
                    debug((s_a < s_b) ? 1:0, o_signals.wdata);
                end
                USlt: begin
                    $display("USlt\t");
                    debug((u_a < u_b) ? 1:0, o_signals.wdata);
                end
            endcase


            i_signals.bsel <= Immediate;
            i_signals.imm <= -1234;
            #2;
            case (ops[i])
                Add: begin
                    $display("Add:\t");
                    debug(s_a + s_b, o_signals.wdata);
                end
                Sub: begin
                    $display("Sub:\t");
                    debug(s_a - s_b, o_signals.wdata);
                end
                USub: begin
                    $display("USub:\t");
                    debug(u_a - u_b, o_signals.wdata);
                end
                Xor: begin
                    $display("Xor:\t");
                    debug(u_a ^ u_b, o_signals.wdata);
                end
                Or: begin
                    $display("Or:\t");
                    debug(u_a | u_b, o_signals.wdata);
                end
                And: begin
                    $display("And:\t");
                    debug(u_a & u_b, o_signals.wdata);
                end
                Shl: begin
                    $display("Shl:\t");
                    debug(u_a << u_b[4:0], o_signals.wdata);
                end
                Shr: begin
                    $display("Srl\t");
                    debug(u_a >> u_b[4:0], o_signals.wdata);
                end
                Asr: begin
                    $display("Sra\t");
                    debug(s_a >>> u_b[4:0], o_signals.wdata);
                end
                Slt: begin
                    $display("Slt\t");
                    debug((s_a < s_b) ? 1:0, o_signals.wdata);
                end
                USlt: begin
                    $display("Sltu\t");
                    debug((u_a < u_b) ? 1:0, o_signals.wdata);
                end
            endcase
        end
    end

endmodule
