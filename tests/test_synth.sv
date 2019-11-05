`timescale 1ns / 1ps

`include "svreal.sv"

module test_synth (
    input wire logic signed [15:0] a_ext,
    input wire logic signed [16:0] b_ext,
    input wire logic signed [17:0] dff_init_ext,
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
    `MAKE_SVREAL(dff_init, $size(dff_init_ext), -10);
    assign `SVREAL_SIGNIFICAND(a) = a_ext;
    assign `SVREAL_SIGNIFICAND(b) = b_ext;
    assign `SVREAL_SIGNIFICAND(dff_init) = dff_init_ext;

    // min
    `MAKE_SVREAL(min_o, $size(min_ext), -10);
    `SVREAL_MIN(a, b, min_o);
    assign min_ext = `SVREAL_SIGNIFICAND(min_o);

    // max
    `MAKE_SVREAL(max_o, $size(max_ext), -10);
    `SVREAL_MAX(a, b, max_o);
    assign max_ext = `SVREAL_SIGNIFICAND(max_o);

    // add
    `MAKE_SVREAL(add_o, $size(add_ext), -10);
    `SVREAL_ADD(a, b, add_o);
    assign add_ext = `SVREAL_SIGNIFICAND(add_o);

    // sub
    `MAKE_SVREAL(sub_o, $size(sub_ext), -10);
    `SVREAL_SUB(a, b, sub_o);
    assign sub_ext = `SVREAL_SIGNIFICAND(sub_o);

    // mul
    `MAKE_SVREAL(mul_o, $size(mul_ext), -10);
    `SVREAL_MUL(a, b, mul_o);
    assign mul_ext = `SVREAL_SIGNIFICAND(mul_o);

    // mux
    `MAKE_SVREAL(mux_o, $size(mux_ext), -10);
    `SVREAL_MUX(sel_ext, a, b, mux_o);
    assign mux_ext = `SVREAL_SIGNIFICAND(mux_o);

    // negation
    `MAKE_SVREAL(neg_o, $size(neg_ext), -10);
    `SVREAL_NEGATE(a, neg_o);
    assign neg_ext = `SVREAL_SIGNIFICAND(neg_o);

    // integer to real
    `MAKE_SVREAL(i2r_o_int, 16, -8);
    `INT_TO_SVREAL(i2r_i_ext, i2r_o_int, $size(i2r_i_ext));
    assign i2r_o_ext = `SVREAL_SIGNIFICAND(i2r_o_int);

    // real to integer
    `SVREAL_TO_INT(a, r2i_o_ext, $size(r2i_o_ext));

    // dff
    `MAKE_SVREAL(dff_o, $size(dff_ext), -10);
    `SVREAL_DFF(a, dff_o, rst_ext, clk_ext, ce_ext, dff_init);
    assign dff_ext = `SVREAL_SIGNIFICAND(dff_o);

    // comparisons
    `SVREAL_LT(a, b, lt_ext);
    `SVREAL_LE(a, b, le_ext);
    `SVREAL_GT(a, b, gt_ext);
    `SVREAL_GE(a, b, ge_ext);

endmodule
