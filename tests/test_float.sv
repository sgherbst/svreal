`timescale 1ns/1ps

`include "svreal.sv"

module test_float;
    real inf, nan;  // will be assigned during test

    `MAKE_REAL(x, 10); // range is arbitrary for floating point...

    real out;
    assign out = `TO_REAL(x);

    task check_equals(input real a, input real b);
        if (a == b) begin
            $display("%e == %e", a, b);
        end else begin
            $error("%e != %e", a, b);
        end
    endtask

    task check_tol(input real meas, input real expct, input real tol);
        if (((expct-tol)<meas) && (meas<(expct+tol))) begin
            $display("%e is close to %e", meas, expct);
        end else begin
            $error("%e is not close to %e", meas, expct);
        end
    endtask

    function isnan(input real a);
        logic [63:0] data;
        data = $realtobits(a);
        if ((data[62:52] == 11'h7ff) && (data[51:0] != 0)) begin
            return 1;
        end else begin
            return 0;
        end
    endfunction

    initial begin
        // inf and nan need to be assigned like this because
        // Xcelium will error out if we just did inf = 1e1000
        inf = $bitstoreal(64'h7FF0000000000000);
        nan = $bitstoreal(64'h7FF8000000000000);

        `FORCE_REAL(0.0, x);
        #1;
        check_equals(out, 0.0);
        #1;

        `FORCE_REAL(1.23, x);
        #1;
        check_tol(out, 1.23, 1e-5);
        #1;

        `FORCE_REAL(-4.56, x);
        #1;
        check_tol(out, -4.56, 1e-5);
        #1;

        `FORCE_REAL(1e15, x);
        #1;
        check_tol(out, 1e15, 1e9);
        #1;

        `FORCE_REAL(1e-15, x);
        #1;
        check_tol(out, 1e-15, 1e-20);
        #1;

        `FORCE_REAL(1e-40, x);  // double can represent this but not the recoded format
        #1;
        check_equals(out, 0.0);
        #1;

        `FORCE_REAL(1e-100, x);  // double can represent this but not the recoded format
        #1;
        check_equals(out, 0.0);
        #1;

        `FORCE_REAL(1e-315, x);  // subnormal for double; too small for recoded format
        #1;
        check_equals(out, 0.0);
        #1;

        `FORCE_REAL(1e-400, x);  // too small for double and recoded format
        #1;
        check_equals(out, 0.0);
        #1;

        `FORCE_REAL(inf, x);
        #1;
        check_equals(out, inf);
        #1;

        `FORCE_REAL(-inf, x);
        #1;
        check_equals(out, -inf);
        #1;

        `FORCE_REAL(nan, x);
        #1;
        if (isnan(out)) begin
            $display("out is nan");
        end else begin
            $error("out is not nan");
        end
        #1;

        `FORCE_REAL(1e100, x);
        #1;
        check_equals(out, inf);
        #1;

        `FORCE_REAL(-1e100, x);
        #1;
        check_equals(out, -inf);
        #1;

        $finish;
    end
endmodule
