#!/usr/bin/env python

from distutils.core import setup

setup(name='PsychroLib',
      version='2.4.0',
      maintainer = 'The PsychroLib Developers',
      description='Library of psychrometric functions to calculate thermodynamic properties of air',
      author='D. Thevenard and D. Meyer',
      author_email='didierthevenard@users.noreply.github.com',
      url='https://github.com/psychrometrics/psychrolib',
      license='MIT',
      platforms = ['Windows', 'Linux', 'Solaris', 'Mac OS-X', 'Unix'],
      python_requires='>=3.6',
      py_modules=['psychrolib'],
     )