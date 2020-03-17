# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params, get_file
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [None, {'FLOAT_REAL': None}])

def model_func(a_i, b_i):
    res = {}
    res['lt_o'] = int(a_i < b_i)
    res['le_o'] = int(a_i <= b_i)
    res['gt_o'] = int(a_i > b_i)
    res['ge_o'] = int(a_i >= b_i)
    res['eq_o'] = int(a_i == b_i)
    res['ne_o'] = int(a_i != b_i)

    return res

def test_comp(simulator, defines):
    # declare circuit
    dut = m.DeclareCircuit(
        'test_comp',
        'a_i', fault.RealIn,
        'b_i', fault.RealIn,
        'lt_o', m.BitOut,
        'le_o', m.BitOut,
        'gt_o', m.BitOut,
        'ge_o', m.BitOut,
        'eq_o', m.BitOut,
        'ne_o', m.BitOut
    )

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

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
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('test_comp.sv')],
        inc_dirs=[get_svreal_header().parent],
        defines=defines,
        ext_model_file=True,
        tmp_dir=True
    )
