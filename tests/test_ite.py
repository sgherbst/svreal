# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params, get_file
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [None, {'FLOAT_REAL': None}])

def model_func(a_i, b_i, cond_i):
    return a_i if cond_i else b_i

def test_ite(simulator, defines):
    # declare circuit
    dut = m.DeclareCircuit(
        'test_ite',
        'a_i', fault.RealIn,
        'b_i', fault.RealIn,
        'cond_i', m.BitIn,
        'ite_o', fault.RealOut
    )

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

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
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('test_ite.sv')],
        inc_dirs=[get_svreal_header().parent],
        defines=defines,
        ext_model_file=True,
        tmp_dir=True
    )
