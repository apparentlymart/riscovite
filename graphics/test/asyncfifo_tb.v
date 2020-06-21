`include "crossdomain.v"
`include "dual_port_buffer.v"
`include "asyncfifo.v"

module asyncfifo_tb();

    reg reset;

    reg write_clk;
    reg write;
    reg [15:0] write_data;
    wire can_write;

    reg read_clk;
    reg read;
    wire [15:0] read_data;
    wire can_read;

    asyncfifo #(.BUFFER_ADDR_WIDTH(2)) dut(
        .reset(reset),
        .write_clk(write_clk),
        .write(write),
        .write_data(write_data),
        .can_write(can_write),

        .read_clk(read_clk),
        .read(read),
        .read_data(read_data),
        .can_read(can_read)
    );

    initial begin
        $dumpfile(`DUMP_FILENAME);
        $dumpvars;

        write_clk = 0;
        read_clk = 0;
        write = 0;
        write_data = 0;
        read = 0;
        reset = 1;
        #5
        reset = 0;
        #5
        write_data = 16'hdead;
        write = 1;
        #2
        write_data = 16'hbeef;
        write = 1;
        #2
        write_data = 16'hfeed;
        write = 1;
        #2
        write_data = 16'hface;
        write = 1;
        #2
        // This message should not be seen by the reader, because the buffer will be full at this point
        write_data = 16'hd00b;
        write = 1;
        #2
        write = 0;
        write_data = 16'hffff;
        #10
        read = 1;
        #4;
        read = 0;
        #4
        read = 1;
        #4
        read = 0;
        #4
        read = 1;
        #4
        read = 0;
        #4
        read = 1;
        #4
        read = 0;
        #2
        write_data = 16'hf00f;
        write = 1;
        #2
        write_data = 16'h0000;
        write = 0;
        #10
        read = 1;
        #4
        read = 0;
        #2

        $finish;
    end

    // Our read clock runs slower than our write clock for the sake of this
    // testbench.
    always begin
        #1 write_clk = ~write_clk;
    end
    always begin
        #2 read_clk = ~read_clk;
    end

endmodule
