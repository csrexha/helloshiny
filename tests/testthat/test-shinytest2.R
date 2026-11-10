library(shinytest2)

test_that("Initial Shiny values are consistent", {
  skip_on_cran()
  path <- system.file("app", package="helloshiny")
  app <- AppDriver$new(app_dir = path)

  # plotly's event inputs (plotly_afterplot-A, plotly_relayout-A, ...) record which chart
  # drew last and its size, which varies between runs; snapshot every other input
  inputs <- names(app$get_values(input = TRUE)$input)
  app$expect_values(
    input = grep("^plotly_", inputs, value = TRUE, invert = TRUE),
    output = TRUE,
    export = TRUE
  )
})
