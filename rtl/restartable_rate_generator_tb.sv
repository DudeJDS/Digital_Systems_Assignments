`timescale 1ns / 1ps
module restartable_rate_generator_tb;

    logic clk;
    logic run;
    logic tick;

    //instantiate the DUT (Device Under Test)
    restartable_rate_generator #(
        .CYCLE_COUNT(1)
    ) u_restartable_rate_generator (
        .clk(clk),
        .run(run),
        .tick(tick)
    );

    // Clock generation: For us a 50Mhz clock => 20ns period
    always #10 clk = ~clk; // Toggle clock every 10ns (half period) => 20ns full period

    // Test sequence
    initial begin
        clk = 0; // Initialize clock
        run = 0; // Initialize run to 0 (not running)

        #50; // Wait for 50ns to let signals settle after initialization
        run = 1;

        #1000;
        run = 0;

        #100;
        $finish; // End the simulation
    end

endmodule
