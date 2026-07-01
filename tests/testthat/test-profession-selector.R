library(shinytest2)

test_that("test profession selector", {
    cleaned_df <- test_path("testdata", "23621-0008_de_flat.csv") |>
        load_workforce_data() |>
        clean_workforce_data()
    
    app_driver <- AppDriver$new(app_dir="../../app")

    profession <- app_driver$get_values()$input$profession_select

    # expect profession_select is not null
    expect_failure(expect_null(profession))
    # expect profession_select contains at at least one profession label
    labels <- app_driver$get_js('
            Object.values($("#profession_select")[0].selectize.options).map(o => o.value)
        ') |>
        unlist()
    expect_in(labels, cleaned_df$profession_label)
    }
)
