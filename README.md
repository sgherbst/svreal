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

As shown below, slight differences of a few parts per million may be observed between fixed-point and floating-point implementations, since the default settings assume that fixed-point numbers are 25 bits wide (although their binary point locations are in general different).  If more precision is needed, the width can be increased globally or locally, however FPGA resource utilization may increase.

```shell
> cd svreal/tests
> ./test.py simple.sv --xrun `which xrun`
a = 1.200000
b = 3.400000
c = 4.600000
d = 5.600000
e = 43.679932
f = 200.927673
g = -2.200000
h = 2.200000
i = -2.200000
j = 2.200000
k = 3.400000
{a_gt_b, a_ge_b, a_lt_b, a_le_b}: 0011
> ./test.py simple.sv --float --xrun `which xrun`
a = 1.200000
b = 3.400000
c = 4.600000
d = 5.600000
e = 43.680000
f = 200.928000
g = -2.200000
h = 2.200000
i = -2.200000
j = 2.200000
k = 3.400000
{a_gt_b, a_ge_b, a_lt_b, a_le_b}: 0011
```

## state.sv

This example illustrates how to implement a state variable; a real-valued variable is incremented on each clock edge.  Comparing the results of the floating point and fixed-point simulations, a discrepancy is clear: in the fixed-point case, the state variable overflows and becomes negative.

```shell
> cd svreal/tests
> ./test.py state.sv --xrun `which xrun`
curr = 0.000000
curr = 0.500000
curr = 1.000000
curr = 1.500000
curr = 2.000000
curr = 2.500000
curr = 3.000000
curr = 3.500000
curr = -4.000000
curr = -3.500000
curr = -3.000000
> ./test.py state.sv --float --xrun `which xrun`
curr = 0.000000
curr = 0.500000
curr = 1.000000
curr = 1.500000
curr = 2.000000
curr = 2.500000
curr = 3.000000
curr = 3.500000
curr = 4.000000
curr = 4.500000
curr = 5.000000
```

The problem is that the user has specific a range for the state variable that is too small.  To catch this error, the **--debug** flag can be used.  This option causes assertions to continually monitor real-valued variables to determine if their stated range is exceded.

```shell
> cd svreal/tests
> ./test.py state.sv --float --debug --xrun `which xrun`
curr = 0.000000
curr = 0.500000
curr = 1.000000
curr = 1.500000
curr = 2.000000
curr = 2.500000
Real number 3.500000 out of range (-3.000000 to 3.000000).
```

## module.sv

This file demonstrates how a hierarchical design can be created using **svreal**.  A submodule named **clamp** is defined, which clamps its real-valued input between two limits.

```shell
> cd svreal/tests
> ./test.py module.sv --xrun `which xrun`
clamp_in = -4.000000
clamp_out = -2.500000
clamp_in = -3.000000
clamp_out = -2.500000
clamp_in = -2.000000
clamp_out = -2.000000
clamp_in = -1.000000
clamp_out = -1.000000
clamp_in = 0.000000
clamp_out = 0.000000
clamp_in = 1.000000
clamp_out = 1.000000
clamp_in = 2.000000
clamp_out = 2.000000
clamp_in = 3.000000
clamp_out = 2.500000
clamp_in = 4.000000
clamp_out = 2.500000
```
