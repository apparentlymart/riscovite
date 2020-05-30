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

    // Our video RAM (SDRAM) clock is just our 100MHz input clock, unmodified.
    assign vram_clk = clk_100M;

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
        .PLLOUT_SELECT("GENCLK"),
        .ENABLE_ICEGATE(1'b0)
    ) pixel_clock (
        .REFERENCECLK(clk_100M),
        .PLLOUTCORE(pixel_clk),
        .EXTFEEDBACK(),
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .LATCHINPUTVALUE()
    );

    wire host_vram_cs;
    wire host_reg_cs;
    wire [13:1] host_addr;
    wire [15:0] host_data;
    wire host_done;
    wire host_write_avail;

    wire [15:0] gpmc_vram_write_addr;
    wire [15:0] gpmc_vram_write_data;
    wire gpmc_vram_write;
    wire gpmc_vram_can_write;
    am335x_gpmc gpmc(
        .reset(reset),
        .gpmc_ad(gpmc_ad),
        .gpmc_advn(gpmc_advn),
        .gpmc_csn1(gpmc_csn1),
        .gpmc_wein(gpmc_wein),
        .gpmc_oen(gpmc_oen),
        .gpmc_clk(gpmc_clk),
        .vram_write_addr(gpmc_vram_write_addr),
        .vram_write_data(gpmc_vram_write_data),
        .vram_write(gpmc_vram_write),
        .vram_can_write(gpmc_vram_can_write)
    );

    // gpmc_vram_queue is an async FIFO used to bring video RAM writes from
    // the gpmc clock domain into the SDRAM domain so that the SDRAM controller
    // can process them next time the SDRAM bus is available.
    asyncfifo #(.BUFFER_ADDR_WIDTH(4), .DATA_WIDTH(32)) gpmc_vram_queue (
        .reset(reset),
        .write_clk(gpmc_clk),
        .write(gpmc_vram_write),
        .write_data({gpmc_vram_write_addr, gpmc_vram_write_data}),
        .can_write(gpmc_vram_can_write),

        .read_clk(vram_clk),
        // TODO: hook up the rest, once we have something consuming the output.
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
        .disp_r(disp_r),

        .host_vram_cs(host_vram_cs),
        .host_vram_addr(host_addr),
        .host_vram_data(host_data),
        .host_vram_done(host_done),
        .host_reg_cs(host_reg_cs),
        .host_reg_addr(host_addr),
        .host_reg_data(host_data),
        .host_reg_done(host_done),
        .host_write_avail(host_write_avail)
    );

endmodule
