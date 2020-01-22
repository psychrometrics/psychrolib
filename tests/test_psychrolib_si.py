# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

# Test of PsychroLib in SI units for Python, C, and Fortran.

import numpy as np
import pytest

pytestmark = pytest.mark.usefixtures('SetUnitSystem_SI')

# Test of helper functions
def test_GetTKelvinFromTCelsius(psy):
    assert psy.GetTKelvinFromTCelsius(20) == pytest.approx(293.15, 0.000001)

def test_GetTCelsiusFromTKelvin(psy):
    assert psy.GetTCelsiusFromTKelvin(293.15) == pytest.approx(20, rel = 0.000001)


###############################################################################
# Tests at saturation
###############################################################################

# Test saturation vapour pressure calculation
# The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# over the range [-100, +200] C
# ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C
def test_GetSatVapPres(psy):
    assert psy.GetSatVapPres(-60) == pytest.approx(1.08, abs = 0.01)
    assert psy.GetSatVapPres(-20) == pytest.approx(103.24, rel = 0.0003)
    assert psy.GetSatVapPres( -5) == pytest.approx(401.74, rel = 0.0003)
    assert psy.GetSatVapPres(  5) == pytest.approx(872.6, rel = 0.0003)
    assert psy.GetSatVapPres( 25) == pytest.approx(3169.7, rel = 0.0003)
    assert psy.GetSatVapPres( 50) == pytest.approx(12351.3, rel = 0.0003)
    assert psy.GetSatVapPres(100) == pytest.approx(101418.0, rel = 0.0003)
    assert psy.GetSatVapPres(150) == pytest.approx(476101.4, rel = 0.0003)

# Test saturation humidity ratio
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is not terrific - up to 2% difference with the values published in the table
def test_GetSatHumRatio(psy):
    assert psy.GetSatHumRatio(-50, 101325) == pytest.approx(0.0000243, rel = 0.01)
    assert psy.GetSatHumRatio(-20, 101325) == pytest.approx(0.0006373, rel = 0.01)
    assert psy.GetSatHumRatio( -5, 101325) == pytest.approx(0.0024863, rel = 0.005)
    assert psy.GetSatHumRatio(  5, 101325) == pytest.approx(0.005425, rel = 0.005)
    assert psy.GetSatHumRatio( 25, 101325) == pytest.approx(0.020173, rel = 0.005)
    assert psy.GetSatHumRatio( 50, 101325) == pytest.approx(0.086863, rel = 0.01)
    assert psy.GetSatHumRatio( 85, 101325) == pytest.approx(0.838105, rel = 0.02)

# Test enthalpy at saturation
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is rarely better than 1%, and close to 3% at -5 C
def test_GetSatAirEnthalpy(psy):
    assert psy.GetSatAirEnthalpy(-50, 101325) == pytest.approx( -50222, rel = 0.01)
    assert psy.GetSatAirEnthalpy(-20, 101325) == pytest.approx( -18542, rel = 0.01)
    assert psy.GetSatAirEnthalpy( -5, 101325) == pytest.approx(   1164, rel = 0.03)
    assert psy.GetSatAirEnthalpy(  5, 101325) == pytest.approx(  18639, rel = 0.01)
    assert psy.GetSatAirEnthalpy( 25, 101325) == pytest.approx(  76504, rel = 0.01)
    assert psy.GetSatAirEnthalpy( 50, 101325) == pytest.approx( 275353, rel = 0.01)
    assert psy.GetSatAirEnthalpy( 85, 101325) == pytest.approx(2307539, rel = 0.01)


###############################################################################
# Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
# These relationships are identified with bold arrows in the doc's diagram
###############################################################################

