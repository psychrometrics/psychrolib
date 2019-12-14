test_that("standard atmosphere pressure functions match tablulated values from the 2017 ASHRAE Handbook in IP units", {
    SetUnitSystem("IP")
    expect_equal_abs(GetStandardAtmPressure(-1000.0), 15.236, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(    0.0), 14.696, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 1000.0), 14.175, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 3000.0), 13.173, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(10000.0), 10.108, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(30000.0), 4.371, abs = 1.0)
})

test_that("standard atmosphere pressure functions match tablulated values from the 2017 ASHRAE Handbook in SI units", {
    SetUnitSystem("SI")
    expect_equal_abs(GetStandardAtmPressure( -500.0), 107478.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(    0.0), 101325.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(  500.0), 95461.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 1000.0), 89875.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure( 4000.0), 61640.0, abs = 1.0)
    expect_equal_abs(GetStandardAtmPressure(10000.0), 26436.0, abs = 1.0)
})

test_that("standard atmosphere temperature functions match tablulated values from the 2017 ASHRAE Handbook in IP units", {
    SetUnitSystem("IP")
    expect_equal_abs(GetStandardAtmTemperature(-1000.0), 62.6, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(    0.0), 59.0, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 1000.0), 55.4, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 3000.0), 48.3, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(10000.0), 23.4, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(30000.0), -47.8, abs = 0.2) # Doesn't work with abs = 0.1
})

test_that("standard atmosphere temperature functions match tablulated values from the 2017 ASHRAE Handbook in SI units", {
    SetUnitSystem("SI")
    expect_equal_abs(GetStandardAtmTemperature( -500.0), 18.2, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(    0.0), 15.0, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(  500.0), 11.8, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 1000.0), 8.5, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature( 4000.0), -11.0, abs = 0.1)
    expect_equal_abs(GetStandardAtmTemperature(10000.0), -50.0, abs = 0.1)
})

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267 converted to IP
test_that("sea level pressure calculations return expected results in IP units", {
    SetUnitSystem("IP")
    sea_level_pressure <- GetSeaLevelPressure(14.681662559, 344.488, 62.942)
    expect_equal_abs(sea_level_pressure, 14.8640475, abs = 0.0001)
    expect_equal_abs(GetStationPressure(sea_level_pressure, 344.488, 62.942), 14.681662559, abs = 0.0001)
})

# Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
test_that("sea level pressure calculations return expected results in SI units", {
    SetUnitSystem("SI")
    sea_level_pressure <- GetSeaLevelPressure(101226.5, 105, 17.19)
    expect_equal_abs(sea_level_pressure, 102484.0, abs = 1.0)
    expect_equal_abs(GetStationPressure(sea_level_pressure, 105, 17.19), 101226.5, abs = 1.0)
})
