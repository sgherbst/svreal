from setuptools import setup, find_packages

name = 'svreal'
version = '0.2.5'

DESCRIPTION = '''\
Library for working with fixed-point numbers in SystemVerilog\
'''

with open('README.md', 'r') as fh:
    LONG_DESCRIPTION = fh.read()

setup(
    name=name,
    version=version,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    long_description_content_type='text/markdown',
    keywords = ['fixed-point', 'fixed point', 'verilog', 'system-verilog', 'system verilog', 'synthesizable', 'fpga'],
    packages=find_packages(exclude=['tests']),
    license='MIT',
    url=f'https://github.com/sgherbst/{name}',
    author='Steven Herbst',
    author_email='sgherbst@gmail.com',
    python_requires='>=3.7',
    download_url = f'https://github.com/sgherbst/{name}/archive/v{version}.tar.gz',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)',
        'License :: OSI Approved :: MIT License',
        f'Programming Language :: Python :: 3.7'
    ],
    include_package_data=True,
    zip_safe=False
)
