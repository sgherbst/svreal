`timescale 1ns/1ps

`include "math.sv"

`default_nettype none

module dump_real #(
    `DECL_REAL(in),
    parameter filename="out.txt"
) (
    `INPUT_REAL(in),
    input wire logic clk,
    input wire logic rst
);

    integer f;

    initial begin
        f = $fopen(filename, "w");
    end

    always @(posedge clk) begin
        if (rst == 1'b0) begin
            $fwrite(f, "%f\n", `TO_REAL(in));
        end
    end

endmodule

`default_nettype none