module cipher_text_generation_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg start;
    reg [31:0] m1;
    reg [63:0] n;
    wire [63:0] c;
    wire done;

    // Instantiate the cipher_text_generation module
    cipher_text_generation uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .m1(m1),
        .n(n),
        .c(c),
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
        m1 = 0;
        n = 0;

        // Apply reset
        #10;
        rst = 0;

        // Test case 1: Provide example values for m1 and n
        #10;
        m1 = 32'd123;        // Example plaintext message
        n = 64'd3233;        // Example modulus (product of two 32-bit primes)
        start = 1;           // Start the encryption process

        // Wait for the module to complete computation
        wait(done);
        
        // Display the outputs
        #10;
        $display("Test Case 1:");
        $display("m1 (plaintext) = %d", m1);
        $display("n (modulus) = %d", n);
        $display("g (n + 1) = %d", n + 1);
        $display("c (ciphertext) = %h", c);
        $display("Computation done: %b", done);

        // End simulation after a delay to observe the final results
        #50;
        $stop;
    end
endmodule
