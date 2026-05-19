`timescale 1ns / 1ps
module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // Note: REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  /*================= Goal =================
Goal 1: When a button is pressed briefly, emit a SINGLE pulse
Goal 2: When it is held down emit an initial pulse immediately, then repeatedly emit pulses
        then repeatedly emit pulses after its button has been held high for HOLD_CYCLES
/*================= Steps =================
(1) Detect the rising edge of button:
rising_edge_detector produces a single cycle rise pulse (high logic) the moment button goes
from low to high. -> Gives the immediate pulse on press
(2) Detect the button has been held long enough:
button_hold_detect counts CONSECUTIVE cycles where button is high. After HOLD_CYCLES -
REPEAT_CYCLES + 1 cycles it sets held high for one cycle.
(3) Latch the held state:
The SR flag running is set by held and cleared only when button goes low (as otherwise held
is only high for a single cycle). This held sustained high for the duratiom of button - hold.
(4) Generate repeat pulse_train:
when running is high => sets pulse_train high for one cycle every REPEAT_CYCLES clocks. bcs.
running went high exactly REPEAT CYCLES - 1  cycles before HOLD_CYCLES => first tick lands on
cycle HOLD_CYCLES.*/

  logic rise;  // button -> rising_edge_detector -> rise
  logic held;
  logic running;
  logic pulse_train;  // button -> button_hold_detect -> restartable_rate_generator -> pulse train

  /*================= Step 1 =================*/
  rising_edge_detector #() u_rising_edge_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  /*================= Step 2 =================*/
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_button_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  /*================= Step 3 =================*/
  always_ff @(posedge clk) begin
    if (!button) running <= 0;
    else if (held) running <= 1;
  end

  /*================= Step 4 =================*/
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_restartable_rate_generator (
      .clk (clk),
      .run (running),
      .tick(pulse_train)
  );

  // Output
  assign pulse = rise | (button & pulse_train);

endmodule
