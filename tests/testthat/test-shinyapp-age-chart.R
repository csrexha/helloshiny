library(shinytest2)

profession <- "Altenpflege (oS) - Helfer"

test_that("age chart renders for selected profession and year", {
    cleaned_df <- test_path("testdata", "23621-0008_de_flat.csv") |>
        load_workforce_data() |>
        clean_workforce_data()
    prof_code <- cleaned_df |>
        filter(profession_label == profession) |>
        pull(profession_code) |>
        unique()
    expected <- age_distribution(cleaned_df, prof_code = prof_code, time = 2018)

    path <- system.file("app", package = "helloshiny")
    app_driver <- AppDriver$new(app_dir = path)
    app_driver$set_inputs(profession_select = profession, age_year = "2018")

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
    expect_equal(unlist(trace$x), as.character(expected$age_group))
    expect_equal(unlist(trace$y), expected$fte)
    }
)

test_that("age chart waits for a year before rendering", {
    app <- shinyAppDir(system.file("app", package = "helloshiny"))

    # age_year is never set, as at app startup: req() must stop the reactive silently
    testServer(app, {
        session$setInputs(profession_select = profession)
        expect_error(selected_age_distribution(), class = "shiny.silent.error")
    })
    }
)

test_that("age chart waits for a profession before rendering", {
    app <- shinyAppDir(system.file("app", package = "helloshiny"))

    # profession_select is never set: req() must stop the reactive silently
    testServer(app, {
        session$setInputs(age_year = "2018")
        expect_error(selected_age_distribution(), class = "shiny.silent.error")
    })
    }
)
