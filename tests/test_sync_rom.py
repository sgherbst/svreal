# AHA imports
import magma as m
import fault

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def test_sync_rom(simulator, real_type):
    # declare circuit
    class dut(m.Circuit):
        io = m.IO(
            addr=m.In(m.Bits[2]),
            out=fault.RealOut,
            clk=m.ClockIn,
            ce=m.BitIn
        )
        name='test_sync_rom'

    # define the test
    t = SvrealTester(dut, dut.clk)

    # initialize
    t.poke(dut.clk, 0)
    t.poke(dut.ce, 1)
    t.poke(dut.addr, 0)
    t.eval()

    # check output values
    expct = [1.23, -2.34, 3.45, -4.56]
    for k in range(4):
        t.poke(dut.addr, k)
        t.eval()
        t.step(2)
        t.expect(dut.out, expct[k], abs_tol=0.001)

    # disable clock enable and walk through addresses
    t.poke(dut.ce, 0)
    t.eval()
    for k in range(4):
        t.poke(dut.addr, k)
        t.eval()
        t.step(2)
        t.expect(dut.out, expct[-1], abs_tol=0.001)

    # add path to ROM
    path_to_mem = get_file('test_sync_rom.mem').resolve()
    defines = {'PATH_TO_MEM': f'"{path_to_mem}"'}

    # run the test
    t.compile_and_run(
        simulator=simulator,
        ext_srcs=[get_file('test_sync_rom.sv')],
        real_type=real_type,
        defines=defines
    )
