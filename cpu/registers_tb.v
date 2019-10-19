`include "registers.v"

module registers_tb();

    reg clk;
    reg rst;
    reg [5:0] raddr1;
    reg [5:0] raddr2;
    reg [5:0] waddr;
    reg we;
    reg  [31:0] wdata;
    wire [31:0] rdata1;
    wire [31:0] rdata2;

    registers dut(
        .clk(clk),
        .rst(rst),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .we(we),
        .wdata(wdata),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    initial begin
        $dumpfile(`DUMP_FILENAME);
        $dumpvars;

        clk = 0;
        rst = 1;
        raddr1 = 0;
        raddr2 = 0;
        waddr = 0;
        we = 0;
        wdata = 0;
        #2
        rst = 0;
        #2
        wdata = 32'hdeadbeef;
        waddr = 1;
        we = 1;
        #2
        we = 0;
        raddr1 = 1;
        #2;
        raddr1 = 0;
        raddr2 = 1;
        #2;
        waddr = 2;
        raddr1 = 2;
        raddr2 = 2;
        we = 1;
        #2;
        we = 0;
        #2;
        waddr = 0;
        raddr1 = 0;
        raddr2 = 0;
        #2;
        we = 1;
        #2;
        we = 0;
        #2;
        raddr1 = 1;
        raddr2 = 1;
        #2;
        rst = 1;
        #2;
        rst = 0;
        #2;

        $finish;
    end

    always begin
        #1  clk = ~clk; 
    end

endmodule
