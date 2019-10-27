`include "alu.v"

module alu_tb();

    reg  [31:0] s1;
    reg  [31:0] s2;
    reg   [3:0] op;
    wire [31:0] d;
    reg  [31:0] op_str;
    integer i;

    alu dut(
        .s1(s1),
        .s2(s2),
        .op(op),
        .d(d)
    );

    initial begin
        $dumpfile(`DUMP_FILENAME);
        $dumpvars;

        s1 = 0;
        s2 = 0;
        op = 0;
        for (i = 0; i <= 4'b1111; i++) begin
            s1 = 4;
            s2 = 3;
            op = i;
            #2;
        end
        $finish;
    end

    always @(*) begin
        case (op)
            4'b0000: op_str = "ADD ";
            4'b1000: op_str = "SUB ";
            4'b0001: op_str = "SLL ";
            4'b0010: op_str = "SLT ";
            4'b0011: op_str = "SLTU";
            4'b0100: op_str = "XOR ";
            4'b0101: op_str = "SRL ";
            4'b1101: op_str = "SRA ";
            4'b0110: op_str = "OR  ";
            4'b0111: op_str = "AND ";
            default: op_str = "????";
        endcase
    end

endmodule
