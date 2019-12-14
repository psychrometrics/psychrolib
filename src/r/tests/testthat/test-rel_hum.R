# Test that the NR in GetTDewPointFromVapPres converges.
# This test was known problem in versions of PsychroLib <= 2.0.0
test_that("the NR in GetTDewPointFromVapPres converges", {
    SetUnitSystem("IP")
    TDryBulb <- seq(-148, 392, 1)
    RelHum <- seq(0, 1, 0.1)
    Pressure <- seq(8.6, 17.4, 1)
    expect_silent(
        for (RH in RelHum) {
            for (P in Pressure) {
                GetTWetBulbFromRelHum(TDryBulb, RH, P)
            }
        }
    )
})
