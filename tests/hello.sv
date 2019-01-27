// Steven Herbst
// sherbst@stanford.edu

// Sanity check for simulation

`timescale 1ns/1ps

module top;
    initial begin
        $display("Hello, world!");
        $finish;
    end
endmodule
