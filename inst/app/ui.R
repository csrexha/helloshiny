library(shiny)
library(bslib)
library(helloshiny)
library(plotly)
library(DT)

# compact tile: Bootstrap's fs-5 utility (!important) shrinks the value text, which
# bslib's value-box stylesheet would otherwise set large
summary_tile <- function(title, output_id) {
    value_box(
        title,
        textOutput(output_id, container = function(...) tags$span(class = "fs-5", ...)),
        max_height = "100px"
    )
}

page_sidebar(
    title = "Gesundheitspersonalrechnung",
    theme = bs_theme(version = 5, preset = "minty"),
    sidebar = sidebar(
        panelselectinput(),
        panelsliderinput(),
        panelyearinput()
    ),
    layout_column_wrap(
        width = 1 / 3,
        fill = FALSE,
        summary_tile("FTE, last year in range", "vb_latest"),
        summary_tile("Change over the range", "vb_change"),
        summary_tile("Largest age group", "vb_age")
    ),
    layout_columns(
        # side by side from 1200px; below that the table is too narrow, so stack
        col_widths = breakpoints(sm = 12, xl = c(7, 5)),
        card(full_screen = TRUE, card_header("FTE over time"), plotlyOutput("trend_chart")),
        card(card_header("FTE per year"), DTOutput("workforce_table"))
    ),
    card(full_screen = TRUE, card_header("FTE by age group"), plotlyOutput("age_chart"))
)
