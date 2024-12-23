module keygen (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] p,
    input wire [31:0] q,
    output wire [31:0] lambda, // LCM output (32 bits)
    output wire [31:0] mu,     // Modular inverse output (32 bits)
    output wire done           // Done signal
);
    // Internal signals
    reg [31:0] n;               // Product of p and q (32 bits)
    reg [63:0] n_sq;            // Square of n (32 bits)
    wire [31:0] lcm_out;        // LCM output from lcm_calculator (32 bits)
    wire lcm_done;              // Done signal from lcm_calculator
    wire [31:0] exp_out;        // Output from modular_exponentiation (32 bits)
    wire exp_done;              // Done signal from modular_exponentiation
    wire [31:0] L_out;          // Output from L module (32 bits)
    wire L_done;                // Done signal from L module
    wire [31:0] inv_out;        // Output from modular_inverse (32 bits)
    wire inv_done, inv_valid;   // Done and valid signals from modular_inverse
    reg keygen_done;            // Overall done signal for keygen

    // Calculate n = p * q and n_sq = n^2
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            n <= 0;
            n_sq <= 0;
        end else if (start) begin
            n <= p * q;
            n_sq <= (p * q) * (p * q);
        end
    end

    // g is assigned as a constant value internally
    wire [31:0] g = n + 1;

    // Instantiate the lcm_calculator module
    lcm_calculator lcm_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a_in(p - 1),
        .b_in(q - 1),
        .lcm_out(lcm_out),
        .done(lcm_done)
    );

    // Instantiate the modular_exponentiation module
    modular_exponentiation mod_exp (
        .clk(clk),
        .rst(rst),
        .start(lcm_done), // Start after LCM is done
        .a(g),            // g = n + 1
        .b(lcm_out),      // Exponent is lambda
        .m(n_sq),         // Modulus is n^2
        .result(exp_out),
        .done(exp_done)
    );

    // Instantiate the L module
    L L_inst (
        .clk(clk),
        .reset(rst),
        .start(exp_done), // Start after modular exponentiation is done
        .u(exp_out),
        .n(n),
        .out(L_out),
        .done(L_done)
    );

    // Instantiate the modular_inverse module
    modular_inverse mod_inv_inst (
        .clk(clk),
        .reset(rst),
        .start(L_done), // Start after L computation is done
        .a(L_out),
        .n(n),
        .inverse(inv_out),
        .done(inv_done),
        .valid(inv_valid)
    );

    // Control the overall done signal
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            keygen_done <= 0;
        end else if (inv_done) begin
            keygen_done <= 1;
        end
    end

    // Output assignments
    assign lambda = lcm_out;
    assign mu = inv_out;
    assign done = keygen_done;

endmodule
