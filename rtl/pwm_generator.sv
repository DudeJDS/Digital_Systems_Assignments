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
    
endmodule
