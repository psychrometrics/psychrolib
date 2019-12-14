# Values are compared against values calculated with Excel
test_that("moist air calculations match values calculated with Excel using IP units", {
    SetUnitSystem("IP")
    expect_equal_rel(GetMoistAirEnthalpy(86, 0.02), 42.6168, rel = 0.0003)
    expect_equal_rel(GetMoistAirVolume(86, 0.02, 14.175), 14.7205749002918, rel = 0.0003)
    expect_equal_rel(GetMoistAirDensity(86, 0.02, 14.175), 0.0692907720594378, rel = 0.0003)
    expect_equal_rel(GetTDryBulbFromMoistAirVolumeAndHumRatio(14.7205749002918, 0.02, 14.175), 86, rel = 0.0003)
})

# Values are compared against values calculated with Excel
test_that("moist air calculations match values calculated with Excel using SI units", {
    SetUnitSystem("SI")
    expect_equal_rel(GetMoistAirEnthalpy(30, 0.02), 81316, rel = 0.0003)
    expect_equal_rel(GetMoistAirVolume(30, 0.02, 95461), 0.940855374352943, rel = 0.0003)
    expect_equal_rel(GetMoistAirDensity(30, 0.02, 95461), 1.08411986348219, rel = 0.0003)
    expect_equal_rel(GetTDryBulbFromMoistAirVolumeAndHumRatio(0.940855374352943, 0.02, 95461), 30, rel = 0.0003)
})
