# Introduction

**svreal** is a SystemVerilog library to facilitate real number computation on an FPGA.  The user can switch between a fixed-point implementation (for synthesis or simulation) and a floating point implementation (for simulation) by changing a single flag.  The details of the fixed-point implementation are mostly hidden from the user: it is usually only necessary to define the range of the real-valued state variables and module I/Os.  Common operations such as addition, multiplication, comparison, and conditional assignment are all supported.

# Examples

Several samples are provided in the repository to illustrate the features of the library.

## hello.sv

This first example tests that the simulator can be invoked.

```shell
> cd svreal/tests
> ./test.py hello.sv --xrun `which xrun`
Hello, world!
```

The command should also work with **\`which irun\`**, in case you have Incisive, rather than Xcelium.  

## simple.sv

This example shows the usage of typical operations such as variable creation, addition, and subtraction.  By using the **--float** flag, the user can switch to a floating-point implementation.  This flag will work with any code written using the **svreal** library.

```shell
> cd svreal/tests
> ./test.py simple.sv --xrun `which xrun`
...
> ./test.py simple.sv --float --xrun `which xrun`
...
```

## state.sv

This example illustrates how to implement a state variable; a real-valued variable is incremented on each clock edge.  Comparing the results of the floating point and fixed-point simulations, a discrepancy is clear: in the fixed-point case, the state variable overflows and becomes negative.

```shell
> cd svreal/tests
> ./test.py state.sv --xrun `which xrun`
...
> ./test.py state.sv --float --xrun `which xrun`
...
```

The problem is that the user has specific a range for the state variable that is too small.  To catch this error, the **--debug** flag can be used.  This option causes assertions to continually monitor real-valued variables to determine if their stated range is exceded.

```shell
> cd svreal/tests
> ./test.py state.sv --float --debug --xrun `which xrun`
...
```

## module.sv

This file demonstrates how a hierarchical design can be created using **svreal**.  A submodule named **clamp** is defined, which clamps its real-valued input between two limits.

```shell
> cd svreal/tests
> ./test.py clamp.sv --float --xrun `which xrun`
...
```
