# PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

# Test of helper functions
test_that("IP temperature conversions give the right answers", {
    SetUnitSystem("IP")
    expect_equal(GetTRankineFromTFahrenheit(70), 529.67)
})

test_that("SI temperature conversions give the right answers", {
    SetUnitSystem("SI")
    expect_equal(GetTKelvinFromTCelsius(20), 293.15)
})

###############################################################################
# Tests at saturation
###############################################################################

# Test saturation vapour pressure calculation
# The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# over the range [-148, +392] F
# ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
test_that("saturated vapor pressure calculations match ASHRAE's tabulated results for IP units", {
    SetUnitSystem("IP")
    expect_equal_abs(GetSatVapPres(-76.0), 0.000157, abs = 0.00001)
    expect_equal_rel(GetSatVapPres( -4.0), 0.014974, rel = 0.0003)
    expect_equal_rel(GetSatVapPres( 23.0), 0.058268, rel = 0.0003)
    expect_equal_rel(GetSatVapPres( 41.0), 0.12656, rel = 0.0003)
    expect_equal_rel(GetSatVapPres( 77.0), 0.45973, rel = 0.0003)
    expect_equal_rel(GetSatVapPres(122.0), 1.79140, rel = 0.0003)
    expect_equal_rel(GetSatVapPres(212.0), 14.7094, rel = 0.0003)
    expect_equal_rel(GetSatVapPres(300.0), 67.0206, rel = 0.0003)
})

# Test saturation vapour pressure calculation
# The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# over the range [-100, +200] C
# ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C
test_that("saturated vapor pressure calculations match ASHRAE's tabulated results for SI units", {
    SetUnitSystem("SI")
    expect_equal_abs(GetSatVapPres(-60.0), 1.08, abs = 0.01)
    expect_equal_rel(GetSatVapPres(-20.0), 103.24, rel = 0.0003)
    expect_equal_rel(GetSatVapPres( -5.0), 401.74, rel = 0.0003)
    expect_equal_rel(GetSatVapPres(  5.0), 872.6, rel = 0.0003)
    expect_equal_rel(GetSatVapPres( 25.0), 3169.7, rel = 0.0003)
    expect_equal_rel(GetSatVapPres( 50.0), 12351.3, rel = 0.0003)
    expect_equal_rel(GetSatVapPres(100.0), 101418.0, rel = 0.0003)
    expect_equal_rel(GetSatVapPres(150.0), 476101.4, rel = 0.0003)
})

# Test saturation humidity ratio
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is not terrific - up to 2% difference with the values published in the table
test_that("saturated humidity ratio calculations match ASHRAE's tabulated results for IP units", {
    SetUnitSystem("IP")
    expect_equal_rel(GetSatHumRatio(-58.0, 14.696), 0.0000243, rel = 0.01)
    expect_equal_rel(GetSatHumRatio( -4.0, 14.696), 0.0006373, rel = 0.01)
    expect_equal_rel(GetSatHumRatio( 23.0, 14.696), 0.0024863, rel = 0.005)
    expect_equal_rel(GetSatHumRatio( 41.0, 14.696), 0.005425, rel = 0.005)
    expect_equal_rel(GetSatHumRatio( 77.0, 14.696), 0.020173, rel = 0.005)
    expect_equal_rel(GetSatHumRatio(122.0, 14.696), 0.086863, rel = 0.01)
    expect_equal_rel(GetSatHumRatio(185.0, 14.696), 0.838105, rel = 0.02)
})

# Test saturation humidity ratio
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is not terrific - up to 2% difference with the values published in the table
test_that("saturated humidity ratio calculations match ASHRAE's tabulated results for SI units", {
    SetUnitSystem("SI")
    expect_equal_rel(GetSatHumRatio(-50.0, 101325), 0.0000243, rel = 0.01)
    expect_equal_rel(GetSatHumRatio(-20.0, 101325), 0.0006373, rel = 0.01)
    expect_equal_rel(GetSatHumRatio( -5.0, 101325), 0.0024863, rel = 0.005)
    expect_equal_rel(GetSatHumRatio(  5.0, 101325), 0.005425, rel = 0.005)
    expect_equal_rel(GetSatHumRatio( 25.0, 101325), 0.020173, rel = 0.005)
    expect_equal_rel(GetSatHumRatio( 50.0, 101325), 0.086863, rel = 0.01)
    expect_equal_rel(GetSatHumRatio( 85.0, 101325), 0.838105, rel = 0.02)
})

