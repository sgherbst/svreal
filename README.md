# Introduction

**svreal** is a single-file SystemVerilog library that makes it easy to perform fixed-point operations in a synthesizable fashion in SystemVerilog.  The alignment details are handled automatically, so the user is free to customize the format of each fixed-point signal in the design without inconvenience.  For debugging range/resolution issues, the user can switch all signal types to a floating-point representation using a single **define** command-line option.  Supported fixed-point operations include addition, subtraction, negation, multiplication, comparison, and conditional assignment.

# Installation

1. Clone the repository:
```shell
> git clone https://github.com/sgherbst/svreal.git
```
2. Install the corresponding Python3 package:
```shell
> cd svreal
> pip install -e .
```

If you get a permissions error when running the **pip** command, you can try adding the **--user** flag.  This will cause **pip** to install packages in your user directory rather than to a system-wide location.

# Introduction

## Simple example

Here's a simple **svreal** example to get started:
```verilog
`include "svreal.sv"
`MAKE_SVREAL(a, 16, -8);
`MAKE_SVREAL(b, 17, -9);
`MAKE_SVREAL(c, 18, -10);
`SVREAL_ADD(a, b, c);
initial begin
    `SVREAL_SET(a, 1.23);
    `SVREAL_SET(b, 4.56);
    #(0ns);
    `SVREAL_PRINT(c);
end
```
This creates fixed-point signals **a**, **b**, and **c** and instantiates an adder that sums **a** and **b** into **c**.  In the **initial** block, the values of **a** and **b** are set to "1.23" and "4.56" and then the value of "c" is printed.  Hence, we'd expect that the value of **c** is around "5.79".

## Fixed-point formatting

The formats of these three fixed-point signals are all different; **a** has width 16 and exponent -8, **b** has width 17 and exponent -9, and **c** has width 18 and exponent -10.  In **svreal**, the "width" refers to the width of the signed integer used to represent a real number, while the "exponent" refers to the scale factor applied to that integer to produce a real number.  For example, "a" is represented by a 16-bit signed integer and has a scale factor of 2^(-8).  As a result, the range of integers stored in "a" is -32,768 to +32,767, and the scale factor applied to the integer value is about 0.004.  Therefore the real number represented by "a" can range from -128.000 to +127.996 with resolution 0.004.

With this formatting scheme, range is increased by increasing the "width" of an **svreal** value while resolution is increased by making the "exponent" smaller.  Note that changing the "exponent" changes the range unless the "width" is changed to compensate.

Note that the user doesn't have to provide any information about alignment to perform fixed-point addition; that is taken care of by **svreal** under the hood.  In addition, note that it is easy to write fixed-point tests using the \`SVREAL_SET and \`SVREAL_PRINT macros.  Even if the formatting of the fixed-point numbers changes, the test doesn't have to be modified at all.

## Debugging

Suppose that the range of **c** is not sufficient to contain the sum of **a** and **b**.  Then **c** may contain an entirely wrong value due to overflow.  In order to debug this problem, define the **SVREAL_DEBUG** flag (for example, using **+define+SVREAL_DEBUG**).  This switches the real number representation from fixed-point to float-point, which helps the user to identify whether the fixed-point representation is the cause of the problem, or whether it is something else.

## Operations available

Here is a partial list of operations that can be performed with **svreal**:
```verilog
// arithmetic operations
`SVREAL_MIN(a, b, out);
`SVREAL_MAX(a, b, out);
`SVREAL_ADD(a, b, out);
`SVREAL_SUB(a, b, out);
`SVREAL_MUL(a, b, out);
`SVREAL_ASSIGN(in, out);
`SVREAL_NEGATE(in, out);

// mux
`SVREAL_MUX(sel, in0, in1, out);

// real <-> integer
`SVREAL_TO_INT(in, out, $size(out));
`INT_TO_SVREAL(in, out, $size(in));

// comparisons
`SVREAL_LT(lhs, rhs, out);
`SVREAL_LE(lhs, rhs, out);
`SVREAL_GT(lhs, rhs, out);
`SVREAL_GE(lhs, rhs, out);
`SVREAL_EQ(lhs, rhs, out);
`SVREAL_NE(lhs, rhs, out);
```

To see usage examples of all of the fixed-point operations available, please look at the [tests/test_ops.sv](tests/test_ops.sv) file.  The only operation not tested there is the fixed-point memory element, which is tested in [tests/test_dff.sv](tests/test_dff.sv).

# a

# Running the Tests

To test **svreal**, please make sure that at least one of the following simulators is in the system path: 
1. vivado
2. xrun
3. vcs

Then make sure that **pytest** is installed.  If it's not, run the following command:
```shell
> pip install pytest
```

Finally, run **pytest** on the **tests** directory (the "-xs" flag means "stop if there are any failures, and print output from tests as it is available."):
```shell
> pytest -xs tests/
```
This will run as many tests as possible given the tools installed on your system.  For example, if **vivado** is installed, synthesis tests will be run, but if not, only the simulation-based tests will be run.

You can run a specific test of interest like this:
```shell
> pytest -xs tests/test_ops.py
```
