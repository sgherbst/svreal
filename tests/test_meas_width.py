# generic imports
from math import log2, floor

# AHA imports
import magma as m

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)

def model_func(x):
    if x==0:
        return 0
    else:
        return int(floor(log2(x))) + 1

def test_meas_width(simulator):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_meas_width'
        io = m.IO(
            in_=m.In(m.Bits[8]),
            out = m.Out(m.Bits[8])
        )

    # define the test
    t = SvrealTester(dut)

    for in_ in range(256):
        t.poke(dut.in_, in_)
        t.eval()
        t.expect(dut.out, model_func(in_))

    t.compile_and_run(
        get_file('test_meas_width.sv'),
        simulator=simulator
    )
