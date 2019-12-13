# Behave like pytest.approx when used with rel option
# TODO: confirm this works as we think it does.
expect_equal_rel <- function(object, expected, tolerance) {
  expect_equal(object, expected, tolerance, scale = abs(expected))
}

# Behave like pytest.approx when used with abs option
# TODO: confirm this works as we think it does.
expect_equal_abs <- function(object, expected, tolerance) {
  expect_equal(object, expected, tolerance, scale = 1.0)
}

expect_equivalent_rel <- function(object, expected, tolerance) {
  expect_equivalent(object, expected, tolerance, scale = abs(expected))
}

expect_equivalent_abs <- function(object, expected, tolerance) {
  expect_equivalent(object, expected, tolerance, scale = 1.0)
}
