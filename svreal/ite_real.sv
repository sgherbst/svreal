`timescale 1ns / 1ps

`include "real.sv"

`default_nettype none

module ite_real #(
    `DECL_REAL(true),
    `DECL_REAL(false),
    `DECL_REAL(out)
) (
    input wire logic cond,
    `INPUT_REAL(true),
    `INPUT_REAL(false),
    `OUTPUT_REAL(out)
);

    `COPY_FORMAT_REAL(out,  true_aligned);
    `COPY_FORMAT_REAL(out, false_aligned);

    `ASSIGN_REAL(true,   true_aligned);
    `ASSIGN_REAL(false, false_aligned);

    assign out = (cond == 1'b1) ? true_aligned : false_aligned;

endmodule

`default_nettype wire
