from .common import *

TOP = 'test_hier'
PROJECT = 'test_hier'
FILES = ['test_hier.sv']

def test_vivado():
    res = vivado_sim(*FILES, top=TOP, project=PROJECT)
    process_result(res)

def test_xrun():
    res = xrun_sim(*FILES)
    process_result(res)

def test_vcs():
    res = vcs_sim(*FILES, top=TOP)
    process_result(res)

def process_result(res):
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
