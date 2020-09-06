`timescale 1ns/1ps

`include "svreal.sv"

`ifndef WIDTH
    `define WIDTH 8
`endif

module test_compress_uint (
    input [((`WIDTH)-1):0] in_,
    output real out
);
    `COMPRESS_UINT(in_, (`WIDTH), val);
    assign out = `TO_REAL(val);
endmodule
