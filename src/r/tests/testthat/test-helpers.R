test_that("helper functions work sanely before initialization", {
  init_psychrolib()
  expect_true(is.na(get_unit_system()))
  expect_error(is_ip())
})

test_that("unit system can be set to SI", {
  set_unit_system("SI")
  expect_identical(get_unit_system(), "SI")
  expect_false(is_ip())
})

test_that("unit system can be set to IP", {
  set_unit_system("IP")
  expect_identical(get_unit_system(), "IP")
  expect_true(is_ip())
})

test_that("unit system cannot be set to garbage", {
  expect_error(set_unit_system("foo"))
})

test_that("unit system can be reset to SI", {
  set_unit_system("IP")
  set_unit_system("SI")
  expect_identical(get_unit_system(), "SI")
  expect_false(is_ip())
})

test_that("unit system can be reset to IP", {
  set_unit_system("SI")
  set_unit_system("IP")
  expect_identical(get_unit_system(), "IP")
  expect_true(is_ip())
})
