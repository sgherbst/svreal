def fixed2real(in_, exp, width=None, treat_as_unsigned=False):
    # if the incoming integer is unsigned, we have to convert
    # it to a signed integer based on the width
    if treat_as_unsigned:
        if ((in_ >> (width - 1)) & 1) == 1:
            in_ -= (1 << width)

    # return result
    return in_ * (2**exp)

def real2fixed(in_, exp, width=None, treat_as_unsigned=False):
    # compute the signed integer representation
    retval = int(round(in_ * (2**(-exp))))

    # if needed, convert to unsigned
    if treat_as_unsigned:
        retval &= ((1<<width)-1)

    # return result
    return retval

