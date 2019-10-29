from svreal import *
import subprocess

def print_section(name, text):
    text = text.rstrip()
    if text != '':
        print(f'<{name}>')
        print(text)
        print(f'</{name}>')

def check_text(text):
    assert 'CRITICAL WARNING' not in text
    assert 'FATAL' not in text
    assert 'ERROR' not in text

def test_synth_vivado():
    cmd = ['vivado', '-mode', 'batch', '-source', 'test_synth.tcl', '-nolog', '-nojournal']
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)
    process_result(res)

def process_result(res):
    # print results
    print_section('STDOUT', res.stdout)
    print_section('STDERR', res.stderr)

    # check results
    check_text(res.stdout)
    check_text(res.stderr)

if __name__ == '__main__':
    test_synth_vivado()
    print('Success!')
