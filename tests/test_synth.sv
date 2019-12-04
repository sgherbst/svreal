`timescale 1ns / 1ps

`include "svreal.sv"

`define A_WIDTH 16
`define B_WIDTH 17
`define I2R_WIDTH 8
`define R2I_WIDTH 8

module test_synth (
    // real-number inputs
    input wire logic signed [`A_WIDTH-1:0] a_ext,
    input wire logic signed [`B_WIDTH-1:0] b_ext,
    // unary op I/O
    output wire logic signed [`A_WIDTH-1:0] neg_ext,
    output wire logic signed [`A_WIDTH-1:0] abs_ext,
    output wire logic signed [`A_WIDTH-1:0] dff_ext,
    // binary op I/O
    output wire logic signed [19:0] min_ext,
    output wire logic signed [20:0] max_ext,
    output wire logic signed [21:0] add_ext,
    output wire logic signed [22:0] sub_ext,
    output wire logic signed [23:0] mul_ext,
    output wire logic signed [24:0] mux_ext,
    // conversion I/O
    input wire logic signed [`I2R_WIDTH-1:0] i2r_i_ext,
    output wire logic signed [`I2R_WIDTH-1:0] i2r_o_ext,
    output wire logic signed [`R2I_WIDTH-1:0] r2i_o_ext,
    // comparison I/O
    output wire logic lt_ext,
    output wire logic le_ext,
    output wire logic gt_ext,
    output wire logic ge_ext,
    // control I/O
    input wire logic sel_ext,
    input wire logic rst_ext,
    input wire logic clk_ext,
    input wire logic ce_ext
);
    `DECL_CLOG2_MATH

    // create signals
    `REAL_FROM_WIDTH_EXP(a, $size(a_ext), -8);
    `REAL_FROM_WIDTH_EXP(b, $size(b_ext), -9);
    assign a = a_ext;
    assign b = b_ext;

    // min
    `MIN_REAL_GENERIC(a, b, min_o, $size(min_ext));
    assign min_ext = min_o;

    // max
    `MAX_REAL_GENERIC(a, b, max_o, $size(max_ext));
    assign max_ext = max_o;

    // add
    `ADD_REAL_GENERIC(a, b, add_o, $size(add_ext));
    assign add_ext = add_o;

    // sub
    `SUB_REAL_GENERIC(a, b, sub_o, $size(sub_ext));
    assign sub_ext = sub_o;

    // mul
    `MUL_REAL_GENERIC(a, b, mul_o, $size(mul_ext));
    assign mul_ext = mul_o;

    // mux
    `ITE_REAL_GENERIC(sel_ext, a, b, mux_o, $size(mux_ext));
    assign mux_ext = mux_o;

    // negation
    `NEGATE_REAL(a, neg_o);
    assign neg_ext = neg_o;

    // absolute value
    `ABS_REAL(a, abs_o);
    assign abs_ext = abs_o;

    // integer to real
    `INT_TO_REAL(i2r_i_ext, $size(i2r_i_ext), i2r_o_int);
    assign i2r_o_ext = i2r_o_int;

    // real to integer
    `REAL_TO_INT(a, $size(r2i_o_ext), r2i_o_int);
    assign r2i_o_ext = r2i_o_int;

    // dff
    `DFF_REAL(a, dff_o, rst_ext, clk_ext, ce_ext, 1.23);
    assign dff_ext = dff_o;

    // comparisons
    `LT_INTO_REAL(a, b, lt_ext);
    `LE_INTO_REAL(a, b, le_ext);
    `GT_INTO_REAL(a, b, gt_ext);
    `GE_INTO_REAL(a, b, ge_ext);
endmodule
