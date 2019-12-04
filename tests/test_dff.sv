`timescale 1ns / 1ps

`include "svreal.sv"

module test_dff;

    `DECL_MATH_FUNCS

    // create signals
    `MAKE_REAL(d, 127.99);

    logic clk, rst, cke;
    `DFF_REAL(d, q, rst, clk, cke, 1.23);

    task print_signals();
        `PRINT_REAL(d);
        `PRINT_REAL(q);
        $display("clk=%0b", clk);
        $display("rst=%0b", rst);
        $display("cke=%0b", cke);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        // read out the reset value
        `FORCE_REAL(2.34, d);
        clk = 1'b0;
        rst = 1'b1;
        cke = 1'b1;
        #(1ns);
        clk = 1'b1;
        #(1ns);
        $display("SVREAL TEST SET 1");
        print_signals();

        // clock in the first value
        `FORCE_REAL(2.34, d);
        clk = 1'b0;
        rst = 1'b0;
        cke = 1'b1;
        #(1ns);
        clk = 1'b1;
        $display("SVREAL TEST SET 2");
        print_signals();
        #(1ns);
        $display("SVREAL TEST SET 3");
        print_signals();

        // clock in the second value
        `FORCE_REAL(3.45, d);
        clk = 1'b0;
        rst = 1'b0;
        cke = 1'b1;
        #(1ns);
        $display("SVREAL TEST SET 4");
        print_signals();
        clk = 1'b1;
        #(1ns);
        $display("SVREAL TEST SET 5");
        print_signals();

        // disable clock
        `FORCE_REAL(4.56, d);
        clk = 1'b0;
        rst = 1'b0;
        cke = 1'b0;
        #(1ns);
        $display("SVREAL TEST SET 6");
        print_signals();
        clk = 1'b1;
        #(1ns);
        $display("SVREAL TEST SET 7");
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
