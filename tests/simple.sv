// Steven Herbst
// sherbst@stanford.edu

// Basic demonstration of artithmetic operations

`timescale 1ns/1ps

`include "real.sv"

module test;
    // addition of two constants
    `MAKE_CONST_REAL(1.2, a);
    `MAKE_CONST_REAL(3.4, b);
    `ADD_REAL(a, b, c);

    // creating a variable with range +/-10, 
    // then assigning a constant to it
    `MAKE_REAL(d, 10);
    `ASSIGN_CONST_REAL(5.6, d);

    // multiplication of constant and variable
    `MUL_CONST_REAL(7.8, d, e);

    // multiplication of two variables
    `MUL_REAL(c, e, f);

    // working with negation
    `ADD_REAL(a, `MINUS_REAL(b), g);
    `ADD_REAL(`MINUS_REAL(a), b, h);

    // max/min operations
    `MIN_REAL(g, h, i);
    `MAX_REAL(g, h, j);

    // ternary operator
    logic cond = 1'b0;
    `ITE_REAL(cond, a, b, k);

    // comparsions
    `GT_REAL(a, b, a_gt_b);
    `GE_REAL(a, b, a_ge_b);
    `LT_REAL(a, b, a_lt_b);
    `LE_REAL(a, b, a_le_b);

    initial begin
        #1;
        `PRINT_REAL(a);
        `PRINT_REAL(b);
        `PRINT_REAL(c);
        `PRINT_REAL(d);
        `PRINT_REAL(e);
        `PRINT_REAL(f);
        `PRINT_REAL(g);
        `PRINT_REAL(h);
        `PRINT_REAL(i);
        `PRINT_REAL(j);
        `PRINT_REAL(k);
        $display("{a_gt_b, a_ge_b, a_lt_b, a_le_b}: %b", {a_gt_b, a_ge_b, a_lt_b, a_le_b});
        $finish;
    end
endmodule
