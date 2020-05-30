// This is an adapter for the AM335x (BeagleBone Black) General Purpose Memory
// Controller to the generic async memory interface expected by our main
// module in main.v.
//
// This is set up to work within the limitations of the pinout of a
// BeagleWire board connected to a BeagleBone Black, where only a subset of
// the GPMC pins are connected to the FPGA. In particular, this is required to
// work in synchronous mode because the async "wait" pin is not connected.
// We also have only one chip select exposed, and so we use the highest-order
// address pin to distinguish RAM vs. register writes (RAM on low addresses,
// registers on high addresses).
module am335x_gpmc(
    input reset,

    // GPMC signals: these are connected to the relevant pins of the
    // AM335x package where the GPMC peripheral is active.
    inout [15:0] gpmc_ad, // multiplexed address/data
    input gpmc_advn,      // Address valid (active low)
    input gpmc_csn1,      // GPMC peripheral chip select 1 (active low)
    input gpmc_wein,      // Write enable (active low)
    input gpmc_oen,       // Output enable (active low)
    input gpmc_clk,       // GPMC peripheral external clock

    // Queue signals: incoming GPMC requests are queued so that they can be
    // processed either in the video RAM clock domain (for video RAM writes)
    // or in the pixel clock domain (for register writes) while freeing up
    // the GPMC bus for further writes (at least, until the queues fill).
    //
    // These signals all belong to the gpmc_clk domain; the calling module
    // is responsible for configuring the target queue to transfer into the
    // appropriate target clock domain.
    output reg [15:0] vram_write_addr,
    output reg [15:0] vram_write_data,
    output reg        vram_write,
    input             vram_can_write,
    output reg [15:0] reg_write_addr,
    output reg [15:0] reg_write_data,
    output reg        reg_write,
    input             reg_can_write
);

    // We'll manage the bidirectional gpmc_ad signals safely using a SB_IO
    // primitive, which is ICE40-specific (described in the "SiliconBlue
    // Technology Library" documentation). That makes this particular module
    // ICE40-specific, but we're accepting that because it's here primarily
    // to support the BeagleWire-based development environment setup and
    // therefore we know we only need to deal with ICE40 devices there.
    reg [15:0] gpmc_data_out;
    wire [15:0] gpmc_data_in;
    SB_IO # (
        .PIN_TYPE(6'b1010_01),
        .PULLUP(1'b 0)
    ) gpmc_ad_tristate [15:0] (
        .PACKAGE_PIN(gpmc_ad),
        .OUTPUT_ENABLE(!gpmc_csn1 && gpmc_advn && !gpmc_oen && gpmc_wein),
        .D_OUT_0(gpmc_data_out),
        .D_IN_0(gpmc_data_in)
    );

    // The above deals with gpmc_ad being bidirectional, but we also need to
    // deal with it being multiplexed: it's initially also the address, which
    // we need to copy into a register before then using the same signals
    // for data.
    reg [15:0] gpmc_addr;
    always @(negedge gpmc_clk) begin
        if (!gpmc_csn1 && !gpmc_advn && gpmc_wein && gpmc_oen) begin
            gpmc_addr <= gpmc_data_in;
        end
    end

    always @(negedge gpmc_clk) begin
        // If gpmc_advn is unasserted (high) then gpmc_data_in is data to
        // be written. (assuming this is a write -- we only actually support
        // writes, so reads are entirely ignored.)
        // TODO: We're just assuming everything is a video RAM write for now.
        // Ultimately we'll need to decode part of the address space as
        // registers, but we don't need that for initial prototyping and when
        // we do it it'll steal away from our already-teeny 16-bit VRAM address
        // space that this interface provides. :(
        if (!gpmc_csn1 && gpmc_advn && !gpmc_wein && !gpmc_oen) begin
            vram_write_addr <= gpmc_addr;
            vram_write_data <= gpmc_data_in;
            vram_write <= 1;
        end else begin
            vram_write_addr <= 0;
            vram_write_data <= 0;
            vram_write <= 0;
        end
    end

endmodule
