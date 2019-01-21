from setuptools import setup, find_packages

setup(
    name='svreal',
    version='0.0.1',
    description='Library for working with fixed-point numbers in SystemVerilog',
    url='https://github.com/sgherbst/svreal',
    author='Steven Herbst',
    author_email='sherbst@stanford.edu',
    packages=['svreal'],
    install_requires=[
    ],
    include_package_data=True,
    zip_safe=False,
)
