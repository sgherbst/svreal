import pytest
from math import isnan
from svreal import *

def test_fixed_point(width=25):
    def there_and_back(x):
        exp = calc_fixed_exp(abs(x), width=width)
        repr = real2fixed(x, exp=exp, width=width, treat_as_unsigned=True)
        return fixed2real(repr, exp=exp, width=width, treat_as_unsigned=True)

    def check_val(num, tol=None, eq=None):
        if eq is not None:
            assert there_and_back(num) == eq
        elif tol is not None:
            err = num - there_and_back(num)
            assert abs(err) <= tol
        else:
            raise Exception('Must specify tol or eq.')

    # basic cases
    check_val(0, eq=0)
    check_val(1.23, tol=1e-6)
    check_val(-4.56, tol=1e-6)
    check_val(1e15, tol=1e9)
    check_val(1e-15, tol=1e-22)
    check_val(1e100, tol=1e94)
    check_val(1e-100, tol=1e-107)
    check_val(1e-400, eq=0)

    # exceptional cases
    with pytest.raises(Exception, match='Function undefined for an infinite range.'):
        there_and_back(float('inf'))
    with pytest.raises(Exception, match='Function undefined for an infinite range.'):
        there_and_back(float('-inf'))
    with pytest.raises(Exception, match='Function undefined when range is NaN.'):
        there_and_back(float('nan'))

def test_hard_float():
    def there_and_back(x):
        repr = real2recfn(x)
        return recfn2real(repr)

    def check_val(num, tol=None, eq=None):
        if eq is not None:
            assert there_and_back(num) == eq
        elif tol is not None:
            err = num - there_and_back(num)
            assert abs(err) <= tol
        else:
            raise Exception('Must specify tol or eq.')

    # basic cases
    check_val(0, eq=0)
    check_val(1.23, tol=1e-5)
    check_val(-4.56, tol=1e-5)
    check_val(1e15, tol=1e9)
    check_val(1e-15, tol=1e-20)
    check_val(1e-40, eq=0)   # Python float is can represent this but recoded format cannot
    check_val(1e-100, eq=0)  # Python float is can represent this but recoded format cannot
    check_val(1e-315, eq=0)  # Subnormal for Python float; too small for recoded format
    check_val(1e-400, eq=0)  # Neither Python float nor the recoded format can represent this
    check_val(float('inf'), eq=float('inf'))
    check_val(float('-inf'), eq=float('-inf'))

    # dealing with nan
    assert isnan(there_and_back(float('nan'))), \
        'nan was not processed properly'

    # dealing with numbers that cannot be represented
    with pytest.raises(Exception, match='Recoded exponent is out of bounds.'):
        there_and_back(1e100)
