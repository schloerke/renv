
context("Snapshot")

test_that("snapshot failures are reported", {

  renv_scope_envvars(RENV_PATHS_ROOT = tempfile())
  renv_tests_scope("oatmeal")
  renv::init()

  descpath <- system.file("DESCRIPTION", package = "oatmeal")
  unlink(descpath)

  output <- tempfile("renv-snapshot-output-")
  local({
    renv_scope_sink(file = output)
    renv::snapshot(confirm = FALSE)
  })

  contents <- readLines(output)
  expect_true(length(contents) > 1)

})

test_that("broken symlinks are reported", {
  skip_on_os("windows")

  renv_scope_envvars(RENV_PATHS_ROOT = tempfile())
  renv_tests_scope("oatmeal")
  renv::init()

  oatmeal <- normalizePath(system.file(package = "oatmeal"), winslash = "/")
  unlink(oatmeal, recursive = TRUE)

  output <- tempfile("renv-snapshot-output-")
  local({
    renv_scope_sink(file = output)
    renv::snapshot(confirm = FALSE)
  })

  contents <- readLines(output)
  expect_true(length(contents) > 1)

})

test_that("multiple libraries can be used when snapshotting", {

  renv_scope_envvars(RENV_PATHS_ROOT = tempfile())
  renv_tests_scope()

  renv::init()

  lib1 <- tempfile("renv-lib1-")
  lib2 <- tempfile("renv-lib2-")
  ensure_directory(c(lib1, lib2))
  renv_scope_libpaths(c(lib1, lib2))

  renv::install("bread", library = lib1)
  breadloc <- find.package("bread")
  expect_true(renv_file_same(dirname(breadloc), lib1))

  renv::install("toast", library = lib2)
  toastloc <- find.package("toast")
  expect_true(renv_file_same(dirname(toastloc), lib2))

  lockfile <- renv::snapshot(lockfile = NULL, library = c(lib1, lib2))
  records <- renv_records(lockfile)

  expect_length(records, 2L)
  expect_setequal(names(records), c("bread", "toast"))

})
