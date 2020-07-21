`timescale 1ns / 1ps

`include "svreal.sv"

module test_sync_ram (
    input [1:0] addr,
    input signed [((`WIDTH)-1):0] din,
    output real out,
    input clk,
    input ce,
    input we
);
    // instantiate the RAM
    `SYNC_RAM_REAL(addr, din, out_int, clk, ce, we, 2, `WIDTH, `EXPONENT);

    // wire up the RAM output
    assign out = `TO_REAL(out_int);
endmodule
