# generic imports
from copy import deepcopy
from shutil import which, copyfile
from pathlib import Path

# AHA imports
import fault
from fault.subprocess_run import subprocess_run

# svreal imports
from svreal import (get_hard_float_sources, get_hard_float_inc_dirs,
                    get_hard_float_headers, get_svreal_header,
                    RealType)

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

def pytest_sim_params(metafunc, simulators=None, skip=None):
    # set defaults
    if skip is None:
        skip = []
    if simulators is None:
        #simulators = ['vcs', 'vivado', 'ncsim', 'iverilog']
        simulators = ['verilator']

    # parameterize with the simulators available
    if 'simulator' in metafunc.fixturenames:
        targets = []
        for simulator in simulators:
            if (simulator not in skip) and which(simulator):
                targets.append(simulator)

        metafunc.parametrize('simulator', targets)

def pytest_real_type_params(metafunc, real_types=None):
    if real_types is None:
        real_types = [RealType.FixedPoint, RealType.FloatReal, RealType.HardFloat]

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
              real_type=RealType.FixedPoint):
    # set defaults
    if src_files is None:
        src_files = []
    if hdr_files is None:
        hdr_files = []
    if defines is None:
        defines = {}

    # add to source files
    if real_type == RealType.HardFloat:
        src_files = get_hard_float_sources() + src_files

    # add to header files
    hdr_files = [get_svreal_header()] + hdr_files
    if real_type == RealType.HardFloat:
        hdr_files = get_hard_float_headers() + hdr_files

    # update define variables
    defines = defines.copy()
    if real_type == RealType.HardFloat:
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
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def compile_and_run(self, ext_model_file, simulator='iverilog',
                        ext_srcs=None, inc_dirs=None, disp_type='on_error',
                        real_type=RealType.FixedPoint, defines=None,
                        directory='build', **kwargs):
        # copy kwargs
        kwargs = deepcopy(kwargs)
        if 'flags' not in kwargs:
            kwargs['flags'] = []

        # set defaults
        if ext_srcs is None:
            ext_srcs = []
        if inc_dirs is None:
            inc_dirs = []
        if defines is None:
            defines = {}

        # set the target type
        if simulator == 'verilator':
            target = 'verilator'
        else:
            target = 'system-verilog'
            kwargs['simulator'] = simulator

        # add to ext_srcs
        if real_type == RealType.HardFloat:
            ext_srcs = get_hard_float_sources() + ext_srcs

        # add to inc_dirs
        inc_dirs = [get_svreal_header().parent] + inc_dirs
        if real_type == RealType.HardFloat:
            inc_dirs = get_hard_float_inc_dirs() + inc_dirs

        # add defines as needed for the real number type
        defines = deepcopy(defines)
        if real_type == RealType.FixedPoint:
            pass
        elif real_type == RealType.FloatReal:
            defines['FLOAT_REAL'] = None
        elif real_type == RealType.HardFloat:
            defines['HARD_FLOAT'] = None

        # map arguments depending on simulator type
        if target == 'verilator':
            # prepare arguments lists
            for k, v in defines.items():
                if v is not None:
                    kwargs['flags'] += [f'-D{k}={v}']
                else:
                    kwargs['flags'] += [f'-D{k}']
            kwargs['include_directories'] = inc_dirs
            kwargs['include_verilog_libraries'] = ext_srcs
            kwargs['skip_compile'] = True

            # determine file extension
            if Path(ext_model_file).suffix == '.sv':
                kwargs['magma_opts'] = {'sv': None}

            # copy in files
            Path(directory).mkdir(exist_ok=True, parents=True)
            copyfile(str(ext_model_file), str(Path(directory) / Path(ext_model_file).name))
        else:
            kwargs['defines'] = defines
            kwargs['inc_dirs'] = inc_dirs
            kwargs['ext_srcs'] = ext_srcs + [ext_model_file]
            kwargs['ext_model_file'] = True

        # call the command
        super().compile_and_run(
            target=target,
            directory=directory,
            tmp_dir=False,
            disp_type=disp_type,
            **kwargs
        )
