import Common::*;

module WriteBack (
    input logic   clk,
    input logic   clk_100m,
    input logic   rst,
    input Signals i_signals,

    output Signals o_signals,
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue,
    output logic hsync,
    output logic vsync
);

    logic [31:0] pc;
    logic [31:0] next;
    assign next = i_signals.pc + 4;
    always_comb begin
        case (i_signals.cond)
            Zero:     pc = (i_signals.flags.zero == 1) ? i_signals.branch : next;
            NotZero:  pc = (i_signals.flags.zero == 0) ? i_signals.branch : next;
            Carry:    pc = (i_signals.flags.carry == 1) ? i_signals.branch : next;
            NotCarry: pc = (i_signals.flags.carry == 0) ? i_signals.branch : next;
            Never:    pc = next;
            Always:   pc = i_signals.branch;
            default: begin
                pc = 0;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            o_signals.valid <= 0;
            o_signals.pc    <= 0;
            o_signals.wback <= 0;
            o_signals.wreg  <= 0;
            o_signals.wdata <= 0;
        end else begin
            o_signals.valid <= i_signals.valid;
            o_signals.pc    <= pc;
            o_signals.wback <= i_signals.wback;
            o_signals.wreg  <= i_signals.wreg;
            o_signals.wdata <= i_signals.wdata;
        end
    end

`ifndef SIMULATION

    logic clk_pix;
    logic clk_pix_x;
    logic clk_pix_locked;
    clock_480p vga_clk (
        .clk_100m(clk_100m),
        .rst(rst),
        .clk_pix(clk_pix),
        .clk_pix_x(clk_pix_x),
        .clk_pix_locked(clk_pix_locked)
    );

    // horizontal timings
    parameter HA_END = 639;  // end of active pixels
    parameter HS_STA = HA_END + 16;  // sync starts after front porch
    parameter HS_END = HS_STA + 96;  // sync ends
    parameter LINE = 799;  // last pixel on line (after back porch)

    // vertical timings
    parameter VA_END = 479;  // end of active pixels
    parameter VS_STA = VA_END + 10;  // sync starts after front porch
    parameter VS_END = VS_STA + 2;  // sync ends
    parameter SCREEN = 524;  // last line on screen (after back porch)
    parameter VISIBLE_END = 439;

    logic [9:0] sx = 0;
    logic [9:0] sy = 0;
    logic de;
    logic lhsync;
    logic lvsync;

    always_comb begin
        lhsync = ~(sx >= HS_STA && sx < HS_END);  // invert: negative polarity
        lvsync = ~(sy >= VS_STA && sy < VS_END);  // invert: negative polarity
        de = (sx <= HA_END && sy <= VA_END);
    end

    parameter WIDTH = 640;
    parameter UPSCALE = 10;

    logic [31:0] vram[0:128-1];
    logic [$clog2($size(vram))-1:0] line = 0;
    logic [$clog2($size(vram))-1:0] running = 0;
    logic [4:0] bit_offset = 0;
    logic [4:0] stallx = 0;
    logic [4:0] stally = 0;

    // calculate horizontal and vertical screen position
    always @(posedge clk_pix) begin
        if (sx == LINE) begin  // last pixel on line?
            sx <= 0;
            sy <= (sy == SCREEN) ? 0 : sy + 1;  // last line on screen?
        end else begin
            sx <= sx + 1;
        end

        if (sx == LINE) begin
            bit_offset <= 0;
            stallx <= 0;

            if (sy == SCREEN) begin
                line <= 0;
                stally <= 0;
                running <= 0;
            end else begin
                if (stally == UPSCALE - 1) begin
                    stally <= 0;
                    line <= line + WIDTH / UPSCALE / 32;
                    running <= line + WIDTH / UPSCALE / 32;
                end else begin
                    stally  <= stally + 1;
                    running <= line;
                end
            end
        end else begin
            if (stallx == UPSCALE - 1) begin
                stallx <= 0;
                if (bit_offset == 31) begin
                    bit_offset <= 0;
                    running <= running + 1;
                end else begin
                    bit_offset <= bit_offset + 1;
                end
            end else begin
                stallx <= stallx + 1;
            end
        end
    end

    logic [31:0] pixel = 'hffffffff;
    logic sync = 1;
    always @(negedge clk_pix) begin
        // if (sync) begin
        pixel <= vram[running];
        // end
        // sync <= !sync;
        // pixel <= ram[line];
    end

    always @(posedge clk_pix) begin
        red   <= de ? (pixel[bit_offset] ? 'hf : 'h0) : 'h0;
        green <= de ? (pixel[bit_offset] ? 'hf : 'h0) : 'h0;
        blue  <= de ? (pixel[bit_offset] ? 'hf : 'h0) : 'h0;
        // red   <= 'h0;
        // green <= 'h0;
        // blue  <= de ? 'hf : 'h0;
        hsync <= lhsync;
        vsync <= lvsync;
    end

`endif

endmodule
