`timescale 1ns / 1ps

`include "svreal.sv"

module test_dff #(
    parameter real init=0.0
) (
    input real d_i,
    output real q_o,
    input rst_i,
    input clk_i,
    input cke_i
);
    // create data input
    `REAL_FROM_WIDTH_EXP(d_int, 16, -8);
    assign `FORCE_REAL(d_i, d_int);

    // create data output
    `REAL_FROM_WIDTH_EXP(q_int, 17, -9);
    assign q_o = `TO_REAL(q_int);

    // instantiate DFF
    `DFF_INTO_REAL(d_int, q_int, rst_i, clk_i, cke_i, init);
endmodule
