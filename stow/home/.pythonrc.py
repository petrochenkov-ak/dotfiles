"""
~/.logging.conf
~/.pythonrc.py

export PYTHONSTARTUP=~/.pythonrc.py
"""


import logging.config
import os

path = os.path.join(os.path.dirname(__file__), '.logging.conf')
logging.config.fileConfig(path)
