# AHA imports
import magma as m
import fault

# svreal imports
from .common import *
from svreal import real2fixed, real2recfn

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def test_sync_ram(simulator, real_type):
    # determine formatting
    if real_type == 'HARD_FLOAT':
        exp_width = 8
        sig_width = 24
        def conv_func(in_):
            return real2recfn(in_=in_, exp_width=exp_width, sig_width=sig_width)
        defines = {
            'WIDTH': exp_width+sig_width+1,
            'EXPONENT': 0,
            'HARD_FLOAT_EXP_WIDTH': exp_width,
            'HARD_FLOAT_SIG_WIDTH': sig_width
        }
    else:
        exponent = -12
        def conv_func(in_):
            return real2fixed(in_=in_, exp=exponent)
        defines = {
            'WIDTH': 18,
            'EXPONENT': exponent
        }

    # declare circuit
    class dut(m.Circuit):
        name = 'test_sync_ram'
        io = m.IO(
            addr=m.In(m.Bits[2]),
            din=m.In(m.Bits[defines['WIDTH']]),
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
        simulator=simulator,
        ext_srcs=[get_file('test_sync_ram.sv')],
        real_type=real_type,
        defines=defines
    )
