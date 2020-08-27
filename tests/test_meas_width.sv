`timescale 1ns/1ps

`include "svreal.sv"

module test_meas_width (
    input [7:0] in_,
    output [7:0] out
);
    `MEAS_UINT_WIDTH_INTO(in_, 8, out, 8);
endmodule
