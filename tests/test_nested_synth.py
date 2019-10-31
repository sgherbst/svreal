import pytest
from svreal import *
from .common import *

def pytest_generate_tests(metafunc):
    pytest_synth_params(metafunc)

@pytest.mark.skip(reason="no way of currently testing this")
def test_nested_synth(synth):
    res = run_synth('test_nested_synth.tcl', synth=synth)
