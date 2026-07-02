library(shinytest2)

test_that("Initial Shiny values are consistent", {
  skip_on_cran()
  path <- system.file("app", package="helloshiny")
  app <- AppDriver$new(app_dir = path)

  app$expect_values()
})
