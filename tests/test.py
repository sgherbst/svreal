from argparse import ArgumentParser
from glob import glob
from shutil import which

import os
import os.path
import sys
import subprocess

def get_full_path(path):
    return os.path.realpath(os.path.expanduser(path))

def top_dir():
    this_file_path = get_full_path(__file__)
    return os.path.dirname(os.path.dirname(this_file_path))

def get_file(*args):
    return os.path.join(top_dir(), *args)

def get_dir(*args, mkdir_p=True):
    path = get_file(*args)
    
    if mkdir_p:
        os.makedirs(path, exist_ok=True)

    return path

def call(cmd):
    subprocess.call(cmd, stdout=sys.stdout, stderr=sys.stdout)

def verilog_define(name, value=None):
    retval = ''
    
    retval += '-d ' + name
    retval += '=' + str(value) if value is not None else ''
    
    return retval

def xvlog(args):
    cmd = []
    
    cmd.append(which('xvlog'))
    cmd.append(args.input)
    cmd.extend(glob(get_file('src', '*.sv')))
    cmd.extend(['-i', get_dir('include')])
    cmd.extend(['-L', get_dir('src')])
    cmd.extend(['-sourcelibext', 'sv'])
    cmd.append('-sv')
    
    if args.debug:
        cmd.append(verilog_define('DEBUG_REAL'))
    if args.float:
        cmd.append(verilog_define('FLOAT_REAL'))

    call(cmd)
    
def xelab(args):
    cmd = []
    
    cmd.append(which('xelab'))
    cmd.append('test')
    cmd.extend(['-s', 'test'])
    
    call(cmd)
    
def xsim(args):
    cmd = []
    
    cmd.append(which('xsim'))
    cmd.append('test')
    cmd.append('-R')
    
    call(cmd)

def main():
    # parse command line arguments
    parser = ArgumentParser()

    parser.add_argument('-i', '--input', type=str, default=get_file('tests', 'hello.sv'))
    parser.add_argument('-o', '--output', type=str, default=None)
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--float', action='store_true')
    
    args = parser.parse_args()

    # expand path of input file
    args.input = get_full_path(args.input)

    # set the output directory if necessary
    if args.output is None:
        args.output = get_dir('build')

    # change directory to output
    os.chdir(args.output)

    # run the compiling steps
    xvlog(args)
    xelab(args)
    xsim(args)

if __name__ == "__main__":
    main()
