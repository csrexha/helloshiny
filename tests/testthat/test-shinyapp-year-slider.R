library(shinytest2)

test_that("test year range slider", {
    path <- system.file("app", package = "helloshiny")
    app_driver <- AppDriver$new(app_dir = path)

    # check valid input
    year_range <- app_driver$get_values()$input
    expect_failure(expect_null(year_range))

    app_driver$set_inputs(year_range = c(2018, 2020))
    filtered_years <- app_driver$get_values()$export$filtered_years
    expect_setequal(filtered_years, 2018:2020)
    }
)