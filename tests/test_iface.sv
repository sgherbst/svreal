`timescale 1ns/1ps

`include "svreal.sv"

module test_iface(
    input real a_i,
    input real b_i,
    output real c_o
);
    // create a_int interface
    svreal #(`REAL_INTF_PARAMS(value, 16, -8)) a_int ();
    assign `INTF_FORCE_REAL(a_i, a_int.value);

    // create b_int interface
    svreal #(`REAL_INTF_PARAMS(value, 17, -9)) b_int ();
    assign `INTF_FORCE_REAL(b_i, b_int.value);

    // create c_int interface
    svreal #(`REAL_INTF_PARAMS(value, 18, -10)) c_int ();
    assign c_o = `INTF_TO_REAL(c_int.value);

    level1 inner (
        .a(a_int),
        .b(b_int),
        .c(c_int)
    );
endmodule
