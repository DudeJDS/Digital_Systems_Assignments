`timescale 1ns / 1ps
module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
)(
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

    // Declare variables for hours, minutes, and seconds
    logic [4:0] hours;   // 0-23 can be represented in 5 bits
    logic [5:0] minutes; // 0-59 can be represented in 6 bits
    logic [5:0] seconds; // 0-59

    // Counter to keep track of time, where we will count up with a particular frequency depending on enable.
    // We will use restartable_rate_generator to generate the desired tick frequency.
    hms_counter #(
        .N_HOURS(24),
        .N_MINUTES(60),
        .N_SECONDS(60),
        .W_HOURS(5),
        .W_MINUTES(6),
        .W_SECONDS(6)
    ) u_hms_counter (
        .clk(CLOCK_50),
        .enable(second_tick_frequency), // Enable signal that determines how fast we count time
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds)
    );

    // Need an enable signal that will tick every desired time interval depending on the switch.
    logic second_tick_frequency;
    logic tick_frequency_1hz; // For normal clock operation (1 second tick frequency)
    logic tick_frequency_25hz; // For 25x faster clock operation (0.04 second tick frequency)
    logic tick_frequency_1khz; // For 1000x faster clock operation (0.001 second tick frequency)
    logic tick_frequency_50mhz; // For 50_000_000x faster clock operation (0.00000002 second tick frequency)
    always_comb begin
        case (SW)
            2'b00: second_tick_frequency = tick_frequency_1hz; // Normal clock operation: seconds incremented every second => "real time" display
            2'b01: second_tick_frequency = tick_frequency_25hz; // 25hz clock operation => 25x faster than real time
            2'b10: second_tick_frequency = tick_frequency_1khz; // 1Khz clock operation => 1000x faster than real time
            2'b11: second_tick_frequency = tick_frequency_50mhz; // 50Mhz clock operation => 50_000_000x faster than real time (for testing purposes)
            default: second_tick_frequency = 1'b0;
        endcase
    end

    // Normal clock operation: seconds incremented every second => "real time" display
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND) // 1 second = CYCLES_PER_SECOND clock cycles
    ) u_rate_generator_00 (
        .clk(CLOCK_50),
        .run(1'b1), // Always run to keep time
        .tick(tick_frequency_1hz)
    );

    // 25hz clock operation => 25x faster than real time
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND / 25) // 0.04 second = CYCLES_PER_SECOND / 25 clock cycles
    ) u_rate_generator_01 (
        .clk(CLOCK_50),
        .run(1'b1), // Always run to keep time
        .tick(tick_frequency_25hz)
    );

    // 1Khz clock operation => 1000x faster than real time
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND / 1000) // 0.001 second = CYCLES_PER_SECOND / 1000 clock cycles
    ) u_rate_generator_10 (
        .clk(CLOCK_50),
        .run(1'b1), // Always run to keep time
        .tick(tick_frequency_1khz)
    );

    // 50Mhz clock operation => 50_000_000x faster than real time (for testing purposes)
    restartable_rate_generator #(
        .CYCLE_COUNT(CYCLES_PER_SECOND / 50000000) // 0.00000002 second = CYCLES_PER_SECOND / 50000000
    ) u_rate_generator_11 (
        .clk(CLOCK_50),
        .run(1'b1), // Always run to keep time
        .tick(tick_frequency_50mhz)
    );

    // Binary to BCD conversion: Hours
    logic [3:0] hours_tens;
    logic [3:0] hours_ones;
    binary_to_bcd #(
    ) u_binary_to_bcd_hours (
        .bin({2'b0, hours}), // Pad hours to 7 bits for binary to BCD conversion
        .tens(hours_tens),
        .ones(hours_ones)
    );

    // Binary to BCD conversion: Minutes
    logic [3:0] minutes_tens;
    logic [3:0] minutes_ones;
    binary_to_bcd #(
    ) u_binary_to_bcd_minutes (
        .bin({1'b0, minutes}), // Pad minutes to 7 bits for binary to BCD conversion
        .tens(minutes_tens),
        .ones(minutes_ones)
    );

    // Binary to BCD conversion: Seconds
    logic [3:0] seconds_tens;
    logic [3:0] seconds_ones;
    binary_to_bcd #(
    ) u_binary_to_bcd_seconds (
        .bin({1'b0, seconds}), // Pad seconds to 7 bits for binary to BCD conversion
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
