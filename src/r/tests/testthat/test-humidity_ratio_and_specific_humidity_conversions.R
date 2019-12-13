###############################################################################
# Test conversion between humidity types
###############################################################################

test_that("conversion between humidity types are correct in IP unuts", {
  for (unit_system in PSYCHROLIB_UNITS_OPTIONS) { # results should be the same in all unit systems
    set_unit_system(unit_system)
    expect_equal_rel(get_specific_hum_from_hum_ratio(0.006), 0.00596421471, tolerance = 0.01)
    expect_equal_rel(get_hum_ratio_from_specific_hum(0.00596421471), 0.006, 0.01)
  }
})
