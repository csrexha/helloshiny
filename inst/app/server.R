library(shiny)
library(helloshiny)
library(dplyr)
library(plotly)
library(DT)

function(input, output, session) {
    cleaned_data <- workforce_data()

    aggregate_data <- aggregate_fte(cleaned_data)

    filtered_data <- reactive(
        {   
            req(input$year_range)

            cleaned_data |>
                filter(between(year, input$year_range[1], input$year_range[2]))
        }
    )

    filtered_aggregate_fte <- reactive(
        {   
            req(input$year_range, input$profession_select)

            aggregate_data |>
                filter(between(year, input$year_range[1], input$year_range[2])) |>
                filter(profession_label %in% input$profession_select)
        }
    )

    selected_age_distribution <- reactive(
        {
            req(input$profession_select, input$age_year)

            prof_code <- cleaned_data |>
                filter(profession_label == input$profession_select) |>
                pull(profession_code) |>
                unique()

            age_distribution(
                cleaned_data,
                prof_code = prof_code,
                time = as.integer(input$age_year)
            )
        }
    )

    exportTestValues(filtered_years = unique(filtered_data()$year))

    output$trend_chart <- renderPlotly(
        {
            plot_ly(
                filtered_aggregate_fte(),
                x = ~year,
                y = ~total_fte,
                name = ~profession_label,
                type = "scatter",
                mode = "lines+markers"
            )
        }
    )

    output$age_chart <- renderPlotly(
        {
            plot_ly(
                selected_age_distribution(),
                x = ~age_group,
                y = ~fte,
                type = "bar"
            )
        }
    )

    output$workforce_table <- renderDT(
        {
            datatable(
                select(filtered_aggregate_fte(), year, profession_label, total_fte),
                rownames = FALSE
            )
        }
    )

    # summary tiles (FTE in thousands)
    output$vb_latest <- renderText(
        {
            fte <- filtered_aggregate_fte()
            last_year <- max(fte$year)
            sprintf("%s thousand (%d)", format(sum(fte$total_fte[fte$year == last_year])), last_year)
        }
    )

    output$vb_change <- renderText(
        {
            fte <- arrange(filtered_aggregate_fte(), year)
            first <- fte$total_fte[1]
            last <- fte$total_fte[nrow(fte)]
            sprintf("%+.1f %% (%d to %d)", 100 * (last / first - 1), fte$year[1], fte$year[nrow(fte)])
        }
    )

    output$vb_age <- renderText(
        {
            ages <- selected_age_distribution()
            sprintf("%s (%s)", ages$age_group[which.max(ages$fte)], input$age_year)
        }
    )
}
