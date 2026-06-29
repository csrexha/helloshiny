library(shiny)

test_that("app launches and has correct title", {
    app_driver <- AppDriver$new(app_dir="../../app")

    title <- app_driver$get_text("title")
    expect_equal(title, "Gesundheitspersonalrechnung")
  }
)
