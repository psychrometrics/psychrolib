# Humidity ratio values to test against are calculated with Excel
test_that("relationships between humidity ratio and vapour pressure are correct in IP units", {
    SetUnitSystem("IP")
    HumRatio <- GetHumRatioFromVapPres(0.45973, 14.175)   # conditions at 77 F, std atm pressure at 1000 ft
    expect_equal_rel(HumRatio, 0.0208473311024865, rel = 0.000001)
    vap_pres <- GetVapPresFromHumRatio(HumRatio, 14.175)
    expect_equal_abs(vap_pres, 0.45973, abs = 0.00001)
})

# Humidity ratio values to test against are calculated with Excel
test_that("relationships between humidity ratio and vapour pressure are correct in SI units", {
    SetUnitSystem("SI")
    HumRatio <- GetHumRatioFromVapPres(3169.7, 95461) # conditions at 25 C, std atm pressure at 500 m
    expect_equal_rel(HumRatio, 0.0213603998047487, rel = 0.000001)
    vap_pres <- GetVapPresFromHumRatio(HumRatio, 95461)
    expect_equal_abs(vap_pres, 3169.7, abs = 0.0001)
})
