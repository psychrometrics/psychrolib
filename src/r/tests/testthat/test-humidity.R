###############################################################################
# Test conversion between humidity types
###############################################################################

test_that("conversion between humidity types are correct in all units", {
    for (unit_system in PSYCHROLIB_UNITS_OPTIONS) { # results should be the same in all unit systems
        SetUnitSystem(unit_system)
        expect_equal_rel(GetSpecificHumFromHumRatio(0.006), 0.00596421471, rel = 0.01)
        expect_equal_rel(GetHumRatioFromSpecificHum(0.00596421471), 0.006, rel = 0.01)
    }
})
