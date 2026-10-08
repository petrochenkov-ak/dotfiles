#!/usr/bin/env python
import datetime
import os
import sys

name = os.path.basename(os.getcwd()).replace('.py','')
version = '0.0.0'
if os.path.exists('.pypi-metadata/version.txt'):
    version = open('.pypi-metadata/version.txt').read().strip()
code = """
import setuptools

# PRODUCTION setup.py: name, version, install_requires, packages only
with open('requirements.txt', encoding="utf-8") as file:
    install_requires = file.read().splitlines()
setuptools.setup(
    name='{name}',
    version='{version}',
    install_requires=install_requires,
    packages=setuptools.find_packages()
)
""".format(name=name,version=version)
if not os.path.exists('requirements.txt'):
    code = """
import setuptools

# PRODUCTION setup.py: name, version, packages only
setuptools.setup(
    name='{name}',
    version='{version}',
    packages=setuptools.find_packages()
)
""".format(name=name,version=version)
open('setup.py','w').write(code.strip()+'\n')
