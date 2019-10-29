from .common import *

def test_ops_vivado():
    res = vivado_sim('test_ops.tcl')
    process_result(res)

def test_ops_xrun():
    res = xrun_sim('test_ops.sv')
    process_result(res)

def test_ops_vcs():
    res = vcs_sim('test_ops.sv', top='test_ops')
    process_result(res)

def process_result(res):
    # print results
    print_section('STDOUT', res.stdout)
    print_section('STDERR', res.stderr)

    # parse results
    res = parse_stdout(res.stdout)

    # check results
    sec = res[1]
    assert is_close(sec['min_o'], +1.23)
    assert is_close(sec['max_o'], +4.56)
    assert is_close(sec['add_o'], +5.79)
    assert is_close(sec['sub_o'], -3.33)
    assert is_close(sec['mul_o'], +5.6088)
    assert is_close(sec['mux_o'], +1.23)
    assert bool_eq(sec['lt_o'], 1)
    assert bool_eq(sec['le_o'], 1)
    assert bool_eq(sec['gt_o'], 0)
    assert bool_eq(sec['ge_o'], 0)
    sec = res[2]
    assert is_close(sec['mux_o'], +4.56)
    sec = res[3]
    assert bool_eq(sec['lt_o'], 0)
    assert bool_eq(sec['le_o'], 0)
    assert bool_eq(sec['gt_o'], 1)
    assert bool_eq(sec['ge_o'], 1)

if __name__ == '__main__':
    test_ops_xrun()
    #test_ops_vivado()
    print('Success!')
