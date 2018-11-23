# Copyright (c) 2018 D. Thevenard and D. Meyer. Licensed under the MIT License.
# Test of PsychroLib in SI units

import pytest
from psychrolib import *

pytestmark = pytest.mark.usefixtures('SetUnitSystem_SI')

# Test of helper functions
def test_GetTKelvinFromTCelsius():
    assert GetTKelvinFromTCelsius(20) == pytest.approx(293.15, 0.000001)


###############################################################################
# Tests at saturation
###############################################################################

# Test saturation vapour pressure calculation
# The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# over the range [-100, +200] C
# ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C
def test_GetSatVapPres():
    assert GetSatVapPres(-60) == pytest.approx(1.08, abs = 0.01)
    assert GetSatVapPres(-20) == pytest.approx(103.24, rel = 0.0003)
    assert GetSatVapPres( -5) == pytest.approx(401.74, rel = 0.0003)
    assert GetSatVapPres(  5) == pytest.approx(872.6, rel = 0.0003)
    assert GetSatVapPres( 25) == pytest.approx(3169.7, rel = 0.0003)
    assert GetSatVapPres( 50) == pytest.approx(12351.3, rel = 0.0003)
    assert GetSatVapPres(100) == pytest.approx(101418.0, rel = 0.0003)
    assert GetSatVapPres(150) == pytest.approx(476101.4, rel = 0.0003)

# Test saturation humidity ratio
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is not terrific - up to 2% difference with the values published in the table
def test_GetSatHumRatio():
    assert GetSatHumRatio(-50, 101325) == pytest.approx(0.0000243, rel = 0.01)
    assert GetSatHumRatio(-20, 101325) == pytest.approx(0.0006373, rel = 0.01)
    assert GetSatHumRatio( -5, 101325) == pytest.approx(0.0024863, rel = 0.005)
    assert GetSatHumRatio(  5, 101325) == pytest.approx(0.005425, rel = 0.005)
    assert GetSatHumRatio( 25, 101325) == pytest.approx(0.020173, rel = 0.005)
    assert GetSatHumRatio( 50, 101325) == pytest.approx(0.086863, rel = 0.01)
    assert GetSatHumRatio( 85, 101325) == pytest.approx(0.838105, rel = 0.02)

# Test enthalpy at saturation
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is rarely better than 1%, and close to 3% at -5 C
def test_GetSatAirEnthalpy():
    assert GetSatAirEnthalpy(-50, 101325) == pytest.approx( -50222, rel = 0.01)
    assert GetSatAirEnthalpy(-20, 101325) == pytest.approx( -18542, rel = 0.01)
    assert GetSatAirEnthalpy( -5, 101325) == pytest.approx(   1164, rel = 0.03)
    assert GetSatAirEnthalpy(  5, 101325) == pytest.approx(  18639, rel = 0.01)
    assert GetSatAirEnthalpy( 25, 101325) == pytest.approx(  76504, rel = 0.01)
    assert GetSatAirEnthalpy( 50, 101325) == pytest.approx( 275353, rel = 0.01)
    assert GetSatAirEnthalpy( 85, 101325) == pytest.approx(2307539, rel = 0.01)


###############################################################################
# Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
# These relationships are identified with bold arrows in the doc's diagram
###############################################################################

# Test of relationships between vapour pressure and dew point temperature
# No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
def test_VapPres_TDewPoint():
    VapPres = GetVapPresFromTDewPoint(-20.0)
    assert GetTDewPointFromVapPres(15.0, VapPres) == pytest.approx(-20.0, abs = 0.001)
    VapPres = GetVapPresFromTDewPoint(5.0)
    assert GetTDewPointFromVapPres(15.0, VapPres) == pytest.approx(5.0, abs = 0.001)
    VapPres = GetVapPresFromTDewPoint(50.0)
    assert GetTDewPointFromVapPres(60.0, VapPres) == pytest.approx(50.0, abs = 0.001)

# Test of relationships between humidity ratio and vapour pressure
# Humidity ratio values to test against are calculated with Excel
def test_HumRatio_VapPres():
    HumRatio = GetHumRatioFromVapPres(3169.7, 95461)          # conditions at 25 C, std atm pressure at 500 m
    assert HumRatio == pytest.approx(0.0213603998047487, rel = 0.000001)
    VapPres = GetVapPresFromHumRatio(HumRatio, 95461)
    assert VapPres == pytest.approx(3169.7, abs = 0.00001)

# Test of relationships between vapour pressure and relative humidity
def test_VapPres_RelHum():
    VapPres = GetVapPresFromRelHum(25, 0.8)
    assert VapPres == pytest.approx(3169.7*0.8, rel = 0.0003)
    RelHum = GetRelHumFromVapPres(25, VapPres)
    assert RelHum == pytest.approx(0.8, rel = 0.0003)

