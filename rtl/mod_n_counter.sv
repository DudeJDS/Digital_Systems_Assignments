`timescale 1ns / 1ps
module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
)(
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);
    initial count = WIDTH'(0); // Initial value for simulation
    // Next count variable for next state logic
    logic [WIDTH-1:0] next_count;

    // State register (synchronous reset, enable gated)
    always_ff @(posedge clk) begin
        if (rst)
            count <= WIDTH'(0);
        else if (enable)
            count <= next_count;
    end

    // Next state logic
    always_comb begin
        if (count == WIDTH'(N-1))
            next_count = WIDTH'(0);
        else
            next_count = count + 1;
    end
endmodule
