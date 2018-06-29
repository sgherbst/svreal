`timescale 1ns / 1ps

`include "real.sv"

`default_nettype none

module add_real #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c)
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);

    `COPY_FORMAT_REAL(c, a_aligned);
    `COPY_FORMAT_REAL(c, b_aligned);
    
    `ASSIGN_REAL(a, a_aligned);
    `ASSIGN_REAL(b, b_aligned);
    
    assign c = a_aligned + b_aligned;
                        
endmodule

`default_nettype wire
