# AHA imports
import magma as m

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)

def test_float(simulator):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_float'
        io = m.IO()

    # define the test
    t = SvrealTester(dut)

    t.zero_inputs()
    t.eval()

    t.compile_and_run(
        simulator=simulator,
        ext_srcs=[get_file('test_float.sv')],
        ext_test_bench=True,
        real_type=RealType.HardFloat
    )
