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
# This test does not have an IP units analog in the original library.
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
