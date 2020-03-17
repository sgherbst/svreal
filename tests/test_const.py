# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params, get_file
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [None, {'FLOAT_REAL': None}])

def test_const(simulator, defines):
    # constant definitions
    a_const = 1.23
    b_const = 4.56
    c_const = 7.89

    # declare circuit
    dut = m.DeclareCircuit(
        'test_const',
        'a_o', fault.RealOut,
        'b_i', fault.RealIn,
        'b_o', fault.RealOut,
        'c_i', fault.RealIn,
        'c_o', fault.RealOut
    )

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

    # test a_o output
    tester.eval()
    tester.expect(dut.a_o, a_const, abs_tol=0.025)

    # test b_o output
    b_i = 2.22
    tester.poke(dut.b_i, b_i)
    tester.eval()
    tester.expect(dut.b_o, b_const * b_i, abs_tol=0.025)

    # test c_o output
    c_i = 3.33
    tester.poke(dut.c_i, c_i)
    tester.eval()
    tester.expect(dut.c_o, c_const + c_i, abs_tol=0.025)

    # set parameter values
    parameters = {}
    parameters['a_const'] = a_const
    parameters['b_const'] = b_const
    parameters['c_const'] = c_const

    # run the test
    tester.compile_and_run(
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('test_const.sv')],
        inc_dirs=[get_svreal_header().parent],
        defines=defines,
        parameters=parameters,
        ext_model_file=True,
        tmp_dir=True
    )
