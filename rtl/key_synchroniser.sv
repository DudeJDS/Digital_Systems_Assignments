`timescale 1ns / 1ps
module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active-low, asynchronous
    output logic [3:0] key_sync  // active-high, synchronised
);
  // Invert bits (BITWISE NOT on all 4 bits)
  // Intermediate signal
  logic [3:0] key_inv;
  assign key_inv = ~key_n;

  // 2 flip flops in series initialised to 0
  logic [3:0] stage_1 = 4'b0000;
  logic [3:0] stage_2 = 4'b0000;
  always_ff @(posedge clk) begin
    stage_1 <= key_inv;
    stage_2 <= stage_1;
  end

  assign key_sync = stage_2;

endmodule
