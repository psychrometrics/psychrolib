# TODO: add explicit tests for get_t_dew_point_from_hum_ratio; none were in the original library
# TODO: add explicit tests for get_rel_hum_from_hum_ratio; none were in the original library
# TODO: add explicit tests for get_hum_ratio_from_t_dew_point; none were in the original library
# TODO: add explicit tests for get_hum_ratio_from_rel_hum; none were in the original library

## Test of relationships between humidity ratio and wet bulb temperature in IP units
## The formulae are tested for two conditions, one above freezing and the other below
## Humidity ratio values to test against are calculated with Excel
test_that("the relationships between humidity ratio and wet bulb temperature are as expected in IP units", {

  set_unit_system("IP")

  # Above freezing
  hum_ratio <- get_hum_ratio_from_t_wet_bulb(86.0, 77.0, 14.175)
  expect_equal_rel(hum_ratio, 0.0187193288418892, tolerance = 0.0003)
  t_wet_bulb <- get_t_wet_bulb_from_hum_ratio(86.0, hum_ratio, 14.175)
  expect_equal_abs(t_wet_bulb, 77.0, 0.001)

  # Below freezing
  hum_ratio <- get_hum_ratio_from_t_wet_bulb(30.2, 23.0, 14.175)
  expect_equal_rel(hum_ratio, 0.00114657481090184, tolerance = 0.0003)
  t_wet_bulb <- get_t_wet_bulb_from_hum_ratio(30.2, hum_ratio, 14.175)
  expect_equal_abs(t_wet_bulb, 23.0, 0.001)

  # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
  expect_identical(get_t_wet_bulb_from_hum_ratio(25.0, 1e-09, 95461.0),
                   get_t_wet_bulb_from_hum_ratio(25.0, 1e-07, 95461.0)) # TODO: is this a sane pressure in these units?
})

## Test of relationships between humidity ratio and wet bulb temperature in SI units
## The formulae are tested for two conditions, one above freezing and the other below
## Humidity ratio values to test against are calculated with Excel
test_that("the relationships between humidity ratio and wet bulb temperature are as expected in IP units", {

  set_unit_system("SI")

  # Above freezing
  hum_ratio <- get_hum_ratio_from_t_wet_bulb(30.0, 25.0, 95461.0)
  expect_equal_rel(hum_ratio, 0.0192281274241096, tolerance = 0.0003)
  t_wet_bulb <- get_t_wet_bulb_from_hum_ratio(30.0, hum_ratio, 95461.0)
  expect_equal_abs(t_wet_bulb, 25.0, 0.001)

  # Below freezing
  hum_ratio <- get_hum_ratio_from_t_wet_bulb(-1.0, -5.0, 95461.0)
  expect_equal_rel(hum_ratio, 0.00120399819933844, tolerance = 0.0003)
  t_wet_bulb <- get_t_wet_bulb_from_hum_ratio(-1.0, hum_ratio, 95461.0)
  expect_equal_abs(t_wet_bulb, -5.0, 0.001)

  # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
  expect_identical(get_t_wet_bulb_from_hum_ratio(-5.0, 1e-09, 95461.0),
                   get_t_wet_bulb_from_hum_ratio(-5.0, 1e-07, 95461.0))
})
