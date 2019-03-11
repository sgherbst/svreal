// Steven Herbst
// sherbst@stanford.edu

// Basic demonstration of artithmetic operations

`timescale 1ns/1ps

`include "real.sv"

module top(
    input clk,
    input rst
);
    `MAKE_REAL(coeff, 10);
    
    logic [31:0] addr;
    always @(*) begin
        case (addr[1:0])
            2'b00: `FORCE_REAL(1.2, coeff);
            2'b01: `FORCE_REAL(3.4, coeff);
            2'b10: `FORCE_REAL(5.6, coeff);
            2'b11: `FORCE_REAL(7.8, coeff);
        endcase
    end

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            addr <= 0;
        end else begin
            `PRINT_REAL(coeff);

            if (addr == 'd3) begin
                $finish;
            end else begin
                addr <= addr + 1;
            end
        end
    end
endmodule
