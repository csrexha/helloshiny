library(shinytest2)

test_that("age chart shows FTE per age group for selected profession and year", {
    path <- system.file("app", package = "helloshiny")
    app_driver <- AppDriver$new(app_dir = path)
    app_driver$set_inputs(profession_select = "Altenpflege (oS) - Helfer", age_year = "2018")

    age_chart <- app_driver$get_values(output = "age_chart")$output$age_chart
    expect_false(is.null(age_chart))

    # read the bars plotly actually drew in the browser, once it has drawn them
    app_driver$wait_for_js("document.getElementById('age_chart').data !== undefined")
    trace <- app_driver$get_js("
        (function() {
            var d = document.getElementById('age_chart').data[0];
            return {x: d.x, y: d.y};
        })()
    ")

    # known values from 23621-0008 for Altenpflege (oS) - Helfer, 2018 (FTE in thousands)
    expect_equal(
        unlist(trace$x),
        c(
            "unter 30 Jahre",
            "30 bis unter 40 Jahre",
            "40 bis unter 50 Jahre",
            "50 bis unter 60 Jahre",
            "60 Jahre und mehr"
        )
    )
    expect_equal(unlist(trace$y), c(40, 43, 48, 65, 22))
    }
)

test_that("age chart waits for a year before rendering", {
    app <- shinyAppDir(system.file("app", package = "helloshiny"))

    # age_year is never set: the chart must stop silently, not show an error
    testServer(app, {
        session$setInputs(profession_select = "Altenpflege (oS) - Helfer")
        expect_error(output$age_chart, class = "shiny.silent.error")
    })
    }
)

test_that("age chart waits for a profession before rendering", {
    app <- shinyAppDir(system.file("app", package = "helloshiny"))

    # profession_select is never set: the chart must stop silently, not show an error
    testServer(app, {
        session$setInputs(age_year = "2018")
        expect_error(output$age_chart, class = "shiny.silent.error")
    })
    }
)