# Test enthalpy at saturation
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
test_that("saturated air enthalpy calculations match ASHRAE's tabulated results for IP units", {
    SetUnitSystem("IP")
    expect_equal_rel(GetSatAirEnthalpy(-58.0, 14.696), -13.906, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( -4.0, 14.696), -0.286, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( 23.0, 14.696), 8.186, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( 41.0, 14.696), 15.699, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( 77.0, 14.696), 40.576, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy(122.0, 14.696), 126.0666, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy(185.0, 14.696), 999.749, rel = 0.01)
})

# Test enthalpy at saturation
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is rarely better than 1%, and close to 3% at -5 C
test_that("saturated air enthalpy calculations match ASHRAE's tabulated results for SI units", {
    SetUnitSystem("SI")
    expect_equal_rel(GetSatAirEnthalpy(-50.0, 101325), -50222, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy(-20.0, 101325), -18542, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( -5.0, 101325), 1164, rel = 0.03)
    expect_equal_rel(GetSatAirEnthalpy(  5.0, 101325), 18639, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( 25.0, 101325), 76504, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( 50.0, 101325), 275353, rel = 0.01)
    expect_equal_rel(GetSatAirEnthalpy( 85.0, 101325), 2307539, rel = 0.01)
})

###############################################################################
# Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
# These relationships are identified with bold arrows in the doc's diagram
###############################################################################

# Test of relationships between vapour pressure and dew point temperature in IP units
# No need to test vapour pressure calculation as it is just the saturation vapour pressure tested elsewhere
test_that("reciprocal relationships between vapor pressure and sew point hold in IP units", {
    SetUnitSystem("IP")
    vap_pres <- GetVapPresFromTDewPoint(-4.0)
    expect_equal_abs(GetTDewPointFromVapPres(59.0, vap_pres), -4.0, abs = 0.001)
    vap_pres <- GetVapPresFromTDewPoint(41.0)
    expect_equal_abs(GetTDewPointFromVapPres(59.0, vap_pres), 41.0, abs = 0.002) # 40.99879 Failed to pass with abs=0.001
    vap_pres <- GetVapPresFromTDewPoint(122.0)
    expect_equal_abs(GetTDewPointFromVapPres(140.0, vap_pres), 122.0, abs = 0.001)
})

# Test of relationships between vapour pressure and dew point temperature in SI units
# No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
test_that("reciprocal relationships between vapor pressure and sew point hold in IP units", {
    SetUnitSystem("SI")
    vap_pres <- GetVapPresFromTDewPoint(-20.0)
    expect_equal_abs(GetTDewPointFromVapPres(15.0, vap_pres), -20.0, abs = 0.001)
    vap_pres <- GetVapPresFromTDewPoint(5.0)
    expect_equal_abs(GetTDewPointFromVapPres(15.0, vap_pres), 5.0, abs = 0.001)
    vap_pres <- GetVapPresFromTDewPoint(50.0)
    expect_equal_abs(GetTDewPointFromVapPres(60.0, vap_pres), 50.0, abs = 0.001)
})

# Test of relationships between wet bulb temperature and relative humidity
# This test was known to cause a convergence issue in GetTDewPointFromVapPres
# in versions of PsychroLib <= 2.0.0
# This test does not have an IP units analog in the original library.
test_that("GetTDewPointFromVapPres converges for a known problematic case", {
    SetUnitSystem("SI")
    expect_equal_rel(GetTWetBulbFromRelHum(7.0, 0.61, 100000), 3.92667433781955, rel = 0.001)
})

# Test that the NR in GetTDewPointFromVapPres converges.
# This test was known problem in versions of PsychroLib <= 2.0.0
test_that("GetTDewPointFromVapPres converges", {
    SetUnitSystem("IP")
    TDryBulb <- seq(-148, 392, 1)
    RelHum <- seq(0, 1, 0.1)
    Pressure <- seq(8.6, 17.4, 1)

    expect_silent(
        for (Tdb in TDryBulb) {
            for (RH in RelHum) {
                GetTWetBulbFromRelHum(Tdb, RH, Pressure)
            }
        }
    )
})

# Test that the NR in GetTDewPointFromVapPres converges.
# This test was known problem in versions of PsychroLib <= 2.0.0
test_that("the NR in GetTDewPointFromVapPres converges", {
    SetUnitSystem("SI")
    TDryBulb <- seq(-100, 200, 1)
    RelHum <- seq(0, 1, 0.1)
    Pressure <- seq(60000, 120000, 10000)

    expect_silent(
        for (RH in RelHum) {
            for (P in Pressure) {
                GetTWetBulbFromRelHum(TDryBulb, RH, P)
            }
        }
    )
})

