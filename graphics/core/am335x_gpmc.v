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
    input clk,       // system clock (always at least as fast as pixel_clk, but separate clock domain)
    input pixel_clk, // pixel clock  (approx. 74.250 MHz)

    // GPMC signals: these are connected to the relevant pins of the
    // AM335x package where the GPMC peripheral is active.
    inout [15:0] gpmc_ad, // multiplexed address/data
    input gpmc_advn,      // Address valid (active low)
    input gpmc_csn1,      // GPMC peripheral chip select 1 (active low)
    input gpmc_wein,      // Write enable (active low)
    input gpmc_oen,       // Output enable (active low)
    input gpmc_clk,       // GPMC peripheral external clock

    // Graphics core signals: these should be connected to the corresponding
    // host_... signals on the main module. Everything except the two chip
    // select signals (..._cs) should be connected to both host_vram... and
    // host_reg_... corresponding signals, and then the chip selects will be
    // set as needed to distinguish the two.
    output gfx_vram_cs,
    output gfx_reg_cs,
    output [13:1] gfx_addr, // write target address from the host
    output [15:0] gfx_data, // data to write from the host
    input  gfx_done,        // write operation has completed (signalled by main module)
    input  gfx_write_avail  // updated synchronously with pixel_clk to indicate whether a write can succeed without stalling
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

    // The "gfx_" signals are in the pixel_clk clock domain, so we need some
    // extra steps here to ensure that we don't cause metastability. We're
    // propagating the values through a two-level staging register, which should
    // be sufficient as long as the GPMC timing is set slow enough for the
    // main module (using pixel_clk) to keep up.
    reg [1:0] cs_cross;
    reg [1:0] we_cross;
    reg [1:0] oe_cross;
    reg [31:0] write_data_cross;
    reg [15:0] addr_cross;
    reg vram_cs;
    reg reg_cs;
    reg we;
    reg oe;
    reg [15:0] addr;
    reg [15:0] write_data;
    always @(negedge gpmc_clk) begin
        cs_cross[1] <= gpmc_csn1;
        we_cross[1] <= gpmc_wein;
        oe_cross[1] <= gpmc_oen;
        write_data_cross[31:16] <= gpmc_data_in;
    end
    always @ (posedge pixel_clk) begin
        // Stage 1: copy from the gpmc_clk halves of the staging registers
        // into the pixel_clk halves.
        cs_cross[0] <= cs_cross[1];
        we_cross[0] <= we_cross[1];
        oe_cross[0] <= os_cross[1];
        write_data_cross[15:0] <= write_data_cross[31:16];
        addr_cross <= gpmc_addr;

        // Stage 2: copy from the pixel_clk halves of the staging registers
        // into the final output registers.
        // FIXME: Our vram_cs and reg_cs expressions just ignore writes when
        // gfx_write_avail isn't asserted, which ensures that we won't lock up
        // when a write is delayed but it also means that we'll just drop
        // incorrectly-timed writes altogether. Ideally we'd wait until the
        // main module is ready to receive them, but that would require
        // maintaining a queue.
        vram_cs <= cs_cross[0] & we_cross[0] & ~addr_cross[15] & gfx_write_avail; // high-order bit selects registers
        reg_cs <= cs_cross[0] & we_cross[0] & addr_cross[15] & gfx_write_avail;   // ...and we only support writes, so we ignore reads
        we <= we_cross[0];
        oe <= oe_cross[0];
        write_data <= write_data_cross[15:0];
        addr <= addr_cross;
    end

    // The final output registers are then connected to the relevant gfx_...
    // signals to interact with the main module.
    assign gfx_vram_cs = vram_cs;
    assign gfx_reg_cs = reg_cs;
    assign gfx_addr = addr;
    assign gfx_data = data;
    // We ignore gfx_done because we're using the gpmc in async mode and so
    // it'll just assume the operation succeeded after the appropriate number
    // of gpmc_clk cycles.

endmodule
