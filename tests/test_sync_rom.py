# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params, get_file
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [{}, {'FLOAT_REAL': None}])

def test_sync_rom(simulator, defines):
    # declare circuit
    class dut(m.Circuit):
        io = m.IO(
            addr=m.In(m.Bits[2]),
            out=fault.RealOut,
            clk=m.BitIn,
            ce=m.BitIn
        )
        name='test_sync_rom'

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

    # initialize
    tester.poke(dut.clk, 0)
    tester.poke(dut.ce, 1)
    tester.poke(dut.addr, 0)
    tester.eval()

    # check output values
    expct = [1.23, -2.34, 3.45, -4.56]
    for k in range(4):
        tester.poke(dut.addr, k)
        tester.eval()
        tester.poke(dut.clk, 1)
        tester.eval()
        tester.poke(dut.clk, 0)
        tester.eval()
        tester.expect(dut.out, expct[k], abs_tol=0.001)

    # run the test
    defines = defines.copy()
    defines['PATH_TO_MEM'] = get_file('test_sync_rom.mem')
    tester.compile_and_run(
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('test_sync_rom.sv')],
        inc_dirs=[get_svreal_header().parent],
        defines=defines,
        ext_model_file=True
    )
