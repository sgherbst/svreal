# install svreal
pip install -e .

# install a specific version of pysmt to avoid cluttering the output with warnings
pip install pysmt==0.8.1.dev93

# install a specific version of fault
pip install -e git://github.com/leonardt/fault.git@paths_w_spaces_2#egg=fault

# install testing dependencies
pip install pytest pytest-cov mantle

# run tests
pytest --cov-report=xml --cov=svreal tests/ -v -r s

# upload coverage
bash <(curl -s https://codecov.io/bash)
