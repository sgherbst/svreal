`timescale 1ns / 1ps

`include "svreal.sv"

module test_synth (
    input wire logic signed [15:0] a_ext,
    input wire logic signed [16:0] b_ext,
    input wire logic signed [7:0] i2r_i_ext,
    input wire logic sel_ext,
    input wire logic rst_ext,
    input wire logic clk_ext,
    input wire logic ce_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] min_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] max_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] add_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] sub_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] mul_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] mux_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] neg_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] i2r_o_ext,
    output wire logic signed [((`LONG_WIDTH_REAL)-1):0] dff_ext,
    output wire logic signed [7:0] r2i_o_ext,
    output wire logic lt_ext,
    output wire logic le_ext,
    output wire logic gt_ext,
    output wire logic ge_ext
);

    `DECL_CLOG2_MATH

    // create signals
    `REAL_FROM_WIDTH_EXP(a, $size(a_ext), -8);
    `REAL_FROM_WIDTH_EXP(b, $size(b_ext), -9);
    assign a = a_ext;
    assign b = b_ext;

    // min
    `MIN_REAL(a, b, min_o);
    assign min_ext = min_o;

    // max
    `MAX_REAL(a, b, max_o);
    assign max_ext = max_o;

    // add
    `ADD_REAL(a, b, add_o);
    assign add_ext = add_o;

    // sub
    `SUB_REAL(a, b, sub_o);
    assign sub_ext = sub_o;

    // mul
    `MUL_REAL(a, b, mul_o);
    assign mul_ext = mul_o;

    // mux
    `ITE_REAL(sel_ext, a, b, mux_o);
    assign mux_ext = mux_o;

    // negation
    `NEGATE_REAL(a, neg_o);
    assign neg_ext = neg_o;

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
