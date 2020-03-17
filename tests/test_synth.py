# svreal imports
from .common import pytest_synth_params, run_synth, get_file, get_dir
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_synth_params(metafunc)

def test_synth(synth):
    run_synth(synth=synth,
              src_files=[get_file('test_synth.sv')],
              hdr_files=[get_svreal_header()],
              top='test_synth',
              cwd=get_dir('tmp/test_synth')
    )
