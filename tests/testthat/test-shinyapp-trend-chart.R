library(shinytest2)

test_that("trend chart renders for selected profession", {
    path <- system.file("app", package = "helloshiny")
    app_driver <- AppDriver$new(app_dir = path)

    # pick a non-default profession so the reactive chain must re-fire
    app_driver$set_inputs(profession_select = "Altenpflege (oS) - Helfer")

    trend_chart <- app_driver$get_values(output = "trend_chart")$output$trend_chart
    expect_false(is.null(trend_chart))
    expect_no_error(app_driver$get_screenshot(tempfile(fileext = ".png")))
    }
)
