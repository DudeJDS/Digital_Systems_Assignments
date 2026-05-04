`timescale 1ns / 1ps
module binary_to_bcd (
    input logic [6:0] bin, // binary input 0-99
    output logic [3:0] tens, // decimal tens digit
    output logic [3:0] ones // decimal ones digit
);
    // Tens digit is the quotient of the binary number when divided by 10
    assign tens = 4'(bin / 7'd10);

    // Ones digit is the remainder of the binary number when divided by 10
    assign ones = 4'(bin % 7'd10);
endmodule
