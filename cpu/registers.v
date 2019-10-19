module registers(
    input clk,
    input rst,
    input [5:0] raddr1,
    input [5:0] raddr2,
    input [5:0] waddr,
    input we,
    input [31:0] wdata,

    output [31:0] rdata1,
    output [31:0] rdata2
);

    integer i;

    // We have two copies of the registers so that each one
    // only has one reader, to increase the likelihood of
    // these synthesizing as block RAM.
    // We're currently allocating a register for r0 even though
    // it is required to always be zero, just because it keeps
    // things simple in here. We'll revisit that if it turns out
    // to be problematic, but expect that these will end up in
    // oversize block RAMs anyway.
    reg [31:0] regs1 [0:31];
    reg [31:0] regs2 [0:31];

    assign rdata1 = regs1[raddr1];
    assign rdata2 = regs2[raddr2];

    initial begin
        for (i = 0; i < 32; i++) begin
            regs1[i] = 32'd0;
            regs2[i] = 32'd0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i++) begin
                regs1[i] <= 32'd0;
                regs2[i] <= 32'd0;
            end
        end else begin
            if (we && waddr != 0) begin
                regs1[waddr] <= wdata;
                regs2[waddr] <= wdata;
            end
        end
    end

endmodule
