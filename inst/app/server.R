library(shiny)
library(helloshiny)
library(dplyr)
library(plotly)
library(DT)
library(logger)

function(input, output, session) {
    log_info("session started: token={session$token}")
    onUnhandledError(function(err) log_error("unhandled error: {conditionMessage(err)}"))

    observeEvent(
        list(input$profession_select, input$year_range, input$age_year),
        log_info(
            "filters changed: profession={input$profession_select} ",
            "years={input$year_range[1]}-{input$year_range[2]} age_year={input$age_year}"
        ),
        ignoreInit = TRUE
    )

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

    # summary tiles (FTE in thousands), both FTE tiles read the same per-year totals
    fte_per_year <- reactive(
        filtered_aggregate_fte() |>
            group_by(year) |>
            summarise(total_fte = sum(total_fte), .groups = "drop") |>
            arrange(year)
    )

    output$vb_latest <- renderText(
        {
            totals <- fte_per_year()
            latest <- totals[nrow(totals), ]
            sprintf("%s thousand (%d)", format(latest$total_fte), latest$year)
        }
    )

    output$vb_change <- renderText(
        {
            totals <- fte_per_year()
            start_fte <- totals$total_fte[1]
            end_fte <- totals$total_fte[nrow(totals)]
            # FTE is in rounded thousands, so small professions can start at 0
            change <- if (start_fte == 0) "n/a" else sprintf("%+.1f %%", 100 * (end_fte / start_fte - 1))
            sprintf("%s (%d to %d)", change, totals$year[1], totals$year[nrow(totals)])
        }
    )

    output$vb_age <- renderText(
        {
            ages <- selected_age_distribution()
            sprintf("%s (%s)", ages$age_group[which.max(ages$fte)], input$age_year)
        }
    )
}
