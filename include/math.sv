// Steven Herbst
// sherbst@stanford.edu

// Library of Verilog macros for math functions

`ifndef __MATH_SV__
`define __MATH_SV__

    // MIN_MATH: returns the minimum of "a" and "b"
    `define MIN_MATH(a, b) \
        (((a) <= (b)) ? (a) : (b))

    // MAX_MATH: returns the maximum of "a" and "b"
    `define MAX_MATH(a, b) \
        (((a) >= (b)) ? (a) : (b))

    // ABS_MATH: returns the absolute value of "x"
    `define ABS_MATH(x) \
        `MAX_MATH(-(x), (x))

    // POW2_MATH: returns two to the power of "x"
    `define POW2_MATH(x) \
        (2.0**(1.0*(x)))

    // CLOG2_MATH: returns ceil(log2(x))

    // notes:
    // 1. works for 1e-19 <= x <= 1e19
    // 2. needed because $clog2 doesn't allow a floating point argument
    // 3. in addition, tool support for $clog2 seems to be buggy

    // ref: https://stackoverflow.com/questions/5269634/address-width-from-ram-depth/19737411#19737411
    
    `define CLOG2_ENTRY_MATH(x, pow) \
        ((x) <= `POW2_MATH(pow)) ? (pow) : 

    `define CLOG2_MATH(x) \
     (`CLOG2_ENTRY_MATH(x, -64) \
      `CLOG2_ENTRY_MATH(x, -63) \
      `CLOG2_ENTRY_MATH(x, -62) \
      `CLOG2_ENTRY_MATH(x, -61) \
      `CLOG2_ENTRY_MATH(x, -60) \
      `CLOG2_ENTRY_MATH(x, -59) \
      `CLOG2_ENTRY_MATH(x, -58) \
      `CLOG2_ENTRY_MATH(x, -57) \
      `CLOG2_ENTRY_MATH(x, -56) \
      `CLOG2_ENTRY_MATH(x, -55) \
      `CLOG2_ENTRY_MATH(x, -54) \
      `CLOG2_ENTRY_MATH(x, -53) \
      `CLOG2_ENTRY_MATH(x, -52) \
      `CLOG2_ENTRY_MATH(x, -51) \
      `CLOG2_ENTRY_MATH(x, -50) \
      `CLOG2_ENTRY_MATH(x, -49) \
      `CLOG2_ENTRY_MATH(x, -48) \
      `CLOG2_ENTRY_MATH(x, -47) \
      `CLOG2_ENTRY_MATH(x, -46) \
      `CLOG2_ENTRY_MATH(x, -45) \
      `CLOG2_ENTRY_MATH(x, -44) \
      `CLOG2_ENTRY_MATH(x, -43) \
      `CLOG2_ENTRY_MATH(x, -42) \
      `CLOG2_ENTRY_MATH(x, -41) \
      `CLOG2_ENTRY_MATH(x, -40) \
      `CLOG2_ENTRY_MATH(x, -39) \
      `CLOG2_ENTRY_MATH(x, -38) \
      `CLOG2_ENTRY_MATH(x, -37) \
      `CLOG2_ENTRY_MATH(x, -36) \
      `CLOG2_ENTRY_MATH(x, -35) \
      `CLOG2_ENTRY_MATH(x, -34) \
      `CLOG2_ENTRY_MATH(x, -33) \
      `CLOG2_ENTRY_MATH(x, -32) \
      `CLOG2_ENTRY_MATH(x, -31) \
      `CLOG2_ENTRY_MATH(x, -30) \
      `CLOG2_ENTRY_MATH(x, -29) \
      `CLOG2_ENTRY_MATH(x, -28) \
      `CLOG2_ENTRY_MATH(x, -27) \
      `CLOG2_ENTRY_MATH(x, -26) \
      `CLOG2_ENTRY_MATH(x, -25) \
      `CLOG2_ENTRY_MATH(x, -24) \
      `CLOG2_ENTRY_MATH(x, -23) \
      `CLOG2_ENTRY_MATH(x, -22) \
      `CLOG2_ENTRY_MATH(x, -21) \
      `CLOG2_ENTRY_MATH(x, -20) \
      `CLOG2_ENTRY_MATH(x, -19) \
      `CLOG2_ENTRY_MATH(x, -18) \
      `CLOG2_ENTRY_MATH(x, -17) \
      `CLOG2_ENTRY_MATH(x, -16) \
      `CLOG2_ENTRY_MATH(x, -15) \
      `CLOG2_ENTRY_MATH(x, -14) \
      `CLOG2_ENTRY_MATH(x, -13) \
      `CLOG2_ENTRY_MATH(x, -12) \
      `CLOG2_ENTRY_MATH(x, -11) \
      `CLOG2_ENTRY_MATH(x, -10) \
      `CLOG2_ENTRY_MATH(x, -9) \
      `CLOG2_ENTRY_MATH(x, -8) \
      `CLOG2_ENTRY_MATH(x, -7) \
      `CLOG2_ENTRY_MATH(x, -6) \
      `CLOG2_ENTRY_MATH(x, -5) \
      `CLOG2_ENTRY_MATH(x, -4) \
      `CLOG2_ENTRY_MATH(x, -3) \
      `CLOG2_ENTRY_MATH(x, -2) \
      `CLOG2_ENTRY_MATH(x, -1) \
      `CLOG2_ENTRY_MATH(x, 0) \
      `CLOG2_ENTRY_MATH(x, 1) \
      `CLOG2_ENTRY_MATH(x, 2) \
      `CLOG2_ENTRY_MATH(x, 3) \
      `CLOG2_ENTRY_MATH(x, 4) \
      `CLOG2_ENTRY_MATH(x, 5) \
      `CLOG2_ENTRY_MATH(x, 6) \
      `CLOG2_ENTRY_MATH(x, 7) \
      `CLOG2_ENTRY_MATH(x, 8) \
      `CLOG2_ENTRY_MATH(x, 9) \
      `CLOG2_ENTRY_MATH(x, 10) \
      `CLOG2_ENTRY_MATH(x, 11) \
      `CLOG2_ENTRY_MATH(x, 12) \
      `CLOG2_ENTRY_MATH(x, 13) \
      `CLOG2_ENTRY_MATH(x, 14) \
      `CLOG2_ENTRY_MATH(x, 15) \
      `CLOG2_ENTRY_MATH(x, 16) \
      `CLOG2_ENTRY_MATH(x, 17) \
      `CLOG2_ENTRY_MATH(x, 18) \
      `CLOG2_ENTRY_MATH(x, 19) \
      `CLOG2_ENTRY_MATH(x, 20) \
      `CLOG2_ENTRY_MATH(x, 21) \
      `CLOG2_ENTRY_MATH(x, 22) \
      `CLOG2_ENTRY_MATH(x, 23) \
      `CLOG2_ENTRY_MATH(x, 24) \
      `CLOG2_ENTRY_MATH(x, 25) \
      `CLOG2_ENTRY_MATH(x, 26) \
      `CLOG2_ENTRY_MATH(x, 27) \
      `CLOG2_ENTRY_MATH(x, 28) \
      `CLOG2_ENTRY_MATH(x, 29) \
      `CLOG2_ENTRY_MATH(x, 30) \
      `CLOG2_ENTRY_MATH(x, 31) \
      `CLOG2_ENTRY_MATH(x, 32) \
      `CLOG2_ENTRY_MATH(x, 33) \
      `CLOG2_ENTRY_MATH(x, 34) \
      `CLOG2_ENTRY_MATH(x, 35) \
      `CLOG2_ENTRY_MATH(x, 36) \
      `CLOG2_ENTRY_MATH(x, 37) \
      `CLOG2_ENTRY_MATH(x, 38) \
      `CLOG2_ENTRY_MATH(x, 39) \
      `CLOG2_ENTRY_MATH(x, 40) \
      `CLOG2_ENTRY_MATH(x, 41) \
      `CLOG2_ENTRY_MATH(x, 42) \
      `CLOG2_ENTRY_MATH(x, 43) \
      `CLOG2_ENTRY_MATH(x, 44) \
      `CLOG2_ENTRY_MATH(x, 45) \
      `CLOG2_ENTRY_MATH(x, 46) \
      `CLOG2_ENTRY_MATH(x, 47) \
      `CLOG2_ENTRY_MATH(x, 48) \
      `CLOG2_ENTRY_MATH(x, 49) \
      `CLOG2_ENTRY_MATH(x, 50) \
      `CLOG2_ENTRY_MATH(x, 51) \
      `CLOG2_ENTRY_MATH(x, 52) \
      `CLOG2_ENTRY_MATH(x, 53) \
      `CLOG2_ENTRY_MATH(x, 54) \
      `CLOG2_ENTRY_MATH(x, 55) \
      `CLOG2_ENTRY_MATH(x, 56) \
      `CLOG2_ENTRY_MATH(x, 57) \
      `CLOG2_ENTRY_MATH(x, 58) \
      `CLOG2_ENTRY_MATH(x, 59) \
      `CLOG2_ENTRY_MATH(x, 60) \
      `CLOG2_ENTRY_MATH(x, 61) \
      `CLOG2_ENTRY_MATH(x, 62) \
      `CLOG2_ENTRY_MATH(x, 63) \
      0                 )

`endif
