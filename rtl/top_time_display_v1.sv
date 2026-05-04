`timescale 1ns / 1ps
module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
)(
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [5:0] HEX5,
    output logic [5:0] HEX4,
    output logic [5:0] HEX3,
    output logic [5:0] HEX2,
    output logic [5:0] HEX1,
    output logic [5:0] HEX0
);

    // Declare variables for hours, minutes, and seconds
    logic [4:0] hours;   // 0-23 can be represented in 5 bits
    logic [5:0] minutes; // 0-59 can be represented in 6 bits
    logic [5:0] seconds; // 0-59

    hms_counter #(
        .N_HOURS(24),
        .N_MINUTES(60),
        .N_SECONDS(60),
        .W_HOURS(5),
        .W_MINUTES(6),
        .W_SECONDS(6)
    ) u_hms_counter (
        .clk(CLOCK_50),
        .enable(1'b1), // Enable counting continuously
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds)
    )

    // Generate a tick every second using the restartable_rate_generator


    // Binary to BCD conversion: Hours
    logic [3:0] hours_tens;
    logic [3:0] hours_ones;
    binary_to_bcd (
        .bin(hours),
        .tens(hours_tens),
        .ones(hours_ones)
    );

    // Binary to BCD conversion: Minutes
    logic [3:0] minutes_tens;
    logic [3:0] minutes_ones;
    binary_to_bcd (
        .bin(minutes),
        .tens(minutes_tens),
        .ones(minutes_ones)
    );

    // Binary to BCD conversion: Seconds
    logic [3:0] seconds_tens;
    logic [3:0] seconds_ones;
    binary_to_bcd (
        .bin(seconds),
        .tens(seconds_tens),
        .ones(seconds_ones)
    );

    // Display hours (tens) HEX5
    seven_segment #(
        .ACTIVE_LOW(1) // Assuming active-low LEDs
    ) u_seven_segment_hours_tens (
        .digit(hours_tens),
        .blank(1'b0), // Always display
        .segments(HEX5)
    );

    // Display hours (ones) HEX4
    seven_segment #(
        .ACTIVE_LOW(1)
    ) u_seven_segment_hours_ones (
        .digit(hours_ones),
        .blank(1'b0),
        .segments(HEX4)
    );

    // Display minutes (tens) HEX3
    seven_segment #(
        .ACTIVE_LOW(1)
    ) u_seven_segment_minutes_tens (
        .digit(minutes_tens),
        .blank(1'b0),
        .segments(HEX3)
    );

    // Display minutes (ones) HEX2
    seven_segment #(
        .ACTIVE_LOW(1)
    ) u_seven_segment_minutes_ones (
        .digit(minutes_ones),
        .blank(1'b0),
        .segments(HEX2)
    );

    // Display seconds (tens) HEX1
    seven_segment #(
        .ACTIVE_LOW(1)
    ) u_seven_segment_seconds_tens (
        .digit(seconds_tens),
        .blank(1'b0),
        .segments(HEX1)
    );

    // Display seconds (ones) HEX0
    seven_segment #(
        .ACTIVE_LOW(1)
    ) u_seven_segment_seconds_ones (
        .digit(seconds_ones),
        .blank(1'b0),
        .segments(HEX0)
    );

endmodule
