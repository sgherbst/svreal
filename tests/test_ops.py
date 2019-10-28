from svreal import get_dir
import subprocess

def print_section(name, text):
    text = text.rstrip()
    if text != '':
        print(f'<{name}>')
        print(text)
        print(f'</{name}>')

def bool_eq(a, b):
    return bool(int(a)) == bool(int(b))

def is_close(a, b, abs_tol=0.01):
    return abs(float(a)-float(b)) <= abs_tol

def parse_stdout(text):
    started = False
    test_no = None
    result = {}
    for line in text.split('\n'):
        line = line.strip()
        if line == 'SVREAL TEST START':
            started = True
            continue
        elif line == 'SVREAL TEST END':
            return result
        elif line.startswith('SVREAL TEST SET'):
            test_no = int(line.split(' ')[3])
            result[test_no] = {}
        elif started and test_no is not None:
            toks = line.split('=')
            result[test_no][toks[0]] = toks[1]
        else:
            pass

def test_ops():
    # run simulation
    cmd = ['vivado', '-mode', 'batch', '-source', 'project.tcl', '-nolog', '-nojournal']
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

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
    test_ops()
    print('Success!')
