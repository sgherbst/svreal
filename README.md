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

The formats of these three fixed-point signals are all different; **a** has width 16 and exponent -8, **b** has width 17 and exponent -9, and **c** has width 18 and exponent -10.  In **svreal**, the "width" refers to the width of the signed integer used to represent a real number, while the "exponent" 

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
