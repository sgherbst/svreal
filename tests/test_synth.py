from svreal import *
from .common import *

def pytest_generate_tests(metafunc):
    pytest_synth_params(metafunc)

def test_synth(synth):
    res = run_synth('test_synth.tcl', synth=synth)
