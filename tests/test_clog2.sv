`timescale 1ns/1ps

`include "svreal.sv"

module test_clog2;

    `DECL_CLOG2_MATH

    task test_set(input real x, input integer n);
        $display("SVREAL TEST SET %0d", n);
        $display("x=%0f", x);
        $display("y=%0d", clog2_math(x));
        #(1ns);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        test_set(4.00, 1);
        test_set(3.00, 2);
        test_set(2.00, 3);
        test_set(1.00, 4);
        test_set(0.50, 5);
        test_set(0.30, 6);
        test_set(0.25, 7);
        test_set(0.20, 8);
        test_set(0.00, 9);

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
