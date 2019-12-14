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
