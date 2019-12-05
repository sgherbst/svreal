`timescale 1ns/1ps

`include "svreal.sv"

interface svreal #(
    parameter integer width=0,
    parameter integer exponent=0
);
    `DATA_TYPE_REAL(width) value;
    logic [(width+exponent-1):exponent] fmt;
    modport in (input value, input fmt);
    modport out (output value, input fmt);
    function real from_repr();
        `ifdef FLOAT_REAL
            from_repr = value;
        `else
	    	from_repr = `FIXED_TO_FLOAT(value, exponent);
        `endif
    endfunction
    function `DATA_TYPE_REAL(width) to_repr(input real x);
        `ifdef FLOAT_REAL
            to_repr = x;
        `else
		    to_repr = `FLOAT_TO_FIXED(x, exponent);
        `endif
    endfunction
endinterface

module level4 #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c)
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);
    `MUL_INTO_REAL(a, b, c);
endmodule

module level3 (svreal.in a, svreal.in b, svreal.out c);
    generate
        `REAL_FROM_WIDTH_EXP(a_value, $size(a.fmt), $low(a.fmt));
        assign a_value = a.value;
        `REAL_FROM_WIDTH_EXP(b_value, $size(b.fmt), $low(b.fmt));
        assign b_value = b.value;
        `REAL_FROM_WIDTH_EXP(c_value, $size(c.fmt), $low(c.fmt));
        assign c.value = c_value;

        level4 #(
            `PASS_REAL(a, a_value),
            `PASS_REAL(b, b_value),
            `PASS_REAL(c, c_value)
        ) inner (
            .a(a_value),
            .b(b_value),
            .c(c_value)
        );
    endgenerate
endmodule

module level2 (svreal.in a, svreal.in b, svreal.out c);
    level3 inner(.a(a), .b(b), .c(c));
endmodule

module level1 (svreal.in a, svreal.in b, svreal.out c);
    level2 inner(.a(a), .b(b), .c(c));
endmodule

module test_iface_synth(
    input logic signed [15:0] a_value,
    input logic signed [16:0] b_value,
    output logic signed [17:0] c_value
);
    svreal #(.width($size(a_value)), .exponent(-8)) a ();
    svreal #(.width($size(b_value)), .exponent(-9)) b ();
    svreal #(.width($size(c_value)), .exponent(-10)) c ();

    assign a.value = a_value;
    assign b.value = b_value;
    assign c_value = c.value;

    level1 inner (
        .a(a),
        .b(b),
        .c(c)
    );
endmodule
