module alu(
    input      [31:0] s1,
    input      [31:0] s2,
    input      [3:0]  op,
    output reg [31:0] d
);

    always @(*) begin
        case (op)
            4'b0000: d = s1 + s2;  // ADD
            4'b1000: d = s1 - s2;  // SUB
            4'b0001: d = s1 << s2; // SLL
            4'b0010: d = $signed(s1) < $signed(s2); // SLT
            4'b0011: d = s1 < s2;  // SLTU
            4'b0100: d = s1 ^ s2;  // XOR
            4'b0101: d = s1 >> s2; // SRL
            4'b1101: d = $signed(s1) >> s2; // SRA
            4'b0110: d = s1 | s2;  // OR
            4'b0111: d = s1 & s2;  // AND
            default: d = 0;
        endcase
    end

endmodule
