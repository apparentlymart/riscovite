// This is the main module for the graphics core. Each of the board modules
// in ../boards should instantiate this and wire all of its I/O signals to
// suitable physical package pins to implement the expected behavior.

module main(
    input pixel_clk, // Should be approx. 74.250 MHz for a correct 720p signal
    input reset,

    // "Host" signals are writes from the main CPU, which can either be
    // writes into video RAM or writes into the control registers depending
    // on which "chip select" is activated.
    // The calling module must adapt this generic interface to whatever bus
    // interface the main CPU is expecting. We expose an entirely separate
    // bus interface for VRAM vs. registers but in practice we expect most
    // callers will connect these together aside from the chip select signals.
    // Host writes are accepted only during the vertical blanking period. Any
    // writes at other times will stall the bus, with host_done delayed until
    // the pending write is completed at the beginning of the vertical blanking
    // period.
    input  host_vram_cs,          // host selects VRAM for write
    input  [13:1] host_vram_addr, // write target address from the host
    inout  [15:0] host_vram_data, // data to write from the host
    output host_vram_done,        // write operation has completed
    input  host_reg_cs,           // host selects registers for write
    input  [13:1] host_reg_addr,  // write target address from the host
    inout  [15:0] host_reg_data,  // data to write from the host
    output host_reg_done,         // write operation has completed
    output host_write_avail,      // updated synchronously with pixel_clk to indicate whether a write can succeed without stalling

    // "VRAM" signals are reads/writes to our video memory. This module expects
    // a generic asynchronous memory interface which can satisfy reads/writes
    // in less than one pixel clock (approx 13ns). The calling module must
    // adapt this generic interface to whatever the target memory controller
    // expects.
    output vram_cs,    // video RAM chip select
    output vram_we,    // video RAM write enable
    output [13:1] vram_addr,
    inout  [15:0] vram_data,
    input  vram_done,  // video RAM controller asserts that data is ready or write is complete

    // Display output signals. We're expecting to drive a 4-bit-per-channel
    // parallel output port here, with the control signals following what is
    // conventionally expected for a 720p display. The result of this could be
    // fed (by the caller) into a resistor ladder for VGA output, into a
    // DVI/HDMI encoder to produce a digital output, or other similar options.
    output disp_clk,
    output disp_hsync,
    output disp_vsync,
    output disp_de,
    output [3:0] disp_b,
    output [3:0] disp_g,
    output [3:0] disp_r
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
