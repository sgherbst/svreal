# generic imports
from shutil import which
from pathlib import Path

# AHA imports
import fault
from fault.subprocess_run import subprocess_run

# svreal imports
from svreal import (get_hard_float_sources, get_hard_float_inc_dirs,
                    get_hard_float_headers, get_svreal_header)

TEST_DIR = Path(__file__).resolve().parent

def get_file(path):
    return Path(TEST_DIR, path)

def get_dir(path):
    # alias for get_file
    return get_file(path)

def get_files(*args):
    return [get_file(path) for path in args]

def get_dirs(*args):
    # alias for get_files
    return get_files(*args)

def pytest_sim_params(metafunc, simulators=None):
    if simulators is None:
        simulators = ['vcs', 'vivado', 'ncsim', 'iverilog']

    # parameterize with the simulators available
    if 'simulator' in metafunc.fixturenames:
        targets = []
        for simulator in simulators:
            if which(simulator):
                targets.append(simulator)

        metafunc.parametrize('simulator', targets)

def pytest_real_type_params(metafunc, real_types=None):
    if real_types is None:
        real_types = ['FIXED_POINT', 'FLOAT_REAL', 'HARD_FLOAT']

    if 'real_type' in metafunc.fixturenames:
        metafunc.parametrize('real_type', real_types)

def pytest_synth_params(metafunc):
    if 'synth' in metafunc.fixturenames:
        targets = []
        for synth in ['vivado']:
            if which(synth):
                targets.append(synth)

        metafunc.parametrize('synth', targets)

def run_synth(synth, top=None, cwd='build', src_files=None, hdr_files=None, defines=None,
              real_type='FIXED_POINT'):
    # set defaults
    if src_files is None:
        src_files = []
    if hdr_files is None:
        hdr_files = []
    if defines is None:
        defines = {}

    # add to source files
    if real_type == 'HARD_FLOAT':
        src_files = get_hard_float_sources() + src_files

    # add to header files
    hdr_files = [get_svreal_header()] + hdr_files
    if real_type == 'HARD_FLOAT':
        hdr_files = get_hard_float_headers() + hdr_files

    # update define variables
    if real_type == 'HARD_FLOAT':
        defines['HARD_FLOAT'] = None

    # run synthesis using the desired tool
    if synth == 'vivado':
        return run_vivado_synth(top=top, cwd=cwd, src_files=src_files,
                                hdr_files=hdr_files, defines=defines)
    else:
        raise Exception(f'Unknown synth tool: {synth}.')

def run_vivado_synth(top, cwd, src_files, hdr_files, defines,
                     part='xc7z020clg484-1', proj_name='project'):
    lines = []

    # create the project at the desired location
    proj_dir = Path(cwd) / proj_name
    lines += [f'create_project -force "{proj_name}" "{proj_dir}" -part "{part}"']

    # add source and header files
    lines += [f'add_files "{file}"' for file in hdr_files+src_files]

    # identify header files
    lines += [f'set_property file_type "Verilog Header" [get_files "{hdr_file}"]' for hdr_file in hdr_files]

    # add define variables
    define_list = []
    for k, v in defines.items():
        if v is not None:
            define_list.append(f'{k}={v}')
        else:
            define_list.append(f'{k}')
    if len(define_list) > 0:
        lines += [f'set_property verilog_define {{{" ".join(define_list)}}} [current_fileset]']

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

class SvrealTester(fault.Tester):
    def __init__(self, circuit, clock=None, expect_strict_default=True, debug_mode=False):
        super().__init__(circuit=circuit, clock=clock,
                         expect_strict_default=expect_strict_default)
        self.debug_mode = debug_mode

    def compile_and_run(self, target='system-verilog', ext_srcs=None,
                        inc_dirs=None, ext_model_file=True, tmp_dir=None,
                        disp_type=None, real_type='FIXED_POINT',
                        defines=None, **kwargs):
        # set defaults
        if ext_srcs is None:
            ext_srcs = []
        if inc_dirs is None:
            inc_dirs = []
        if tmp_dir is None:
            tmp_dir = not self.debug_mode
        if disp_type is None:
            disp_type = 'on_error' if (not self.debug_mode) else 'realtime'
        if defines is None:
            defines = {}

        # add to ext_srcs
        if real_type == 'HARD_FLOAT':
            ext_srcs = get_hard_float_sources() + ext_srcs

        # add to inc_dirs
        inc_dirs = [get_svreal_header().parent] + inc_dirs
        if real_type == 'HARD_FLOAT':
            inc_dirs = get_hard_float_inc_dirs() + inc_dirs

        # add defines as needed for the real number type
        if real_type == 'FIXED_POINT':
            pass
        elif real_type == 'FLOAT_REAL':
            defines['FLOAT_REAL'] = None
        elif real_type == 'HARD_FLOAT':
            defines['HARD_FLOAT'] = None

        # call the command
        super().compile_and_run(
            target='system-verilog',
            ext_srcs=ext_srcs,
            inc_dirs=inc_dirs,
            defines=defines,
            ext_model_file=ext_model_file,
            tmp_dir=tmp_dir,
            disp_type=disp_type,
            **kwargs
        )
