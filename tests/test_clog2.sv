`timescale 1ns/1ps

`include "svreal.sv"

module test_clog2;

    integer count = 1;
    task test_set(input real x);
        $display("SVREAL TEST SET %0d", count);
        count = count + 1;
        $display("x=%0e", x);
        $display("y=%0d", clog2_math(x));
        #(1ns);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        test_set(4.00);
        test_set(3.00);
        test_set(2.00);
        test_set(1.00);
        test_set(0.50);
        test_set(0.30);
        test_set(0.25);
        test_set(0.20);
        test_set(0.00);
        for (int e=-1000; e<=+1000; e=e+1) begin
            test_set(1.1**e);
        end

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
