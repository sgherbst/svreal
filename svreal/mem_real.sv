`timescale 1ns / 1ps

`include "real.sv"

`default_nettype none

module mem_real #(
    real init = 0,
    `DECL_REAL(in),
    `DECL_REAL(out)
) (
    `INPUT_REAL(in),
    `OUTPUT_REAL(out),
    input wire logic clk,
    input wire logic rst
);

    // create wires to hold reset and input value,
    // using the output format

    `COPY_FORMAT_REAL(out,   in_aligned);
    `COPY_FORMAT_REAL(out, init_aligned);
    `COPY_FORMAT_REAL(out,  out_aligned);

    // assign reset and input values

    `ASSIGN_REAL(in, in_aligned);
    `ASSIGN_CONST_REAL(init, init_aligned);

    // create the memory unit

    always_ff @(posedge clk) begin
        if (rst == 1'b1) begin
            out_aligned <= init_aligned;
        end else begin
            out_aligned <= in_aligned;
        end
    end

    // assign output 

    `ASSIGN_REAL(out_aligned, out);
                        
endmodule

`default_nettype wire
