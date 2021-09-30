#!/usr/bin/env python

from setuptools import setup, find_packages

setup(name='kl_cert_chooser',
      version='0.1',
      # Modules to import from other scripts:
      packages=find_packages(),
      # Executables
      scripts=["klvpn_cert_chooser.py"])
