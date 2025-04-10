import Common::*;
import Mem::*;

module RAM (
    input logic   clk,
    input logic   rst,
    input Signals i_signals,

    output Signals o_signals
);

    parameter int RAM_WORDS = (36 * 125 * 64 / 4);
    (*ram_style = block*)
    logic [31:0] ram[0:RAM_WORDS-1];
    // initial $readmemh("frames.bin", ram);
    logic [31:0] idx;
    logic [3:0] enable_mask;
    logic [4:0] shift;

    always_comb begin
        idx = i_signals.wdata[31:0];

        case (i_signals.memt)
            LoadByte, ULoadByte, StoreByte: begin
                case (idx & 'b11)
                    'b00: begin
                        enable_mask = 'b0001;
                        shift = 0;
                    end
                    'b01: begin
                        enable_mask = 'b0010;
                        shift = 8;
                    end
                    'b10: begin
                        enable_mask = 'b0100;
                        shift = 16;
                    end
                    'b11: begin
                        enable_mask = 'b1000;
                        shift = 24;
                    end
                    default: begin
                        enable_mask = 'b0000;
                        shift = 0;
                    end
                endcase
            end
            LoadHalf, ULoadHalf, StoreHalf: begin
                case (idx & 'b10)
                    'b00: begin
                        enable_mask = 'b0011;
                        shift = 0;
                    end
                    'b10: begin
                        enable_mask = 'b1100;
                        shift = 16;
                    end
                    default: begin
                        enable_mask = 'b0000;
                        shift = 0;
                    end
                endcase
            end
            LoadWord, StoreWord: begin
                enable_mask = 'b1111;
                shift = 0;
            end
            default: begin
                enable_mask = 'b0000;
                shift = 0;
            end
        endcase
    end

    logic [31:0] result;
    logic [ 1:0] memrw;
    assign memrw = {i_signals.memr, i_signals.memw};

    always_ff @(posedge clk) begin
        o_signals.valid  <= i_signals.valid;
        o_signals.pc     <= i_signals.pc;
        o_signals.wback  <= i_signals.wback;
        o_signals.wreg   <= i_signals.wreg;
        o_signals.branch <= i_signals.branch;
        o_signals.flags  <= i_signals.flags;
        o_signals.cond   <= i_signals.cond;
        result = 0;

        o_signals.wdata <= i_signals.wdata;

        if (idx[24] == 0) begin
            case (memrw)
                'b10: begin
                    if (enable_mask[0]) result[07:00] = ram[idx>>2][07:00];
                    if (enable_mask[1]) result[15:08] = ram[idx>>2][15:08];
                    if (enable_mask[2]) result[23:16] = ram[idx>>2][23:16];
                    if (enable_mask[3]) result[31:24] = ram[idx>>2][31:24];

                    case (i_signals.memt)
                        LoadByte:  o_signals.wdata[31:0] <= 32'(signed'(result[shift+:8]));
                        ULoadByte: o_signals.wdata[31:0] <= 32'(unsigned'(result[shift+:8]));
                        LoadHalf:  o_signals.wdata[31:0] <= 32'(signed'(result[shift+:16]));
                        ULoadHalf: o_signals.wdata[31:0] <= 32'(unsigned'(result[shift+:16]));
                        LoadWord:  o_signals.wdata[31:0] <= result;
                        default:   o_signals.wdata[31:0] <= 0;
                    endcase

                    o_signals.wdata[32] <= 0;
                end
                'b01: begin
                    case (shift)
                        'h00: result = i_signals.reg2;
                        'h08: result = {i_signals.reg2[23:0], 8'd0};
                        'h10: result = {i_signals.reg2[15:0], 16'd0};
                        'h18: result = {i_signals.reg2[07:0], 24'd0};
                        default: result = 0;
                    endcase

                    if (enable_mask[0]) ram[idx>>2][07:00] <= result[07:00];
                    if (enable_mask[1]) ram[idx>>2][15:08] <= result[15:08];
                    if (enable_mask[2]) ram[idx>>2][23:16] <= result[23:16];
                    if (enable_mask[3]) ram[idx>>2][31:24] <= result[31:24];

                    o_signals.wdata <= 0;
                end
                default: begin
                    o_signals.wdata <= i_signals.wdata;
                end
            endcase
        end
    end

endmodule
