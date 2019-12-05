`timescale 1ns/1ps

`include "svreal.sv"

module test_iface;
    svreal #(`REAL_INTF_PARAMS(value, 16, -8)) a ();
    svreal #(`REAL_INTF_PARAMS(value, 17, -9)) b ();
    svreal #(`REAL_INTF_PARAMS(value, 18, -10)) c ();

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
