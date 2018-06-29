`timescale 1ns / 1ps

`include "real.sv"

`default_nettype none

module assign_real #(
    `DECL_REAL(in),
    `DECL_REAL(out)
) (
    `INPUT_REAL(in),
    `OUTPUT_REAL(out)
);

    `ifdef FLOAT_REAL
        assign out = in;
    `else
        localparam integer lshift = `EXPONENT_PARAM_REAL(in) - `EXPONENT_PARAM_REAL(out);
    
        generate
            if (lshift >= 0) begin
                assign out = in <<< (+lshift);
            end else begin
                assign out = in >>> (-lshift);
            end
        endgenerate
    `endif

endmodule

`default_nettype wire
