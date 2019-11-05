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

module test_nested; 

    // create signals
    `MAKE_TWO_NUMBER(ti, 16, -8, 17, -9);
    `MAKE_TWO_NUMBER(to, 18, -10, 19, -11);

    // instantiate test module
    mymod mymod_i (
        .ti(ti),
        .to(to)
    );

    // print signals
    task print_signals();
        `SVREAL_PRINT(ti.a);
        `SVREAL_PRINT(ti.b);
        `SVREAL_PRINT(to.a);
        `SVREAL_PRINT(to.b);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        // read out the reset value
        `SVREAL_SET(ti.a, 1.23);
        `SVREAL_SET(ti.b, 3.45);
        #(1ns);
        $display("SVREAL TEST SET 1");
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
