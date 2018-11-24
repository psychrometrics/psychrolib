# Copyright (c) 2018 D. Thevenard and D. Meyer. Licensed under the MIT License.

import sys
from pathlib import Path

import pytest

PACKAGE_PATH = Path(__file__).parents[2] / 'src' / 'python'
sys.path.append(str(PACKAGE_PATH))

from psychrolib import SetUnitSystem, SI, IP

@pytest.fixture(scope = 'module')
def SetUnitSystem_IP():
    SetUnitSystem(IP)

@pytest.fixture(scope = 'module')
def SetUnitSystem_SI():
    SetUnitSystem(SI)