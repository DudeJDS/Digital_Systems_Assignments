`timescale 1ns / 1ps
module hms_counter #(
    parameter int N_HOURS = 24, // number of hours
    parameter int N_MINUTES = 60, // number of minutes
    parameter int N_SECONDS = 60, // number of seconds

    // Output port widths
    parameter int W_HOURS = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
)(
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
    // Max values (N-1)
    localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);
    localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);

    // Rollover signals
    // Note: No need for an hours rollover signal since there is nothing that depends on it.
    // It's our most significant measure of time
    logic seconds_rollover;
    logic minutes_rollover;

    // Rollover logic
    assign seconds_rollover = enable && (seconds == MaxSeconds);
    assign minutes_rollover = seconds_rollover && (minutes == MaxMinutes);

    // Here we utilise the up_down_counter module to create the seconds, minutes and hours counters.
    // We connect the enable and clock signals to all three counters, but we only connect the up signal to count up.
    // The minutes counter is enabled when the seconds counter wraps around from 59 back to 0, and the hours counter is
    // enabled when the minutes counter wraps around from 59 back to 0.
    // Note: We have to insantiate the counters s.t. .MAZ(N-1) because the counter counts from 0 to MAX, but our MAX,
    // using seconds as an example, should be 59, not 60.
    // Note: enable is connected (for minutes and hours) to our rollover signals

    // Seconds counter
    up_down_counter #(
        .MAX(N_SECONDS-1),
        .WIDTH(W_SECONDS)
    ) u_seconds (
        .clk(clk),
        .enable(enable),
        .up(1'b1), // alwayys counting up
        .count(seconds)
    );
    // Minutes counter
    up_down_counter #(
        .MAX(N_MINUTES-1),
        .WIDTH(W_MINUTES)
    ) u_minutes (
        .clk(clk),
        .enable(seconds_rollover), // Increment minutes when seconds wrap around
        .up(1'b1),
        .count(minutes)
    );
    // Hours counter
    up_down_counter #(
        .MAX(N_HOURS-1),
        .WIDTH(W_HOURS)
    ) u_hours (
        .clk(clk),
        .enable(minutes_rollover), // Increment hours when minutes wrap around
        .up(1'b1),
        .count(hours)
    );
endmodule
