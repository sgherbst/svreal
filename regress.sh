# install HardFloat
wget -O install_hardfloat.sh https://git.io/JJ5YF
source install_hardfloat.sh

# install svreal
pip install -e .

# install a specific version of pysmt to avoid cluttering the output with warnings
pip install pysmt==0.9.0

# install testing dependencies
pip install pytest pytest-cov fault==3.0.36 magma-lang==2.1.17 coreir==2.0.120 mantle==2.0.10 hwtypes==1.4.3 ast_tools==0.0.30 kratos==0.0.31.1

# run tests
pytest --cov-report=xml --cov=svreal tests/ -v -r s

# upload coverage
bash <(curl -s https://codecov.io/bash)
