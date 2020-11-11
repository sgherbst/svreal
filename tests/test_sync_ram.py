# AHA imports
import magma as m
import fault

# svreal imports
from .common import *
from svreal import real2fixed, real2recfn, DEF_HARD_FLOAT_WIDTH

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def test_sync_ram(simulator, real_type):
    # determine formatting
    if real_type == RealType.HardFloat:
        width = DEF_HARD_FLOAT_WIDTH
        conv_func = real2recfn
    else:
        width = 18
        exponent = -12
        def conv_func(x):
            return real2fixed(x, exp=exponent)

    # declare circuit
    class dut(m.Circuit):
        name = 'test_sync_ram'
        io = m.IO(
            addr=m.In(m.Bits[2]),
            din=m.In(m.Bits[width]),
            out=fault.RealOut,
            clk=m.ClockIn,
            ce=m.BitIn,
            we=m.BitIn,
        )

    # define the test
    t = SvrealTester(dut, dut.clk)

    # initialize
    t.zero_inputs()
    t.poke(dut.ce, 1)
    t.step(2)

    # write data

    write_order = [1, 0, 3, 2]
    write_data = [1.23, -2.34, 3.45, -4.56]

    t.poke(dut.we, 1)
    for addr in write_order:
        t.poke(dut.addr, addr)
        t.poke(dut.din, conv_func(write_data[addr]))
        t.step(2)

    # read data

    read_order = [0, 3, 2, 1]

    t.poke(dut.we, 0)
    for addr in read_order:
        t.poke(dut.addr, addr)
        t.step(2)
        t.expect(dut.out, write_data[addr], abs_tol=0.001)

    # run the test
    t.compile_and_run(
        get_file('test_sync_ram.sv'),
        simulator=simulator,
        real_type=real_type,
        defines={'WIDTH': width}
    )
