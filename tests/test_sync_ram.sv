`timescale 1ns / 1ps

`include "svreal.sv"

module test_sync_ram (
    input [1:0] addr,
    input real in_,
    output real out,
    input clk,
    input ce,
    input we
);
    // wire up the RAM input
    `MAKE_REAL(in_int, 10);
    assign `FORCE_REAL(in_, in_int);

    // instantiate the RAM
    `SYNC_RAM_REAL(addr, in_int, out_int, clk, ce, we, 2, 18, -12);

    // wire up the RAM output
    assign out = `TO_REAL(out_int);
endmodule
