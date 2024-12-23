module L (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [31:0] u,    // 32-bit input
    input wire [31:0] n,    // 32-bit divisor
    output reg [31:0] out,  // 32-bit output
    output reg done         // Indicates when division is complete
);

    // Internal registers
    reg [31:0] dividend;
    reg [31:0] quotient;
    reg [31:0] divisor;
    reg [31:0] temp_dividend;
    integer i;

    // State machine
    reg [2:0] state;
    localparam IDLE    = 3'd0;
    localparam INIT    = 3'd1;
    localparam DIVIDE  = 3'd2;
    localparam DONE    = 3'd3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            out <= 0;
            quotient <= 0;
            dividend <= 0;
            divisor <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= INIT;
                        done <= 0;
                    end
                end

                INIT: begin
                    // Initialize the dividend as (u - 1) and the divisor
                    dividend <= u - 1;
                    divisor <= n;
                    quotient <= 0;
                    temp_dividend <= 0;
                    i <= 31; // Start with the most significant bit of the 32-bit dividend
                    state <= DIVIDE;
                end

                DIVIDE: begin
                    // Shift the temporary dividend left and bring in the next bit from dividend
                    temp_dividend = (temp_dividend << 1) | dividend[i];
                    
                    if (temp_dividend >= divisor) begin
                        temp_dividend = temp_dividend - divisor;
                        quotient = (quotient << 1) | 1;
                    end else begin
                        quotient = quotient << 1;
                    end
                    
                    if (i == 0) begin
                        state <= DONE; // Division is complete when we've processed all bits
                    end else begin
                        i = i - 1;
                    end
                end

                DONE: begin
                    out <= quotient;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
