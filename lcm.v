module lcm_calculator (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] a_in,
    input wire [31:0] b_in,
    output wire [31:0] lcm_out,
    output wire done
);
    // Internal wires and registers
    wire [31:0] gcd_out;
    reg [31:0] a_reg, b_reg, lcm_reg;
    reg done_reg;

    // GCD calculator module
    gcd_calculator gcd_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a_in(a_in),
        .b_in(b_in),
        .gcd_out(gcd_out),
        .done(gcd_done)
    );

    // LCM calculation logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg <= 0;
            b_reg <= 0;
            lcm_reg <= 0;
            done_reg <= 0;
        end else begin
            if (start) begin
                a_reg <= a_in;
                b_reg <= b_in;
                done_reg <= 0;
            end
            if (gcd_done) begin
                lcm_reg <= (a_reg * b_reg) / gcd_out;
                done_reg <= 1;
            end
        end
    end

    // Output assignments
    assign lcm_out = lcm_reg;
    assign done = done_reg;
endmodule
