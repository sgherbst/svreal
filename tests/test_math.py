from .common import *
from math import log2, ceil

TOP = 'test_math'
PROJECT = 'test_math'
FILES = ['test_math.sv']

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)

def test_math(simulator):
    # run sim
    res=run_sim(*FILES, top=TOP, project=PROJECT, simulator=simulator)

    # parse results
    res = parse_stdout(res.stdout)

    # check normal results
    inputs = [4, 3, 2, 1, 0.5, 0.3, 0.25, 0.2]
    for k, inpt in enumerate(inputs):
        assert int(res[k+1]['y']) == int(ceil(log2(inpt)))

    # check exceptional result
    assert int(res[9]['y']) == 0
