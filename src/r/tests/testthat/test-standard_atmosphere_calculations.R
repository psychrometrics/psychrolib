test_that("standard atmosphere pressure functions match tablulated values from the 2017 ASHRAE Handbook in IP units", {
  set_unit_system("IP")
  expect_equal_abs(get_standard_atm_pressure(-1000.0), 15.236, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(0.0), 14.696, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(1000.0), 14.175, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(3000.0), 13.173, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(10000.0), 10.108, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(30000.0), 4.371, tolerance = 1.0)
})

test_that("standard atmosphere pressure functions match tablulated values from the 2017 ASHRAE Handbook in SI units", {
  set_unit_system("SI")
  expect_equal_abs(get_standard_atm_pressure(-500.0), 107478.0, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(0.0), 101325.0, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(500.0), 95461.0, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(1000.0), 89875.0, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(4000.0), 61640.0, tolerance = 1.0)
  expect_equal_abs(get_standard_atm_pressure(10000.0), 26436.0, tolerance = 1.0)
})

test_that("standard atmosphere temperature functions match tablulated values from the 2017 ASHRAE Handbook in IP units", {
  set_unit_system("IP")
  expect_equal_abs(get_standard_atm_temperature(-1000.0), 62.6, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(0.0), 59.0, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(1000.0), 55.4, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(3000.0), 48.3, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(10000.0), 23.4, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(30000.0), -47.8, tolerance = 0.2) # Doesn't work with abs = 0.1
})

test_that("standard atmosphere temperature functions match tablulated values from the 2017 ASHRAE Handbook in SI units", {
  set_unit_system("SI")
  expect_equal_abs(get_standard_atm_temperature(-500.0), 18.2, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(0.0), 15.0, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(500.0), 11.8, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(1000.0), 8.5, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(4000.0), -11.0, tolerance = 0.1)
  expect_equal_abs(get_standard_atm_temperature(10000.0), -50.0, tolerance = 0.1)
})

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267 converted to IP
test_that("sea level pressure calculations return expected results in IP units", {
  set_unit_system("IP")
  sea_level_pressure <- get_sea_level_pressure(14.681662559, 344.488, 62.942)
  expect_equal_abs(sea_level_pressure, 14.8640475, tolerance = 0.0001)
  expect_equal_abs(get_station_pressure(sea_level_pressure, 344.488, 62.942), 14.681662559, tolerance = 0.0001)
})

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
test_that("sea level pressure calculations return expected results in SI units", {
  set_unit_system("SI")
  sea_level_pressure <- get_sea_level_pressure(101226.5, 105, 17.19)
  expect_equal_abs(sea_level_pressure, 102484.0, tolerance = 1.0)
  expect_equal_abs(get_station_pressure(sea_level_pressure, 105, 17.19), 101226.5, tolerance = 1.0)
})
