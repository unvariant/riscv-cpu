module clock_480p (
    input wire logic clk_100m,  // input clock (100 MHz)
    input wire logic rst,       // reset

    output logic clk_pix,        // pixel clock
    output logic clk_pix_x,
    output logic clk_pix_locked  // pixel clock locked?
);

    localparam MULT_MASTER = 63;  // master clock multiplier (2.000-64.000)
    localparam DIV_MASTER = 25;  // master clock divider (1-106)
    localparam IN_PERIOD = 10.0;  // period of master clock in ns (10 ns == 100 MHz)

    logic feedback;  // internal clock feedback
    logic clk_pix_unbuf;  // unbuffered pixel clock
    logic clk_pix_x_unbuf;  // unbuffered 5x pixel clock
    logic locked;  // unsynced lock signal

    PLLE2_BASE #(
        .CLKFBOUT_MULT(MULT_MASTER),  // MULT_MASTER
        .CLKIN1_PERIOD(IN_PERIOD),
        .CLKOUT0_DIVIDE(10),  // 10
        .CLKOUT1_DIVIDE(2),
        .DIVCLK_DIVIDE(DIV_MASTER)  // DIV_MASTER
    ) PLLE2_BASE_inst (
        .CLKIN1(clk_100m),
        .RST(rst),
        .CLKOUT0(clk_pix_unbuf),
        .CLKOUT1(clk_pix_x_unbuf),
        .LOCKED(locked),
        .CLKFBOUT(feedback),
        .CLKFBIN(feedback),
        /* verilator lint_off PINCONNECTEMPTY */
        .CLKOUT2(),
        .CLKOUT3(),
        .CLKOUT4(),
        .CLKOUT5(),
        .PWRDWN()
        /* verilator lint_on PINCONNECTEMPTY */
    );

    // explicitly buffer output clocks
    BUFG bufg_clk (
        .I(clk_pix_unbuf),
        .O(clk_pix)
    );

    BUFG bufg_clk_x (
        .I(clk_pix_x_unbuf),
        .O(clk_pix_x)
    );

    // ensure clock lock is synced with pixel clock
    logic locked_sync_0;
    always_ff @(posedge clk_pix) begin
        locked_sync_0  <= locked;
        clk_pix_locked <= locked_sync_0;
    end
endmodule