# Test of relationships between humidity ratio and wet bulb temperature
# The formulae are tested for two conditions, one above freezing and the other below
# Humidity ratio values to test against are calculated with Excel
def test_HumRatio_TWetBulb():
    # Above freezing
    HumRatio = GetHumRatioFromTWetBulb(30, 25, 95461)
    assert HumRatio == pytest.approx(0.0192281274241096, rel = 0.0003)
    TWetBulb = GetTWetBulbFromHumRatio(30, HumRatio, 95461)
    assert TWetBulb == pytest.approx(25, abs = 0.001)
    # Below freezing
    HumRatio = GetHumRatioFromTWetBulb(-1, -5, 95461)
    assert HumRatio == pytest.approx(0.00120399819933844, rel = 0.0003)
    TWetBulb = GetTWetBulbFromHumRatio(-1, HumRatio, 95461)
    assert TWetBulb == pytest.approx(-5, abs = 0.001)


###############################################################################
# Dry air calculations
###############################################################################

# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
def test_DryAir():
    assert GetDryAirEnthalpy(25) == pytest.approx(25148, rel = 0.0003)
    assert GetDryAirVolume(25, 101325) == pytest.approx(0.8443, rel = 0.001)
    assert GetDryAirDensity(25, 101325) == pytest.approx(1/0.8443, rel = 0.001)


###############################################################################
# Moist air calculations
###############################################################################

# Values are compared against values calculated with Excel
def test_MoistAir():
    assert GetMoistAirEnthalpy(30, 0.02) == pytest.approx(81316, rel = 0.0003)
    assert GetMoistAirVolume(30, 0.02, 95461) == pytest.approx(0.940855374352943, rel = 0.0003)
    assert GetMoistAirDensity(30, 0.02, 95461) == pytest.approx(1.08411986348219, rel = 0.0003)

###############################################################################
# Test standard atmosphere
###############################################################################

# The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
def test_GetStandardAtmPressure():
    assert GetStandardAtmPressure( -500) == pytest.approx(107478, abs = 1)
    assert GetStandardAtmPressure(    0) == pytest.approx(101325, abs = 1)
    assert GetStandardAtmPressure(  500) == pytest.approx( 95461, abs = 1)
    assert GetStandardAtmPressure( 1000) == pytest.approx( 89875, abs = 1)
    assert GetStandardAtmPressure( 4000) == pytest.approx( 61640, abs = 1)
    assert GetStandardAtmPressure(10000) == pytest.approx( 26436, abs = 1)

def test_GetStandardAtmTemperature():
    assert GetStandardAtmTemperature( -500) == pytest.approx( 18.2, abs = 0.1)
    assert GetStandardAtmTemperature(    0) == pytest.approx( 15.0, abs = 0.1)
    assert GetStandardAtmTemperature(  500) == pytest.approx( 11.8, abs = 0.1)
    assert GetStandardAtmTemperature( 1000) == pytest.approx(  8.5, abs = 0.1)
    assert GetStandardAtmTemperature( 4000) == pytest.approx(-11.0, abs = 0.1)
    assert GetStandardAtmTemperature(10000) == pytest.approx(-50.0, abs = 0.1)


###############################################################################
# Test sea level pressure conversions
###############################################################################

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
def test_SeaLevel_Station_Pressure():
    SeaLevelPressure = GetSeaLevelPressure(101226.5, 105, 17.19)
    assert SeaLevelPressure == pytest.approx(102484.0, abs = 1)
    assert GetStationPressure(SeaLevelPressure, 105, 17.19) == pytest.approx(101226.5, abs = 1)


###############################################################################
# Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
###############################################################################

def test_AllPsychrometrics():
    # This is example 1. The values are provided in the text of the Handbook
    HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        CalcPsychrometricsFromTWetBulb(40, 20, 101325)
    assert HumRatio == pytest.approx(0.0065, abs = 0.0001)
    assert MoistAirEnthalpy == pytest.approx(56700, abs = 100)
    assert TDewPoint == pytest.approx(7, abs = 0.5)             # not great agreement
    assert RelHum == pytest.approx(0.14, abs = 0.01)
    assert MoistAirVolume == pytest.approx(0.896, rel = 0.01)

    # Reverse calculation: recalculate wet bulb temperature from dew point temperature
    HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        CalcPsychrometricsFromTDewPoint(40, TDewPoint, 101325)
    assert TWetBulb == pytest.approx(20, abs = 0.1)

   # Reverse calculation: recalculate wet bulb temperature from relative humidity
    HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        CalcPsychrometricsFromRelHum(40, RelHum, 101325)
    assert TWetBulb == pytest.approx(20, abs = 0.1)