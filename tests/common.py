from svreal import *
from shutil import which
import subprocess

VIVADO_SIM_TEMPL = '''\
create_project -force {proj_name} {proj_dir} -part "{part}"
{files}
add_files "../svreal.sv"
set_property file_type "Verilog Header" [get_files "../svreal.sv"]
set_property -name top -value {top} -objects [get_fileset sim_1]
set_property -name "xsim.simulate.runtime" -value "-all" -objects [get_fileset sim_1]
{vlog_defs}
launch_simulation'''

def pytest_sim_params(metafunc, simulators=None):
    if simulators is None:
        simulators = ['vcs', 'vivado', 'xrun', 'iverilog']

    # parameterize with the simulators available
    if 'simulator' in metafunc.fixturenames:
        targets = []
        for simulator in simulators:
            if which(simulator):
                targets.append(simulator)

        metafunc.parametrize('simulator', targets)

def pytest_synth_params(metafunc):
    if 'synth' in metafunc.fixturenames:
        targets = []
        for synth in ['vivado']:
            if which(synth):
                targets.append(synth)

        metafunc.parametrize('synth', targets)

def check_for_errors(text, lis=None):
    if lis is None:
        lis = []

    for elem in lis:
        assert elem not in text

def check_for_vivado_errors(res):
    lis = ['CRITICAL WARNING', 'ERROR', 'Fatal']
    check_for_errors(res.stdout, lis)
    check_for_errors(res.stderr, lis)

def print_section(name, text):
    text = text.rstrip()
    if text != '':
        print(f'<{name}>')
        print(text)
        print(f'</{name}>')

def print_res(res):
    print_section('STDOUT', res.stdout)
    print_section('STDERR', res.stderr)

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
            toks = line.split('\t')[0].split('=')
            result[test_no][toks[0]] = toks[1]
        else:
            pass

def run_synth(tcl, synth):
    if synth == 'vivado':
        return run_vivado_tcl(tcl)
    else:
        raise Exception(f'Unknown synth tool: {synth}.')

def run_vivado_tcl(tcl):
    cmd = ['vivado', '-mode', 'batch', '-source', f'{tcl}', '-nolog', '-nojournal']
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

    print('*** RUNNING VIVADO TCL SCRIPT ***')
    print_res(res)
    check_for_vivado_errors(res)

    return res

def run_sim(*files, project, top, defs=None, part='xc7z020clg484-1', simulator='vivado'):
    if simulator == 'vivado':
        return vivado_sim(*files, defs=defs, top=top, part=part, project=project)
    elif simulator == 'xrun':
        return xrun_sim(*files, defs=defs, top=top)
    elif simulator == 'vcs':
        return vcs_sim(*files, defs=defs, top=top)
    elif simulator == 'iverilog':
        return iverilog_sim(*files, defs=defs, top=top)
    else:
        raise Exception(f'Invalid simulator: {simulator}.')

def vivado_sim(*files, project, top, part='xc7z020clg484-1', defs=None):
    # name the project directory
    proj_name = f'proj_{project}'
    proj_dir = f'tmp/{proj_name}'
    
    # get list of files
    files = [f'add_files "{file_}"' for file_ in files]
    files = '\n'.join(files)

    # make the command for verilog defines
    if defs is not None:
        vlog_defs = ' '.join(f'{def_}' for def_ in defs)
        vlog_defs = f'set_property -name "verilog_define" -value {{{vlog_defs}}} -objects [get_fileset sim_1]'
    else:
        vlog_defs = ''

    # write TCL file
    text = VIVADO_SIM_TEMPL.format(proj_name=proj_name, proj_dir=proj_dir, part=part, files=files, top=top,
                                   vlog_defs=vlog_defs)
    tmp_dir = get_dir('tests/tmp')
    tmp_dir.mkdir(exist_ok=True)
    tcl = tmp_dir / f'{project}.tcl'
    with open(tcl, 'w') as f:
        f.write(text)

    # run the command
    return run_vivado_tcl(tcl)

def xrun_sim(*files, defs=None, top=None):
    if defs is None:
        defs = []

    cmd = ['xrun']
    cmd += [f'{file_}' for file_ in files]
    cmd += ['+incdir+..']
    cmd += [f'+define+{def_}' for def_ in defs]
    if top is not None:
        cmd += ['-top', f'{top}']
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

    print('*** RUNNING XRUN SIMULATION ***')
    print_res(res)

    return res

def vcs_sim(*files, defs=None, top=None):
    if defs is None:
        defs = []

    ############################
    # compile
    ############################
    cmd = ['vcs']
    cmd += [f'{file_}' for file_ in files]
    cmd += ['+incdir+..']
    cmd += [f'+define+{def_}' for def_ in defs]
    cmd += ['+systemverilogext+sv']
    if top is not None:
        cmd += ['-top', f'{top}']
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

    print('*** COMPILING VCS SIMULATION ***')
    print_res(res)

    ############################
    # run
    ############################
    cmd = [get_file('tests/simv')]
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

    print('*** RUNNING VCS SIMULATION ***')
    print_res(res)

    return res

def iverilog_sim(*files, defs=None, top=None):
    if defs is None:
        defs = []

    ############################
    # compile
    ############################
    cmd = ['iverilog']
    cmd += ['-g2012']
    cmd += ['-I..']
    cmd += [f'-D{def_}' for def_ in defs]
    if top is not None:
        cmd += [f'-s{top}']
    cmd += [f'{file_}' for file_ in files]
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

    print('*** COMPILING IVERILOG SIMULATION ***')
    print_res(res)

    ############################
    # run
    ############################
    cmd = ['vvp', get_file('tests/a.out')]
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

    print('*** RUNNING IVERILOG SIMULATION ***')
    print_res(res)

    return res
