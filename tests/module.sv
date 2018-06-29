// Steven Herbst
// sherbst@stanford.edu

// Illustrating real number state and the assertion system

`timescale 1ns/1ps

`include "real.sv"

module test;
    // create input variable with range +/- 10
    `MAKE_REAL(clamp_in, 10);

    // create output variable with range +/- 3
    // (i.e., a different format than the input)
    `MAKE_REAL(clamp_out, 3);

    // instantiate the clamp
    clamp #(
        .min(-2.5),
        .max(+2.5),
        `PASS_REAL(in, clamp_in),
        `PASS_REAL(out, clamp_out)
    ) clamp_i (
        .in(clamp_in),
        .out(clamp_out)
    );
        
    // simulation termination
    initial begin
        for (real x=-4; x<=+4; x=x+1) begin
            `FORCE_REAL(x, clamp_in);
            #1;
            `PRINT_REAL(clamp_in);
            `PRINT_REAL(clamp_out);
        end
    end
endmodule

module clamp #(
    real min = -1,
    real max = +1,
    `DECL_REAL(in),
    `DECL_REAL(out)
) (
    `INPUT_REAL(in),
    `OUTPUT_REAL(out)
);

    `MAKE_CONST_REAL(min, min_var);
    `MAKE_CONST_REAL(max, max_var);

    `MAX_REAL(in, min_var, tmp);
    `MIN_INTO_REAL(tmp, max_var, out);

endmodule
