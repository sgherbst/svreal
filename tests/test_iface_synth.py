# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_synth_params(metafunc)
    pytest_real_type_params(metafunc, [RealType.FixedPoint, RealType.HardFloat])

def test_synth(synth, real_type):
    run_synth(synth=synth,
              src_files=[get_file('test_iface_core.sv'),
                         get_file('test_iface_synth.sv')],
              real_type=real_type,
              top='test_iface_synth',
              cwd=get_dir('tmp/test_iface_synth')
    )
