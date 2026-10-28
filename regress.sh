# install HardFloat
wget -O install_hardfloat.sh https://git.io/JJ5YF
source install_hardfloat.sh

# install svreal
pip install -e .

# install testing dependencies: svtb stands in for fault and magma, which do not install on
# current Python
pip install pytest numpy svtb

# run tests
pytest tests/ -v -r s
