module testpattern
(
    input wire reset,
    input wire clk,
    input wire can_write,
    output wire [11:0] write_data,
    output reg write_ready
);

    reg [15:0] x;
    reg [15:0] y;
    reg [3:0] r;
    reg [3:0] g;
    reg [3:0] b;
    assign write_data = {b, g, r};

    always @(posedge clk) begin
        write_ready <= 0;
        if (reset) begin
            x <= 16'h0000;
            y <= 16'h0000;
            r <= 4'b0000;
            g <= 4'b0000;
            b <= 4'b0000;
        end else begin
            if (can_write) begin
                r <= 4'b0000;
                g <= 4'b0000;
                b <= 4'b0000;

                if (y < 100) begin
                    r <= x[5:2];
                end else if (y < 200) begin
                    g <= x[5:2];
                end else if (y < 300) begin
                    b <= x[5:2];
                end else if (y < 400) begin
                    r <= x[5:2];
                    g <= x[5:2];
                end else if (y < 500) begin
                    r <= x[5:2];
                    b <= x[5:2];
                end else if (y < 600) begin
                    g <= x[5:2];
                    b <= x[5:2];
                end else if (y < 700) begin
                    r <= x[5:2];
                    g <= x[5:2];
                    b <= x[5:2];
                end else begin
                    if (x[7:0] < 64) begin
                        r <= x[3:0];
                    end else if (x[7:0] < 128) begin
                        g <= x[3:0];
                    end else if (x[7:0] < 192) begin
                        b <= x[3:0];
                    end else begin
                        r <= x[3:0];
                        g <= x[3:0];
                        b <= x[3:0];
                    end
                end

                write_ready <= 1;

                if (x == 1279) begin
                    if (y == 719) begin
                        x <= 0;
                        y <= 0;
                    end else begin
                        x <= 0;
                        y <= y + 1;
                    end
                end else begin
                    x <= x + 1;
                end
            end
        end
    end

endmodule
