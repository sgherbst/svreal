`timescale 1ns / 1ps

`include "real.sv"

`default_nettype none

module mul_real #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c)
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);

    // create wire to hold product result
    `MAKE_FORMAT_REAL(
        prod, 
        `RANGE_PARAM_REAL(a) * `RANGE_PARAM_REAL(b),
        `WIDTH_PARAM_REAL(a) + `WIDTH_PARAM_REAL(b),
        `EXPONENT_PARAM_REAL(a) + `EXPONENT_PARAM_REAL(b)
    );

    // compute product
    assign prod = a * b;
  
    // assign result to output (which will left/right shift if necessary)
    `ASSIGN_REAL(prod, c);
                        
endmodule

`default_nettype wire
