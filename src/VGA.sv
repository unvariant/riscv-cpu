import Common::*;
import Mem::*;

module VGA (
    input logic   clk,
    input logic   rst,
    input logic   clk_100m,
    input Signals i_signals,

    output logic hsync,
    output logic vsync,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
);

    // https://projectf.io/posts/fpga-graphics/

`ifdef SIMULATION
    logic clk_pix;
    assign clk_pix = clk;
`else
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
`endif

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
    logic display_enable;
    logic hsync_i;
    logic vsync_i;

    always_comb begin
        hsync_i = ~(sx >= HS_STA && sx < HS_END);  // invert: negative polarity
        vsync_i = ~(sy >= VS_STA && sy < VS_END);  // invert: negative polarity
        display_enable = (sx <= HA_END && sy <= VA_END);
    end

    // width of the visible frame
    parameter WIDTH = 640;
    // upscale factor
    parameter UPSCALE = 1;

    logic [31:0] vram[0:'h9600-1];
    logic [31:0] idx;
    logic [15:0] off;
    assign idx = i_signals.wdata[31:0];
    assign off = i_signals.wdata[$size(off)-1:0];

    // only support word writes
    // for some reason idx[25:24] == 'b01 doesn't work???
    always @(posedge clk) begin
        if (i_signals.memw && i_signals.memt == StoreWord && idx[24] == 1) begin
            // $display("vram[0x%x] = 0x%x", off >> 2, i_signals.reg2);
            vram[off>>2] <= i_signals.reg2;
        end
    end

    logic [$size(off)-1:0] line = 0;
    logic [$size(off)-1:0] running = 0;
    logic [4:0] bit_offset = 0;
    logic [4:0] stallx = 0;
    logic [4:0] stally = 0;

    always_ff @(posedge clk_pix) begin
        if (bit_offset == 30) begin
            running <= running + 1;
        end

        if (bit_offset == 31) begin
            bit_offset <= 0;
        end else begin
            bit_offset <= bit_offset + 1;
        end

        if (sx == LINE - 1) begin
            line <= line + WIDTH / UPSCALE / 32;
            running <= line + WIDTH / UPSCALE / 32;
        end

        if (sx == LINE) begin
            sx <= 0;
            if (sy == SCREEN) begin
                sy <= 0;
                running <= 0;
                line <= 0;
            end else begin
                sy <= sy + 1;
                bit_offset <= 0;
            end
        end else begin
            sx <= sx + 1;
        end
    end

    // // calculate horizontal and vertical screen position
    // always_ff @(posedge clk_pix) begin
    //     if (sx == LINE) begin  // last pixel on line?
    //         sx <= 0;
    //         sy <= (sy == SCREEN) ? 0 : sy + 1;  // last line on screen?
    //     end else begin
    //         sx <= sx + 1;
    //     end

    //     if (sx == LINE) begin
    //         bit_offset <= 0;
    //         stallx <= 0;

    //         if (sy == SCREEN) begin
    //             line <= 0;
    //             stally <= 0;
    //             running <= 0;
    //         end else begin
    //             if (stally == UPSCALE - 1) begin
    //                 stally <= 0;
    //                 line <= line + WIDTH / UPSCALE / 32;
    //                 running <= line + WIDTH / UPSCALE / 32;
    //             end else begin
    //                 stally  <= stally + 1;
    //                 running <= line;
    //             end
    //         end
    //     end else begin
    //         if (stallx == UPSCALE - 1) begin
    //             stallx <= 0;
    //             if (bit_offset == 31) begin
    //                 bit_offset <= 0;
    //                 running <= running + 1;
    //             end else begin
    //                 bit_offset <= bit_offset + 1;
    //             end
    //         end else begin
    //             stallx <= stallx + 1;
    //         end
    //     end
    // end

    logic [31:0] pixel = 'hffffffff;
    // always @(negedge clk_pix) begin
    always @(posedge clk_pix) begin
        pixel <= vram[running];
    end

    always @(posedge clk_pix) begin
        r <= display_enable ? (pixel[bit_offset] ? 'hf : 'h0) : 'h0;
        g <= display_enable ? (pixel[bit_offset] ? 'hf : 'h0) : 'h0;
        b <= display_enable ? (pixel[bit_offset] ? 'hf : 'h0) : 'h0;
        // red   <= 'h0;
        // green <= 'h0;
        // blue  <= de ? 'hf : 'h0;
        hsync <= hsync_i;
        vsync <= vsync_i;
    end

endmodule
