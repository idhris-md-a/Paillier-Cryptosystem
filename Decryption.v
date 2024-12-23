module decryption (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [63:0] cipher_text, // 128-bit ciphertext input
    input wire [31:0] p,            // 32-bit prime p
    input wire [31:0] q,            // 32-bit prime q
    input wire [31:0] lambda,       // 32-bit lambda (private key component)
    input wire [31:0] mu,           // 32-bit mu (modular inverse)
    output reg [31:0] out,          // 32-bit plaintext output
    output reg done                 // Done signal
);
    // Internal signals
    reg [63:0] n;                   // 64-bit modulus n = p * q
    reg [127:0] n_sq;               // 128-bit n^2
    wire [31:0] exp_out;            // Result of modular exponentiation (cipher_text^lambda % n^2)
    wire exp_done;                  // Done signal for modular exponentiation
    wire [31:0] L_out;              // Result of L function
    wire L_done;                    // Done signal for L function
    wire [63:0] mul_out;            // Result of (L_out * mu) % n
    wire mul_done;                  // Done signal for modular multiplication

    // Calculate n and n^2
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            n <= 64'd0;
            n_sq <= 128'd0;
        end else if (start) begin
            n <= p * q;
            n_sq <= (p * q) * (p * q);
        end
    end

    // Instantiate the modular exponentiation module to compute cipher_text^lambda % n^2
    modular_exponentiation mod_exp_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(cipher_text[31:0]),  // Lower 32 bits of cipher_text
        .b(lambda),             // Exponent is lambda
        .m(n_sq[31:0]),         // Modulus is n^2 (lower 32 bits)
        .result(exp_out),
        .done(exp_done)
    );

    // Instantiate the L module to compute L(exp_out) = (exp_out - 1) / n
    L L_inst (
        .clk(clk),
        .reset(rst),
        .start(exp_done),       // Start when modular exponentiation is done
        .u(exp_out),
        .n(n[31:0]),            // Lower 32 bits of n
        .out(L_out),
        .done(L_done)
    );

    // Instantiate the modular multiplication module to compute (L_out * mu) % n
    modular_multiplier mod_mul_inst (
        .clk(clk),
        .rst_n(!rst),
        .start(L_done),         // Start when L function computation is done
        .a(L_out),
        .b(mu),
        .m(n[31:0]),            // Modulus is n (lower 32 bits)
        .result(mul_out),
        .done(mul_done)
    );

    // Control the done signal and final output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 32'd0;
            done <= 1'b0;
        end else if (mul_done) begin
            out <= mul_out[31:0]; // Assign the lower 32 bits as the final plaintext
            done <= 1'b1;
        end
    end
endmodule
