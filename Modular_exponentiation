module modular_exponentiation (
    input wire clk,          // Clock signal
    input wire rst,          // Synchronous reset signal (active high)
    input wire start,        // Start signal for computation
    input wire [31:0] a,     // Base
    input wire [31:0] b,     // Exponent
    input wire [31:0] m,     // Modulus
    output reg [31:0] result,// Result of a^b % m
    output reg done          // Done signal, high when computation is complete
);
    // Internal registers
    reg [31:0] base;
    reg [31:0] exponent;
    reg [31:0] temp_result;
    reg [31:0] mult_result;  // Register for storing multiplication results
    reg step_done;           // Step flag to control sequential operations

    // State machine states using localparam
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam FINISH  = 2'b10;

    // Current state register
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all internal registers and output signals
            base <= 0;
            exponent <= 0;
            temp_result <= 1; // Initialize temp_result to 1 (neutral element for multiplication)
            result <= 0;
            done <= 0;
            state <= IDLE;
            step_done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        base <= a % m;    // Initialize base (a % m)
                        exponent <= b;    // Load exponent
                        temp_result <= 1; // Initialize result to 1
                        done <= 0;        // Clear done signal
                        state <= COMPUTE; // Move to COMPUTE state
                        step_done <= 0;
                    end
                end

                COMPUTE: begin
                    if (exponent > 0) begin
                        if (!step_done) begin
                            if (exponent[0] == 1'b1) begin
                                // If the current bit of exponent is 1, perform multiplication
                                mult_result <= (temp_result * base) % m;
                                step_done <= 1;
                            end else begin
                                step_done <= 1; // Skip this step if LSB is 0
                            end
                        end else begin
                            // Complete the step and update the registers
                            if (exponent[0] == 1'b1) begin
                                temp_result <= mult_result; // Update temp_result
                            end
                            // Right shift exponent and square base in the next clock cycle
                            exponent <= exponent >> 1;
                            base <= (base * base) % m;
                            step_done <= 0; // Reset step flag for next operation
                        end
                    end else begin
                        // Once exponent is 0, computation is done
                        result <= temp_result;
                        done <= 1;
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    // Hold the result and wait for reset
                    done <= 1;
                end
            endcase
        end
    end
endmodule
