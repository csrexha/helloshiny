library(shiny)
library(helloshiny)
library(plotly)
library(DT)

fluidPage(
    title="Gesundheitspersonalrechnung",
    h1("Gesundheitspersonalrechnung"),
    sidebarPanel(
        panelselectinput(),
        panelsliderinput(),
        panelyearinput()
        ),
    plotlyOutput("trend_chart"),
    plotlyOutput("age_chart"),
    DTOutput("workforce_table")
)