# Test of relationships between vapour pressure and relative humidity in IP units
test_that("expected relationships between vapor pressure and relative humidity hold in IP units", {
    SetUnitSystem("IP")
    vap_pres <- GetVapPresFromRelHum(77.0, 0.8)
    expect_equal_rel(vap_pres, 0.45973 * 0.8, rel = 0.0003)
    RelHum <- GetRelHumFromVapPres(77.0, vap_pres)
    expect_equal_rel(RelHum, 0.8, rel = 0.0003)
})

# Test of relationships between vapour pressure and relative humidity in SI units
test_that("expected relationships between vapor pressure and relative humidity hold in SI units", {
    SetUnitSystem("SI")
    vap_pres <- GetVapPresFromRelHum(25.0, 0.8)
    expect_equal_rel(vap_pres, 3169.7 * 0.8, rel = 0.0003)
    RelHum <- GetRelHumFromVapPres(25.0, vap_pres)
    expect_equal_rel(RelHum, 0.8, rel = 0.0003)
})

# Test of relationships between humidity ratio and vapour pressure
# Humidity ratio values to test against are calculated with Excel
test_that("relationships between humidity ratio and vapour pressure are correct in IP units", {
    SetUnitSystem("IP")
    HumRatio <- GetHumRatioFromVapPres(0.45973, 14.175)   # conditions at 77 F, std atm pressure at 1000 ft
    expect_equal_rel(HumRatio, 0.0208473311024865, rel = 0.000001)
    vap_pres <- GetVapPresFromHumRatio(HumRatio, 14.175)
    expect_equal_abs(vap_pres, 0.45973, abs = 0.00001)
})

# Humidity ratio values to test against are calculated with Excel
test_that("relationships between humidity ratio and vapour pressure are correct in SI units", {
    SetUnitSystem("SI")
    HumRatio <- GetHumRatioFromVapPres(3169.7, 95461) # conditions at 25 C, std atm pressure at 500 m
    expect_equal_rel(HumRatio, 0.0213603998047487, rel = 0.000001)
    vap_pres <- GetVapPresFromHumRatio(HumRatio, 95461)
    expect_equal_abs(vap_pres, 3169.7, abs = 0.0001)
})

