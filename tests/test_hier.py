# AHA imports
import magma as m
import fault

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def test_hier(simulator, real_type):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_hier'
        io = m.IO(
            a_i=fault.RealIn,
            b_i=fault.RealIn,
            c_o=fault.RealOut
        )

    # define the test
    tester = SvrealTester(dut, expect_strict_default=True)

    # initialize
    tester.poke(dut.a_i, 1.23)
    tester.poke(dut.b_i, 4.56)
    tester.eval()
    tester.expect(dut.c_o, 1.23*4.56, abs_tol=0.01)

    # run the test
    tester.compile_and_run(
        simulator=simulator,
        ext_srcs=[get_file('test_hier.sv')],
        real_type=real_type
    )
