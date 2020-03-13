# upgrade pip
python -m pip install --upgrade pip

# install svreal
pip install -e .

# install a specific version of pysmt to avoid cluttering the output with warnings
pip install pysmt==0.8.1.dev93

# install testing dependencies
pip install pytest pytest-cov mantle fault

# run tests
pytest --cov-report=xml --cov=svreal tests/ -v -r s

# upload coverage
bash <(curl -s https://codecov.io/bash)
