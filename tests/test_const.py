# AHA imports
import magma as m
import fault

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def test_const(simulator, real_type):
    # constant definitions
    a_const = 1.23
    b_const = 4.56
    c_const = 7.89

    # declare circuit
    class dut(m.Circuit):
        name = 'test_const'
        io = m.IO(
            a_o=fault.RealOut,
            b_i=fault.RealIn,
            b_o=fault.RealOut,
            c_i=fault.RealIn,
            c_o=fault.RealOut
        )

    # define the test
    tester = SvrealTester(dut)

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
        simulator=simulator,
        ext_srcs=[get_file('test_const.sv')],
        parameters=parameters,
        real_type=real_type
    )
