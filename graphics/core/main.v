// This is the main module for the graphics core. Each of the board modules
// in ../boards should instantiate this and wire all of its I/O signals to
// suitable physical package pins to implement the expected behavior.

module main(
    input pixel_clk, // Should be approx. 74.250 MHz for a correct 720p signal
    input reset,

    // The pixel data source is expected to stream pixel values (0xBBGGRR)
    // into these inputs as fast as possible whenever data_can_write is
    // asserted. The data_ signals all belong to the data_clk clock domain,
    // which should usually be faster than pixel_clk to allow the data source
    // to stay ahead of the display generator (using pixel_clk) and thus avoid
    // data underruns during the visible portions of our raster.
    input data_clk,        // Clock for the pixel data source. Should generally be faster than pixel_clk.
    output data_can_write, // Asserted when we have enough buffer space to receive a new pixel.
    input [11:0] data_in,  // 0xBBGGRR data to be added to the pixel buffer when data_write is asserted.
    input data_write,      // Assert this on positive edge of data_clk to append data_in to the pixel buffer.

    // Display output signals. We're expecting to drive a 4-bit-per-channel
    // parallel output port here, with the control signals following what is
    // conventionally expected for a 720p display. The result of this could be
    // fed (by the caller) into a resistor ladder for VGA output, into a
    // DVI/HDMI encoder to produce a digital output, or other similar options.
    output disp_clk,
    output disp_hsync,
    output disp_vsync,
    output disp_de,
    output reg [3:0] disp_b,
    output reg [3:0] disp_g,
    output reg [3:0] disp_r
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

    // The data source (usually some sort of RAM, but could be a test pattern
    // generator or similar) is expected to stream pixel values (0x00BBGGRR)
    // into the write end of this FIFO. We'll consume the read end and show
    // the pixels on-screen.
    //
    // The data source must be able to produce pixels fast enough that the
    // queue is always readable when our raster is in the visible picture area.
    // If not, the display output will fall out of sync with the data source
    // and the display will be corrupted.
    //
    // TODO: For robustness we should detect the data underrun condition and,
    // if we hit it during the visible pixel area, we should reset both the
    // timing and the data source so we can try to recover, rather than just
    // being unsynchronized for all fields thereafter.
    wire [11:0] next_pixel_value;
    reg pixel_read; // Asserted on posedge pixel_clk if we consumed a pixel
    asyncfifo #(.BUFFER_ADDR_WIDTH(8), .DATA_WIDTH(16)) pixel_queue (
        .reset(reset),
        .write_clk(data_clk),
        .write(data_write),
        .write_data({4'b0000, data_in}),
        .can_write(data_can_write),

        .read_clk(pixel_clk),
        .read_data(next_pixel_value),
        .read(pixel_read),
        // NOTE: We don't do anything with can_read right now, because we
        // have no way to react robustly to an underrun. If can_read is
        // false when we're trying to display a visible pixel then we'll
        // just corrupt the display by taking whatever garbage the FIFO's
        // read pointer happens to be pointing at.
    );

    timing timing(
        .clk(pixel_clk),
        .reset(reset),

        .hsync(hsync),
        .vsync(vsync),
        .visible(visible),
        .x(x),
        .y(y)
    );

    always @(posedge pixel_clk) begin
        if (visible) begin
            disp_r <= next_pixel_value[3:0];
            disp_g <= next_pixel_value[7:4];
            disp_b <= next_pixel_value[11:8];
            pixel_read <= 1;
        end else begin
            disp_r <= 0;
            disp_g <= 0;
            disp_b <= 0;
            pixel_read <= 0;
        end
    end

endmodule
