# generic imports
from math import floor
from random import uniform, randint

# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params
from svreal.files import get_file, get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [None, {'FLOAT_REAL': None}])

def model_func(a_i, b_i, i2r_i, cond_i):
    reals = {}
    reals['min_o'] = min(a_i, b_i)
    reals['max_o'] = max(a_i, b_i)
    reals['add_o'] = a_i + b_i
    reals['sub_o'] = a_i - b_i
    reals['mul_o'] = a_i * b_i
    reals['mux_o'] = a_i if cond_i else b_i
    reals['neg_o'] = -a_i
    reals['abs_o'] = abs(a_i)
    reals['i2r_o'] = float(i2r_i)

    ints = {}
    ints['lt_o'] = int(a_i < b_i)
    ints['le_o'] = int(a_i <= b_i)
    ints['gt_o'] = int(a_i > b_i)
    ints['ge_o'] = int(a_i >= b_i)
    ints['r2i_o'] = int(floor(a_i))

    return reals, ints

def test_ops(simulator, defines):
    # declare circuit
    dut = m.DeclareCircuit(
        'test_ops',
        'a_i', fault.RealIn,
        'b_i', fault.RealIn,
        'min_o', fault.RealOut,
        'max_o', fault.RealOut,
        'add_o', fault.RealOut,
        'sub_o', fault.RealOut,
        'mul_o', fault.RealOut,
        'neg_o', fault.RealOut,
        'abs_o', fault.RealOut,
        'cond_i', m.BitIn,
        'mux_o', fault.RealOut,
        'lt_o', m.BitOut,
        'le_o', m.BitOut,
        'gt_o', m.BitOut,
        'ge_o', m.BitOut,
        'r2i_o', m.Out(m.SInt[8]),
        'i2r_i', m.In(m.SInt[8]),
        'i2r_o', fault.RealOut
    )

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

    # generic check routine
    def run_iteration(a_i, b_i, i2r_i, cond_i):
        # print current status
        tester.print(f'a_i: {a_i}, b_i: {b_i}, i2r_i: {i2r_i}, cond_i: {cond_i}\n')

        # poke
        tester.poke(dut.a_i, a_i)
        tester.poke(dut.b_i, b_i)
        tester.poke(dut.i2r_i, i2r_i)
        tester.poke(dut.cond_i, cond_i)
        tester.eval()

        # check results
        reals, ints = model_func(a_i=a_i, b_i=b_i, i2r_i=i2r_i, cond_i=cond_i)
        for key, val in reals.items():
            # skip ambiguous case in which values are slightly different but not equal
            if key in {'lt_o', 'le_o', 'gt_o', 'ge_o'} and (a_i != b_i) and abs((a_i-b_i) < 0.05):
                continue
            else:
                tester.expect(getattr(dut, key), val, rel_tol=0.05, abs_tol=0.05)
        for key, val in ints.items():
            # skip ambiguous case in which the real number is just slightly
            # below a boundary
            if key == 'r2i_o' and (a_i - floor(a_i)) > 0.98:
                continue
            else:
                tester.expect(getattr(dut, key), val)

    # check results with hand-written vectors
    run_iteration(a_i=1.23, b_i=4.56, cond_i=0, i2r_i=78)
    run_iteration(a_i=1.23, b_i=4.56, cond_i=1, i2r_i=78)
    run_iteration(a_i=4.56, b_i=1.23, cond_i=0, i2r_i=78)
    run_iteration(a_i=9.0, b_i=1.23, cond_i=0, i2r_i=78)
    run_iteration(a_i=-1.23, b_i=4.56, cond_i=0, i2r_i=78)
    run_iteration(a_i=1.23, b_i=1.23, cond_i=0, i2r_i=78)

    # check results with randomized inputs
    def random_trial():
        a_i = uniform(-100, 100)
        b_i = uniform(-100, 100)
        i2r_i = randint(-100, 100)
        cond_i = randint(0, 1)
        run_iteration(a_i=a_i, b_i=b_i, i2r_i=i2r_i, cond_i=cond_i)

    for _ in range(100):
        random_trial()

    # run the test
    tester.compile_and_run(
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('tests/test_ops.sv')],
        inc_dirs=[get_svreal_header().parent],
        defines=defines,
        ext_model_file=True,
        tmp_dir=True
    )