`include "CPU.h.sv"

module InstructionBench;

    Insn insns[4:0];

    initial begin
        $readmemh("rom_file.mem", insns);
        $display("opcode = %07b", insns[0].opcode);
    end

endmodule
