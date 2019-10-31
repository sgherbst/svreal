`timescale 1ns / 1ps

`include "svreal.sv"

interface two_number #(
    parameter integer a_width=1,
    parameter integer a_exponent=0,
    parameter integer b_width=1,
    parameter integer b_exponent=0
);

    `MAKE_SVREAL(a, a_width, a_exponent);
    `MAKE_SVREAL(b, b_width, b_exponent);

endinterface

module mymod (
    two_number ti,
    two_number to
);

    `SVREAL_COPY_FORMAT(to.a, to_a);
    `SVREAL_COPY_FORMAT(to.b, to_b);

    `SVREAL_ADD(ti.a, ti.b, to_a);
    `SVREAL_SUB(ti.a, ti.b, to_b);

    assign to.a.value = to_a.value;
    assign to.b.value = to_b.value;

endmodule

module test_nested; 

    // create signals
    two_number #(.a_width(16), .a_exponent(-8), .b_width(17), .b_exponent(-9)) ti();
    two_number #(.a_width(18), .a_exponent(-10), .b_width(19), .b_exponent(-11)) to();

    // instantiate test module
    mymod mymod_i (
        .ti(ti),
        .to(to)
    );

    // print signals
    task print_signals();
        `SVREAL_PRINT(ti.a);
        `SVREAL_PRINT(ti.b);
        `SVREAL_PRINT(to.a);
        `SVREAL_PRINT(to.b);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        // read out the reset value
        `SVREAL_SET(ti.a, 1.23);
        `SVREAL_SET(ti.b, 3.45);
        #(1ns);
        $display("SVREAL TEST SET 1");
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
