from svreal import *
from .common import *

def pytest_generate_tests(metafunc):
    pytest_synth_params(metafunc)

def check_text(text):
    assert 'CRITICAL WARNING' not in text
    assert 'FATAL' not in text
    assert 'ERROR' not in text

def test_synth(synth):
    res = run_synth('test_synth.tcl', synth=synth)

    # print results
    print_section('STDOUT', res.stdout)
    print_section('STDERR', res.stderr)

    # check results
    check_text(res.stdout)
    check_text(res.stderr)