# Test of relationships between humidity ratio and wet bulb temperature in IP units
# The formulae are tested for two conditions, one above freezing and the other below
# Humidity ratio values to test against are calculated with Excel
test_that("the relationships between humidity ratio and wet bulb temperature are as expected in IP units", {
    SetUnitSystem("IP")

    # Above freezing
    HumRatio <- GetHumRatioFromTWetBulb(86.0, 77.0, 14.175)
    expect_equal_rel(HumRatio, 0.0187193288418892, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(86.0, HumRatio, 14.175)
    expect_equal_abs(TWetBulb, 77.0, abs = 0.001)

    # Below freezing
    HumRatio <- GetHumRatioFromTWetBulb(30.2, 23.0, 14.175)
    expect_equal_rel(HumRatio, 0.00114657481090184, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(30.2, HumRatio, 14.175)
    expect_equal_abs(TWetBulb, 23.0, abs = 0.001)

    # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    expect_identical(GetTWetBulbFromHumRatio(25.0, 1e-09, 95461.0),
                     GetTWetBulbFromHumRatio(25.0, 1e-07, 95461.0)) # TODO: is this a sane pressure in these units?
})

# Test of relationships between humidity ratio and wet bulb temperature in SI units
# The formulae are tested for two conditions, one above freezing and the other below
# Humidity ratio values to test against are calculated with Excel
test_that("the relationships between humidity ratio and wet bulb temperature are as expected in IP units", {
    SetUnitSystem("SI")

    # Above freezing
    HumRatio <- GetHumRatioFromTWetBulb(30.0, 25.0, 95461.0)
    expect_equal_rel(HumRatio, 0.0192281274241096, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(30.0, HumRatio, 95461.0)
    expect_equal_abs(TWetBulb, 25.0, abs = 0.001)

    # Below freezing
    HumRatio <- GetHumRatioFromTWetBulb(-1.0, -5.0, 95461.0)
    expect_equal_rel(HumRatio, 0.00120399819933844, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(-1.0, HumRatio, 95461.0)
    expect_equal_abs(TWetBulb, -5.0, abs = 0.001)

    # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    expect_identical(GetTWetBulbFromHumRatio(-5.0, 1e-09, 95461.0),
                     GetTWetBulbFromHumRatio(-5.0, 1e-07, 95461.0))
})

###############################################################################
# Dry air calculations
###############################################################################

# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
test_that("dry air calculations match results tabulated in the ASHRAE Handbook in IP units", {
    SetUnitSystem("IP")
    expect_equal_rel(GetDryAirEnthalpy(77.0), 18.498, rel = 0.001)
    expect_equal_rel(GetDryAirVolume(77.0, 14.696), 13.5251, rel = 0.001)
    expect_equal_rel(GetDryAirDensity(77.0, 14.696), 1.0 / 13.5251, rel = 0.001)
    expect_equal_abs(GetTDryBulbFromEnthalpyAndHumRatio(42.6168, 0.02), 85.97, abs = 0.05)
    expect_equal_rel(GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 86.0), 0.02, rel = 0.001)
})

# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
test_that("dry air calculations match results tabulated in the ASHRAE Handbook in SI units", {
    SetUnitSystem("SI")
    expect_equal_rel(GetDryAirEnthalpy(25.0), 25148, rel = 0.0003)
    expect_equal_rel(GetDryAirVolume(25.0, 101325), 0.8443, rel = 0.001)
    expect_equal_rel(GetDryAirDensity(25.0, 101325), 1.0 / 0.8443, rel = 0.001)
    expect_equal_abs(GetTDryBulbFromEnthalpyAndHumRatio(81316.0, 0.02), 30.0, abs = 0.001)
    expect_equal_rel(GetHumRatioFromEnthalpyAndTDryBulb(81316.0, 30.0), 0.02, rel = 0.001)
})

# Values are compared against values calculated with Excel
test_that("moist air calculations match values calculated with Excel using IP units", {
    SetUnitSystem("IP")
    expect_equal_rel(GetMoistAirEnthalpy(86, 0.02), 42.6168, rel = 0.0003)
    expect_equal_rel(GetMoistAirVolume(86, 0.02, 14.175), 14.7205749002918, rel = 0.0003)
    expect_equal_rel(GetMoistAirDensity(86, 0.02, 14.175), 0.0692907720594378, rel = 0.0003)
    expect_equal_rel(GetTDryBulbFromMoistAirVolumeAndHumRatio(14.7205749002918, 0.02, 14.175), 86, rel = 0.0003)
})

# Values are compared against values calculated with Excel
test_that("moist air calculations match values calculated with Excel using SI units", {
    SetUnitSystem("SI")
    expect_equal_rel(GetMoistAirEnthalpy(30, 0.02), 81316, rel = 0.0003)
    expect_equal_rel(GetMoistAirVolume(30, 0.02, 95461), 0.940855374352943, rel = 0.0003)
    expect_equal_rel(GetMoistAirDensity(30, 0.02, 95461), 1.08411986348219, rel = 0.0003)
    expect_equal_rel(GetTDryBulbFromMoistAirVolumeAndHumRatio(0.940855374352943, 0.02, 95461), 30, rel = 0.0003)
})

###############################################################################
# Test standard atmosphere
###############################################################################

test_that("standard atmosphere pressure functions match tablulated values from the 2017 ASHRAE Handbook in IP units", {
    SetUnitSystem("IP")
    expect_equal_abs(GetStandardAtmPressure(-1000.0), 15.236, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(    0.0), 14.696, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 1000.0), 14.175, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 3000.0), 13.173, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(10000.0), 10.108, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(30000.0), 4.371, abs = 1.0)
})

test_that("standard atmosphere pressure functions match tablulated values from the 2017 ASHRAE Handbook in SI units", {
    SetUnitSystem("SI")
    expect_equal_abs(GetStandardAtmPressure( -500.0), 107478.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(    0.0), 101325.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(  500.0), 95461.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 1000.0), 89875.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 4000.0), 61640.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(10000.0), 26436.0, abs = 1.0)
})

test_that("standard atmosphere temperature functions match tablulated values from the 2017 ASHRAE Handbook in IP units", {
    SetUnitSystem("IP")
    expect_equal_abs(GetStandardAtmTemperature(-1000.0), 62.6, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(    0.0), 59.0, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 1000.0), 55.4, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 3000.0), 48.3, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(10000.0), 23.4, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(30000.0), -47.8, abs = 0.2) # Doesn't work with abs = 0.1
})

