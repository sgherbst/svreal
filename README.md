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

This part of the project is being restructured, stay tuned...
