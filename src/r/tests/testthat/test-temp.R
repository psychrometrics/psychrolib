test_that("IP temperature conversions give the right answers", {
    SetUnitSystem("IP")
    expect_equal(GetTRankineFromTFahrenheit(70), 529.67)
})

test_that("SI temperature conversions give the right answers", {
    SetUnitSystem("SI")
    expect_equal(GetTKelvinFromTCelsius(20), 293.15)
})
