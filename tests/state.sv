// Steven Herbst
// sherbst@stanford.edu

// Illustrating real number state and the assertion system

`timescale 1ns/1ps

`include "real.sv"

module test;
    // clock and reset signals 
    logic clk=1'b0, rst=1'b1;

    // create a state variable with range +/-3
    `MAKE_REAL(curr, 3);

    // compute the next state by adding 0.5
    `ADD_CONST_REAL(0.5, curr, next);

    // update the state on every clock edge
    `MEM_INTO_REAL(next, curr);

    // reset generator
    initial begin
        #2 rst = 1'b0;
    end

    // clock generator and monitor
    always begin
        #1 clk = 1'b1;
        #1 clk = 1'b0;

        `PRINT_REAL(curr);
    end

    // simulation termination
    initial begin
        #24;
        $finish;
    end
endmodule
