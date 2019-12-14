## Test of relationships between humidity ratio and wet bulb temperature in IP units
## The formulae are tested for two conditions, one above freezing and the other below
## Humidity ratio values to test against are calculated with Excel
test_that("the relationships between humidity ratio and wet bulb temperature are as expected in IP units", {
    SetUnitSystem("IP")

    # Above freezing
    HumRatio <- GetHumRatioFromTWetBulb(86.0, 77.0, 14.175)
    expect_equal_rel(HumRatio, 0.0187193288418892, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(86.0, HumRatio, 14.175)
    expect_equal_abs(TWetBulb, 77.0, abs = 0.001)

    # Below freezing
    HumRatio <- GetHumRatioFromTWetBulb(30.2, 23.0, 14.175)
    expect_equal_rel(HumRatio, 0.00114657481090184, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(30.2, HumRatio, 14.175)
    expect_equal_abs(TWetBulb, 23.0, abs = 0.001)

    # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    expect_identical(GetTWetBulbFromHumRatio(25.0, 1e-09, 95461.0),
                     GetTWetBulbFromHumRatio(25.0, 1e-07, 95461.0)) # TODO: is this a sane pressure in these units?
})

## Test of relationships between humidity ratio and wet bulb temperature in SI units
## The formulae are tested for two conditions, one above freezing and the other below
## Humidity ratio values to test against are calculated with Excel
test_that("the relationships between humidity ratio and wet bulb temperature are as expected in IP units", {
    SetUnitSystem("SI")

    # Above freezing
    HumRatio <- GetHumRatioFromTWetBulb(30.0, 25.0, 95461.0)
    expect_equal_rel(HumRatio, 0.0192281274241096, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(30.0, HumRatio, 95461.0)
    expect_equal_abs(TWetBulb, 25.0, abs = 0.001)

    # Below freezing
    HumRatio <- GetHumRatioFromTWetBulb(-1.0, -5.0, 95461.0)
    expect_equal_rel(HumRatio, 0.00120399819933844, rel = 0.0003)
    TWetBulb <- GetTWetBulbFromHumRatio(-1.0, HumRatio, 95461.0)
    expect_equal_abs(TWetBulb, -5.0, abs = 0.001)

    # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    expect_identical(GetTWetBulbFromHumRatio(-5.0, 1e-09, 95461.0),
                     GetTWetBulbFromHumRatio(-5.0, 1e-07, 95461.0))
})
