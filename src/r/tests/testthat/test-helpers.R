# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.


test_that("helper functions work sanely before initialization", {
    PSYCHRO_OPT$UNITS <- NA_character_
    expect_true(is.na(GetUnitSystem()))
    expect_error(isIP())
})

test_that("unit system can be set to SI", {
    SetUnitSystem("SI")
    expect_identical(GetUnitSystem(), "SI")
    expect_false(isIP())
})

test_that("unit system can be set to IP", {
    SetUnitSystem("IP")
    expect_identical(GetUnitSystem(), "IP")
    expect_true(isIP())
})

test_that("unit system cannot be set to garbage", {
    expect_error(SetUnitSystem("foo"))
})

test_that("unit system can be reset to SI", {
    SetUnitSystem("IP")
    SetUnitSystem("SI")
    expect_identical(GetUnitSystem(), "SI")
    expect_false(isIP())
})

test_that("unit system can be reset to IP", {
    SetUnitSystem("SI")
    SetUnitSystem("IP")
    expect_identical(GetUnitSystem(), "IP")
    expect_true(isIP())
})
