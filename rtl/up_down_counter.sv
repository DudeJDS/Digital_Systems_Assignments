`timescale 1ns / 1ps
module up_down_counter #(
    parameter int MAX = 2,
    parameter int WIDTH = 2
)(
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
    // Initialise count => initially count is not assigned i.e. xxxxxx
    initial count = '0;
    // We must properly size the constants Max and One
    localparam logic [WIDTH-1:0] Max = WIDTH'(MAX); // => Take the integer value MAX and convert it into a WIDTH-bit binary num.
    localparam logic [WIDTH-1:0] One = WIDTH'(1); 

    logic [WIDTH-1:0] next_count;
    
    // State register (enable gated)
    always_ff @(posedge clk) begin
        if (enable)
            count <= next_count;
    end

    // Next state logic
    always_comb begin
        // Increment logic 
        if (up) begin // Note: In SystemVerilog an if without begin ... end can only control one statement
            if (count == Max)
                next_count = '0;
            else
                next_count = count + One;
        end else begin
            // Decrement logic
            if (count == '0)
                next_count = Max;
            else
                next_count = count - One;
        end 
    end
endmodule
