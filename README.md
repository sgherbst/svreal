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

Here's a simple **svreal** example to get started.  Note that we only have to include a single file, "svreal.sv":
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

### Assignment and negation

```verilog
`SVREAL_ASSIGN(in, out);
`SVREAL_NEGATE(in, out);
```

These operations take one input (first argument) and produce one output (second argument).  Note that \`SVREAL_ASSIGN should *always* be used in place of a raw **assign** statement.  This is because \`SVREAL_ASSIGN performs alignment as necessary.

### Arithmetic operations

```verilog
`SVREAL_MIN(a, b, out);
`SVREAL_MAX(a, b, out);
`SVREAL_ADD(a, b, out);
`SVREAL_SUB(a, b, out);
`SVREAL_MUL(a, b, out);
```

These operations take two inputs (first and second arguments) and produce one output (third argument).  Note the ordering of the subtraction operation: \`SVREAL_SUB(a, b, out) means "out := a - b".

### Mux operations

```verilog
`SVREAL_MUX(sel, in0, in1, out);
```

This is a handy operation when constructing conditional operations: if **sel** is "0", then **in0** is muxed to **out**, otherwise if **sel** is "1", then **in1** is muxed to **out**.  Note that this is not implemented as a literal mux, but instead performs alignment as necessary. Hence, the formats of all three fixed-point numbers can be different.

### Real <-> integer conversion

```verilog
`SVREAL_TO_INT(in, out, $size(out));
`INT_TO_SVREAL(in, out, $size(in));
```

### Comparisons

```verilog
// comparisons
`SVREAL_LT(lhs, rhs, out);
`SVREAL_LE(lhs, rhs, out);
`SVREAL_GT(lhs, rhs, out);
`SVREAL_GE(lhs, rhs, out);
`SVREAL_EQ(lhs, rhs, out);
`SVREAL_NE(lhs, rhs, out);
```

### Memory

```verilog
```

# Using fixed-point numbers in interfaces

One of the key features of **svreal** is the ability to use one or more fixed-point numbers in an interface.  This makes it much more convenient to pass around bundles of numbers with arbitrary formats.

## Interface with one fixed-point number
The simplest case would be an interface that contains just one fixed-point number and nothing else.  Since this is such a common case, it is built right into the **svreal** library itself.  The following code is an example demonstrating this capability:

```verilog
`include "svreal.sv"
module mytop;
    `MAKE_SVREAL_INTF(a, 16, -8);
    `MAKE_SVREAL_INTF(b, 17, -9);
    `MAKE_SVREAL_INTF(c, 18, -10);
    mymod mymod_i (.a(a), .b(b), .c(c));
endmodule
module mymod (svreal.in a, svreal.in b, svreal.out c);
    generate
        `SVREAL_ALIAS_INPUT(a.value, a_value);
        `SVREAL_ALIAS_INPUT(b.value, b_value);
        `SVREAL_ALIAS_OUTPUT(c.value, c_value);
        `SVREAL_MUL(a_value, b_value, c_value);
    endgenerate
endmodule
```

In **mytop**, we create three instances of the parameterized **svreal** interface with the same formatting as the "simple example" above.  These signals can then be passed directly into **mymod** using the standard verilog dot notation.

Within the **mymod** implementation, note that the directions of **a**, **b**, and **c** are indicated as modports of the parameterized **svreal** interface.  There are two unusual details to be aware of:
1. The body of the **mymod** implementation has to go in a **generate** block.  (This is due to a Vivado-specific bug)
2. The **value** of each of the ports has to be aliased to a local signal name without dots.  (This has to do with how **svreal** generates module and parameter names)
After the I/O aliasing has been done, the user can then perform all **svreal** operations on the aliased signals.

The effect is that passing arbitrary **svreal** types through the hierarchy is straightforward, although performing operations on ports of the **svreal** interface type requires a bit of boilerplate code.

## Custom interface with multiple fixed-point numbers

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
