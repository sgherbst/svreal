# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params, get_file
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [None, {'FLOAT_REAL': None}])

def test_hier(simulator, defines):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_hier'
        io = m.IO(
            a_i=fault.RealIn,
            b_i=fault.RealIn,
            c_o=fault.RealOut
        )

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

    # initialize
    tester.poke(dut.a_i, 1.23)
    tester.poke(dut.b_i, 4.56)
    tester.eval()
    tester.expect(dut.c_o, 1.23*4.56, abs_tol=0.01)

    # run the test
    tester.compile_and_run(
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('test_hier.sv')],
        inc_dirs=[get_svreal_header().parent],
        defines=defines,
        ext_model_file=True,
        tmp_dir=True
    )
