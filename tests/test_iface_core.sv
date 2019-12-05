`timescale 1ns/1ps

`include "svreal.sv"

interface svreal #(
    `INTF_DECL_REAL(value)
);
    `INTF_MAKE_REAL(value);
    modport in(`MODPORT_IN_REAL(value));
    modport out(`MODPORT_OUT_REAL(value));
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
        `ifndef INTF_USE_LOCAL
            level4 #(
                `INTF_PASS_REAL(a, a.value),
                `INTF_PASS_REAL(b, b.value),
                `INTF_PASS_REAL(c, c.value)
            ) inner (
                .a(a.value),
                .b(b.value),
                .c(c.value)
            );
        `else
            `INTF_INPUT_TO_REAL(a.value, a_value);
            `INTF_INPUT_TO_REAL(b.value, b_value);
            `INTF_OUTPUT_TO_REAL(c.value, c_value);
            level4 #(
                `PASS_REAL(a, a_value),
                `PASS_REAL(b, b_value),
                `PASS_REAL(c, c_value)
            ) inner (
                .a(a_value),
                .b(b_value),
                .c(c_value)
            );
        `endif
    endgenerate
endmodule

module level2 (svreal.in a, svreal.in b, svreal.out c);
    level3 inner(.a(a), .b(b), .c(c));
endmodule

module level1 (svreal.in a, svreal.in b, svreal.out c);
    level2 inner(.a(a), .b(b), .c(c));
endmodule
