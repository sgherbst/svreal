`timescale 1ns/1ps

`include "svreal.sv"

module test_clog2(
    input real in_,
    output signed [31:0] out
);
    assign out = clog2_math(in_);
endmodule
