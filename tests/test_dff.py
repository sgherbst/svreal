from .common import *

TOP = 'test_dff'
PROJECT = 'test_dff'
FILES = ['test_dff.sv']

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
    assert is_close(sec['d'], +2.34)
    assert is_close(sec['q'], +1.23)
    sec = res[2]
    assert is_close(sec['d'], +2.34)
    assert is_close(sec['q'], +1.23)
    sec = res[3]
    assert is_close(sec['d'], +2.34)
    assert is_close(sec['q'], +2.34)
    sec = res[4]
    assert is_close(sec['d'], +3.45)
    assert is_close(sec['q'], +2.34)
    sec = res[5]
    assert is_close(sec['d'], +3.45)
    assert is_close(sec['q'], +3.45)
    sec = res[6]
    assert is_close(sec['d'], +4.56)
    assert is_close(sec['q'], +3.45)
    sec = res[7]
    assert is_close(sec['d'], +4.56)
    assert is_close(sec['q'], +3.45)
