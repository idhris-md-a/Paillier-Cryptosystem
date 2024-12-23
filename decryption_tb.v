`timescale 1ns / 1ps

module decryption_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg start;
    reg [127:0] cipher_text;
    reg [31:0] p;
    reg [31:0] q;
    reg [31:0] lambda;
    reg [31:0] mu;
    wire [31:0] out;
    wire done;

    // Instantiate the decryption module
    decryption uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cipher_text(cipher_text),
        .p(p),
        .q(q),
        .lambda(lambda),
        .mu(mu),
        .out(out),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock (10 ns period)
    end

    // Test procedure
    initial begin
        // Initial values
        rst = 1;
        start = 0;
        cipher_text = 0;
        p = 0;
        q = 0;
        lambda = 0;
        mu = 0;

        // Apply reset
        #10;
        rst = 0;

        // Test case 1: Provide example values for cipher_text, p, q, lambda, and mu
        #10;
        cipher_text = 128'd7086447; // Example ciphertext
        p = 32'd13;        // Example prime number
        q = 32'd7;        // Example prime number
        lambda = 32'd12;  // Example lambda value (computed in keygen)
        mu = 32'd38;       // Example mu value (modular inverse)
        start = 1;         // Start the decryption process

        // Wait for the module to complete computation
        wait(done);
        
        // Display the outputs
        #10;
        $display("Test Case 1:");
        $display("Cipher Text: %d", cipher_text);
        $display("p: %d, q: %d", p, q);
        $display("Lambda: %d", lambda);
        $display("Mu: %d", mu);
        $display("Decrypted Output (Plaintext): %d", out);
        $display("Computation done: %b", done);

        // End simulation after a delay to observe the final results
        #50;
        $stop;
    end
endmodule
