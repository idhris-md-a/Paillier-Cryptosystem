module modular_multiplier (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] m,
    output reg [63:0] result,
    output reg done
);

    // State encoding - one hot encoding for better synthesis
    localparam [3:0] IDLE     = 4'b0001,
                     LOAD     = 4'b0010,
                     MULTIPLY = 4'b0100,
                     REDUCE   = 4'b1000;
                     
    reg [3:0] current_state, next_state;
    
    // Internal registers
    reg [63:0] product;
    reg [31:0] multiplier;    // Renamed from temp_b for clarity
    reg [5:0]  count;
    reg [31:0] modulus;       // Renamed from temp_m for clarity
    reg [31:0] multiplicand;  // Renamed from temp_a for clarity
    
    // State register with synchronous reset
    always @(posedge clk) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    
    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start)
                    next_state = LOAD;
                else
                    next_state = IDLE;
            end
            
            LOAD: begin
                next_state = MULTIPLY;
            end
            
            MULTIPLY: begin
                if (count == 6'd32)
                    next_state = REDUCE;
                else
                    next_state = MULTIPLY;
            end
            
            REDUCE: begin
                if (product < {32'b0, modulus})
                    next_state = IDLE;
                else
                    next_state = REDUCE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Datapath and output logic
    always @(posedge clk) begin
        if (!rst_n) begin
            product <= 64'b0;
            multiplier <= 32'b0;
            multiplicand <= 32'b0;
            modulus <= 32'b0;
            count <= 6'b0;
            result <= 64'b0;
            done <= 1'b0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        count <= 6'b0;
                        product <= 64'b0;
                    end
                end
                
                LOAD: begin
                    multiplicand <= a;
                    multiplier <= b;
                    modulus <= m;
                end
                
                MULTIPLY: begin
                    if (count < 6'd32) begin
                        if (multiplier[0])
                            product <= product + ({32'b0, multiplicand} << count);
                        multiplier <= multiplier >> 1;
                        count <= count + 1;
                    end
                end
                
                REDUCE: begin
                    if (product >= {32'b0, modulus}) begin
                        product <= product - {32'b0, modulus};
                    end
                    else begin
                        result <= product;
                        done <= 1'b1;
                    end
                end
                
                default: begin
                    product <= 64'b0;
                    done <= 1'b0;
                end
            endcase
        end
    end

endmodule
