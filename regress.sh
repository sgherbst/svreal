# install HardFloat
wget -O install_hardfloat.sh https://git.io/JJ5YF
source install_hardfloat.sh

# install svreal
pip install -e .

# install a specific version of pysmt to avoid cluttering the output with warnings
pip install pysmt==0.9.0

# install testing dependencies
pip install pytest pytest-cov fault==3.0.43 magma-lang==2.1.20 coreir==2.0.128 mantle==2.0.15 hwtypes==1.4.4 ast_tools==0.0.30 kratos==0.0.31.2

# run tests
pytest --cov-report=xml --cov=svreal tests/ -v -r s

# upload coverage
bash <(curl -s https://codecov.io/bash)
