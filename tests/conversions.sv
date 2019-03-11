// Steven Herbst
// sherbst@stanford.edu

// Basic demonstration of artithmetic operations

`timescale 1ns/1ps

`include "real.sv"

`define PRINT_INT(name) $display(`"name = %d`", name)
`define INT_WIDTH 8
`define INT_TYPE logic signed[`INT_WIDTH-1:0]

module top(
    input clk,
    input rst
);
    `MAKE_CONST_REAL(12.3, a);
    `REAL_TO_INT(a, `INT_WIDTH, b);
    
    `MAKE_CONST_REAL(89.8, c);
    `INT_TYPE d;
    `REAL_INTO_INT(c, `INT_WIDTH, d);

    `INT_TYPE e = 'd56;
    `INT_TO_REAL(e, `INT_WIDTH, f);
    
    `INT_TYPE g = 'd45;
    `MAKE_REAL(h, 500);
    `INT_INTO_REAL(g, `INT_WIDTH, h);

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            // nothing
        end else begin
            `PRINT_REAL(a);
            `PRINT_INT(b);

            `PRINT_REAL(c);
            `PRINT_INT(d);

            `PRINT_INT(e);
            `PRINT_REAL(f);

            `PRINT_INT(g);
            `PRINT_REAL(h);
            $finish;
        end
    end
endmodule
