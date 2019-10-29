`timescale 1ns / 1ps

`include "svreal.sv"

module level3 (svreal.in a, svreal.in b, svreal.out c);
    `SVREAL_MUL(a, b, c);
endmodule

module level2 (svreal.in a, svreal.in b, svreal.out c);
    level3 inner(.a(a), .b(b), .c(c));
endmodule

module level1 (svreal.in a, svreal.in b, svreal.out c);
    level2 inner(.a(a), .b(b), .c(c));
endmodule

module test_hier;

    `MAKE_SVREAL(a, 16, -8);
    `MAKE_SVREAL(b, 17, -9);
    `MAKE_SVREAL(c, 18, -10);
    level1 inner(.a(a), .b(b), .c(c));

    task print_signals();
        `SVREAL_PRINT(a);
        `SVREAL_PRINT(b);
        `SVREAL_PRINT(c);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        // test set #1
        $display("SVREAL TEST SET 1");
        `SVREAL_SET(a, 1.23);
        `SVREAL_SET(b, 4.56);
        #(1ns);
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
