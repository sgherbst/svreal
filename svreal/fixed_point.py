from math import log2, ceil, isinf, isnan

from .constants import *

def clog2(x):
    return int(ceil(log2(x)))

def calc_fixed_exp(range, width=DEF_LONG_WIDTH_REAL):
    if isinf(range):
        raise Exception('Function undefined for an infinite range.')
    elif isnan(range):
        raise Exception('Function undefined when range is NaN.')
    elif range == 0:
        return 0
    else:
        return clog2(range/((1<<(width-1))-1))

def fixed2real(in_, exp, width=DEF_LONG_WIDTH_REAL,
               treat_as_unsigned=False):
    # if the incoming integer is unsigned, we have to convert
    # it to a signed integer based on the width
    if treat_as_unsigned:
        if ((in_ >> (width - 1)) & 1) == 1:
            in_ -= (1 << width)

    # return result
    return in_ * (2**exp)

def real2fixed(in_, exp, width=DEF_LONG_WIDTH_REAL,
               treat_as_unsigned=False):
    # check for special cases
    if isinf(in_):
        raise Exception('Cannot represent infinite values in fixed-point.')
    if isnan(in_):
        raise Exception('Cannot represent NaN values in fixed-point.')

    # compute the signed integer representation
    retval = int(round(in_ * (2**(-exp))))

    # if needed, convert to unsigned
    if treat_as_unsigned:
        retval &= ((1<<width)-1)

    # return result
    return retval
