from svreal import *
from .common import *

def check_text(text):
    assert 'CRITICAL WARNING' not in text
    assert 'FATAL' not in text
    assert 'ERROR' not in text

def test_vivado():
    res = run_vivado_tcl('test_synth.tcl')
    process_result(res)

def process_result(res):
    # print results
    print_section('STDOUT', res.stdout)
    print_section('STDERR', res.stderr)

    # check results
    check_text(res.stdout)
    check_text(res.stderr)
