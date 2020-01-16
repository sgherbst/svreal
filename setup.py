from distutils.core import setup

setup(
    name='svreal',
    version='0.1.2',
    license='MIT',
    description='Library for working with fixed-point numbers in SystemVerilog',
    author='Steven Herbst',
    author_email='sgherbst@gmail.com',
    url='https://github.com/sgherbst/svreal',
    download_url = 'https://github.com/sgherbst/svreal/archive/v0.1.2.tar.gz',
    keywords = ['fixed-point', 'fixed point', 'verilog', 'system-verilog', 'system verilog', 'synthesizable', 'fpga'],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7'
    ],
    zip_safe=False
)
