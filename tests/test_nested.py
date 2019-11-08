from .common import *

TOP = 'test_nested'
PROJECT = 'test_nested'
FILES = ['test_nested.sv']

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc, simulators=['xrun', 'vcs', 'vivado'])
    metafunc.parametrize('defs', [None, ['SVREAL_DEBUG']])

def test_nested(simulator, defs):
    # run sim
    res=run_sim(*FILES, top=TOP, project=PROJECT, simulator=simulator, defs=defs)

    # parse results
    res = parse_stdout(res.stdout)

    # check results
    sec = res[1]
    assert is_close(sec['ti.a'], +1.23)
    assert is_close(sec['ti.b'], +3.45)
    assert is_close(sec['to.a'], +4.68)
    assert is_close(sec['to.b'], -2.22) 
