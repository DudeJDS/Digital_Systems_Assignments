timescale 1ns / 1ps
module button_auto_repeat #(
    parameter int HOLD_CYCLES = 50_000_000
    // Note: REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
)(
    input logic clk,
    input logic button,
    output logic pulse
);
    logic rise; // button -> rising_edge_detector -> rise
    logic held;
    logic pulse_train; // button -> button_hold_detect -> restartable_rate_generator -> pulse train

    // Instatiating rising_edge_detector to generate our internal signal rise
    rising_edge_detector #(
    ) u_rising_edge_detector (
        .clk(clk),
        .sig_in(button),
        .rise(rise)
    );

    // Instatiating button_hold_detect to give us held
    button_hold_detect #(
        .HOLD_CYCLES(HOLD_CYCLES)
    ) u_button_hold_detect (
        .clk(clk),
        .button(button),
        .held(held)
    );

endmodule
