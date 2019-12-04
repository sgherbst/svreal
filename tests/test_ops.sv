`timescale 1ns / 1ps

`include "svreal.sv"

module test_ops;

    `DECL_CLOG2_MATH

    // create signals
    `REAL_FROM_WIDTH_EXP(a, 16, -8);
    `REAL_FROM_WIDTH_EXP(b, 17, -9);

    // min
    `MIN_REAL_GENERIC(a, b, min_o, 20);

    // max
    `MAX_REAL_GENERIC(a, b, max_o, 21);

    // add
    `ADD_REAL_GENERIC(a, b, add_o, 22);

    // sub
    `SUB_REAL_GENERIC(a, b, sub_o, 23);

    // mul
    `MUL_REAL_GENERIC(a, b, mul_o, 24);

    // mux
    logic cond;
    `ITE_REAL_GENERIC(cond, a, b, mux_o, 25);

    // negate
    `NEGATE_REAL(a, neg_o);

    // absolute value
    `ABS_REAL(a, abs_o);

    // real to integer
    `REAL_TO_INT(a, 8, r2i_o);

    // integer to real
    logic signed [7:0] i2r_i;
    `INT_TO_REAL(i2r_i, 8, i2r_o);

    // comparisons
    `LT_REAL(a, b, lt_o);
    `LE_REAL(a, b, le_o);
    `GT_REAL(a, b, gt_o);
    `GE_REAL(a, b, ge_o);

    task print_signals();
        `PRINT_REAL(a);
        `PRINT_REAL(b);
        `PRINT_REAL(min_o);
        `PRINT_REAL(max_o);
        `PRINT_REAL(add_o);
        `PRINT_REAL(sub_o);
        `PRINT_REAL(mul_o);
        `PRINT_REAL(mux_o);
        `PRINT_REAL(neg_o);
        `PRINT_REAL(abs_o);
        `PRINT_REAL(i2r_o);
        $display("r2i_o=%0d", r2i_o);
        $display("lt_o=%0b", lt_o);
        $display("le_o=%0b", le_o);
        $display("gt_o=%0b", gt_o);
        $display("ge_o=%0b", ge_o);
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
        cond = 1'b0;
        i2r_i = 78;
        #(1ns);
        print_signals();

        // test set #2
        $display("SVREAL TEST SET 2");
        `FORCE_REAL(1.23, a);
        `FORCE_REAL(4.56, b);
        cond = 1'b1;
        i2r_i = 78;
        #(1ns);
        print_signals();

        // test set #3
        $display("SVREAL TEST SET 3");
        `FORCE_REAL(4.56, a);
        `FORCE_REAL(1.23, b);
        cond = 1'b0;
        i2r_i = 78;
        #(1ns);
        print_signals();

        // test set #4
        $display("SVREAL TEST SET 4");
        `FORCE_REAL(56.0, a);
        `FORCE_REAL(1.23, b);
        cond = 1'b0;
        i2r_i = 78;
        #(1ns);
        print_signals();

        // test set #5
        $display("SVREAL TEST SET 5");
        `FORCE_REAL(-1.23, a);
        `FORCE_REAL(4.56, b);
        cond = 1'b0;
        i2r_i = 78;
        #(1ns);
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
