# AHA imports
import magma as m
import fault

# svreal imports
from .common import pytest_sim_params
from svreal.files import get_file, get_svreal_header

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    metafunc.parametrize('defines', [None, {'FLOAT_REAL': None}])

def test_dff(simulator, defines):
    # declare circuit
    dut = m.DeclareCircuit(
        'test_dff',
        'd_i', fault.RealIn,
        'q_o', fault.RealOut,
        'rst_i', m.BitIn,
        'clk_i', m.BitIn,
        'cke_i', m.BitIn
    )

    # define the test
    tester = fault.Tester(dut, expect_strict_default=True)

    # initialize
    tester.poke(dut.clk_i, 0)
    tester.poke(dut.rst_i, 1)
    tester.poke(dut.cke_i, 1)
    tester.poke(dut.d_i, 2.34)
    tester.eval()

    # check reset value
    tester.poke(dut.clk_i, 1)
    tester.eval()
    tester.expect(dut.q_o, 1.23, abs_tol=0.01)

    # clear reset
    tester.poke(dut.rst_i, 0)
    tester.poke(dut.clk_i, 0)
    tester.eval()
    tester.expect(dut.q_o, 1.23, abs_tol=0.01)

    # clock in first value
    tester.poke(dut.clk_i, 1)
    tester.eval()
    tester.expect(dut.q_o, 2.34, abs_tol=0.01)

    # change input
    tester.poke(dut.d_i, 3.45)
    tester.poke(dut.clk_i, 0)
    tester.eval()
    tester.expect(dut.q_o, 2.34, abs_tol=0.01)

    # clock in second value
    tester.poke(dut.clk_i, 1)
    tester.eval()
    tester.expect(dut.q_o, 3.45, abs_tol=0.01)

    # change input and disable clock enable
    tester.poke(dut.d_i, 4.56)
    tester.poke(dut.clk_i, 0)
    tester.poke(dut.cke_i, 0)
    tester.eval()
    tester.expect(dut.q_o, 3.45, abs_tol=0.01)

    # make sure output doesn't change when the clock is disabled
    tester.poke(dut.clk_i, 1)
    tester.eval()
    tester.expect(dut.q_o, 3.45, abs_tol=0.01)

    # run the test
    tester.compile_and_run(
        target='system-verilog',
        simulator=simulator,
        ext_srcs=[get_file('tests/test_dff.sv')],
        inc_dirs=[get_svreal_header().parent],
        defines=defines,
        parameters={'init': 1.23},
        ext_model_file=True,
        tmp_dir=True
    )