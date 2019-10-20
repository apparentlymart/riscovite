module alu(
    input clk,
    input      [31:0] rs1,
    input      [31:0] rs2,
    input      [3:0]  op,
    output reg [31:0] rd
);

    always @(posedge clk) begin
        case (op)
            4'b0000: rd <= rs1 + rs2; // ADD
            4'b1000: rd <= rs1 - rs2; // SUB
            //4'b0001: rd <= rs1; // TODO: SLL
            4'b0010: rd <= $signed(rs1) < $signed(rs2); // SLT
            4'b0011: rd <= rs1 < rs2; // SLTU
            4'b0100: rd <= rs1 ^ rs2; // XOR
            //4'b0101: rd <= rs1; // TODO: SRL
            //4'b1101: rd <= rs1; // TODO: SRA
            4'b0110: rd <= rs1 | rs2; // OR
            4'b0111: rd <= rs1 & rs2; // AND
            default: rd <= 0;
        endcase
    end

endmodule
