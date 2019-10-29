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
launch_simulation'''

def pytest_sim_params(metafunc):
    if 'simulator' in metafunc.fixturenames:
        targets = []
        for simulator in ['vcs', 'vivado', 'xrun']:
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

def run_synth(tcl, synth):
    if synth == 'vivado':
        return run_vivado_tcl(tcl)
    else:
        raise Exception(f'Unknown synth tool: {synth}.')

def run_vivado_tcl(tcl):
    cmd = ['vivado', '-mode', 'batch', '-source', f'{tcl}', '-nolog', '-nojournal']
    return subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

def run_sim(*files, project, top, defs=None, part='xc7z020clg484-1', simulator='vivado'):
    if simulator == 'vivado':
        return vivado_sim(*files, project=project, top=top, part=part)
    elif simulator == 'xrun':
        return xrun_sim(*files, defs=defs)
    elif simulator == 'vcs':
        return vcs_sim(*files, defs=defs, top=top)
    else:
        raise Exception(f'Invalid simulator: {simulator}.')

def vivado_sim(*files, project, top, part='xc7z020clg484-1'):
    # name the project directory
    proj_name = f'proj_{project}'
    proj_dir = f'tmp/{proj_name}'
    
    # get list of files
    files = [f'add_files "{file_}"' for file_ in files]
    files = '\n'.join(files)

    # write TCL file
    text = VIVADO_SIM_TEMPL.format(proj_name=proj_name, proj_dir=proj_dir, part=part, files=files, top=top)
    tmp_dir = get_dir('tests/tmp')
    tmp_dir.mkdir(exist_ok=True)
    tcl = tmp_dir / f'{project}.tcl'
    with open(tcl, 'w') as f:
        f.write(text)

    # run the command
    return run_vivado_tcl(tcl)

def xrun_sim(*files, defs=None):
    if defs is None:
        defs = []

    cmd = ['xrun']
    cmd += [f'{file_}' for file_ in files]
    cmd += ['+incdir+..']
    cmd += [f'+define+{def_}' for def_ in defs]
    return subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

def vcs_sim(*files, defs=None, top=None):
    if defs is None:
        defs = []

    # compile
    cmd = ['vcs']
    cmd += [f'{file_}' for file_ in files]
    cmd += ['+incdir+..']
    cmd += [f'+define+{def_}' for def_ in defs]
    cmd += ['+systemverilogext+sv']
    if top is not None:
        cmd += ['-top', f'{top}']
    res = subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)

    # run
    cmd = [get_file('tests/simv')]
    return subprocess.run(cmd, cwd=get_dir('tests'), capture_output=True, text=True)
