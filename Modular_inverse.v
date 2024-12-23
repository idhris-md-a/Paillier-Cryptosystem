module modular_inverse (
    input wire clk,             // Clock signal
    input wire reset,           // Reset signal, active high
    input wire start,           // Start signal, active high
    input wire [31:0] a,        // Input value 'a'
    input wire [31:0] n,        // Modulus 'n'
    output reg done,            // Done signal, goes high when computation is done
    output reg [31:0] inverse,  // Output inverse of 'a' modulo 'n'
    output reg valid            // Valid signal, goes high if inverse exists
);

    reg signed [31:0] r0, r1, t0, t1, q;
    reg signed [31:0] temp_r, temp_t;
    
    // State encoding
    reg [2:0] state;
    localparam IDLE     = 3'd0;
    localparam INIT     = 3'd1;
    localparam CALC_Q   = 3'd2;
    localparam UPDATE   = 3'd3;
    localparam FINISH   = 3'd4;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= IDLE;
            done    <= 0;
            valid   <= 0;
            inverse <= 0;
            r0      <= 0;
            r1      <= 0;
            t0      <= 0;
            t1      <= 0;
            q       <= 0;
            temp_r  <= 0;
            temp_t  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= INIT;
                        done  <= 0;
                        valid <= 0;
                    end
                end
                
                INIT: begin
                    // Initialize variables with blocking assignments for immediate effect
                    r0 = n;
                    r1 = a;
                    t0 = 0;
                    t1 = 1;
                    q  = 0;
                    temp_r = 0;
                    temp_t = 0;
                    state <= CALC_Q;  // Move directly to CALC_Q
                    $display("INIT: r0 = %d, r1 = %d, t0 = %d, t1 = %d", r0, r1, t0, t1);
                end
                
                CALC_Q: begin
                    if (r1 != 0) begin
                        q <= r0 / r1;  // Calculate quotient
                    end else begin
                        q <= 0;  // Prevent division by zero
                    end
                    state <= UPDATE;
                    $display("CALC_Q: q = %d", q);
                end
                
                UPDATE: begin
                    // Calculate new remainders and coefficients
                    temp_r = r0 - q * r1;  // temp_r is the new remainder
                    temp_t = t0 - q * t1;  // temp_t is the new coefficient

                    // Shift values for next iteration
                    r0 <= r1;
                    r1 <= temp_r;

                    t0 <= t1;
                    t1 <= temp_t;

                    $display("UPDATE: r0 = %d, r1 = %d, t0 = %d, t1 = %d", r0, r1, t0, t1);
                    
                    if (r1 == 0) begin
                        // If r1 becomes zero, we're done with the Euclidean part
                        if (r0 == 1) begin
                            // Modular inverse exists
                            inverse <= (t0 < 0) ? t0 + n : t0; // Ensure inverse is positive
                            valid   <= 1;
                            $display("INVERSE FOUND: %d", inverse);
                        end else begin
                            // No modular inverse if gcd(a, n) != 1
                            inverse <= 0;
                            valid   <= 0;
                            $display("NO INVERSE EXISTS");
                        end
                        state <= FINISH;
                    end else begin
                        state <= CALC_Q;
                    end
                end
                
                FINISH: begin
                    done  <= 1;
                    state <= IDLE;  // Go back to IDLE and wait for next start
                end
            endcase
        end
    end
endmodule
