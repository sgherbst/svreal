# upgrade pip
pip install -U pip

# install svreal
pip install -e .

############################
# special handling of some #
# packages for testing     #
############################

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    # speed up the build process until it's fixed at z3
    # see https://github.com/Z3Prover/z3/issues/2800
    pip install https://github.com/Z3Prover/z3/releases/download/Nightly/z3_solver-4.8.8.0-py2.py3-none-macosx_10_14_x86_64.whl

    # install kratos from source on macOS since the wheel is not compatible with macOS <= 10.14
    pip install kratos --no-binary :all:
fi

# install a specific version of pysmt to avoid cluttering the output with warnings
pip install pysmt==0.8.1.dev93

############################

# install testing dependencies
pip install pytest pytest-cov mantle fault

# run tests
pytest --cov-report=xml --cov=svreal tests/ -v -r s

# upload coverage
bash <(curl -s https://codecov.io/bash)
