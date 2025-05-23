import Common::*;
import Opcode::*;
module BenchImmGen ();

    logic stall = 0;
    bit clk;
    bit rst;
    Signals i_signals;
    Signals o_signals;
    Insn insn;
    int passed;
    int total;
    assign insn = i_signals.insn;

    ImmGen ImmGen(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .i_buffer(i_signals),
        .o_signals(o_signals)
    );

    initial begin
        clk = 0;
        passed = 0;
        total = 0;
        forever begin
            #1 clk = ~clk;
        end  
    end
 
    

    logic[6:0] opcode[4] = '{RegImm, Branch, Jal, Jalr};
    function void test(logic[31:0] expected, logic[31:0] actual);
        if (expected == actual) begin
            $display("Pass");
            passed +=1;
        end else begin
            $display("fail");
        end
        $display("expected: %032b, actual: %032b \n", expected, actual);
    endfunction
    initial begin
    
        foreach (opcode[i]) begin
            rst <= 1;
            #2
            rst <= 0;
            case (opcode[i])
                RegImm: begin
                    i_signals.insn <= 'h00d00013;
                    #2
                    $display("addi x0, x0, 13");
                    test(13, o_signals.imm);
                    total +=1;
                    test(0, o_signals.jimm);
                    total +=1;
                    i_signals.insn <= 'h02804013;
                    #2
                    $display("xori x0, x0, 40");
                    test(40, o_signals.imm);
                    total +=1;
                    test(0, o_signals.jimm);
                    total +=1;
                    i_signals.insn <= 'h02006013;
                    #2
                    $display("ori x0, x0, 32");
                    test(32, o_signals.imm);
                    total +=1;
                    test(0, o_signals.jimm);
                    total +=1;
                    i_signals.insn <= 'h00907013;
                    #2
                    $display("andi x0, x0, 9");
                    test(9, o_signals.imm);
                    total +=1;
                    test(0, o_signals.jimm);
                    total +=1;
                    i_signals.insn <= 'h00500013;
                    #2
                    $display("addi x0, x0, 5");
                    test(5, o_signals.imm);
                    total +=1;
                    test(0, o_signals.jimm);
                    total +=1;
                end
                Branch: begin
                    $display("beq x0 x0 10");
                    i_signals.insn <= 'h00000563;
                    #2
                    test(0, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.b.imm4, insn.b.imm3, insn.b.imm2, insn.b.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("beq x0 x1 30");
                    i_signals.insn <= 'h00100f63;
                    #2
                    test(0, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.b.imm4, insn.b.imm3, insn.b.imm2, insn.b.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("beq x1, x0, 32");
                    i_signals.insn <= 'h02008063;
                    #2
                    test(0, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.b.imm4, insn.b.imm3, insn.b.imm2, insn.b.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("beq x0, x2, 6");
                    i_signals.insn <= 'h00200363;
                    #2
                    test(0, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.b.imm4, insn.b.imm3, insn.b.imm2, insn.b.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("beq x1, x1, 16");
                    i_signals.insn <= 'h00108863;
                    #2
                    test(0, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.b.imm4, insn.b.imm3, insn.b.imm2, insn.b.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                end
                Jal: begin
                    $display("jal x1, 4");
                    i_signals.insn <= 'h004000ef;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.j.imm4, insn.j.imm3, insn.j.imm2, insn.j.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("jal x0, 16");
                    i_signals.insn <= 'h0100006f;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.j.imm4, insn.j.imm3, insn.j.imm2, insn.j.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("jal x2, 4");
                    i_signals.insn <= 'h0040016f;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.j.imm4, insn.j.imm3, insn.j.imm2, insn.j.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("jal x0, 2");
                    i_signals.insn <= 'h0020006f;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.j.imm4, insn.j.imm3, insn.j.imm2, insn.j.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                    $display("jal x1, 8");
                    i_signals.insn <= 'h008000ef;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(32'(signed'({insn.j.imm4, insn.j.imm3, insn.j.imm2, insn.j.imm1, 1'b0})), o_signals.jimm);
                    total +=1;
                end
                Jalr: begin
                    $display("jalr x2, x1, 2");
                    i_signals.insn <= 'h00208167;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(2, o_signals.jimm);
                    total +=1;
                    $display("jalr x3, x0, 6");
                    i_signals.insn <= 'h006001e7;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(6, o_signals.jimm);
                    total +=1;
                    $display("jalr x0, x1, 8");
                    i_signals.insn <= 'h00808067;
                    #2
                    test(32'd4, o_signals.imm);
                    total +=1;
                    test(8, o_signals.jimm);
                    total +=1;
                    $display("jalr x0, x0, 16");
                    i_signals.insn <= 'h01000067;
                    #2
                    test(32'd4, o_signals.imm);
                    total += 1;
                    test(16, o_signals.jimm);
                    total += 1;
                    $display("jalr x5, x1, 2");
                    i_signals.insn <= 'h002082e7;
                    #2
                    test(32'd4, o_signals.imm);
                    total += 1;
                    test(2, o_signals.jimm);
                    total += 1;
                    $display("Testbench completed: %0d/%0d tests passed", passed, total);
                    $finish;
                end
            endcase
        end
    end
endmodule