module timing(
    input wire reset,
    input wire clk,

    output reg [15:0] x,
    output reg [15:0] y,
    output reg hsync,
    output reg vsync,
    output reg hprep, // negative x is counting up to display position zero
    output reg vprep, // negative y is counting up to display position zero
    output reg visible
);

    // State constants for our two timing state machines (one horizontal, one vertical)
    `define VIDEO_SYNC       2'd0
    `define VIDEO_BACKPORCH  2'd1
    `define VIDEO_ACTIVE     2'd2
    `define VIDEO_FRONTPORCH 2'd3

    // These settings are for 720p, assuming clk is running at 74.25 MHz
    `define VIDEO_H_SYNC_PIXELS   16'd40
    `define VIDEO_H_BP_PIXELS     16'd220
    `define VIDEO_H_ACTIVE_PIXELS 16'd1280
    `define VIDEO_H_FP_PIXELS     16'd110
    `define VIDEO_H_SYNC_ACTIVE   1'b1
    `define VIDEO_V_SYNC_LINES    16'd5
    `define VIDEO_V_BP_LINES      16'd20
    `define VIDEO_V_ACTIVE_LINES  16'd720
    `define VIDEO_V_FP_LINES      16'd5
    `define VIDEO_V_SYNC_ACTIVE   1'b1

    reg [1:0] state_h = `VIDEO_FRONTPORCH;
    reg [15:0] count_h = 1; // 1-based so we will stop when count_h is the total pixels for the current state
    reg inc_v = 1'b0;
    reg [1:0] state_v = `VIDEO_FRONTPORCH;
    reg [15:0] count_v = 1; // 1-based so we will stop when count_v is the total lines for the current state

    // Output updates. Our outputs actually update one clock behind the main
    // state machine, because our timing is too tight to reliably do everything
    // inside a single clock period.
    always @(posedge clk) begin
        hsync   <= (state_h == `VIDEO_SYNC) ^ (~`VIDEO_H_SYNC_ACTIVE);
        vsync   <= (state_v == `VIDEO_SYNC) ^ (~`VIDEO_V_SYNC_ACTIVE);
        hprep   <= (state_h == `VIDEO_BACKPORCH && state_v == `VIDEO_ACTIVE);
        vprep   <= state_v == `VIDEO_BACKPORCH;
        visible <= (state_h == `VIDEO_ACTIVE) && (state_v == `VIDEO_ACTIVE);
        x       <= count_h - 1;
        y       <= count_v - 1;
    end

    // Main state machine. This is responsible for keeping track of our virtual
    // "beam position" and transitioning between the different states that will
    // inform how we set our external control
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            // We'll start with a very short one-line vsync and a full hsync,
            // just because we need to start somewhere and this approach is
            // easier to look at in simulation. Maybe we'll adjust this
            // starting condition later if we find that a particular approach
            // allows real displays to lock faster.
            count_h <= ~16'b0;
            count_v <= `VIDEO_V_SYNC_LINES-1;
            state_h <= `VIDEO_SYNC;
            state_v <= `VIDEO_SYNC;
        end else begin
            inc_v <= 0;
            count_h <= count_h + 16'd1;

            case (state_h)
                `VIDEO_SYNC: begin
                    if (count_h == `VIDEO_H_SYNC_PIXELS) begin
                        state_h <= `VIDEO_BACKPORCH;
                        // For this case in particular we count from a negative
                        // number of pixels up to zero, so that other modules
                        // that consume this output can start the display data
                        // pipeline some number of pixel clocks before the
                        // display actually begins.
                        count_h <= -`VIDEO_H_BP_PIXELS;
                    end
                end
                `VIDEO_BACKPORCH: begin
                    // As noted in the VIDEO_SYNC case above, our back porch
                    // phase counts up from a negative number to zero.
                    if (count_h == 0) begin
                        state_h <= `VIDEO_ACTIVE;
                        count_h <= 16'b1;
                    end
                end
                `VIDEO_ACTIVE: begin
                    if (count_h == `VIDEO_H_ACTIVE_PIXELS) begin
                        state_h <= `VIDEO_FRONTPORCH;
                        count_h <= 16'b1;
                    end
                end
                `VIDEO_FRONTPORCH: begin
                    if (count_h == `VIDEO_H_FP_PIXELS) begin
                        state_h <= `VIDEO_SYNC;
                        count_h <= 16'b1;
                        count_v <= count_v + 16'd1;
                        case (state_v)
                            `VIDEO_SYNC: begin
                                if (count_v == `VIDEO_V_SYNC_LINES) begin
                                    state_v <= `VIDEO_BACKPORCH;
                                    // Counting from negative up to zero, as
                                    // with the horizontal back porch.
                                    count_v <= -`VIDEO_V_BP_LINES;
                                end
                            end
                            `VIDEO_BACKPORCH: begin
                                // Counting from negative up to zero, as
                                // with the horizontal back porch.
                                if (count_v == 0) begin
                                    state_v <= `VIDEO_ACTIVE;
                                    count_v <= 16'b1;
                                end
                            end
                            `VIDEO_ACTIVE: begin
                                if (count_v == `VIDEO_V_ACTIVE_LINES) begin
                                    state_v <= `VIDEO_FRONTPORCH;
                                    count_v <= 16'b1;
                                end
                            end
                            `VIDEO_FRONTPORCH: begin
                                if (count_v == `VIDEO_V_FP_LINES) begin
                                    state_v <= `VIDEO_SYNC;
                                    count_v <= 16'b1;
                                end
                            end
                        endcase
                    end
                end
            endcase
        end
    end

endmodule
