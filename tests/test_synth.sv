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
    output wire logic signed [17:0] min_ext,
    output wire logic signed [17:0] max_ext,
    output wire logic signed [17:0] add_ext,
    output wire logic signed [17:0] sub_ext,
    output wire logic signed [17:0] mul_ext,
    output wire logic signed [17:0] mux_ext,
    output wire logic signed [17:0] neg_ext,
    output wire logic signed [17:0] i2r_o_ext,
    output wire logic signed [7:0] r2i_o_ext,
    output wire logic signed [17:0] dff_ext,
    output wire logic lt_ext,
    output wire logic le_ext,
    output wire logic gt_ext,
    output wire logic ge_ext
);

    // create signals
    `MAKE_SVREAL(a, $size(a_ext), -8);
    `MAKE_SVREAL(b, $size(b_ext), -9);
    assign a.value = a_ext;
    assign b.value = b_ext;

    // min
    `MAKE_SVREAL(min_o, $size(min_ext), -10);
    `SVREAL_MIN(a, b, min_o);
    assign min_ext = min_o.value;

    // max
    `MAKE_SVREAL(max_o, $size(max_ext), -10);
    `SVREAL_MAX(a, b, max_o);
    assign max_ext = max_o.value;

    // add
    `MAKE_SVREAL(add_o, $size(add_ext), -10);
    `SVREAL_ADD(a, b, add_o);
    assign add_ext = add_o.value;

    // sub
    `MAKE_SVREAL(sub_o, $size(sub_ext), -10);
    `SVREAL_SUB(a, b, sub_o);
    assign sub_ext = sub_o.value;

    // mul
    `MAKE_SVREAL(mul_o, $size(mul_ext), -10);
    `SVREAL_MUL(a, b, mul_o);
    assign mul_ext = mul_o.value;

    // mux
    `MAKE_SVREAL(mux_o, $size(mux_ext), -10);
    `SVREAL_MUX(sel_ext, a, b, mux_o);
    assign mux_ext = mux_o.value;

    // negation
    `MAKE_SVREAL(neg_o, $size(neg_ext), -10);
    `SVREAL_NEGATE(a, neg_o);
    assign neg_ext = neg_o.value;

    // integer to real
    `MAKE_SVREAL(i2r_o_int, 16, -8);
    `INT_TO_SVREAL(i2r_i_ext, i2r_o_int);
    assign i2r_o_ext = i2r_o_int.value;

    // real to integer
    `SVREAL_TO_INT(a, r2i_o_ext);

    // dff
    `MAKE_SVREAL(dff_o, $size(dff_ext), -10);
    `SVREAL_DFF(a, dff_o, rst_ext, clk_ext, ce_ext);
    assign dff_ext = dff_o.value;

    // comparisons
    `SVREAL_LT(a, b, lt_ext);
    `SVREAL_LE(a, b, le_ext);
    `SVREAL_GT(a, b, gt_ext);
    `SVREAL_GE(a, b, ge_ext);

endmodule
