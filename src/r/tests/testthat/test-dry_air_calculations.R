# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
test_that("dry air calculations match results tabulated in the ASHRAE Handbook in IP units", {
  set_unit_system("IP")
  expect_equal_rel(get_dry_air_enthalpy(77.0), 18.498, tolerance = 0.001)
  expect_equal_rel(get_dry_air_volume(77.0, 14.696), 13.5251, tolerance = 0.001)
  expect_equal_rel(get_dry_air_density(77.0, 14.696), 1.0 / 13.5251, tolerance = 0.001)
  expect_equal_abs(get_t_dry_bulb_from_enthalpy_and_hum_ratio(42.6168, 0.02), 85.97, tolerance = 0.05)
  expect_equal_rel(get_hum_ratio_from_enthalpy_and_t_dry_bulb(42.6168, 86.0), 0.02, 0.001)
})

# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
test_that("dry air calculations match results tabulated in the ASHRAE Handbook in SI units", {
  set_unit_system("SI")
  expect_equal_rel(get_dry_air_enthalpy(25.0), 25148, tolerance = 0.0003)
  expect_equal_rel(get_dry_air_volume(25.0, 101325), 0.8443, tolerance = 0.001)
  expect_equal_rel(get_dry_air_density(25.0, 101325), 1.0 / 0.8443, tolerance = 0.001)
  expect_equal_abs(get_t_dry_bulb_from_enthalpy_and_hum_ratio(81316.0, 0.02), 30.0, tolerance = 0.001)
  expect_equal_rel(get_hum_ratio_from_enthalpy_and_t_dry_bulb(81316.0, 30.0), 0.02, 0.001)
})
