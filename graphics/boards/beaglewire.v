// This is the top module when building for development on the BeagleWire
// ICE40 development board. See beaglewire.pcf for information on what
// peripherals are used in this mode.

module top(
    input clk_100M,
    input reset,

    output disp_clk,
    output disp_hsync,
    output disp_vsync,
    output disp_de,
    output [3:0] disp_b,
    output [3:0] disp_g,
    output [3:0] disp_r,

    output int_vblank,

    output [12:0] vram_addr,
    inout  [7:0] vram_data,
    output [1:0] vram_bank,
    output vram_clk,
    output vram_cke,
    output vram_we,
    output vram_cs,
    output vram_dqm,
    output vram_ras,
    output vram_cas,

    inout [15:0] gpmc_ad,
    input gpmc_advn,
    input gpmc_csn1,
    input gpmc_wein,
    input gpmc_oen,
    input gpmc_clk,

    output [3:0] led
);

    wire pixel_clk;
    reg [31:0] count = 0;
    assign led = { 0, 0, disp_de };

    // PLL to generate our pixel clock from the 100MHz clk_100M input clock
    // icepll -i 100 -o 74.25
    //   Given input frequency:       100.000 MHz
    //   Requested output frequency:   74.250 MHz
    //   Achieved output frequency:    73.750 MHz
    // F_OUT = (F_REF * (DIVF + 1)) / ((2^DIVQ) * (DIVR+1))
    //       = (100 * (58 + 1)) / ((2 ^ 3) * (9 + 1))
    //       = 73.75 MHz
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b1001),        // DIVR =  9
        .DIVF(7'b0111010),     // DIVF = 58
        .DIVQ(3'b011),         // DIVQ =  3
        .FILTER_RANGE(3'b001), // FILTER_RANGE = 1
        .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
        .FDA_FEEDBACK(4'b0000),
        .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
        .FDA_RELATIVE(4'b0000),
        .SHIFTREG_DIV_MODE(2'b00),
        //.PLLOUT_SELECT("GENCLK"),
        .ENABLE_ICEGATE(1'b0)
    ) pixel_clock (
        .REFERENCECLK(clk_100M),
        .PLLOUTCORE(pixel_clk),
        .EXTFEEDBACK(),
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .LATCHINPUTVALUE()
    );

    main main(
        .pixel_clk(pixel_clk),
        .reset(reset),

        .disp_clk(disp_clk),
        .disp_hsync(disp_hsync),
        .disp_vsync(disp_vsync),
        .disp_de(disp_de),
        .disp_b(disp_b),
        .disp_g(disp_g),
        .disp_r(disp_r)
    );

endmodule
