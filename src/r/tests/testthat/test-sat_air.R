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
