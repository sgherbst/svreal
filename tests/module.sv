// Steven Herbst
// sherbst@stanford.edu

// Illustrating real number state and the assertion system

`timescale 1ns/1ps

`include "real.sv"

module top(
    input clk,
    input rst
);
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

    logic [31:0] addr;
    always @(*) begin
        case (addr)
            'd0: `FORCE_REAL(-4.0, clamp_in);
            'd1: `FORCE_REAL(-3.0, clamp_in);
            'd2: `FORCE_REAL(-2.0, clamp_in);
            'd3: `FORCE_REAL(-1.0, clamp_in);
            'd4: `FORCE_REAL( 0.0, clamp_in);
            'd5: `FORCE_REAL(+1.0, clamp_in);
            'd6: `FORCE_REAL(+2.0, clamp_in);
            'd7: `FORCE_REAL(+3.0, clamp_in);
            'd8: `FORCE_REAL(+4.0, clamp_in);
	    default: `FORCE_REAL(0.0, clamp_in);
        endcase
    end

    // apply stimulus
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            addr <= 0;
        end else begin
            `PRINT_REAL(clamp_in);
            `PRINT_REAL(clamp_out);

            if (addr == 'd8) begin
                $finish;
            end else begin
                addr <= addr + 1;
            end
        end
    end
endmodule

module clamp #(
    parameter real min = -1,
    parameter real max = +1,
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
