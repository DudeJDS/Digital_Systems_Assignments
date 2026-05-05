`timescale 1ns / 1ps
module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000, // Default to 1 second period at 50MHz clock
    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000 // Default to 50% duty cycle
)(
    input logic clk,
    input logic rst,
    output logic pwm_out
);
    // Generate PWM signal based on the mod_n_counter
    logic [$clog2(PERIOD_CYCLES)-1:0] counter_value; // Counter value from mod_n_counter
    mod_n_counter #(
        .N(PERIOD_CYCLES),
        .WIDTH($clog2(PERIOD_CYCLES))
    ) u_mod_n_counter (
        .clk(clk),
        .rst(rst),
        .enable(1'b1), // Always enable counting
        .count(counter_value) // Connect count output to counter_value
    );

    // Generate PWM output based on counter value and duty cycle
    // Note: Can't cast DUTY_CYCLES to the same width as counter_value without 
    always_comb begin
        if (32'(counter_value) < DUTY_CYCLES)
            pwm_out = 1'b1; // Output high for duty cycle duration
        else
            pwm_out = 1'b0; // Output low for the rest of the period
    end
endmodule
