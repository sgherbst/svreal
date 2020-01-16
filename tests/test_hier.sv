`timescale 1ns / 1ps

`include "svreal.sv"

module level3 #(
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

module level2 #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c)
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);
    level3 #(
        `PASS_REAL(a, a),
        `PASS_REAL(b, b),
        `PASS_REAL(c, c)
    ) inner (
        .a(a),
        .b(b),
        .c(c)
    );
endmodule

module level1 #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c)
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);
    level2 #(
        `PASS_REAL(a, a),
        `PASS_REAL(b, b),
        `PASS_REAL(c, c)
    ) inner (
        .a(a),
        .b(b),
        .c(c)
    );
endmodule

module test_hier(
    input real a_i,
    input real b_i,
    output real c_o
);
    // create a_int signal
    `REAL_FROM_WIDTH_EXP(a_int, 16, -8);
    assign `FORCE_REAL(a_i, a_int);

    // create b_int signal
    `REAL_FROM_WIDTH_EXP(b_int, 17, -9);
    assign `FORCE_REAL(b_i, b_int);

    // create c_int signal
    `REAL_FROM_WIDTH_EXP(c_int, 18, -10);
    assign c_o = `TO_REAL(c_int);

    level1 #(
        `PASS_REAL(a, a_int),
        `PASS_REAL(b, b_int),
        `PASS_REAL(c, c_int)
    ) inner (
        .a(a_int),
        .b(b_int),
        .c(c_int)
    );
endmodule
