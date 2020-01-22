# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

# Test of PsychroLib in IP units for Python, C, and Fortran.

import numpy as np
import pytest

pytestmark = pytest.mark.usefixtures('SetUnitSystem_IP')

# Test of helper functions
def test_GetTRankineFromTFahrenheit(psy):
    assert psy.GetTRankineFromTFahrenheit(70) == pytest.approx(529.67, rel = 0.000001)

def test_GetTFahrenheitFromTRankine(psy):
    assert psy.GetTFahrenheitFromTRankine(529.67) == pytest.approx(70, rel = 0.000001)

###############################################################################
# Tests at saturation
###############################################################################

# Test saturation vapour pressure calculation
# The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# over the range [-148, +392] F
# ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
def test_GetSatVapPres(psy):
    assert psy.GetSatVapPres(-76) == pytest.approx(0.000157, abs = 0.00001)
    assert psy.GetSatVapPres( -4) == pytest.approx(0.014974, rel = 0.0003)
    assert psy.GetSatVapPres( 23) == pytest.approx(0.058268, rel = 0.0003)
    assert psy.GetSatVapPres( 41) == pytest.approx(0.12656, rel = 0.0003)
    assert psy.GetSatVapPres( 77) == pytest.approx(0.45973, rel = 0.0003)
    assert psy.GetSatVapPres(122) == pytest.approx(1.79140, rel = 0.0003)
    assert psy.GetSatVapPres(212) == pytest.approx(14.7094, rel = 0.0003)
    assert psy.GetSatVapPres(300) == pytest.approx(67.0206, rel = 0.0003)

# Test that the NR in GetTDewPointFromVapPres converges.
# This test was known problem in versions of PsychroLib <= 2.0.0
def test_GetTDewPointFromVapPres_convergence(psy):
    TDryBulb = np.arange(-148, 392, 1)
    RelHum = np.arange(0, 1, 0.1)
    Pressure = np.arange(8.6, 17.4, 1)
    for T in TDryBulb:
        for RH in RelHum:
            for p in Pressure:
                psy.GetTWetBulbFromRelHum(T, RH, p)
    print('GetTDewPointFromVapPres converged')

# Test saturation humidity ratio
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is not terrific - up to 2% difference with the values published in the table
def test_GetSatHumRatio(psy):
    assert psy.GetSatHumRatio(-58, 14.696) == pytest.approx(0.0000243, rel = 0.01)
    assert psy.GetSatHumRatio( -4, 14.696) == pytest.approx(0.0006373, rel = 0.01)
    assert psy.GetSatHumRatio( 23, 14.696) == pytest.approx(0.0024863, rel = 0.005)
    assert psy.GetSatHumRatio( 41, 14.696) == pytest.approx(0.005425, rel = 0.005)
    assert psy.GetSatHumRatio( 77, 14.696) == pytest.approx(0.020173, rel = 0.005)
    assert psy.GetSatHumRatio(122, 14.696) == pytest.approx(0.086863, rel = 0.01)
    assert psy.GetSatHumRatio(185, 14.696) == pytest.approx(0.838105, rel = 0.02)

# Test enthalpy at saturation
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is rarely better than 1%, and close to 3% at -5 C
def test_GetSatAirEnthalpy(psy):
    assert psy.GetSatAirEnthalpy(-58, 14.696) == pytest.approx(-13.906, rel = 0.01)
    assert psy.GetSatAirEnthalpy( -4, 14.696) == pytest.approx( -0.286, rel = 0.01)
    assert psy.GetSatAirEnthalpy( 23, 14.696) == pytest.approx(  8.186, rel = 0.03)
    assert psy.GetSatAirEnthalpy( 41, 14.696) == pytest.approx( 15.699, rel = 0.01)
    assert psy.GetSatAirEnthalpy( 77, 14.696) == pytest.approx( 40.576, rel = 0.01)
    assert psy.GetSatAirEnthalpy(122, 14.696) == pytest.approx(126.066, rel = 0.01)
    assert psy.GetSatAirEnthalpy(185, 14.696) == pytest.approx(999.749, rel = 0.01)


