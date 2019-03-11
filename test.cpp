// modified from: https://github.com/tommythorn/verilator-demo/blob/master/sim_main.cpp

#include <iostream>

#include "Vtop.h"
#include "verilated.h"

using namespace std;

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    Vtop* top = new Vtop;

    // change rst to "1"
    top->rst = 1;
    top->eval();

    // first clock edge
    top->clk = 1;
    top->eval();

    // change rst to "0"
    top->rst = 0;
    top->eval();

    // run until end of simulation
    while (!Verilated::gotFinish()) {
      top->clk ^= 1;
      top->eval();
    }

    // clean up and exit
    delete top;
    exit(0);
}
