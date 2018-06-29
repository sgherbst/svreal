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
        assert ((min <= `TO_REAL(in)) && (`TO_REAL(in) <= max)) else begin
            $display("Real number %f out of range (%f to %f).", `TO_REAL(in), min, max);
            $fatal;
        end
    end
                        
endmodule

`default_nettype wire
