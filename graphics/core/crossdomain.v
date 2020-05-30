// This is a helper module for a two-step cross-clock-domain synchronizer.
// It uses one intermediate register and one output register to bring
// values into the domain of the clock given as clk.
//
// This module supports values of arbitrary sizes but when using multi-bit
// values it's important to use a grey code, or equivalent, to avoid consistency
// problems if clocked at an unfortunate time.
//
// data_in is read and data_out is updated in the clock domain of "clk".

module crossdomain #(parameter SIZE = 1) (
  input reset,
  input clk,
  input [SIZE-1:0] data_in,
  output reg [SIZE-1:0] data_out
);

    reg [SIZE-1:0] data_tmp;

    always @(posedge clk) begin
        if (reset) begin
            {data_out, data_tmp} <= 0;
        end else begin
            {data_out, data_tmp} <= {data_tmp, data_in};
        end
    end

endmodule
