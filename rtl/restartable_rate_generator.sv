`timescale 1ns / 1ps
// Note: clk cycle is the time b/w two rising edges of the clk
/* spec details:
after CYCLE_COUNT-1 rising edges -> tick once, then every CYCLE_COUNT rising edges -> tick again.
In a nutshell (and why we use mod_n_counter):
count (clk rising edges) up to a limit (CYCLE_COUNT-1), then do something, then repeat.
This is exactly what a mod_n_counter does: it counts up to N-1, then resets to 0 and can be used to generate a tick at
the end of each cycle.
The restartable part that whenever run goes low, the count should reset.
*/
module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);
  // tick_qualifier becomes high after counting to CYCLE_COUNT-1 and is used to "qualify" the run signal to generate tick.
  // this is needed to ensure that tick is generated only at the end of each cycle and not immediately when run goes high.
  logic tick_qualifier;
  // FSM STATE!
  logic running = 1'b0;  // Indicates if the generator is currently running

  // State register (running)
  // Note: count is also a state register its just implemented inside mod_n_counter
  always_ff @(posedge clk) running <= run;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      // CountWidth is the number of bits needed to count up to CYCLE_COUNT - 1.
      localparam int CountWidth = $clog2(CYCLE_COUNT);
      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;
      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );
      // tick_qualifier is high when count reaches CYCLE_COUNT - 1.
      assign tick_qualifier = (count == CountWidth'(CYCLE_COUNT - 1));
      // reset count when run is low
      assign rst_count = ~run;
      assign enable_count = run;  // count only when run is high.

    end else begin : g_special
      // For CYCLE_COUNT = 1
      assign tick_qualifier = 1'b1;  // tick follows run directly
    end
  endgenerate

  // Output logic
  // tick is high only when running is high and tick_qualifier is high.
  // this ensures that tick is generated at the end of each cycle when running is high.
  assign tick = running && tick_qualifier;
endmodule
