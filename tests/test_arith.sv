`timescale 1ns / 1ps

`include "svreal.sv"

module test_arith(
    // generic inputs
    input real a_i,
    input real b_i,
    // operators
    output real min_o,
    output real max_o,
    output real add_o,
    output real sub_o,
    output real mul_o,
    output real neg_o,
    output real abs_o
);
    // create a_i input
    `REAL_FROM_WIDTH_EXP(a_int, 16, -8);
    assign `FORCE_REAL(a_i, a_int);

    // create b_i input
    `REAL_FROM_WIDTH_EXP(b_int, 17, -9);
    assign `FORCE_REAL(b_i, b_int);

    // min
    `MIN_REAL_GENERIC(a_int, b_int, min_int, 20);
    assign min_o = `TO_REAL(min_int);

    // max
    `MAX_REAL_GENERIC(a_int, b_int, max_int, 21);
    assign max_o = `TO_REAL(max_int);

    // add
    `ADD_REAL_GENERIC(a_int, b_int, add_int, 22);
    assign add_o = `TO_REAL(add_int);

    // sub
    `SUB_REAL_GENERIC(a_int, b_int, sub_int, 23);
    assign sub_o = `TO_REAL(sub_int);

    // mul
    `MUL_REAL_GENERIC(a_int, b_int, mul_int, 24);
    assign mul_o = `TO_REAL(mul_int);

    // negate
    `NEGATE_REAL(a_int, neg_int);
    assign neg_o = `TO_REAL(neg_int);

    // absolute value
    `ABS_REAL(a_int, abs_int);
    assign abs_o = `TO_REAL(abs_int);
endmodule