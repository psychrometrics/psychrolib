#!/usr/bin/env python

from distutils.core import setup

from pathlib import Path

PACKAGE_PATH = Path(__file__).resolve().parents[2]

with open(str(PACKAGE_PATH/ 'README.md')) as file:
    long_description = file.read()

setup(name='PsychroLib',
      version='2.0.0',
      maintainer = 'The PsychroLib Developers',
      description='Library of psychrometric functions to calculate thermodynamic properties of air',
      long_description= long_description,
      long_description_content_type="text/markdown",
      author='D. Thevenard and D. Meyer',
      author_email='didierthevenard@users.noreply.github.com',
      url='https://github.com/psychrometrics/psychrolib',
      license='MIT',
      platforms = ['Windows', 'Linux', 'Solaris', 'Mac OS-X', 'Unix'],
      python_requires='>=3.6',
      py_modules=['psychrolib'],
     )