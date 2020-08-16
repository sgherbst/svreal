import os
from pathlib import Path

from svreal.constants import *
from svreal.enums import RealType
from svreal.hard_float import real2recfn, recfn2real
from svreal.fixed_point import real2fixed, fixed2real, calc_fixed_exp

PACK_DIR = Path(__file__).resolve().parent

def get_svreal_header():
    return PACK_DIR / 'svreal.sv'

def get_hard_float_dir():
    if 'HARD_FLOAT_INST_DIR' in os.environ:
        return Path(os.environ['HARD_FLOAT_INST_DIR']).resolve()
    else:
        for retval in [PACK_DIR / 'HardFloat-1', PACK_DIR / 'HardFloat']:
            if retval.exists():
                return retval
        raise Exception(f'Could not find HardFloat installation.  '
                        f'Please move the HardFloat directory in {PACK_DIR} or '
                        f'set the the HARD_FLOAT_INST_DIR environment variable to its absolute path.  '
                        f'HardFloat can be downloaded from http://www.jhauser.us/arithmetic/HardFloat.html')

def get_hard_float_specialization():
    return os.environ.get('HARD_FLOAT_SPECIALIZATION', 'RISCV')

def get_hard_float_headers():
    root = get_hard_float_dir()
    return [
        root / 'source' / 'HardFloat_consts.vi',
        root / 'source' / 'HardFloat_localFuncs.vi',
        root / 'source' / get_hard_float_specialization() / 'HardFloat_specialize.vi'
    ]

def get_hard_float_inc_dirs():
    return list(set(elem.parent for elem in get_hard_float_headers()))

def get_hard_float_sources():
    root = get_hard_float_dir() / 'source'
    specialization = get_hard_float_specialization()
    return [
        root / 'HardFloat_primitives.v',
        root / specialization / 'HardFloat_specialize.v',
        root / 'isSigNaNRecFN.v',
        root / 'HardFloat_rawFN.v',
        root / 'addRecFN.v',
        root / 'compareRecFN.v',
        root / 'iNToRecFN.v',
        root / 'mulRecFN.v',
        root / 'recFNToIN.v'
    ]

