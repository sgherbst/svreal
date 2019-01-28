# Introduction

**svreal** is a SystemVerilog library to facilitate real number computation on an FPGA.  The user can switch between a fixed-point implementation (for synthesis or simulation) and a floating point implementation (for simulation) by changing a single flag.  The details of the fixed-point implementation are mostly hidden from the user: it is usually only necessary to define the range of the real-valued state variables and module I/Os.  Common operations such as addition, multiplication, comparison, and conditional assignment are all supported.

# Installation

Clone the **svreal** repository, navigate to the top-level directory, and use **pip** to install the package.

```shell
> git clone https://github.com/sgherbst/svreal/
> cd svreal
> pip install -e .
```

# Running the Examples

## Installing Icarus Verilog
The first step is to install the simulator [Icarus Verilog](http://iverilog.icarus.com) if it is not already installed:
* Windows: use the latest setup binary from [this website](http://bleyer.org/icarus/).
* Mac (via Homebrew): `brew install icarus-verilog`
* Ubuntu Linux: `sudo apt-get install iverilog`

## Using Icarus Verilog
Each of the examples is contained in a single SystemVerilog file in the **tests** directory.  All tests are run in the same way: **iverilog** is first called to compile the Verilog code, and then **vvp** is called on its output to run the simulation.  For example, the "Hello World" example (which just tests that the environment is set up properly) is run like this from the top-level **svreal** directory:
```shell
> iverilog -c test.scr -g2012 tests/hello.sv
> vvp a.out
Hello, world!
```
The `-c test.scr` option specifies a command file that lists the files needed to compile Verilog projects with **svreal**, while the `-g2012` flag enables SystemVerilog support.  **svreal** does use a few features that are specific to SystemVerilog, such as type-casting.  Both options should be used when simulating the examples.
## Example Descriptions:
* **tests/array.sv**: Illustrates how to make a real-number lookup table using the library.
* **tests/conversions.sv**: Shows how to convert back and forth between integer and real number types.
* **tests/hello.sv**: Simple check to make sure that commands are working correctly.
* **tests/module.sv**: Illustrates how to declare and instantiate modules with real-input inputs.
* **tests/simple.sv**: Demonstrations of artithmetic operations and comparisons.

## Other Options:
### Floating-point datatype
All examples can be run using the floating-point datatype **real** from Verilog by defining **FLOAT_REAL**.  For example, here is how to run **tests/simple.sv** using a floating-point datatype:
```shell
> iverilog -c test.scr -g2012 -D FLOAT_REAL tests/hello.sv
> vvp a.out
...
```
### Range-checking assertions
Another option is to attach range-checking assertions to all real-number types.  This can be done by defining **DEBUG_REAL**.  In general, it is recommended to define **FLOAT_REAL** whenever **DEBUG_REAL** is setup, since it is otherwise possible for a variable to overflow before itself declared range has been exceeded.  So, in order to run **tests/simple.sv** with range-checking assertions, try:
```shell
> iverilog -c test.scr -g2012 -D FLOAT_REAL -D DEBUG_REAL tests/hello.sv
> vvp a.out
...
```
