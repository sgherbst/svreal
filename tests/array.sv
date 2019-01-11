// Steven Herbst
// sherbst@stanford.edu

// Basic demonstration of artithmetic operations

`timescale 1ns/1ps

`include "real.sv"

module test;
    `MAKE_REAL(coeff, 10);
    
    logic [1:0] addr;
    always @(addr) begin
        case (addr)
            2'b00: `FORCE_REAL(1.2, coeff);
            2'b01: `FORCE_REAL(3.4, coeff);
            2'b10: `FORCE_REAL(5.6, coeff);
            2'b11: `FORCE_REAL(7.8, coeff);
        endcase
    end

    initial begin
        for (int i = 0; i < 4; i = i+1) begin
            addr = i;
            #1;
            `PRINT_REAL(coeff);
        end
        $finish;
    end
endmodule
