# AHA imports
import magma as m
import fault

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def model_func(a_i, b_i):
    res = {}
    res['min_o'] = min(a_i, b_i)
    res['max_o'] = max(a_i, b_i)
    res['add_o'] = a_i + b_i
    res['sub_o'] = a_i - b_i
    res['mul_o'] = a_i * b_i
    res['neg_o'] = -a_i
    res['abs_o'] = abs(a_i)

    return res

def test_arith(simulator, real_type):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_arith'
        io = m.IO(
            a_i=fault.RealIn,
            b_i=fault.RealIn,
            min_o=fault.RealOut,
            max_o=fault.RealOut,
            add_o=fault.RealOut,
            sub_o=fault.RealOut,
            mul_o=fault.RealOut,
            neg_o=fault.RealOut,
            abs_o=fault.RealOut
        )

    # define the test
    tester = SvrealTester(dut)

    # generic check routine
    def run_iteration(a_i, b_i):
        # print current status
        tester.print(f'a_i: {a_i}, b_i: {b_i}\n')

        # poke
        tester.poke(dut.a_i, a_i)
        tester.poke(dut.b_i, b_i)
        tester.eval()

        # check results
        res = model_func(a_i=a_i, b_i=b_i)
        for key, val in res.items():
            tester.expect(getattr(dut, key), val, abs_tol=0.05)

    # check results with hand-written vectors
    run_iteration(a_i=+1.23, b_i=+4.56)
    run_iteration(a_i=-1.23, b_i=+4.56)
    run_iteration(a_i=-1.23, b_i=-4.56)
    run_iteration(a_i=+1.23, b_i=-4.56)

    run_iteration(a_i=+4.56, b_i=+1.23)
    run_iteration(a_i=-4.56, b_i=+1.23)
    run_iteration(a_i=-4.56, b_i=-1.23)
    run_iteration(a_i=+4.56, b_i=-1.23)

    # run the test
    tester.compile_and_run(
        simulator=simulator,
        ext_srcs=[get_file('test_arith.sv')],
        real_type=real_type
    )
