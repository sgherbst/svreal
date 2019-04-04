# Introduction

**svreal** is a SystemVerilog library to facilitate real number computation on an FPGA.  The user can switch between a fixed-point implementation (for synthesis or simulation) and a floating point implementation (for simulation) by changing a single flag.  The details of the fixed-point implementation are mostly hidden from the user: it is usually only necessary to define the range of the real-valued state variables and module I/Os.  Common operations such as addition, multiplication, comparison, and conditional assignment are all supported.

# Installation

1. Open a terminal, and note the current directory, since the **pip** command below will clone some code from GitHub and place it in a subdirectory called **src**.  If you prefer to place the cloned code in a different directory, you can specify that by providing the **--src** flag to **pip**.
2. Install msdsl:
```shell
> pip install -e git+https://github.com/sgherbst/svreal.git#egg=svreal
```

If you get a permissions error when running the **pip** command, you can try adding the **--user** flag.  This will cause **pip** to install packages in your user directory rather than to a system-wide location.

# Running the Examples

## Installing Verilator
The first step is to install the simulator [Verilator](https://www.veripool.org/wiki/verilator) if it is not already installed:
* Windows: see [these notes](https://gist.github.com/sgherbst/036456f807dc8aa84ffb2493d1536afd).
* Mac (via Homebrew): `brew install verilator`
* Ubuntu Linux: `sudo apt-get install verilator`

## Using Verilator
Each of the examples is contained in a single SystemVerilog file in the **tests** directory.  All tests are run in the same way, namely by specifying the "target" variable of the Makefile that resides at the top level of the project.  For example, the "Hello World" example (which just tests that the environment is set up properly) is run like this from the top-level **svreal** directory:
```shell
> make target=hello
Hello, world!
```

## Example Descriptions:
* **array**: Illustrates how to make a real-number lookup table using the library.
* **conversions**: Shows how to convert back and forth between integer and real number types.
* **hello**: Simple check to make sure that commands are working correctly.
* **module**: Illustrates how to declare and instantiate modules with real-input inputs.
* **simple**: Demonstrations of artithmetic operations and comparisons.

## Other Options:
### Floating-point datatype
All examples can be run using the floating-point datatype **real** from Verilog by defining **FLOAT_REAL**.  More details coming soon...

### Range-checking assertions
Another option is to attach range-checking assertions to all real-number types.  This can be done by defining **DEBUG_REAL**.  In general, it is recommended to define **FLOAT_REAL** whenever **DEBUG_REAL** is setup, since it is otherwise possible for a variable to overflow before itself declared range has been exceeded.  More details coming soon...
