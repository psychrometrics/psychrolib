# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

import sys
from pathlib import Path

import pytest
import numpy.f2py as f2py
import cffi


#########################################################
# Import Python Library
#########################################################
# make Python package available to tests (tests/python)
PACKAGE_PATH = Path(__file__).parents[1] / 'src' / 'python'
sys.path.append(str(PACKAGE_PATH))
import psychrolib

#########################################################
# Compile and import Fortran library
#########################################################
PATH_TO_LIB = Path(__file__).parents[1] / 'src' / 'fortran' / 'psychrolib.f90'
with open(str(PATH_TO_LIB), 'rb') as fid:
    source = fid.read()
f2py.compile(source , modulename='psychrolib_fortran', extension='.f90')
import psychrolib_fortran
psyf = psychrolib_fortran.psychrolib

#########################################################
# Compile and import C library
#########################################################
PATH_TO_C = Path(__file__).parents[1] / 'src' / 'c'
PATH_TO_HEADER = PATH_TO_C / 'psychrolib.h'
PATH_TO_SRC = PATH_TO_C / 'psychrolib.c'

ffi = cffi.FFI()

with open(PATH_TO_HEADER) as f:
    ffi.cdef(f.read())

with open(PATH_TO_SRC) as f:
    ffi.set_source("psychroc", f.read(),
        include_dirs=[str(PATH_TO_C)])

ffi.compile()

import psychroc
psyc = psychroc.lib


# A fixture is applied directly before running a test.
# We need to use this approach as the alternative would to be
# to call SetUnitSystem at the top of the test file, however,
# that code is run on import, and pytest imports *all* test
# files first before running any tests, hence the global UnitSystem
# setting would be overridden and the unit system would be whatever
# was last set.
@pytest.fixture(scope = 'module')
def SetUnitSystem_IP():
    psychrolib.SetUnitSystem(psychrolib.IP)
    psyf.setunitsystem(1)
    psyc.SetUnitSystem(1)

@pytest.fixture(scope = 'module')
def SetUnitSystem_SI():
    psychrolib.SetUnitSystem(psychrolib.SI)
    psyf.setunitsystem(2)
    psyc.SetUnitSystem(2)

class CaseInsensitiveFortran(object):
    def __getattribute__(self, name: str):
        return getattr(psyf, name.lower())

ffi = cffi.FFI()
HumRatio = ffi.new("double *")
TDewPoint = ffi.new("double *")
RelHum = ffi.new("double *")
VapPres = ffi.new("double *")
MoistAirEnthalpy = ffi.new("double *")
MoistAirVolume = ffi.new("double *")
DegreeOfSaturation = ffi.new("double *")
TWetBulb = ffi.new("double *")

class PythonicC(object):
    # Wrap C functions that use pointers to provide the same Python API.
    def CalcPsychrometricsFromTWetBulb(self, TDryBulb, TWetBulb, Pressure):
        out = [HumRatio, TDewPoint, RelHum, VapPres,
               MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation]
        psyc.CalcPsychrometricsFromTWetBulb(
            TDryBulb, TWetBulb, Pressure, *out)
        return tuple(o[0] for o in out)

    def CalcPsychrometricsFromTDewPoint(self, TDryBulb, TDewPoint, Pressure):
        out = [HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy,\
               MoistAirVolume, DegreeOfSaturation]
        psyc.CalcPsychrometricsFromTDewPoint(TDryBulb, TDewPoint, Pressure, *out)
        return tuple(o[0] for o in out)

    def CalcPsychrometricsFromRelHum(self, TDryBulb, RelHum, Pressure):
        out = [HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy,\
               MoistAirVolume, DegreeOfSaturation]
        psyc.CalcPsychrometricsFromRelHum(TDryBulb, RelHum, Pressure, *out)
        return tuple(o[0] for o in out)

    # forward all other functions directly to C interface, no pointer-wrapping needed
    def __getattr__(self, name: str):
        return getattr(psyc, name)

@pytest.fixture(scope = 'module', params=["C", "Fortran", "Python"])
def psy(request):
    lang = request.param
    if lang == 'C':
        return PythonicC()
    if lang == 'Fortran':
        return CaseInsensitiveFortran()
    if lang == 'Python':
        return psychrolib