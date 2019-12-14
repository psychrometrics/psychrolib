# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
test_that("dry air calculations match results tabulated in the ASHRAE Handbook in IP units", {
    SetUnitSystem("IP")
    expect_equal_rel(GetDryAirEnthalpy(77.0), 18.498, rel = 0.001)
    expect_equal_rel(GetDryAirVolume(77.0, 14.696), 13.5251, rel = 0.001)
    expect_equal_rel(GetDryAirDensity(77.0, 14.696), 1.0 / 13.5251, rel = 0.001)
    expect_equal_abs(GetTDryBulbFromEnthalpyAndHumRatio(42.6168, 0.02), 85.97, abs = 0.05)
    expect_equal_rel(GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 86.0), 0.02, rel = 0.001)
})

# Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
# Note: the accuracy of the formula is not better than 0.1%, apparently
test_that("dry air calculations match results tabulated in the ASHRAE Handbook in SI units", {
    SetUnitSystem("SI")
    expect_equal_rel(GetDryAirEnthalpy(25.0), 25148, rel = 0.0003)
    expect_equal_rel(GetDryAirVolume(25.0, 101325), 0.8443, rel = 0.001)
    expect_equal_rel(GetDryAirDensity(25.0, 101325), 1.0 / 0.8443, rel = 0.001)
    expect_equal_abs(GetTDryBulbFromEnthalpyAndHumRatio(81316.0, 0.02), 30.0, abs = 0.001)
    expect_equal_rel(GetHumRatioFromEnthalpyAndTDryBulb(81316.0, 30.0), 0.02, rel = 0.001)
})
