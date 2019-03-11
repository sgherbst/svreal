// Steven Herbst
// sherbst@stanford.edu

// Sanity check for simulation

`timescale 1ns/1ps

module top(
    input clk,
    input rst
);
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            // nothing
        end else begin
            $display("Hello, world!");
            $finish;
        end
    end
endmodule
