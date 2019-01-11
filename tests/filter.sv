// Steven Herbst
// sherbst@stanford.edu

// Illustrating real number state and the assertion system

`timescale 1ns/1ps

`include "real.sv"

module tb #(
    parameter real alpha=0.3
)(
    input wire logic clk,
    input wire logic rst
); 
    // input is a fixed value
    `MAKE_CONST_REAL(1.0, v_in);

    // output has range range +/- 1.5
    `MAKE_REAL(v_out, 1.5);

    // compute the next state as a blend of the input and output
    `MUL_CONST_REAL(alpha, v_in, prod_1);
    `MUL_CONST_REAL(1-alpha, v_out, prod_2);
    `ADD_REAL(prod_1, prod_2, next);

    // update the state on every clock edge
    `MEM_INTO_REAL(next, v_out);
endmodule

module test;
    // clock and reset signals 
    logic clk=1'b0;
    logic rst=1'b1;

    // reset generator
    initial begin
        #2 rst = 1'b0;
    end

    // instantiate the testbench
    tb tb_i(.clk(clk), .rst(rst));

    // clock generator and monitor
    always begin
        #1 clk = 1'b1;
        #1 clk = 1'b0;

        `PRINT_REAL(tb.v_out);
    end

    // simulation termination
    initial begin
        #24;
        $finish;
    end
endmodule
