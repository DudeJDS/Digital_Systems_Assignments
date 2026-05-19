`timescale 1ns / 1ps
module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000  // 1 second at 50MHz
) (
    input  logic clk,
    input  logic button,
    output logic held
);
  localparam int CountMax = HOLD_CYCLES;  // Count from 0 to HOLD_CYCLES-1
  localparam int CountWidth = $clog2(CountMax + 1);  // Num. of bits needed to count up to CountMax

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;
  mod_n_counter #(
      .N(CountMax + 1),  // 0-CountMax => CountMax+1 states
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .enable(count_enable),
      .rst(count_rst),
      .count(count)
  );

  // Next state logic for count enable and reset
  always_comb begin
    if (button) begin
      count_rst = 0;  // Don't reset the counter while button is held
      if (held)
        count_enable = 0;  // stop counting if button has already, and is continuing, to be held
      else count_enable = 1;  // button hasnt already been held, so start counting!
    end else begin
      count_enable = 0;  // Stop counting when button is released
      count_rst = 1;  // Reset the counter when button is released
    end
  end

  // Output logic: held is high when count reaches CountMax
  always_comb begin
    if (32'(count) == CountMax) held = 1;  // Button has been held for the required duration
    else held = 0;  // Button has not been held long enough
  end
endmodule
