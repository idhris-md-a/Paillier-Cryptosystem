module gcd_calculator (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] a_in,
    input wire [31:0] b_in,
    output wire [31:0] gcd_out,
    output wire done
);

    // Internal registers
    reg [31:0] a_reg, b_reg, gcd_reg;
    reg [31:0] shift_count;
    reg done_reg;

    // State encoding
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] current_state, next_state;

    // Control Path - State Register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Control Path - Next State Logic
    always @(*) begin
        case (current_state)
            IDLE: next_state = (start) ? COMPUTE : IDLE;
            COMPUTE: next_state = (a_reg == b_reg) ? DONE : COMPUTE;
            DONE: next_state = (start) ? DONE : IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Data Path
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg <= 32'd0;
            b_reg <= 32'd0;
            gcd_reg <= 32'd0;
            shift_count <= 32'd0;
            done_reg <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (start) begin
                        a_reg <= a_in;
                        b_reg <= b_in;
                        shift_count <= 0;
                        done_reg <= 1'b0;
                    end
                end
                COMPUTE: begin
                    if (a_reg == b_reg) begin
                        gcd_reg <= a_reg << shift_count;
                    end else if (a_reg == 0) begin
                        gcd_reg <= b_reg << shift_count;
                    end else if (b_reg == 0) begin
                        gcd_reg <= a_reg << shift_count;
                    end else if ((a_reg[0] == 0) && (b_reg[0] == 0)) begin
                        a_reg <= a_reg >> 1;
                        b_reg <= b_reg >> 1;
                        shift_count <= shift_count + 1;
                    end else if (a_reg[0] == 0) begin
                        a_reg <= a_reg >> 1;
                    end else if (b_reg[0] == 0) begin
                        b_reg <= b_reg >> 1;
                    end else if (a_reg > b_reg) begin
                        a_reg <= (a_reg - b_reg) >> 1;
                    end else begin
                        b_reg <= (b_reg - a_reg) >> 1;
                    end
                end
                DONE: begin
                    done_reg <= 1'b1;
                end
            endcase
        end
    end

    // Output assignments
    assign gcd_out = gcd_reg;
    assign done = done_reg;

endmodule

 