# Test of relationships between vapour pressure and dew point temperature
# No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
def test_VapPres_TDewPoint(psy):
    VapPres = psy.GetVapPresFromTDewPoint(-20.0)
    assert psy.GetTDewPointFromVapPres(15.0, VapPres) == pytest.approx(-20.0, abs = 0.001)
    VapPres = psy.GetVapPresFromTDewPoint(5.0)
    assert psy.GetTDewPointFromVapPres(15.0, VapPres) == pytest.approx(5.0, abs = 0.001)
    VapPres = psy.GetVapPresFromTDewPoint(50.0)
    assert psy.GetTDewPointFromVapPres(60.0, VapPres) == pytest.approx(50.0, abs = 0.001)

# Test of relationships between wet bulb temperature and relative humidity
# This test was known to cause a convergence issue in GetTDewPointFromVapPres
# in versions of PsychroLib <= 2.0.0
def test_TWetBulb_RelHum(psy):
    TWetBulb = psy.GetTWetBulbFromRelHum(7, 0.61, 100000)
    assert TWetBulb == pytest.approx(3.92667433781955, rel = 0.001)

# Test that the NR in GetTDewPointFromVapPres converges.
# This test was known problem in versions of PsychroLib <= 2.0.0
def test_GetTDewPointFromVapPres_convergence(psy):
    TDryBulb = np.arange(-100, 200, 1)
    RelHum = np.arange(0, 1, 0.1)
    Pressure = np.arange(60000, 120000, 10000)
    for T in TDryBulb:
        for RH in RelHum:
            for p in Pressure:
                psy.GetTWetBulbFromRelHum(T, RH, p)
    print('GetTDewPointFromVapPres converged')

# Test of relationships between humidity ratio and vapour pressure
# Humidity ratio values to test against are calculated with Excel
def test_HumRatio_VapPres(psy):
    HumRatio = psy.GetHumRatioFromVapPres(3169.7, 95461)          # conditions at 25 C, std atm pressure at 500 m
    assert HumRatio == pytest.approx(0.0213603998047487, rel = 0.000001)
    VapPres = psy.GetVapPresFromHumRatio(HumRatio, 95461)
    assert VapPres == pytest.approx(3169.7, abs = 0.0001) # FIXME Fortran check abs error, should be 0.00001

# Test of relationships between vapour pressure and relative humidity
def test_VapPres_RelHum(psy):
    VapPres = psy.GetVapPresFromRelHum(25, 0.8)
    assert VapPres == pytest.approx(3169.7*0.8, rel = 0.0003)
    RelHum = psy.GetRelHumFromVapPres(25, VapPres)
    assert RelHum == pytest.approx(0.8, rel = 0.0003)

# Test of relationships between humidity ratio and wet bulb temperature
# The formulae are tested for two conditions, one above freezing and the other below
# Humidity ratio values to test against are calculated with Excel
def test_HumRatio_TWetBulb(psy):
    # Above freezing
    HumRatio = psy.GetHumRatioFromTWetBulb(30, 25, 95461)
    assert HumRatio == pytest.approx(0.0192281274241096, rel = 0.0003)
    TWetBulb = psy.GetTWetBulbFromHumRatio(30, HumRatio, 95461)
    assert TWetBulb == pytest.approx(25, abs = 0.001)
    # Below freezing
    HumRatio = psy.GetHumRatioFromTWetBulb(-1, -5, 95461)
    assert HumRatio == pytest.approx(0.00120399819933844, rel = 0.0003)
    TWetBulb = psy.GetTWetBulbFromHumRatio(-1, HumRatio, 95461)
    assert TWetBulb == pytest.approx(-5, abs = 0.001)
    # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    assert psy.GetTWetBulbFromHumRatio(-5,1e-09,95461) == psy.GetTWetBulbFromHumRatio(-5,1e-07,95461)


###############################################################################
# Dry air calculations
###############################################################################

# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
def test_DryAir(psy):
    assert psy.GetDryAirEnthalpy(25) == pytest.approx(25148, rel = 0.0003)
    assert psy.GetDryAirVolume(25, 101325) == pytest.approx(0.8443, rel = 0.001)
    assert psy.GetDryAirDensity(25, 101325) == pytest.approx(1/0.8443, rel = 0.001)
    assert psy.GetTDryBulbFromEnthalpyAndHumRatio(81316, 0.02) == pytest.approx(30, abs = 0.001)
    assert psy.GetHumRatioFromEnthalpyAndTDryBulb(81316, 30) == pytest.approx(0.02, rel = 0.001)


