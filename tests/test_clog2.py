# generic imports
from math import log2, ceil

# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params, get_file
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)

def model_func(x):
    if x <= 0.0:
        return 0
    else:
        return int(ceil(log2(x)))

def test_math(simulator):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_clog2'
        io = m.IO(
            in_=fault.RealIn,
            out=m.Out(m.SInt[32])
        )

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

    def run_iteration(in_):
        tester.poke(dut.in_, in_)
        tester.eval()
        tester.expect(dut.out, model_func(in_))

    run_iteration(4.00)
    run_iteration(3.00)
    run_iteration(2.00)
    run_iteration(1.00)
    run_iteration(0.50)
    run_iteration(0.30)
    run_iteration(0.25)
    run_iteration(0.20)
    run_iteration(0.00)
    for e in range(-1000, 1000):
        run_iteration(1.1**e)

    tester.compile_and_run(
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('test_clog2.sv')],
        inc_dirs=[get_svreal_header().parent],
        ext_model_file=True,
        tmp_dir=True
    )
