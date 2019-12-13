# TODO: the original library does not have an explicit test for get_degree_of_saturation()
# TODO: the original library does not have an explicit test for get_vapor_pressure_deficit()

# Values are compared against values calculated with Excel
test_that("moist air calculations match values calculated with Excel using IP units", {
  set_unit_system("IP")
  expect_equal_rel(get_moist_air_enthalpy(86, 0.02), 42.6168, tolerance = 0.0003)
  expect_equal_rel(get_moist_air_volume(86, 0.02, 14.175), 14.7205749002918, tolerance = 0.0003)
  expect_equal_rel(get_moist_air_density(86, 0.02, 14.175), 0.0692907720594378, tolerance = 0.0003)
})

# Values are compared against values calculated with Excel
test_that("moist air calculations match values calculated with Excel using SI units", {
  set_unit_system("SI")
  expect_equal_rel(get_moist_air_enthalpy(30, 0.02), 81316, tolerance = 0.0003)
  expect_equal_rel(get_moist_air_volume(30, 0.02, 95461), 0.940855374352943, tolerance = 0.0003)
  expect_equal_rel(get_moist_air_density(30, 0.02, 95461), 1.08411986348219, tolerance = 0.0003)
})
