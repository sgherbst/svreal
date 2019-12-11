# generic imports
from shutil import which
from pathlib import Path

# AHA imports
from fault.subprocess_run import subprocess_run

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

def run_synth(synth, top=None, cwd='build', src_files=None, hdr_files=None):
    # set defaults
    if src_files is None:
        src_files = []
    if hdr_files is None:
        hdr_files = []

    # run synthesis using the desired tool
    if synth == 'vivado':
        return run_vivado_synth(top=top, cwd=cwd, src_files=src_files,
                                hdr_files=hdr_files)
    else:
        raise Exception(f'Unknown synth tool: {synth}.')

def run_vivado_synth(top, cwd, src_files, hdr_files, part='xc7z020clg484-1',
                     proj_name='project'):
    lines = []

    # create the project at the desired location
    proj_dir = Path(cwd) / proj_name
    lines += [f'create_project -force "{proj_name}" "{proj_dir}" -part "{part}"']

    # add source and header files
    lines += [f'add_files "{file}"' for file in hdr_files+src_files]

    # identify header files
    lines += [f'set_property file_type "Verilog Header" [get_files "{hdr_file}"]' for hdr_file in hdr_files]

    # set top module
    if top is not None:
        lines += [f'set_property -name top -value {top} -objects [current_fileset]']
    else:
        # if top is not specified, let Vivado pick...
        lines += ['update_compile_order -fileset [current_fileset]']

    # run synthesis
    lines += ['launch_runs synth_1']
    lines += ['wait_on_run synth_1']

    # write to a script
    tcl_file = Path(cwd) / 'synth.tcl'
    tcl_file.parent.mkdir(exist_ok=True, parents=True)
    with open(tcl_file, 'w') as f:
        f.write('\n'.join(lines))

    # run the script
    run_vivado_tcl(tcl_file=tcl_file)

def run_vivado_tcl(tcl_file, cwd=None, err_str=None, disp_type='realtime'):
    # set defaults
    if err_str is None:
        err_str = ['CRITICAL WARNING', 'ERROR', 'Fatal']

    # build up the command
    cmd = []
    cmd += ['vivado']
    cmd += ['-mode', 'batch']
    cmd += ['-source', f'{tcl_file}']
    cmd += ['-nolog']
    cmd += ['-nojournal']

    # run TCL script and return the result
    return subprocess_run(cmd, cwd=cwd, err_str=err_str, disp_type=disp_type)