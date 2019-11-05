`timescale 1ns / 1ps

`include "svreal.sv"

interface two_number #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b)
);
    `DECL_SVREAL_TYPE(a, `SVREAL_SIGNIFICAND_WIDTH(a));
    `DECL_SVREAL_TYPE(b, `SVREAL_SIGNIFICAND_WIDTH(b));
    modport in (
        `SVREAL_MODPORT_IN(a),
        `SVREAL_MODPORT_IN(b)
    );
    modport out (
        `SVREAL_MODPORT_OUT(a),
        `SVREAL_MODPORT_OUT(b)
    );
endinterface

`define MAKE_TWO_NUMBER(name, a_width_expr, a_exponent_expr, b_width_expr, b_exponent_expr) \
    two_number #( \
        .`SVREAL_SIGNIFICAND_WIDTH(a)(``a_width_expr``), \
        .`SVREAL_SIGNIFICAND_WIDTH(b)(``b_width_expr``) \
    ) ``name`` (); \
    assign `SVREAL_EXPONENT(``name``.a) = ``a_exponent_expr``; \
    assign `SVREAL_EXPONENT(``name``.b) = ``b_exponent_expr``

module mymod (
    two_number.in ti,
    two_number.out to
);
    generate
        `SVREAL_ALIAS_INPUT(ti.a, ti_a);
        `SVREAL_ALIAS_INPUT(ti.b, ti_b);
        `SVREAL_ALIAS_OUTPUT(to.a, to_a);
        `SVREAL_ALIAS_OUTPUT(to.b, to_b);

        `SVREAL_ADD(ti_a, ti_b, to_a);
        `SVREAL_SUB(ti_a, ti_b, to_b);
    endgenerate
endmodule

module test_nested_synth(
    input wire logic signed [15:0] ti_a,
    input wire logic signed [16:0] ti_b,
    output wire logic signed [17:0] to_a,
    output wire logic signed [18:0] to_b
); 
    // create signals
    `MAKE_TWO_NUMBER(ti, $size(ti_a), -8, $size(ti_b), -9);
    `MAKE_TWO_NUMBER(to, $size(to_a), -10, $size(to_b), -11);

    // instantiate test module
    mymod mymod_i (
        .ti(ti),
        .to(to)
    );

    // wire I/O
    assign `SVREAL_SIGNIFICAND(ti.a) = ti_a;
    assign `SVREAL_SIGNIFICAND(ti.b) = ti_b;
    assign to_a = `SVREAL_SIGNIFICAND(to.a);
    assign to_b = `SVREAL_SIGNIFICAND(to.b);

endmodule
