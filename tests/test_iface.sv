`timescale 1ns/1ps

`include "svreal.sv"

module test_iface;
    svreal #(.`WIDTH_PARAM_REAL(value)(16), .`EXPONENT_PARAM_REAL(value)(-8)) a ();
    svreal #(.`WIDTH_PARAM_REAL(value)(17), .`EXPONENT_PARAM_REAL(value)(-9)) b ();
    svreal #(.`WIDTH_PARAM_REAL(value)(18), .`EXPONENT_PARAM_REAL(value)(-10)) c ();

    level1 inner (
        .a(a),
        .b(b),
        .c(c)
    );

    task print_signals();
        `INTF_PRINT_REAL(a.value);
        `INTF_PRINT_REAL(b.value);
        `INTF_PRINT_REAL(c.value);
    endtask

    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        // test set #1
        $display("SVREAL TEST SET 1");
        `INTF_FORCE_REAL(1.23, a.value);
        `INTF_FORCE_REAL(4.56, b.value);
        #(1ns);
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end
endmodule
