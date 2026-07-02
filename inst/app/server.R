library(shiny)
library(helloshiny)
library(dplyr)

function(input, output, session) {
    cleaned_data <- load_workforce_data(
        system.file("extdata", "23621-0008_de_flat.csv", package = "helloshiny")
        ) |>
        clean_workforce_data()

    filtered_data <- reactive(
        {
            cleaned_data |>
                filter(between(year, input$year_range[1], input$year_range[2]))
        }
    )
    
    exportTestValues(filtered_years = unique(filtered_data()$year))
}
