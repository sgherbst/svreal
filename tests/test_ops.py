from .common import *

TOP = 'test_ops'
PROJECT = 'test_ops'
FILES = ['test_ops.sv']

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defs', [None, ['FLOAT_REAL']])

def test_ops(simulator, defs):
    # run sim
    res=run_sim(*FILES, top=TOP, project=PROJECT, simulator=simulator, defs=defs)

    # parse results
    res = parse_stdout(res.stdout)

    # check results
    sec = res[1]
    assert is_close(sec['min_o'], +1.23)
    assert is_close(sec['max_o'], +4.56)
    assert is_close(sec['add_o'], +5.79)
    assert is_close(sec['sub_o'], -3.33)
    assert is_close(sec['mul_o'], +5.6088)
    assert is_close(sec['mux_o'], +4.56)
    assert is_close(sec['neg_o'], -1.23)
    assert bool_eq(sec['lt_o'], 1)
    assert bool_eq(sec['le_o'], 1)
    assert bool_eq(sec['gt_o'], 0)
    assert bool_eq(sec['ge_o'], 0)
    sec = res[2]
    assert is_close(sec['mux_o'], +1.23)
    sec = res[3]
    assert bool_eq(sec['lt_o'], 0)
    assert bool_eq(sec['le_o'], 0)
    assert bool_eq(sec['gt_o'], 1)
    assert bool_eq(sec['ge_o'], 1)
    sec = res[4]
    assert is_close(sec['r2i_o'], 56)
    assert is_close(sec['i2r_o'], 78)
