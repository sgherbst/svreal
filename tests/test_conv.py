# generic imports
from math import floor

# AHA imports
import magma as m
import fault

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def model_func(r2i_i, i2r_i, real_type):
    # model real -> int conversion
    # the fixed-point mode rounds down, while
    # the HardFloat mode rounds normally
    if real_type == 'HARD_FLOAT':
        r2i_o = int(round(r2i_i))
    else:
        r2i_o = int(floor(r2i_i))

    # model int -> real conversion
    i2r_o = float(i2r_i)

    # return results
    return r2i_o, i2r_o

def test_conv(simulator, real_type):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_conv'
        io = m.IO(
            r2i_i=fault.RealIn,
            r2i_o=m.Out(m.SInt[8]),
            i2r_i=m.In(m.SInt[8]),
            i2r_o=fault.RealOut
        )

    # define the test
    tester = SvrealTester(dut)

    # generic check routine
    def run_iteration(r2i_i, i2r_i=0):
        # print current status
        tester.print(f'r2i_i: {r2i_i}, i2r_i: {i2r_i}\n')

        # poke
        tester.poke(dut.r2i_i, r2i_i)
        tester.poke(dut.i2r_i, i2r_i)
        tester.eval()

        # check results
        r2i_o, i2r_o = model_func(r2i_i=r2i_i, i2r_i=i2r_i, real_type=real_type)
        tester.expect(dut.r2i_o, r2i_o)
        tester.expect(dut.i2r_o, i2r_o, strict=False)

    # basic test with positive and negative values
    run_iteration(r2i_i=+1.0, i2r_i=+2)
    run_iteration(r2i_i=-3.0, i2r_i=-4)

    # test floor operation
    run_iteration(r2i_i=+1.23)
    run_iteration(r2i_i=-2.34)
    run_iteration(r2i_i=+6.78)
    run_iteration(r2i_i=-7.89)

    # run the test
    tester.compile_and_run(
        simulator=simulator,
        ext_srcs=[get_file('test_conv.sv')],
        real_type=real_type
    )