###############################################################################
# Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
# These relationships are identified with bold arrows in the doc's diagram
###############################################################################

# Test of relationships between vapour pressure and dew point temperature
# No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
def test_VapPres_TDewPoint(psy):
    VapPres = psy.GetVapPresFromTDewPoint(-4.0)
    assert psy.GetTDewPointFromVapPres(59.0, VapPres) == pytest.approx(-4.0, abs = 0.001)
    VapPres = psy.GetVapPresFromTDewPoint(41.0)
    assert psy.GetTDewPointFromVapPres(59.0, VapPres) == pytest.approx(41.0, abs = 0.001)
    VapPres = psy.GetVapPresFromTDewPoint(122.0)
    assert psy.GetTDewPointFromVapPres(140.0, VapPres) == pytest.approx(122.0, abs = 0.001)

## Test of relationships between humidity ratio and vapour pressure
## Humidity ratio values to test against are calculated with Excel
def test_HumRatio_VapPres(psy):
    HumRatio = psy.GetHumRatioFromVapPres(0.45973, 14.175)          # conditions at 77 F, std atm pressure at 1000 ft
    assert HumRatio == pytest.approx(0.0208473311024865, rel = 0.000001)
    VapPres = psy.GetVapPresFromHumRatio(HumRatio, 14.175)
    assert VapPres == pytest.approx(0.45973, abs = 0.00001)

## Test of relationships between vapour pressure and relative humidity
def test_VapPres_RelHum(psy):
    VapPres = psy.GetVapPresFromRelHum(77, 0.8)
    assert VapPres == pytest.approx(0.45973*0.8, rel = 0.0003)
    RelHum = psy.GetRelHumFromVapPres(77, VapPres)
    assert RelHum == pytest.approx(0.8, rel = 0.0003)

## Test of relationships between humidity ratio and wet bulb temperature
## The formulae are tested for two conditions, one above freezing and the other below
## Humidity ratio values to test against are calculated with Excel
def test_HumRatio_TWetBulb(psy):
    # Above freezing
    HumRatio = psy.GetHumRatioFromTWetBulb(86, 77, 14.175)
    assert HumRatio == pytest.approx(0.0187193288418892, rel = 0.0003)
    TWetBulb = psy.GetTWetBulbFromHumRatio(86, HumRatio, 14.175)
    assert TWetBulb == pytest.approx(77, abs = 0.001)
    # Below freezing
    HumRatio = psy.GetHumRatioFromTWetBulb(30.2, 23.0, 14.175)
    assert HumRatio == pytest.approx(0.00114657481090184, rel = 0.0003)
    TWetBulb = psy.GetTWetBulbFromHumRatio(30.2, HumRatio, 14.1751)
    assert TWetBulb == pytest.approx(23.0, abs = 0.001)
    # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    assert psy.GetTWetBulbFromHumRatio(25,1e-09,95461) == psy.GetTWetBulbFromHumRatio(25,1e-07,95461)


###############################################################################
# Dry air calculations
###############################################################################

# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
def test_DryAir(psy):
    assert psy.GetDryAirEnthalpy(77) == pytest.approx(18.498, rel = 0.001)
    assert psy.GetDryAirVolume(77, 14.696) == pytest.approx(13.5251, rel = 0.001)
    assert psy.GetDryAirDensity(77, 14.696) == pytest.approx(1/13.5251, rel = 0.001)
    assert psy.GetTDryBulbFromEnthalpyAndHumRatio(42.6168, 0.02) == pytest.approx(85.97, abs = 0.05)
    assert psy.GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 86) == pytest.approx(0.02, rel = 0.001)


###############################################################################
# Moist air calculations
###############################################################################

# Values are compared against values calculated with Excel
def test_MoistAir(psy):
    assert psy.GetMoistAirEnthalpy(86, 0.02) == pytest.approx(42.6168, rel = 0.0003)
    assert psy.GetMoistAirVolume(86, 0.02, 14.175) == pytest.approx(14.7205749002918, rel = 0.0003)
    assert psy.GetMoistAirDensity(86, 0.02, 14.175) == pytest.approx(0.0692907720594378, rel = 0.0003)

