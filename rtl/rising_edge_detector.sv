`timescale 1ns / 1ps
// Mealy FSM with 2-states S0 and S1
// S0: prev_sig_in = 0, sig_in = 0 => rise = 0
//     prev_sig_in = 0, sig_in = 1 => rise = 1 (rising edge detected)
// S1: prev_sig_in = 1, sig_in = 0 => rise = 0
//     prev_sig_in = 1, sig_in = 1 => rise = 0
module rising_edge_detector (
    input logic clk,
    input logic sig_in,
    output logic rise
);
    // State register to hold the previous value of sig_in
    logic prev_sig_in;
    always_ff @(posedge clk) begin
        prev_sig_in <= sig_in; // Update the previous value at each clock edge
    end

    // Output / next state logic
    always_comb begin
        if ((prev_sig_in == 0) && sig_in == 1) // Rising edge detected
            rise = 1;
        else
            rise = 0;
    end
endmodule