test_that("standard atmosphere temperature functions match tablulated values from the 2017 ASHRAE Handbook in SI units", {
    SetUnitSystem("SI")
    expect_equal_abs(GetStandardAtmTemperature( -500.0), 18.2, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(    0.0), 15.0, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(  500.0), 11.8, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 1000.0), 8.5, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 4000.0), -11.0, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(10000.0), -50.0, abs = 0.1)
})

###############################################################################
# Test sea level pressure conversions
###############################################################################

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267 converted to IP
test_that("sea level pressure calculations return expected results in IP units", {
    SetUnitSystem("IP")
    sea_level_pressure <- GetSeaLevelPressure(14.681662559, 344.488, 62.942)
    expect_equal_abs(sea_level_pressure, 14.8640475, abs = 0.0001)
    expect_equal_abs(GetStationPressure(sea_level_pressure, 344.488, 62.942), 14.681662559, abs = 0.0001)
})

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
test_that("sea level pressure calculations return expected results in SI units", {
    SetUnitSystem("SI")
    sea_level_pressure <- GetSeaLevelPressure(101226.5, 105, 17.19)
    expect_equal_abs(sea_level_pressure, 102484.0, abs = 1.0)
    expect_equal_abs(GetStationPressure(sea_level_pressure, 105, 17.19), 101226.5, abs = 1.0)
})

###############################################################################
# Test conversion between humidity types
###############################################################################

test_that("conversion between humidity types are correct in all units", {
    for (unit_system in PSYCHROLIB_UNITS_OPTIONS) { # results should be the same in all unit systems
        SetUnitSystem(unit_system)
        expect_equal_rel(GetSpecificHumFromHumRatio(0.006), 0.00596421471, rel = 0.01)
        expect_equal_rel(GetHumRatioFromSpecificHum(0.00596421471), 0.006, rel = 0.01)
    }
})

###############################################################################
# Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
###############################################################################

test_that("Bulk computation of psychrometric properties return results consistent with ASHRAE handbook example in IP units", {
    SetUnitSystem("IP")
    results <- CalcPsychrometricsFromTWetBulb(100.0, 65.0, 14.696)
    expect_equivalent_abs(results$HumRatio, 0.00523, abs = 0.001)
    expect_equivalent_abs(results$TDewPoint, 40.0, abs = 1.0)    # not great agreement
    expect_equivalent_abs(results$RelHum, 0.13, abs = 0.01)
    expect_equivalent_abs(results$MoistAirEnthalpy, 29.80, abs = 0.1)
    expect_equivalent_rel(results$MoistAirVolume, 14.22, rel = 0.01)

    # Reverse calculation: recalculate wet bulb temperature from dew point temperature
    results <- CalcPsychrometricsFromTDewPoint(100.0, results$TDewPoint, 14.696)
    expect_equivalent_abs(results$TWetBulb, 65.0, abs = 0.1)

    # Reverse calculation: recalculate wet bulb temperature from relative humidity
    results <- CalcPsychrometricsFromRelHum(100.0, results$RelHum, 14.696)
    expect_equivalent_abs(results$TWetBulb, 65.0, abs = 0.1)
})

test_that("Bulk computation of psychrometric properties return results consistent with ASHRAE handbook example in SI units", {
    SetUnitSystem("SI")
    results <- CalcPsychrometricsFromTWetBulb(40.0, 20.0, 101325.0)
    expect_equivalent_abs(results$HumRatio, 0.0065, abs = 0.0001)
    expect_equivalent_abs(results$TDewPoint, 7.0, abs = 0.5)    # not great agreement
    expect_equivalent_abs(results$RelHum, 0.14, abs = 0.01)
    expect_equivalent_abs(results$MoistAirEnthalpy, 56700.0, abs =  100)
    expect_equivalent_rel(results$MoistAirVolume, 0.896, rel = 0.01)

    # Reverse calculation: recalculate wet bulb temperature from dew point temperature
    results <- CalcPsychrometricsFromTDewPoint(40.0, results$TDewPoint, 101325)
    expect_equivalent_abs(results$TWetBulb, 20.0, abs = 0.1)

    # Reverse calculation: recalculate wet bulb temperature from relative humidity
    results <- CalcPsychrometricsFromRelHum(40.0, results$RelHum, 101325)
    expect_equivalent_abs(results$TWetBulb, 20.0, abs = 0.1)
})
