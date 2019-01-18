`timescale 1ns / 1ps

`include "real.sv"
`include "math.sv"

`default_nettype none

module comp_real #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    parameter integer opcode=0
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    output wire logic c
);

    localparam real max_range = `MAX_MATH(`RANGE_PARAM_REAL(a), `RANGE_PARAM_REAL(b));

    `MAKE_REAL(a_aligned, max_range);
    `MAKE_REAL(b_aligned, max_range);

    `ASSIGN_REAL(a, a_aligned);
    `ASSIGN_REAL(b, b_aligned);

    generate
        if          (opcode == `GT_OPCODE_REAL) begin
            assign c = (a_aligned >  b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `GE_OPCODE_REAL) begin
            assign c = (a_aligned >= b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `LT_OPCODE_REAL) begin
            assign c = (a_aligned <  b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `LE_OPCODE_REAL) begin
            assign c = (a_aligned <= b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `EQ_OPCODE_REAL) begin
            assign c = (a_aligned == b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `NE_OPCODE_REAL) begin
            assign c = (a_aligned != b_aligned) ? 1'b1 : 1'b0;
        end else begin
            $error("Invalid opcode.");
        end
    endgenerate
                        
endmodule

`default_nettype wire
