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
    res['lt_o'] = int(a_i < b_i)
    res['le_o'] = int(a_i <= b_i)
    res['gt_o'] = int(a_i > b_i)
    res['ge_o'] = int(a_i >= b_i)
    res['eq_o'] = int(a_i == b_i)
    res['ne_o'] = int(a_i != b_i)

    return res

def test_comp(simulator, real_type):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_comp'
        io = m.IO(
            a_i=fault.RealIn,
            b_i=fault.RealIn,
            lt_o=m.BitOut,
            le_o=m.BitOut,
            gt_o=m.BitOut,
            ge_o=m.BitOut,
            eq_o=m.BitOut,
            ne_o=m.BitOut
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
            tester.expect(getattr(dut, key), val)

    # check results with hand-written vectors
    run_iteration(a_i=+1.23, b_i=+4.56)
    run_iteration(a_i=-1.23, b_i=+4.56)
    run_iteration(a_i=-1.23, b_i=-4.56)
    run_iteration(a_i=+1.23, b_i=-4.56)

    run_iteration(a_i=+4.56, b_i=+1.23)
    run_iteration(a_i=-4.56, b_i=+1.23)
    run_iteration(a_i=-4.56, b_i=-1.23)
    run_iteration(a_i=+4.56, b_i=-1.23)

    run_iteration(a_i=+1.23, b_i=+1.23)
    run_iteration(a_i=-1.23, b_i=-1.23)

    # run the test
    tester.compile_and_run(
        get_file('test_comp.sv'),
        simulator=simulator,
        real_type=real_type
    )
