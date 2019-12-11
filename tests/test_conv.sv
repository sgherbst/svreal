`timescale 1ns / 1ps

`include "svreal.sv"

module test_conv(
    // real to integer
    input real r2i_i,
    output signed [7:0] r2i_o,
    // integer to real
    input signed [7:0] i2r_i,
    output real i2r_o
);
    // create r2i_i input
    `REAL_FROM_WIDTH_EXP(r2i_int, 16, -8);
    assign `FORCE_REAL(r2i_i, r2i_int);

    // real to integer
    `REAL_INTO_INT(r2i_int, 8, r2i_o);

    // integer to real
    `INT_TO_REAL(i2r_i, 8, i2r_int);
    assign i2r_o = `TO_REAL(i2r_int);
endmodule