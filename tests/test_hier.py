from .common import *

TOP = 'test_hier'
PROJECT = 'test_hier'
FILES = ['test_hier.sv']

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)

def test_hier(simulator):
    res=run_sim(*FILES, top=TOP, project=PROJECT, simulator=simulator)

    # print results
    print_section('STDOUT', res.stdout)
    print_section('STDERR', res.stderr)

    # parse results
    res = parse_stdout(res.stdout)

    # check results
    sec = res[1]
    assert is_close(sec['a'], +1.23)
    assert is_close(sec['b'], +4.56)
    assert is_close(sec['c'], +5.6088)
