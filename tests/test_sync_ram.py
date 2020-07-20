# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params, get_file
from svreal import get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [{}, {'FLOAT_REAL': None}])

def test_sync_ram(simulator, defines):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_sync_ram'
        io = m.IO(
            addr=m.In(m.Bits[2]),
            in_=fault.RealIn,
            out=fault.RealOut,
            clk=m.ClockIn,
            ce=m.BitIn,
            we=m.BitIn,
        )

    # define the test
    t = fault.Tester(dut, dut.clk)

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
        t.poke(dut.in_, write_data[addr])
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
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('test_sync_ram.sv')],
        inc_dirs=[get_svreal_header().parent],
        ext_model_file=True
    )
