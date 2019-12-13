# Test saturation vapour pressure calculation
# The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# over the range [-148, +392] F
# ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
test_that("saturated vapor pressure calculations match ASHRAE's tabulated results for IP units", {
  set_unit_system("IP")
  expect_equal_abs(get_sat_vap_pres(-76.0), 0.000157, tolerance = 0.00001)
  expect_equal_rel(get_sat_vap_pres( -4.0), 0.014974, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres( 23.0), 0.058268, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres( 41.0), 0.12656, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres( 77.0), 0.45973, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(122.0), 1.79140, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(212.0), 14.7094, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(300.0), 67.0206, tolerance = 0.0003)
})

# Test saturation vapour pressure calculation
# The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# over the range [-100, +200] C
# ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C
test_that("saturated vapor pressure calculations match ASHRAE's tabulated results for SI units", {
  set_unit_system("SI")
  expect_equal_abs(get_sat_vap_pres(-60.0), 1.08, tolerance = 0.01)
  expect_equal_rel(get_sat_vap_pres(-20.0), 103.24, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(-5.0), 401.74, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(5.0), 872.6, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(25.0), 3169.7, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(50.0), 12351.3, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(100.0), 101418.0, tolerance = 0.0003)
  expect_equal_rel(get_sat_vap_pres(150.0), 476101.4, tolerance = 0.0003)
})

# Test saturation humidity ratio
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is not terrific - up to 2% difference with the values published in the table
test_that("saturated humidity ratio calculations match ASHRAE's tabulated results for IP units", {
  set_unit_system("IP")
  expect_equal_rel(get_sat_hum_ratio(-58.0, 14.696), 0.0000243, tolerance = 0.01)
  expect_equal_rel(get_sat_hum_ratio(-4.0, 14.696), 0.0006373, tolerance = 0.01)
  expect_equal_rel(get_sat_hum_ratio(23.0, 14.696), 0.0024863, tolerance = 0.005)
  expect_equal_rel(get_sat_hum_ratio(41.0, 14.696), 0.005425, tolerance = 0.005)
  expect_equal_rel(get_sat_hum_ratio(77.0, 14.696), 0.020173, tolerance = 0.005)
  expect_equal_rel(get_sat_hum_ratio(122.0, 14.696), 0.086863, tolerance = 0.01)
  expect_equal_rel(get_sat_hum_ratio(185.0, 14.696), 0.838105, tolerance = 0.02)
})

# Test saturation humidity ratio
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is not terrific - up to 2% difference with the values published in the table
test_that("saturated humidity ratio calculations match ASHRAE's tabulated results for SI units", {
  set_unit_system("SI")
  expect_equal_rel(get_sat_hum_ratio(-50.0, 101325), 0.0000243, tolerance = 0.01)
  expect_equal_rel(get_sat_hum_ratio(-20.0, 101325), 0.0006373, tolerance = 0.01)
  expect_equal_rel(get_sat_hum_ratio(-5.0, 101325), 0.0024863, tolerance = 0.005)
  expect_equal_rel(get_sat_hum_ratio(5.0, 101325), 0.005425, tolerance = 0.005)
  expect_equal_rel(get_sat_hum_ratio(25, 101325), 0.020173, tolerance = 0.005)
  expect_equal_rel(get_sat_hum_ratio(50.0, 101325), 0.086863, tolerance = 0.01)
  expect_equal_rel(get_sat_hum_ratio(85.0, 101325), 0.838105, tolerance = 0.02)
})

# Test enthalpy at saturation
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# TODO: does it make sense to test absolute enthalpy values? Isn't it more important that changes in enthalpy are consistent?
# TODO:   a 1% error in absolute enthalpy may be important or not based on how close it is to an arbitrary zero
test_that("saturated air enthalpy calculations match ASHRAE's tabulated results for IP units", {
  set_unit_system("IP")
  expect_equal_rel(get_sat_air_enthalpy(-58.0, 14.696), -13.906, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(-4.0, 14.696), -0.286, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(23.0, 14.696), 8.186, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(41.0, 14.696), 15.699, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(77.0, 14.696), 40.576, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(122.0, 14.696), 126.0666, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(185.0, 14.696), 999.749, tolerance = 0.01)
})

# Test enthalpy at saturation
# The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
# Agreement is rarely better than 1%, and close to 3% at -5 C
# TODO: does it make sense to test absolute enthalpy values? Isn't it more important that changes in enthalpy are consistent?
# TODO:   a 1% error in absolute enthalpy may be important or not based on how close it is to an arbitrary zero
test_that("saturated air enthalpy calculations match ASHRAE's tabulated results for SI units", {
  set_unit_system("SI")
  expect_equal_rel(get_sat_air_enthalpy(-50.0, 101325), -50222, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(-20.0, 101325), -18542, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(-5.0, 101325), 1164, tolerance = 0.03)
  expect_equal_rel(get_sat_air_enthalpy(5.0, 101325), 18639, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(25.0, 101325), 76504, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(50.0, 101325), 275353, tolerance = 0.01)
  expect_equal_rel(get_sat_air_enthalpy(85.0, 101325), 2307539, tolerance = 0.01)
})
