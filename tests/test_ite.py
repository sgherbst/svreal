# AHA imports
import magma as m
import fault

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def model_func(a_i, b_i, cond_i):
    return a_i if cond_i else b_i

def test_ite(simulator, real_type):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_ite'
        io = m.IO(
            a_i=fault.RealIn,
            b_i=fault.RealIn,
            cond_i=m.BitIn,
            ite_o=fault.RealOut
        )

    # define the test
    tester = SvrealTester(dut)

    # generic check routine
    def run_iteration(a_i, b_i, cond_i):
        # print current status
        tester.print(f'a_i: {a_i}, b_i: {b_i}, cond_i: {cond_i}\n')

        # poke
        tester.poke(dut.a_i, a_i)
        tester.poke(dut.b_i, b_i)
        tester.poke(dut.cond_i, cond_i)
        tester.eval()

        # check results
        expct = model_func(a_i=a_i, b_i=b_i, cond_i=cond_i)
        tester.expect(dut.ite_o, expct, rel_tol=0.05, abs_tol=0.05)

    # check results with hand-written vectors
    for a_i in [-1.23, +1.23]:
        for b_i in [-4.56, +4.56]:
            for cond_i in [0, 1]:
                run_iteration(a_i=a_i, b_i=b_i, cond_i=cond_i)
    for a_i in [-4.56, +4.56]:
        for b_i in [-1.23, +1.23]:
            for cond_i in [0, 1]:
                run_iteration(a_i=a_i, b_i=b_i, cond_i=cond_i)

    # run the test
    tester.compile_and_run(
        get_file('test_ite.sv'),
        simulator=simulator,
        real_type=real_type
    )
