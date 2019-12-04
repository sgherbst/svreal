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
`MAKE_REAL(a,  5.0);
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

In **svreal**, fixed-point formats are generally determined automatically from the range of the signals they represent.  In this case, the range of **a** is set to +/- 5.0, and the range of **b** is set to +/- 10.0.  The width of **a** is not specified, so it defaults to **\`LONG_WIDTH_REAL** (which is 25 unless overridden by the user).  For **b**, the user has explicitly specified a width of 42.  In both cases, the exponent used in the representation is automatically determined from the the width and range, using the formula:

```code
exponent = int(ceil(log2(range/(2^(width-1)-1))))
```

This method of selecting the exponent guarantees that the user-specified range can be represented given the width of the fixed-point value.

Since the user has not provided any formatting information for **c**, its range is automatically determined from the ranges of **a** and **b**.  Since **a** is +/- 5.0 and **b** is +/- 10.0, the range of **c** is +/- 15.0.  The width of **c** defaults to **\`LONG_WIDTH_REAL**, and its exponent is calculated using the formula above.

## Debugging

Suppose that the range of **c** is not sufficient to contain the sum of **a** and **b**.  Then **c** may contain an entirely wrong value due to overflow.  In order to debug this problem, define the **FLOAT_REAL** flag (for example, using **+define+FLOAT_REAL**).  This switches the real number representation from fixed-point to float-point, which helps the user to identify whether the fixed-point representation is the cause of the problem, or whether it is something else.  In addition, this flag adds assertions to check if any real-number signal exceeds its specified range.

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

This is a handy operation when constructing conditional operations: if **cond** is "1", then **val_if_true** is muxed to **out**, otherwise if **cond** is "0", then **val_if_false** is muxed to **out**.  Note that this is not implemented as a literal mux, but instead performs alignment as necessary. Hence, the formats of all three fixed-point numbers can be different.

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

Comparisons always take two fixed-point numbers as the first two arguments, ordered as the left-hand side followed by the right-hand side.  The third macro argument is the output, which is a single bit (type **logic**) with value "1" if the comparison is true and "0" if it is false.

### Memory

```verilog
`DFF_REAL(d, q, rst, clk, cke, init);
```

Fixed-point memory is implemented as a generic D-type flip-flop (DFF).  The input to this flip-flop is **d**, and the output is **q**.  Both are fixed-point types, but they can have different formats.

The **rst** signals is a single active-high bit (type **logic**).  It's a synchronous reset, and when active it causes **q** to take the value of **init**.  **init** is simply a real-number value like "1.23".

Finally, **clk** and **cke** are single bit signals (type **logic**).  **clk** is the clock input of the DFF (active on the rising edge), and **cke** is the clock enable signal (active high). 

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

Suppose you want to create your own interface containing two **svreal** fixed-point numbers, "a" and "b".  That interface might look like this:
```verilog
interface two_number #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b)
);
    `DECL_SVREAL_TYPE(a, `SVREAL_SIGNIFICAND_WIDTH(a));
    `DECL_SVREAL_TYPE(b, `SVREAL_SIGNIFICAND_WIDTH(b));
    modport in (
        `SVREAL_MODPORT_IN(a),
        `SVREAL_MODPORT_IN(b)
    );
    modport out (
        `SVREAL_MODPORT_OUT(a),
        `SVREAL_MODPORT_OUT(b)
    );
endinterface
```
First we declare the parameters needed to vary the format of "a" and "b".  Then in the body of the interface, we declare signals representing "a" and "b" (namely, the significand and the exponent, although the exponent is constant).  Note that \`MAKE_SVREAL should **not** be used here.  Finally we declare a modport "in" that has "a" and "b" as inputs, and a modport "out" that has "a" and "b" as outputs.  It is not necessary to have all fixed-point signals going in the same direction.

This interface should be thought of as a template for creating your own custom interfaces.  It's a bit complicated, but adding new fixed-point numbers only requires a bit of boilerplate code.  Plus, you're free to add other non fixed-point signals as needed.

To make it convenient to create instances of this interface, you might create a macro like this:
```verilog
`define MAKE_TWO_NUMBER(name, a_width_expr, a_exponent_expr, b_width_expr, b_exponent_expr) \
    two_number #( \
        .`SVREAL_SIGNIFICAND_WIDTH(a)(``a_width_expr``), \
        .`SVREAL_SIGNIFICAND_WIDTH(b)(``b_width_expr``) \
    ) ``name`` (); \
    assign `SVREAL_EXPONENT(``name``.a) = ``a_exponent_expr``; \
    assign `SVREAL_EXPONENT(``name``.b) = ``b_exponent_expr``
```
The key things to observe are that:
1. The width has to be defined as a parameter for each signal.
2. The exponent has to be assigned for each of the fixed-point signals.  Even though the exponent is constant, it is represented as a signal, which is later optimized away by the synthesis tool.

Finally, you can use the interface like this:
```verilog
module mytop;
    `MAKE_TWO_NUMBER(ti, 16, -8, 17, -9);
    `MAKE_TWO_NUMBER(to, 18, -10, 19, -11);
    mymod mymod_i (.ti(ti), .to(to));
endmodule
module mymod (two_number.in ti, two_number.out to);
    generate
        `SVREAL_ALIAS_INPUT(ti.a, ti_a);
        `SVREAL_ALIAS_INPUT(ti.b, ti_b);
        `SVREAL_ALIAS_OUTPUT(to.a, to_a);
        `SVREAL_ALIAS_OUTPUT(to.b, to_b);
        `SVREAL_ADD(ti_a, ti_b, to_a);
        `SVREAL_SUB(ti_a, ti_b, to_b);
    endgenerate
endmodule
```
Crucially, this custom interface can be passed around just as conveniently as the built-in **svreal** type.  Hence, it should be relatively straightforward to embed custom fixed-point types into a design, even if that design is using interfaces to pass around signals.

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
