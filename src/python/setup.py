#!/usr/bin/env python

from distutils.core import setup

setup(name='psychrolib',
      version='2.0.0',
      maintainer = 'PsychroLib Developers',
      description='Functions for calculating thermodynamic properties of gas-vapor mixtures and standard atmosphere',
      author='D. Thevenard and D. Meyer',
      #author_email='', # FIXME: pick email address
      url='https://github.com/psychrometrics/psychrolib',
      license='MIT',
      platforms = ['Windows', 'Linux', 'Solaris', 'Mac OS-X', 'Unix'],
      python_requires='>=3.6',
      py_modules=['psychrolib'],
     )