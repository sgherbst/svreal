import struct

from .constants import *

def recfn2real(in_, exp_width=DEF_HARD_FLOAT_EXP_WIDTH,
               sig_width=DEF_HARD_FLOAT_SIG_WIDTH):
    # deconstruct input into binary strings
    rec_sign = (in_ >> (exp_width+sig_width)) & 1
    rec_exp = (in_>>(sig_width-1)) & ((1<<(exp_width+1))-1)
    rec_sig = in_ & ((1<<(sig_width-1))-1)
    rec_exp_top = (rec_exp>>(exp_width-2)) & 0b111

    # walk through various cases
    if rec_exp_top == 0b000:
        # zero
        dbl_sign = rec_sign
        dbl_exp = 0
        dbl_sig = 0
    elif rec_exp_top == 0b110:
        # infinities
        dbl_sign = rec_sign
        dbl_exp = (1<<11)-1
        dbl_sig = 0
    elif rec_exp_top == 0b111:
        # NaNs
        dbl_sign = rec_sign
        dbl_exp = (1<<11)-1
        dbl_sig = (1<<52)-1
    elif rec_exp < ((1<<(exp_width-1))+2):
        # TODO: implement subnormal (treated as zero for now)
        dbl_sign = rec_sign
        dbl_exp = 0
        dbl_sig = 0
    else:
        # normal
        dbl_sign = rec_sign
        dbl_exp = (
            rec_exp
            - ((1<<(exp_width-1))+1)    # remove recoding offset
            - ((1<<(exp_width-1))-1)    # remove exponent bias
            + 1023                      # apply exponent bias
        )
        if (sig_width-1) < 52:
            # zero-pad
            dbl_sig = rec_sig << (52-(sig_width-1))
        else:
            # truncate
            dbl_sig = rec_sig >> ((sig_width-1)-52)

    # format the output into an arbitrary-size integer
    dbl_bits = dbl_sign & 1
    dbl_bits <<= 11
    dbl_bits |= dbl_exp & ((1<<11)-1)
    dbl_bits <<= 52
    dbl_bits |= dbl_sig & ((1<<52)-1)

    # return the result
    return struct.unpack('>d', struct.pack('>Q', dbl_bits))[0]


def real2recfn(in_, exp_width=DEF_HARD_FLOAT_EXP_WIDTH,
               sig_width=DEF_HARD_FLOAT_SIG_WIDTH):
    # deconstruct input
    dbl_bits = struct.unpack('>Q', struct.pack('>d', in_))[0]
    dbl_sign = (dbl_bits >> 63) & 1
    dbl_exp = (dbl_bits >> 52) & ((1<<11)-1)
    dbl_sig = dbl_bits & ((1<<52)-1)

    if dbl_exp == 0:
        # zero or subnormal
        # TODO: handle subnormal properly
        rec_sign = dbl_sign
        rec_exp = 0
        rec_sig = 0
    elif dbl_exp == (1<<11)-1:
        if dbl_sig == 0:
            # infinities
            rec_sign = dbl_sign
            rec_exp = 0b110 << (exp_width-2)
            rec_sig = 0
        else:
            # NaNs
            rec_sign = dbl_sign
            rec_exp = 0b111 << (exp_width-2)
            rec_sig = (1<<(sig_width-1))-1
    else:
        ##########
        # normal #
        ##########

        # sign
        rec_sign = dbl_sign

        # exponent
        rec_exp = (
            dbl_exp
            - 1023                      # remove exponent bias
            + ((1<<(exp_width-1))-1)    # apply exponent bias
            + ((1<<(exp_width-1))+1)    # apply recoding bias
        )

        # significand
        if rec_exp < ((1<<(exp_width-1))+2):
            # TODO: handle case where input is normal but output is subnormal
            # for now the output is simply zero
            rec_exp = 0
            rec_sig = 0
        elif rec_exp > ((3*(1<<(exp_width-1)))-1):
            # Exponent is too large to be represented, so treat as an infinity
            rec_exp = 0b110 << (exp_width-2)
            rec_sig = 0
        else:
            if (sig_width-1) > 52:
                # zero-pad (lossless)
                rec_sig = dbl_sig << ((sig_width-1)-52)
            else:
                # truncate (lossy)
                rec_sig = dbl_sig >> (52-(sig_width-1))

    # format the output into an arbitrary-size integer
    rec_bits = (rec_sign & 1)
    rec_bits <<= (exp_width+1)
    rec_bits |= rec_exp & ((1<<(exp_width+1))-1)
    rec_bits <<= (sig_width-1)
    rec_bits |= rec_sig & ((1<<(sig_width-1))-1)

    # return the result
    return rec_bits
