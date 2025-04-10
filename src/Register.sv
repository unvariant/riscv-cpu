import Common::*;

module Register (
    input logic          clk,
    input logic          rst,
    input logic          stall,
    input Signals        i_signals,
    input logic          i_wback,
    input logic   [ 4:0] i_wreg,
    input logic   [31:0] i_wdata,

    output Signals        o_signals,
    output logic   [31:0] o_debug
);

    logic [31:0][31:0] registers;

    assign o_debug = registers[10];

    Insn prev_insn;
    Insn insn;
    assign insn = stall ? prev_insn : i_signals.insn;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] = 0;
            end
        end else begin
            if (i_wback) begin
                if (i_wreg == 0) begin
                    registers[i_wreg] = 0;
                end else begin
                    registers[i_wreg] = i_wdata;
                    `log(("writing %08x to x%0d", i_wdata, i_wreg));
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!stall) begin
            prev_insn <= i_signals.insn;
        end

        if (rst) begin
            o_signals.reg1 <= 0;
            o_signals.reg2 <= 0;
        end else begin
            // `log(("reg insn = %08x", insn));
            case (insn.r.opcode)
                Opcode::RegReg: begin
                    o_signals.reg1 <= registers[insn.r.rs1];
                    o_signals.reg2 <= registers[insn.r.rs2];
                end
                Opcode::RegImm: begin
                    // if (insn.i.rd != 0) begin
                    //     //     `log(("reg insn = %08x", insn));
                    //     `log(("wdata = %08x", i_wdata));
                    //     `log(("wreg = %0d", i_wreg));
                    //     `log(("reg[wreg] = %08x", registers[i_wreg]));
                    // end
                    // `log(("rd = %0d, rs1 = %0d", insn.i.rd, insn.i.rs1));
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

        // if (o_signals.rs1 != 0 || o_signals.rs2 != 0) begin
        //     `log(("rs1 = %02x, rs2 = %02x", o_signals.rs1, o_signals.rs2));
        // end
    end

endmodule
