###############################################################################
# Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
###############################################################################

test_that("Bulk computation of psychrometric properties return results consistent with ASHRAE handbook example in IP units", {
  set_unit_system("IP")
  results <- calc_psychrometrics_from_t_wet_bulb(100.0, 65.0, 14.696)
  expect_equivalent_abs(results['hum_ratio'], 0.00523, tolerance = 0.001)
  expect_equivalent_abs(results['t_dew_point'], 40.0, tolerance = 1.0)    # not great agreement
  expect_equivalent_abs(results['rel_hum'], 0.13, tolerance = 0.01)
  expect_equivalent_abs(results['moist_air_enthalpy'], 29.80, tolerance = 0.1)
  expect_equivalent_rel(results['moist_air_volume'], 14.22, tolerance = 0.01)

  # Reverse calculation: recalculate wet bulb temperature from dew point temperature
  results <- calc_psychrometrics_from_t_dew_point(100.0, results['t_dew_point'], 14.696)
  expect_equivalent_abs(results['t_wet_bulb'], 65.0, tolerance = 0.1)

  # Reverse calculation: recalculate wet bulb temperature from relative humidity
  results <- calc_psychrometrics_from_rel_hum(100.0, results['rel_hum'], 14.696)
  expect_equivalent_abs(results['t_wet_bulb'], 65.0, tolerance = 0.1)
})

test_that("Bulk computation of psychrometric properties return results consistent with ASHRAE handbook example in SI units", {
  set_unit_system("SI")
  results <- calc_psychrometrics_from_t_wet_bulb(40.0, 20.0, 101325.0)
  expect_equivalent_abs(results['hum_ratio'], 0.0065, tolerance = 0.0001)
  expect_equivalent_abs(results['t_dew_point'], 7.0, tolerance = 0.5)    # not great agreement
  expect_equivalent_abs(results['rel_hum'], 0.14, tolerance = 0.01)
  expect_equivalent_abs(results['moist_air_enthalpy'], 56700.0, tolerance =  100)
  expect_equivalent_rel(results['moist_air_volume'], 0.896, tolerance = 0.01)

  # Reverse calculation: recalculate wet bulb temperature from dew point temperature
  results <- calc_psychrometrics_from_t_dew_point(40.0, results['t_dew_point'], 101325)
  expect_equivalent_abs(results['t_wet_bulb'], 20.0, tolerance = 0.1)

  # Reverse calculation: recalculate wet bulb temperature from relative humidity
  results <- calc_psychrometrics_from_rel_hum(40.0, results['rel_hum'], 101325)
  expect_equivalent_abs(results['t_wet_bulb'], 20.0, tolerance = 0.1)
})
