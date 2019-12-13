# Humidity ratio values to test against are calculated with Excel
test_that("relationships between humidity ratio and vapour pressure are correct in IP units", {
  set_unit_system("IP")
  hum_ratio <- get_hum_ratio_from_vap_pres(0.45973, 14.175)   # conditions at 77 F, std atm pressure at 1000 ft
  expect_equal_rel(hum_ratio, 0.0208473311024865, tolerance = 0.000001)
  vap_pres <- get_vap_pres_from_hum_ratio(hum_ratio, 14.175)
  expect_equal_abs(vap_pres, 0.45973, tol = 0.00001)
})

# Humidity ratio values to test against are calculated with Excel
test_that("relationships between humidity ratio and vapour pressure are correct in SI units", {
  set_unit_system("SI")
  hum_ratio <- get_hum_ratio_from_vap_pres(3169.7, 95461) # conditions at 25 C, std atm pressure at 500 m
  expect_equal_rel(hum_ratio, 0.0213603998047487, tolerance = 0.000001)
  vap_pres <- get_vap_pres_from_hum_ratio(hum_ratio, 95461)
  expect_equal_abs(vap_pres, 3169.7, tolerance = 0.0001)
})
