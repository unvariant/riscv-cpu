import Common::*;

module ROM (
    input logic   clk,
    input Signals i_signals,

    output Signals o_signals
);

    // support 128 instructions
    logic [31:0] mem[0:127];
    initial $readmemh("rom_file.mem", mem);

    always @(posedge clk) begin
        o_signals.insn <= mem[i_signals.pc>>2];

        // $display("== insn dump ==");
        // $display("\traw    = 0b%032b", insns[i_pc>>2]);
        // $display("\topcode = 0b%07b", insns[i_pc>>2].r.opcode);
        // $display("\trs1    = 0x%02x", insns[i_pc>>2].r.rs1);
        // $display("\trs2    = 0x%02x", insns[i_pc>>2].r.rs2);
        // $display("\tfunct3 = 0x%01x", insns[i_pc>>2].r.funct3);
        // $display("\tfunct7 = 0x%02x", insns[i_pc>>2].r.funct7);
    end

endmodule
