`timescale 1ns / 1ps

`include "svreal.sv"

module test_comp(
    // generic inputs
    input real a_i,
    input real b_i,
    // comparisons
    output lt_o,
    output le_o,
    output gt_o,
    output ge_o,
    output eq_o,
    output ne_o
);
    // create a_i input
    `REAL_FROM_WIDTH_EXP(a_int, 16, -8);
    assign `FORCE_REAL(a_i, a_int);

    // create b_i input
    `REAL_FROM_WIDTH_EXP(b_int, 17, -9);
    assign `FORCE_REAL(b_i, b_int);

    // comparisons
    `LT_INTO_REAL(a_int, b_int, lt_o);
    `LE_INTO_REAL(a_int, b_int, le_o);
    `GT_INTO_REAL(a_int, b_int, gt_o);
    `GE_INTO_REAL(a_int, b_int, ge_o);
    `EQ_INTO_REAL(a_int, b_int, eq_o);
    `NE_INTO_REAL(a_int, b_int, ne_o);
endmodule