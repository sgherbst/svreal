# AHA imports
import magma as m
import fault

# svreal imports
from .common import *
from svreal import real2fixed, real2recfn, fixed2real, recfn2real

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

def test_sync_rom(simulator, real_type, abs_tol=0.001):
    # determine formatting
    if real_type == 'HARD_FLOAT':
        exp_width = 8
        sig_width = 23
        def conv_func(in_):
            return real2recfn(in_=in_, exp_width=exp_width, sig_width=sig_width)
        def inv_func(in_):
            return recfn2real(in_=in_, exp_width=exp_width, sig_width=sig_width)
        defines = {
            'WIDTH': exp_width+sig_width+1,
            'EXPONENT': 0,
            'HARD_FLOAT_EXP_WIDTH': exp_width,
            'HARD_FLOAT_SIG_WIDTH': sig_width
        }
    else:
        width = 18
        exponent = -12
        def conv_func(in_):
            return real2fixed(in_=in_, exp=exponent, width=width, treat_as_unsigned=True)
        def inv_func(in_):
            return fixed2real(in_=in_, exp=exponent, width=width, treat_as_unsigned=True)
        defines = {
            'WIDTH': width,
            'EXPONENT': exponent
        }

    # write the lookup table
    expct = [1.23, -2.34, 3.45, -4.56]
    path_to_mem = get_file(f'test_sync_rom_{real_type.lower()}.mem').resolve()
    with open(path_to_mem, 'w') as f:
        for elem in expct:
            line = conv_func(elem)  # format input as an integer
            line = bin(line)  # convert to binary string
            line = line.replace('0b', '')  # strip the beginning '0b'
            line = line.rjust(defines['WIDTH'], '0')  # pad to the right width
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

    # add path to ROM
    defines['PATH_TO_MEM'] = f'"{path_to_mem}"'

    # run the test
    t.compile_and_run(
        simulator=simulator,
        ext_srcs=[get_file('test_sync_rom.sv')],
        real_type=real_type,
        defines=defines
    )
