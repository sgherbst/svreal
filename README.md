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

## Example Descriptions:
* **tests/array.sv**: Illustrates how to make a real-number lookup table using the library.
* **tests/conversions.sv**: Shows how to convert back and forth between integer and real number types.
* **tests/hello.sv**: Simple check to make sure that commands are working correctly.
* **tests/module.sv**: Illustrates how to declare and instantiate modules with real-input inputs.
* **tests/simple.sv**: Demonstrations of artithmetic operations and comparisons.
