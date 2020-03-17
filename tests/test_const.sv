`timescale 1ns / 1ps

`include "svreal.sv"

module test_const #(
    parameter real a_const=0.0,
    parameter real b_const=0.0,
    parameter real c_const=0.0
) (
    output real a_o,
    input real b_i,
    output real b_o,
    input real c_i,
    output real c_o
);
    // produce a_o output
    `MAKE_CONST_REAL(a_const, a_const_int);
    assign a_o = `TO_REAL(a_const_int);

    // produce b_o output
    `MAKE_REAL(b_i_int, 10);
    assign `FORCE_REAL(b_i, b_i_int);
    `MUL_CONST_REAL(b_const, b_i_int, b_o_int);
    assign b_o = `TO_REAL(b_o_int);

    // produce c_o output
    `MAKE_REAL(c_i_int, 10);
    assign `FORCE_REAL(c_i, c_i_int);
    `ADD_CONST_REAL(c_const, c_i_int, c_o_int);
    assign c_o = `TO_REAL(c_o_int);
endmodule
