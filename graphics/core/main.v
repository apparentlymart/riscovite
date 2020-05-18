// This is the main module for the graphics core. Each of the board modules
// in ../boards should instantiate this and wire all of its I/O signals to
// suitable physical package pins to implement the expected behavior.

module main(
    input pixel_clk, // Should be approx. 74.250 MHz for a correct 720p signal
    input reset,

    output disp_clk,
    output disp_hsync,
    output disp_vsync,
    output disp_de,
    output [3:0] disp_b,
    output [3:0] disp_g,
    output [3:0] disp_r,

    output int_vblank
);

    assign disp_clk = pixel_clk;
    wire [15:0] x;
    wire [15:0] y;
    wire hsync;
    wire vsync;
    wire visible;
    assign disp_hsync = hsync;
    assign disp_vsync = vsync;
    assign disp_de = visible;
    assign int_vblank = disp_vsync;

    timing timing(
        .clk(pixel_clk),
        .reset(reset),

        .hsync(hsync),
        .vsync(vsync),
        .visible(visible),
        .x(x),
        .y(y)
    );

    testpattern pattern(
        .clk(pixel_clk),
        .x(x),
        .y(y),
        .visible(visible),
        .r(disp_r),
        .g(disp_g),
        .b(disp_b)
    );

endmodule
