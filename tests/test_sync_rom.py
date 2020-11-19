# AHA imports
import magma as m
import fault

# svreal imports
from .common import *
from svreal import (real2fixed, real2recfn, fixed2real, recfn2real,
                    DEF_HARD_FLOAT_WIDTH)

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def test_sync_rom(simulator, real_type, abs_tol=0.001):
    # determine formatting
    if real_type == RealType.HardFloat:
        width = DEF_HARD_FLOAT_WIDTH
        conv_func = real2recfn
        inv_func = recfn2real
    else:
        width = 18
        exponent = -12
        def conv_func(x):
            return real2fixed(x, exp=exponent, width=width, treat_as_unsigned=True)
        def inv_func(x):
            return fixed2real(x, exp=exponent, width=width, treat_as_unsigned=True)

    # write the lookup table
    expct = [1.23, -2.34, 3.45, -4.56]
    path_to_mem = get_file(f'test_sync_rom_{real_type.value.lower()}.mem').resolve()
    with open(path_to_mem, 'w') as f:
        for elem in expct:
            line = conv_func(elem)  # format input as an integer
            line = bin(line)  # convert to binary string
            line = line.replace('0b', '')  # strip the beginning '0b'
            line = line.rjust(width, '0')  # pad to the right width
            f.write(line + '\n')

    # verify the lookup table
    with open(path_to_mem, 'r') as f:
        for elem in expct:
            line = f.readline()  # read the next line
            line = line.strip()  # remove whitespace
            line = int(line, 2)  # convert to an integer
            meas = inv_func(line)  # convert to a real number
            assert abs(elem-meas) <= abs_tol, 'Lookup table verification failed'

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
    for k in range(4):
        t.poke(dut.addr, k)
        t.eval()
        t.step(2)
        t.expect(dut.out, expct[k], abs_tol=abs_tol)

    # disable clock enable and walk through addresses
    t.poke(dut.ce, 0)
    t.eval()
    for k in range(4):
        t.poke(dut.addr, k)
        t.eval()
        t.step(2)
        t.expect(dut.out, expct[-1], abs_tol=abs_tol)

    # run the test
    t.compile_and_run(
        get_file('test_sync_rom.sv'),
        simulator=simulator,
        real_type=real_type,
        defines={'PATH_TO_MEM': f'"{path_to_mem}"'}
    )
