`timescale 1ns / 1ps

`include "svreal.sv"

interface two_number #(
    parameter integer a_width=1,
    parameter integer a_exponent=0,
    parameter integer b_width=1,
    parameter integer b_exponent=0
);

    `MAKE_SVREAL(a, a_width, a_exponent);
    `MAKE_SVREAL(b, b_width, b_exponent);

endinterface

module mymod (
    two_number ti,
    two_number to
);

    `SVREAL_COPY_FORMAT(to.a, to_a);
    `SVREAL_COPY_FORMAT(to.b, to_b);

    `SVREAL_ADD(ti.a, ti.b, to_a);
    `SVREAL_SUB(ti.a, ti.b, to_b);

    assign to.a.value = to_a.value;
    assign to.b.value = to_b.value;

endmodule

module test_nested_synth(
    input wire logic signed [15:0] ti_a,
    input wire logic signed [16:0] ti_b,
    output wire logic signed [17:0] to_a,
    output wire logic signed [18:0] to_b
); 

    // create signals
    two_number #(.a_width($size(ti_a)), .a_exponent(-8), .b_width($size(ti_b)), .b_exponent(-9)) ti();
    two_number #(.a_width($size(to_a)), .a_exponent(-10), .b_width($size(to_b)), .b_exponent(-11)) to();

    // instantiate test module
    mymod mymod_i (
        .ti(ti),
        .to(to)
    );

    // wire I/O
    assign ti.a.value = ti_a;
    assign ti.b.value = ti_b;
    assign to_a = to.a.value;
    assign to_b = to.b.value;

endmodule
