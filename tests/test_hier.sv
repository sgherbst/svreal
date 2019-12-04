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

module test_hier;
    `REAL_FROM_WIDTH_EXP(a, 16, -8);
    `REAL_FROM_WIDTH_EXP(b, 17, -9);
    `REAL_FROM_WIDTH_EXP(c, 18, -10);

    level1 #(
        `PASS_REAL(a, a),
        `PASS_REAL(b, b),
        `PASS_REAL(c, c)
    ) inner (
        .a(a),
        .b(b),
        .c(c)
    );

    task print_signals();
        `PRINT_REAL(a);
        `PRINT_REAL(b);
        `PRINT_REAL(c);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        // test set #1
        $display("SVREAL TEST SET 1");
        `FORCE_REAL(1.23, a);
        `FORCE_REAL(4.56, b);
        #(1ns);
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
