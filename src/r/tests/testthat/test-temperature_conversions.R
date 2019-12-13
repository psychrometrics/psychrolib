test_that("IP temperature conversions give the right answers", {
  set_unit_system("IP")
  expect_equal(get_t_rankine_from_t_fahrenheit(70), 529.67)
})

test_that("SI temperature conversions give the right answers", {
  set_unit_system("SI")
  expect_equal(get_t_kelvin_from_t_celsius(20), 293.15)
})
