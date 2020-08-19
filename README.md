# svreal
[![Actions Status](https://github.com/sgherbst/svreal/workflows/Regression/badge.svg)](https://github.com/sgherbst/svreal/actions)
[![BuildKite Status](https://badge.buildkite.com/45ed712ae8720e9a3e7c040d2e3bc441a18b6ef269e4573723.svg?branch=master)](https://buildkite.com/stanford-aha/svreal)
[![Code Coverage](https://codecov.io/gh/sgherbst/svreal/branch/master/graph/badge.svg)](https://codecov.io/gh/sgherbst/svreal)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PyPI version](https://badge.fury.io/py/svreal.svg)](https://badge.fury.io/py/svreal)

**svreal** is a SystemVerilog library that makes it easy to perform real-number operations in a synthesizable fashion in SystemVerilog.  Both fixed-point and floating-point representations are supported.  

By default, a fixed-point format is used; the exponent and alignment details are handled automatically, so the user is free to customize the format of each fixed-point signal in the design without inconvenience.  

It is possible to switch to a floating-point representation using one of two compiler flags: **FLOAT_REAL** targets the builtin SystemVerilog **real** type (not synthesizable), whereas **HARD_FLOAT** targets the synthesizable [Berkeley HardFloat](http://www.jhauser.us/arithmetic/HardFloat.html) library.

# Installation

```shell
> pip install svreal
```

If you get a permissions error when running the **pip** command, you can try adding the ```--user``` flag.  This will cause **pip** to install packages in your user directory rather than to a system-wide location.

## HardFloat

If you want to have support for the synthesizable floating-point format, then you'll need to install Berkeley HardFloat.  To do that:
1. Download ``HardFloat-1.zip`` from the [HardFloat website](http://www.jhauser.us/arithmetic/HardFloat.html).
2. Unzip it and move the ``HardFloat-1`` directory into the **svreal** installation directory:
```shell
> unzip HardFloat-1.zip
> python -c 'import svreal; print(svreal.PACK_DIR)'
/path/to/svreal
> mv HardFloat-1 /path/to/svreal/.
```

In case you already have HardFloat installed, or don't want to install it in the **svreal** package directory, you can set the **HARD_FLOAT_INST_DIR** environment variable to the absolute path to the **HardFloat-1** directory.

# Introduction

## Simple example

Here's a simple **svreal** example to get started.  Note that we only have to include a single file, "svreal.sv".  That file is stored in the **site-packages/svreal** directory; its location can be accessed programmatically using the function **svreal.get\_svreal\_header()**.
```verilog
`include "svreal.sv"
`MAKE_REAL(a, 5.0);
`MAKE_GENERIC_REAL(b, 10.0, 42);
`ADD_REAL(a, b, c);
initial begin
    `FORCE_REAL(1.23, a);
    `FORCE_REAL(4.56, b);
    #(1ns);
    `PRINT_REAL(c);
end
```
This creates fixed-point signals **a**, **b**, and **c** and instantiates an adder that sums **a** and **b** into **c**.  In the **initial** block, the values of **a** and **b** are set to "1.23" and "4.56" and then the value of "c" is printed.  Hence, we'd expect that the value of **c** is around "5.79".

## Fixed-point formatting

In **svreal**, fixed-point formats are generally determined automatically from the range of the signals they represent.  In this case, the range of **a** is set to +/- 5.0, and the range of **b** is set to +/- 10.0.  The width of **a** is not specified, so it defaults to **\`LONG_WIDTH_REAL** (which is 25 unless overridden by the user).  For **b**, the user has explicitly specified a width of 42 bits.  In both cases, the exponent used in the representation is automatically determined from the the width and range, using the formula:

```code
exponent = int(ceil(log2(range/(2^(width-1)-1))))
```

This method of selecting the exponent guarantees that the user-specified range can be represented given the width of the fixed-point value.

Since the user has not provided any formatting information for **c**, its range is automatically determined from the ranges of **a** and **b**.  Since **a** is +/- 5.0 and **b** is +/- 10.0, the range of **c** is +/- 15.0.  The width of **c** defaults to **\`LONG_WIDTH_REAL**, and its exponent is calculated using the formula above.

## Floating-point formatting

**svreal** supports synthesizable floating-point operations via [Berkeley HardFloat](http://www.jhauser.us/arithmetic/HardFloat.html).  To switch the real-number representation from fixed-point to floating-point, define the **HARD_FLOAT** flag (e.g., **+define+HARD_FLOAT**).

In order for this to work, you'll need to have installed the HardFloat library as described earlier.  Since HardFloat is installed separately, the simulation or synthesis tool will need to know where the HardFloat headers and source files are located.  To make that straightforward, the **svreal** Python package provides several functions:
1. **get_hard_float_headers**: Returns a list of the absolute paths to the HardFloat Verilog headers.
2. **get_hard_float_sources**: Returns a list of the absolute paths to the HardFloat Verilog source files.
3. **get_hard_float_inc_dirs**: Returns a list of the absolute paths to the directories containing the HardFloat Verilog headers (for use with a command-line argument like **+incdir+**)

In most cases, using **HARD_FLOAT** does not require any code changes.  Although some **svreal** commands specify range, width, or exponent information, those are ignored when using **HARD_FLOAT**, since it uses a single floating-point format (**recfn**) throughout the entire design.

**recfn** is the HardFloat "recoded" format, described in section 5.2 of the [HardFloat documentation](http://www.jhauser.us/arithmetic/HardFloat-1/doc/HardFloat-Verilog.html); it has a 1-to-1 mapping to the IEEE 754 floating-point format but is optimized for better synthesis results.  The user can adjust exponent and significand widths using **HARD_FLOAT_EXP_WIDTH** (default 8) and **HARD_FLOAT_SIG_WIDTH** (default 23), which have the same meaning as **expWidth** and **sigWidth** in the HardFloat documentation.

Although **svreal** mostly handles conversions to and from the **recfn** format, the **svreal** Python module provides the functions **recfn2real** and **real2recfn**.  These conversion functions are useful for tasks like computing the contents of ROMs that store floating-point numbers.

## Debugging

Suppose that the range of **a** is not sufficient to contain the value being assigned to it.  Then **a** may contain an entirely wrong value due to overflow.  In order to debug this problem, define the **FLOAT_REAL** flag (e.g., **+define+FLOAT_REAL**).  This switches the real number representation from fixed-point to float-point, which helps the user to identify whether the fixed-point representation is the cause of the problem, or whether it is something else.  In addition, this flag adds assertions to check if any real-number signal exceeds its specified range.

It is also possible to debug underflow issues using **svreal**.  First set the **FLOAT_REAL** flag to switch to a floating-point representation.  If the problem goes away, but there are no assertion errors indicating overflows, then the problem is likely due to inadequate resolution in one or more **svreal** signals.  This theory can be validated by increasing **\`LONG_WIDTH_REAL** and/or **\`SHORT_WIDTH_REAL**.  If increasing **\`SHORT_WIDTH_REAL** helps, then one or more multiplication constants need to have higher resolution.  Otherwise, one or more fixed-point signals or additive constants need more resolution.

While the **HARD_FLOAT** flag could be used for a similar purpose, since it also switches the real number representation to a floating-point format, **FLOAT_REAL** is generally better for debugging because it simulates faster than **HARD_FLOAT** (at least 10x faster).

## Operations available

Here is a partial list of operations that can be performed with **svreal**:

### Assignment, negation, and absolute value

```verilog
`ASSIGN_REAL(in, out);
`NEGATE_REAL(in, out);
`ABS_REAL(in, out)
```

These operations take one input (first argument) and produce one output (second argument).  Note that \`ASSIGN_REAL should *always* be used in place of a raw **assign** statement.  This is because \`ASSIGN_REAL performs alignment as necessary.

### Arithmetic operations

```verilog
`MIN_REAL(a, b, out);
`MAX_REAL(a, b, out);
`ADD_REAL(a, b, out);
`SUB_REAL(a, b, out);
`MUL_REAL(a, b, out);
```

These operations take two inputs (first and second arguments) and produce one output (third argument).  Note the ordering of the subtraction operation: \`SUB_REAL(a, b, out) means "out := a - b".

### Mux operations

```verilog
`ITE_REAL(cond, val_if_true, val_if_false, out);
```

This is a handy operation when constructing conditional operations: if **cond** is "1", then **val_if_true** is muxed to **out**, otherwise if **cond** is "0", then **val_if_false** is muxed to **out**.  Note that this is not implemented as a literal mux, but instead performs alignment as necessary. Hence, if a fixed-point representation is being used, it's OK if the formats of all three numbers are different.

### Real <-> integer conversion

```verilog
`REAL_TO_INT(in, $size(out), out);
`INT_TO_REAL(in, $size(in), out);
```

Sometimes it is necessary to convert a signed integer into an **svreal** type or vice versa.

The macro \`REAL_TO_INT takes as its first argument an **svreal** type and as its third argument a **logic signed** type.  The second argument is the width of the **logic signed** type (it's left up to the user whether this comes from **$size**, **$bits**, or from a parameter due to simulator quirks).

The macro \`INT_TO_REAL takes as its first argument a **logic signed** type and as its third argument an **svreal** type.  The third argument is the width of the **logic signed** type (it's left up to the user whether this comes from **$size**, **$bits**, or from a parameter due to simulator quirks).

### Comparisons

```verilog
`LT_REAL(lhs, rhs, out);
`LE_REAL(lhs, rhs, out);
`GT_REAL(lhs, rhs, out);
`GE_REAL(lhs, rhs, out);
`EQ_REAL(lhs, rhs, out);
`NE_REAL(lhs, rhs, out);
```

Comparisons always take two real numbers as the first two arguments, ordered as the left-hand side followed by the right-hand side.  The third macro argument is the output, which is a single bit (type **logic**) with value "1" if the comparison is true and "0" if it is false.

### Working with constants

```verilog
`MAKE_CONST_REAL(const, name);
`ASSIGN_CONST_REAL(const, name);
`ADD_CONST_REAL(const, in, out);
`MUL_CONST_REAL(const, in, out);
```

Several functions are available to work with numeric constants.  **\`MAKE_CONST_REAL** creates a new **svreal** type and assigns the given real-number constant to it.  Its width defaults to **\`LONG_WIDTH_REAL** and the exponent is selected automatically based on the constant value.  **\`ASSIGN_CONST_REAL** is similar but does not declare a new **svreal** type; it simply assigns the constant to an existing real-number signal (performing the conversion of the constant to fixed- or floating-point at compile time).

**\`ADD_CONST_REAL** and **\`MUL_CONST_REAL** allow the user to add a constant to a number or multiply a constant by a number, respectively.

When a fixed-point representation is being used, there is one special caveat for **\`MUL_CONST_REAL**: it represents the constant with a fixed-point number of width **\`SHORT_WIDTH_REAL** (18 unless overridden by the user).  As a result, the user can cause **\`MUL_CONST_REAL** to consume exactly one DSP block by picking **\`LONG_WIDTH_REAL** and **\`SHORT_WIDTH_REAL** to be the operand widths of the target FPGA's DSP multipliers.

### Memory

```verilog
`DFF_REAL(d, q, rst, clk, cke, init);
```

Fixed-point memory is implemented as a generic D-type flip-flop (DFF).  The input to this flip-flop is **d**, and the output is **q**.  When a fixed-point format is used, it's OK if **d** and **q** have different formats.

The **rst** signals is a single active-high bit (type **logic**).  It's a synchronous reset, and when active it causes **q** to take the value of **init**.  **init** is simply a real-number value like "1.23".

Finally, **clk** and **cke** are single bit signals (type **logic**).  **clk** is the clock input of the DFF (active on the rising edge), and **cke** is the clock enable signal (active high). 

### Assigning results to existing signals

Most operations have an alternate form that allows the user to assign the result of an operation to an existing real-number signal.  This is indicated by the word **INTO** in the macro name.  For example, suppose that we have defined three signals, **a**, **b**, and **c**, and want to assign the sum of **a** and **b** into **c**:

```verilog
`MAKE_REAL(a, 10.0); // i.e., +/- 10
`MAKE_REAL(b, 21.0); // i.e., +/- 21
`MAKE_REAL(c, 32.0); // i.e., +/- 32
`ADD_INTO_REAL(a, b, c);
```

This special form of the "add" operation will not declare a new signal **c**, but instead will assign the result of the addition to the existing signal called **c** (performing alignment shifts as necessary, of course).

In this case, there is a risk that **c** may have been declared with insufficient range to hold the result.  As mentioned before, this can be debugged using the **FLOAT_REAL** flag, which adds range assertions.  So why would a user ever want to use the **INTO** form of the **svreal** macros?  The most common case is that they are assigning to a signal that appears on the I/O list of the module.  Alternatively, they may want to manually specify the range or resolution of the output signal.  However, a better way to accomplish that is to use the **GENERIC** form of operations, as described in the next section.

### Specifying output resolution

Most operations have an alternate form ending with **GENERIC** that allows the user to specify the width of the result.  Since the range of the operation is determined automatically, this effectively controls the resolution of the operation.  As an example, suppose we want to multiply two signals, but represent the output with more precision than the default.  In that case we could write

```verilog
`MAKE_REAL(a, 10.0); // i.e., +/- 10
`MAKE_REAL(b, 21.0); // i.e., +/- 21
`MUL_REAL_GENERIC(a, b, c, 40);
```

This means: multiply **a** and **b** and store the result in **c** with the appropriate alignment.  The width of **c** is given the custom value "40", and the range of **c** is still determined automatically.  As a result, the user can control the precision of intermediate results, and this in turn is useful when debugging underflow issues.

## Passing real-number signals

Since compile-time parameters are used to store fixed-point formatting information, some care must be taken when passing **svreal** signals through a hierarchy to ensure that information is not lost.  This is not strictly necessary when using **HARD_FLOAT**, but is still good practice because it makes it easier to switch to fixed-point.

Consider this example, in which an outer block instantiates a module that multiplies together two signals to produce an output:

```verilog
`include "svreal.sv"
module inner #(
    `DECL_REAL(in0),
    `DECL_REAL(in1),
    `DECL_REAL(out)
) (
    `INPUT_REAL(in0),
    `INPUT_REAL(in1),
    `OUTPUT_REAL(out)
);
    `MUL_INTO_REAL(in0, in1, out);
endmodule
module outer;
    `MAKE_REAL(a, 10.0); // i.e., +/- 10
    `MAKE_REAL(b, 21.0); // i.e., +/- 21
    `MAKE_REAL(c, 32.0); // i.e., +/- 32

    inner #(
        `PASS_REAL(in0, a),
        `PASS_REAL(in1, b),
        `PASS_REAL(out, c)
    ) inner_i (
        .in0(a),
        .in1(b),
        .out(c)
    );
    ...
endmodule
```

There are a few things to observe here.  First, the parameters and I/O list of the inner module, which has fixed-point I/O, has to be declared in a certain way.  Every fixed-point number in the I/O list (regardless of whether it is an input or an output) needs to have a corresponding **\`DECL_REAL** statement in the parameter list for the module.  This declares all of the parameters needed for that fixed-point signal.  Then, in the I/O list for the module, fixed-point inputs and outputs should be declared using **\`INPUT_REAL** and **\`OUTPUT_REAL**, respectively.

Going up one level to the outer block, observe that a special macro **\`PASS_REAL** is needed to pass parameter information for the fixed-point signals **a**, **b**, and **c** into the inner module.  The syntax of **\`PASS_REAL** is meant to mimick using dot-notation to connect signals to a module instance; that is, the name of the port on the inner module comes first, followed by the name of the local signal.  Finally, note that fixed-point signals are wired up in the I/O list using standard dot notation.

## Using interfaces

Suppose you want to bundle **svreal** signals into an interface.  This might make it easier to pass around groups of real numbers, or allow you to pass digital control signals along with the fixed point numbers.  This task can be achieved using a set of special **svreal** macros.

Here's the simplest such interface, containing a single **svreal** signal and nothing else: 

```verilog
`include "svreal.sv"
interface svreal #(
    `INTF_DECL_REAL(value)
);
    `INTF_MAKE_REAL(value);
    modport in(`MODPORT_IN_REAL(value));
    modport out(`MODPORT_OUT_REAL(value));
endinterface
```

It looks similar to a module declaration that includes **svreal** signals, but there are a few key differences:
  1.  **INTF_DECL_REAL** is used instead of **DECL_REAL**.
  2.  Each **svreal** signal that has been declared in the parameter list needs a corresponding **INTF_MAKE_REAL** statement in the body of the interface.
  3.  When declaring modports for the interface, the **\`MODPORT_IN_REAL** and **\`MODPORT_OUT_REAL** macros must be used to specify that a given **svreal** signal should be treated as an input or an output. 

To work with an **svreal** signal contained in an interface, there are two options: alias the signal to a local name, or pass the signal into a submodule.  Both methods are illustrated below.

### Aliasing an svreal signal contained in an interface to a local name

This is likely the simpler method to use for handwritten code.  As shown in the code sample below, the I/O list for **mymod** directly uses the modports of the **svreal** interface described in the previous section; the macros **DECL_REAL**, **INPUT_REAL**, and **OUTPUT_REAL** are not used.  Inside the module body, however, the "value" signals are aliased to local names using the macros **INTF_INPUT_TO_REAL** and **INTF_OUTPUT_TO_REAL**, at which point all normal **svreal** macros can be used on the local names.  

Crucially, the body of **mymod** needs to be wrapped in a **generate** block.  This is required to avoid bugs in some simulator and synthesis tools related to reading properties out of interfaces.

```verilog
module mymod (
    svreal.in a,
    svreal.in b,
    svreal.out c
); 
    generate
        `INTF_INPUT_TO_REAL(a.value, a_value);
        `INTF_INPUT_TO_REAL(b.value, b_value);
        `INTF_OUTPUT_TO_REAL(c.value, c_value);
        `MUL_INTO_REAL(a_value, b_value, c_value); 
    endgenerate
endmodule

```

### Passing an svreal signal contained in an interface to a submodule

This method is more useful when automatically generating models that use **svreal**.  In the code example below, observe that the **outer** module is just a wrapper for the **inner** module; it breaks out the **svreal** signals contained in interfaces and passes them through to the **inner** module directly.  Hence, there is nothing special about the **inner** module; it contains no references to interfaces or interface macros.

In the **outer** module, however, there are two special requirements.  First, as with the previous method, the body of the module must be wrapped in a **generate** block to ensure proper tool behavior.  Second, when passing signals contained in interfaces, the **INTF_PASS_REAL** macro must be used instead of **PASS_REAL**.

Even though this method is more verbose, it can be handy for generated code, because it decouples implementation of the real-number module from the details of how the incoming signals are bundled.  This allows for two simpler generators (model generator + wrapper generator) rather than one complicated generator.

```verilog
module inner #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c)
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);
    `MUL_INTO_REAL(a, b, c); 
endmodule
module outer (
    svreal.in a,
    svreal.in b,
    svreal.out c
);
    generate
        inner #(
            `INTF_PASS_REAL(a, a.value),
            `INTF_PASS_REAL(b, b.value),
            `INTF_PASS_REAL(c, c.value)
        ) inner_i (
            .a(a.value),
            .b(b.value),
            .c(c.value)
        );
    endgenerate
endmodule
```

# Running the Tests

To test **svreal**, please make sure that at least one of the following simulators is in the system path: 
1. vivado
2. ncsim
3. vcs
4. iverilog

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
