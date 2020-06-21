module asyncfifo(
  input                       reset,
  input                       write_clk,
  input                       write,
  input      [DATA_WIDTH-1:0] write_data,
  output reg                  can_write,
  input                       read_clk,
  input                       read,
  output     [DATA_WIDTH-1:0] read_data,
  output reg                  can_read
);
    parameter DATA_WIDTH = 16;
    parameter BUFFER_ADDR_WIDTH = 8;
    parameter BUFFER_SIZE = 2 ** BUFFER_ADDR_WIDTH;

    ///// WRITE CLOCK DOMAIN /////

    // This is an address into the buffer array.
    // It intentionally has one additional bit so we can track wrap-around by
    // comparing with the MSB of read_ptr (or, at least, with the grey-code
    // form that we synchronize over into this clock domain.)
    reg [BUFFER_ADDR_WIDTH:0] write_ptr;
    wire [BUFFER_ADDR_WIDTH-1:0] write_addr = write_ptr[BUFFER_ADDR_WIDTH-1:0]; // truncated version without the wrap bit

    // This is the grey-coded version of write_ptr in the write clock domain.
    reg [BUFFER_ADDR_WIDTH:0] write_ptr_grey_w;

    // This is the grey-coded version of read_ptr in the write clock domain,
    // synchronized over here using module read_ptr_grey_sync declared later.
    wire [BUFFER_ADDR_WIDTH:0] read_ptr_grey_w;

    // Write pointer (and its grey-coded equivalent) increments whenever
    // "write" is set on a clock, as long as our buffer isn't full.
    wire [BUFFER_ADDR_WIDTH:0] next_write_ptr = write_ptr + 1;
    wire [BUFFER_ADDR_WIDTH:0] next_write_ptr_grey_w = (next_write_ptr >> 1) ^ next_write_ptr;
    // Our buffer is full if the read and write addresses are the same but the
    // MSBs (wrap bits) are different. We compare the grey code versions here
    // so we can use our cross-domain-synchronized copy of the read pointer.
    wire current_can_write = write_ptr_grey_w != { ~read_ptr_grey_w[BUFFER_ADDR_WIDTH:BUFFER_ADDR_WIDTH-1], read_ptr_grey_w[BUFFER_ADDR_WIDTH-2:0] };
    wire next_can_write = next_write_ptr_grey_w != { ~read_ptr_grey_w[BUFFER_ADDR_WIDTH:BUFFER_ADDR_WIDTH-1], read_ptr_grey_w[BUFFER_ADDR_WIDTH-2:0] };
    always @(posedge write_clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
            write_ptr_grey_w <= 0;
            can_write <= 1;
        end else begin
            if (write && can_write) begin
                write_ptr <= next_write_ptr;
                write_ptr_grey_w <= next_write_ptr_grey_w;
                can_write <= next_can_write;
            end else begin
                can_write <= current_can_write;
            end
        end
    end

    ///// READ CLOCK DOMAIN /////

    // This is an address into the buffer array.
    // It intentionally has one additional bit so we can track wrap-around by
    // comparing with the MSB of write_ptr (or, at least, with the grey-code
    // form that we synchronize over into this clock domain.)
    reg [BUFFER_ADDR_WIDTH:0] read_ptr;
    wire [BUFFER_ADDR_WIDTH-1:0] read_addr = read_ptr[BUFFER_ADDR_WIDTH-1:0]; // truncated version without the wrap bit

    // This is the grey-coded version of write_ptr in the read clock domain.
    reg [BUFFER_ADDR_WIDTH:0] read_ptr_grey_r;

    // This is the grey-coded version of write_ptr in the read clock domain,
    // synchronized over here using module write_ptr_grey_sync declared later.
    wire [BUFFER_ADDR_WIDTH:0] write_ptr_grey_r;

    // Read pointer (and its grey-coded equivalent) increments whenever
    // "read" is set on a clock, as long as our buffer isn't full.
    wire [BUFFER_ADDR_WIDTH:0] next_read_ptr = read_ptr + 1;
    wire [BUFFER_ADDR_WIDTH:0] next_read_ptr_grey_r = (next_read_ptr >> 1) ^ next_read_ptr;
    // Our buffer is empty if the read and write addresses are the same and the
    // MSBs (wrap bits) are also equal. We compare the grey code versions here
    // so we can use our cross-domain-synchronized copy of the write pointer.
    wire current_can_read = read_ptr_grey_r != write_ptr_grey_r;
    wire next_can_read = next_read_ptr_grey_r != write_ptr_grey_r;
    always @(posedge read_clk or posedge reset) begin
        if (reset) begin
            read_ptr <= 0;
            read_ptr_grey_r <= 0;
            can_read <= 0;
        end else begin
            if (read) begin
                if (can_read) begin
                    read_ptr <= next_read_ptr;
                    read_ptr_grey_r <= next_read_ptr_grey_r;
                end
                can_read <= next_can_read;
                if (next_can_read) begin
                    read_ptr <= next_read_ptr;
                end
            end else begin
                can_read <= current_can_read;
            end
        end
    end

    ///// CROSS-DOMAIN /////

    // The backing store for our queue is a dual-port buffer, which is
    // written in the write clock domain and read in the read clock domain.
    // This is okay because our rules above ensure that each element of the
    // buffer is either unused pending write or used pending read.
    dual_port_buffer #(.DATA_WIDTH(DATA_WIDTH), .BUFFER_ADDR_WIDTH(BUFFER_ADDR_WIDTH)) buffer(
        .reset(reset),

        .write_clk(write_clk),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_enable(write && can_write),

        .read_clk(read_clk),
        .read_addr(read_addr),
        .read_data(read_data)
    );

    // Synchronize read_ptr_grey_r into read_ptr_grey_w.
    crossdomain #(.SIZE(BUFFER_ADDR_WIDTH+1)) read_ptr_grey_sync (
        .reset(reset),
        .clk(write_clk),
        .data_in(read_ptr_grey_r),
        .data_out(read_ptr_grey_w)
    );

    // Synchronize write_ptr_grey_w into write_ptr_grey_r.
    crossdomain #(.SIZE(BUFFER_ADDR_WIDTH+1)) write_ptr_grey_sync (
        .reset(reset),
        .clk(read_clk),
        .data_in(write_ptr_grey_w),
        .data_out(write_ptr_grey_r)
    );

endmodule