###############################################################################
# Moist air calculations
###############################################################################

# Values are compared against values calculated with Excel
def test_MoistAir(psy):
    assert psy.GetMoistAirEnthalpy(30, 0.02) == pytest.approx(81316, rel = 0.0003)
    assert psy.GetMoistAirVolume(30, 0.02, 95461) == pytest.approx(0.940855374352943, rel = 0.0003)
    assert psy.GetMoistAirDensity(30, 0.02, 95461) == pytest.approx(1.08411986348219, rel = 0.0003)

def test_GetTDryBulbFromMoistAirVolumeAndHumRatio(psy):
    assert psy.GetTDryBulbFromMoistAirVolumeAndHumRatio(0.940855374352943, 0.02, 95461) == pytest.approx(30, rel = 0.0003)

###############################################################################
# Test standard atmosphere
###############################################################################

# The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
def test_GetStandardAtmPressure(psy):
    assert psy.GetStandardAtmPressure( -500) == pytest.approx(107478, abs = 1)
    assert psy.GetStandardAtmPressure(    0) == pytest.approx(101325, abs = 1)
    assert psy.GetStandardAtmPressure(  500) == pytest.approx( 95461, abs = 1)
    assert psy.GetStandardAtmPressure( 1000) == pytest.approx( 89875, abs = 1)
    assert psy.GetStandardAtmPressure( 4000) == pytest.approx( 61640, abs = 1)
    assert psy.GetStandardAtmPressure(10000) == pytest.approx( 26436, abs = 1)

def test_GetStandardAtmTemperature(psy):
    assert psy.GetStandardAtmTemperature( -500) == pytest.approx( 18.2, abs = 0.1)
    assert psy.GetStandardAtmTemperature(    0) == pytest.approx( 15.0, abs = 0.1)
    assert psy.GetStandardAtmTemperature(  500) == pytest.approx( 11.8, abs = 0.1)
    assert psy.GetStandardAtmTemperature( 1000) == pytest.approx(  8.5, abs = 0.1)
    assert psy.GetStandardAtmTemperature( 4000) == pytest.approx(-11.0, abs = 0.1)
    assert psy.GetStandardAtmTemperature(10000) == pytest.approx(-50.0, abs = 0.1)


###############################################################################
# Test sea level pressure conversions
###############################################################################

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
def test_SeaLevel_Station_Pressure(psy):
    SeaLevelPressure = psy.GetSeaLevelPressure(101226.5, 105, 17.19)
    assert SeaLevelPressure == pytest.approx(102484.0, abs = 1)
    assert psy.GetStationPressure(SeaLevelPressure, 105, 17.19) == pytest.approx(101226.5, abs = 1)

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
        psy.CalcPsychrometricsFromTWetBulb(40, 20, 101325)
    assert HumRatio == pytest.approx(0.0065, abs = 0.0001)
    assert TDewPoint == pytest.approx(7, abs = 0.5)             # not great agreement
    assert RelHum == pytest.approx(0.14, abs = 0.01)
    assert MoistAirEnthalpy == pytest.approx(56700, abs = 100)
    assert MoistAirVolume == pytest.approx(0.896, rel = 0.01)

    # Reverse calculation: recalculate wet bulb temperature from dew point temperature
    HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        psy.CalcPsychrometricsFromTDewPoint(40, TDewPoint, 101325)
    assert TWetBulb == pytest.approx(20, abs = 0.1)

   # Reverse calculation: recalculate wet bulb temperature from relative humidity
    HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = \
        psy.CalcPsychrometricsFromRelHum(40, RelHum, 101325)
    assert TWetBulb == pytest.approx(20, abs = 0.1)
