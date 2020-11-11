# generic imports
import numpy as np
from math import log2, floor

# AHA imports
import magma as m

# svreal imports
from .common import *

def pytest_generate_tests(metafunc):
    pytest_sim_params(metafunc)
    pytest_real_type_params(metafunc)

    # set up test vectors
    opts = []

    # width 1
    opts.append((1, list(range(2))))

    # width 8
    opts.append((8, list(range(256))))

    # width 32
    N = 32
    vec = []

    # specifically-chosen entries
    for k in range(0, N-1):
        vec.append((1<<k)-1)
        vec.append((1<<k)+0)
        vec.append((1<<k)+1)
    vec.append((1<<(N-1))-1)
    vec.append(1<<(N-1))

    # pseudo-random entries chosen in a logarithmic fashion
    # the random seed is chosen to make sure this test has
    # consistent result in regression testing
    np.random.seed(1)
    rand_pts = 2**(np.random.uniform(0, N, 100))
    rand_pts = np.floor(rand_pts).astype(np.int)
    rand_pts = [int(elem) for elem in rand_pts]
    vec += rand_pts

    opts.append((N, vec))

    metafunc.parametrize('width,test_vec', opts)

def model_func(r):
    if r == 0:
        return 0
    else:
        x = int(floor(log2(r))) + 1
        y = (r/(1<<(x-1))) - 1
        return x + y

def test_compress_uint(simulator, real_type, width, test_vec):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_compress_uint'
        io = m.IO(
            in_=m.In(m.Bits[width]),
            out = fault.RealOut
        )

    # define the test
    t = SvrealTester(dut)

    for in_ in test_vec:
        t.poke(dut.in_, in_)
        t.eval()
        t.expect(dut.out, model_func(in_), abs_tol=1e-5)

    t.compile_and_run(
        get_file('test_compress_uint.sv'),
        simulator=simulator,
        defines={'WIDTH': width},
        real_type=real_type
    )
