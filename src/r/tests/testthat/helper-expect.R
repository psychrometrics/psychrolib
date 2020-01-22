# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

# Behave like pytest.approx when used with rel option
expect_equal_rel <- function (object, expected, rel) {
    expect_equal(object, expected, scale = abs(expected), tolerance = rel)
}

# Behave like pytest.approx when used with abs option
expect_equal_abs <- function (object, expected, abs) {
    expect_equal(object, expected, scale = 1.0, tolerance = abs)
}

expect_equivalent_rel <- function (object, expected, rel) {
    expect_equivalent(object, expected, scale = abs(expected), tolerance = rel)
}

expect_equivalent_abs <- function (object, expected, abs) {
    expect_equivalent(object, expected, scale = 1.0, tolerance = abs)
}
