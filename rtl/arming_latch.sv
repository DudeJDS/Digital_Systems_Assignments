`timescale 1ns / 1ps
module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);
  /*================= Goal =================

================= Aside =================
Recall,
Synchronous Reset:
Reset only takes effect on a clk edge.

Asynchronous Reset:
Reset takes effect immediatly, regardless of the clk*/

  initial armed = 0;
  always_ff @(posedge clk) begin
    if (disarm) armed <= 0;  // Clear
    else if ((!disarm) & (arm)) armed <= 1;  // Set
    else armed <= armed;  // Hold
  end

endmodule
