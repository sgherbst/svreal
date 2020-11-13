# install HardFloat
wget -O install_hardfloat.sh https://git.io/JJ5YF
source install_hardfloat.sh

# install svreal
pip install -e .

# install a specific version of pysmt to avoid cluttering the output with warnings
pip install pysmt==0.9.0

# install testing dependencies
pip install pytest pytest-cov magma-lang==2.1.20 coreir==2.0.120 mantle==2.0.15 hwtypes==1.4.4 ast_tools==0.0.30 kratos==0.0.31.2

# install fault
git clone https://github.com/leonardt/fault.git
cd fault
git checkout verilator_real
pip install -e .
cd ..

# run tests
pytest --cov-report=xml --cov=svreal tests/ -v -r s

# upload coverage
bash <(curl -s https://codecov.io/bash)
