`timescale 1ns / 1ps

`include "svreal.sv"

module test_ite(
    // generic inputs
    input real a_i,
    input real b_i,
    // if-then-else
    input cond_i,
    output real ite_o
);
    // create a_i input
    `REAL_FROM_WIDTH_EXP(a_int, 16, -8);
    assign `FORCE_REAL(a_i, a_int);

    // create b_i input
    `REAL_FROM_WIDTH_EXP(b_int, 17, -9);
    assign `FORCE_REAL(b_i, b_int);

    // mux
    `ITE_REAL_GENERIC(cond_i, a_int, b_int, ite_int, 25);
    assign ite_o = `TO_REAL(ite_int);
endmodule