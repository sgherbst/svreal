`timescale 1ns / 1ps

`include "svreal.sv"

module level3 (svreal.in a, svreal.in b, svreal.out c);
    svreal_mul_mod #(
        `PASS_SVREAL_PARAMS(a, a.value),
        `PASS_SVREAL_PARAMS(b, b.value),
        `PASS_SVREAL_PARAMS(c, c.value)
    ) mul_i (
        `PASS_SVREAL_SIGNALS(a, a.value),
        `PASS_SVREAL_SIGNALS(b, b.value),
        `PASS_SVREAL_SIGNALS(c, c.value)
    );
endmodule

module level2 (svreal.in a, svreal.in b, svreal.out c);
    level3 inner(.a(a), .b(b), .c(c));
endmodule

module level1 (svreal.in a, svreal.in b, svreal.out c);
    level2 inner(.a(a), .b(b), .c(c));
endmodule

module test_hier;

    `MAKE_SVREAL_INTF(a, 16, -8);
    `MAKE_SVREAL_INTF(b, 17, -9);
    `MAKE_SVREAL_INTF(c, 18, -10);
    level1 inner(.a(a), .b(b), .c(c));

    task print_signals();
        `SVREAL_PRINT(a.value);
        `SVREAL_PRINT(b.value);
        `SVREAL_PRINT(c.value);
    endtask

    // create testbench
    initial begin
        // print header
        $display("SVREAL TEST START");
        #(1ns);

        // test set #1
        $display("SVREAL TEST SET 1");
        `SVREAL_SET(a.value, 1.23);
        `SVREAL_SET(b.value, 4.56);
        #(1ns);
        print_signals();

        // print footer
        $display("SVREAL TEST END");
        #(1ns);
    end

endmodule
