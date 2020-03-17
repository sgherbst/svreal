`timescale 1ns/1ps

`include "svreal.sv"

module test_iface_synth(
    input logic signed [15:0] a_value,
    input logic signed [16:0] b_value,
    output logic signed [17:0] c_value
);
    svreal #(`REAL_INTF_PARAMS(value, $size(a_value), -8)) a ();
    svreal #(`REAL_INTF_PARAMS(value, $size(b_value), -9)) b ();
    svreal #(`REAL_INTF_PARAMS(value, $size(c_value), -10)) c ();

    assign a.value = a_value;
    assign b.value = b_value;
    assign c_value = c.value;

    level1 inner (
        .a(a),
        .b(b),
        .c(c)
    );
endmodule
