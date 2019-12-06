from .common import *
from math import log2, ceil

TOP = 'test_clog2'
PROJECT = 'test_clog2'
FILES = ['test_clog2.sv']

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)

def model_func(x):
    if x <= 0.0:
        return 0
    else:
        return int(ceil(log2(x)))

def test_math(simulator):
    # run sim
    res=run_sim(*FILES, top=TOP, project=PROJECT, simulator=simulator)

    # parse results
    for elem in parse_stdout(res.stdout).values():
        x = float(elem['x'])
        y = int(elem['y'])
        assert y == model_func(x)