def test_GetTDryBulbFromMoistAirVolumeAndHumRatio(psy):
    assert psy.GetTDryBulbFromMoistAirVolumeAndHumRatio(14.7205749002918, 0.02, 14.175) == pytest.approx(86, rel = 0.0003)

###############################################################################
# Test standard atmosphere
###############################################################################

# The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
def test_GetStandardAtmPressure(psy):
    assert psy.GetStandardAtmPressure(-1000) == pytest.approx(15.236, abs = 1)
    assert psy.GetStandardAtmPressure(    0) == pytest.approx(14.696, abs = 1)
    assert psy.GetStandardAtmPressure( 1000) == pytest.approx(14.175, abs = 1)
    assert psy.GetStandardAtmPressure( 3000) == pytest.approx(13.173, abs = 1)
    assert psy.GetStandardAtmPressure(10000) == pytest.approx(10.108, abs = 1)
    assert psy.GetStandardAtmPressure(30000) == pytest.approx( 4.371, abs = 1)

def test_GetStandardAtmTemperature(psy):
    assert psy.GetStandardAtmTemperature(-1000) == pytest.approx( 62.6, abs = 0.1)
    assert psy.GetStandardAtmTemperature(    0) == pytest.approx( 59.0, abs = 0.1)
    assert psy.GetStandardAtmTemperature( 1000) == pytest.approx( 55.4, abs = 0.1)
    assert psy.GetStandardAtmTemperature( 3000) == pytest.approx( 48.3, abs = 0.1)
    assert psy.GetStandardAtmTemperature(10000) == pytest.approx( 23.4, abs = 0.1)
    assert psy.GetStandardAtmTemperature(30000) == pytest.approx(-47.8, abs = 0.2)          # Doesn't work with abs = 0.1


###############################################################################
# Test sea level pressure conversions
###############################################################################

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267,
# converted to IP
def test_SeaLevel_Station_Pressure(psy):
    SeaLevelPressure = psy.GetSeaLevelPressure(14.681662559, 344.488, 62.942)
    assert SeaLevelPressure == pytest.approx(14.8640475, abs = 0.0001)
    assert psy.GetStationPressure(SeaLevelPressure, 344.488, 62.942) == pytest.approx(14.681662559, abs = 0.0001)

###############################################################################
# Test conversion between humidity types
###############################################################################

def test_GetSpecificHumFromHumRatio(psy):
    assert psy.GetSpecificHumFromHumRatio(0.006) == pytest.approx(0.00596421471, rel=0.01)

def test_GetHumRatioFromSpecificHum(psy):
    assert psy.GetHumRatioFromSpecificHum(0.00596421471) == pytest.approx(0.006, rel=0.01)

###############################################################################
# Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
###############################################################################

def test_AllPsychrometrics(psy):
    # This is example 1. The values are provided in the text of the Handbook
    HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        psy.CalcPsychrometricsFromTWetBulb(100, 65, 14.696)
    assert HumRatio == pytest.approx(0.00523, abs = 0.001)
    assert TDewPoint == pytest.approx(40, abs = 1.0)             # not great agreement
    assert RelHum == pytest.approx(0.13, abs = 0.01)
    assert MoistAirEnthalpy == pytest.approx(29.80, abs = 0.1)
    assert MoistAirVolume == pytest.approx(14.22, rel = 0.01)

    # Reverse calculation: recalculate wet bulb temperature from dew point temperature
    HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        psy.CalcPsychrometricsFromTDewPoint(100, TDewPoint, 14.696)
    assert TWetBulb == pytest.approx(65, abs = 0.1)

   # Reverse calculation: recalculate wet bulb temperature from relative humidity
    HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        psy.CalcPsychrometricsFromRelHum(100, RelHum, 14.696)
    assert TWetBulb == pytest.approx(65, abs = 0.1)
