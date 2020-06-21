module dual_port_buffer(
    input reset,

    input write_clk,
    input [BUFFER_ADDR_WIDTH-1:0] write_addr,
    input [DATA_WIDTH-1:0] write_data,
    input write_enable,

    input read_clk,
    input [BUFFER_ADDR_WIDTH-1:0] read_addr,
    output reg [DATA_WIDTH-1:0] read_data
);

    parameter DATA_WIDTH = 16;
    parameter BUFFER_ADDR_WIDTH = 8;
    localparam BUFFER_SIZE = 2 ** BUFFER_ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] buffer[BUFFER_SIZE-1:0];

    always @(negedge read_clk) begin
        read_data <= buffer[read_addr];
    end

    always @(negedge write_clk) begin
        if (write_enable)
            buffer[write_addr] <= write_data;
    end

endmodule
