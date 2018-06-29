#!/usr/bin/env python

from argparse import ArgumentParser
from subprocess import call
import os.path
import sys

def main():
    # parse command line arguments
    parser = ArgumentParser()

    parser.add_argument('file')
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--float', action='store_true')
    parser.add_argument('--xrun', type=str, default='/cad/cadence/XCELIUM18.03.001.lnx86/tools/bin/xrun')
    
    args = parser.parse_args()

    # get path to the directory with real number library
    this_file_path = os.path.realpath(os.path.expanduser(__file__))
    real_dir = os.path.join(os.path.dirname(os.path.dirname(this_file_path)), 'real')

    # assemble the command line options
    cmd = []
    cmd.append(args.xrun)
    cmd.extend(['-incdir', real_dir])
    cmd.extend(['-y', real_dir])
    cmd.append('+libext+.sv')
    if args.debug:
        cmd.append('+define+DEBUG_REAL')
    if args.float:
        cmd.append('+define+FLOAT_REAL')
    cmd.append(args.file)

    # run the simulation command
    call(cmd, stdout=sys.stdout, stderr=sys.stdout)

if __name__ == "__main__":
    main()
