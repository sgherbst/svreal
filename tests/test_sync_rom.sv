`timescale 1ns / 1ps

`include "svreal.sv"

module test_sync_rom (
    input [1:0] addr,
    output real out,
    input clk,
    input ce
);
    `SYNC_ROM_REAL(addr, out_int, clk, ce, 2, 18, `PATH_TO_MEM, -12);
    assign out = `TO_REAL(out_int);
endmodule
