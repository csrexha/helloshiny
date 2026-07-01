library(shinytest2)

test_that("app launches and has correct title", {
    path <-  system.file("app", package="helloshiny")
    app_driver <- AppDriver$new(app_dir = path)

    title <- app_driver$get_text("title")
    expect_equal(title, "Gesundheitspersonalrechnung")
  }
)
