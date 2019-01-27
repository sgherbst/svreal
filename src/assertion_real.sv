`timescale 1ns / 1ps

`include "real.sv"

`default_nettype none

module assertion_real #(
    `DECL_REAL(in)
) (
    `INPUT_REAL(in)
);

    localparam real min = -(`RANGE_PARAM_REAL(in));
    localparam real max = +(`RANGE_PARAM_REAL(in));

    always @(in) begin
        if (!((min <= `TO_REAL(in)) && (`TO_REAL(in) <= max))) begin
            $display("Real number %f out of range (%f to %f).", `TO_REAL(in), min, max);
            $finish;
        end
    end
                        
endmodule

`default_nettype wire
