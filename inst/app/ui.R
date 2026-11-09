library(shiny)
library(helloshiny)
library(plotly)

fluidPage(
    title="Gesundheitspersonalrechnung",
    h1("Gesundheitspersonalrechnung"),
    sidebarPanel(
        panelselectinput(),
        panelsliderinput()
        ),
    plotlyOutput("trend_chart")
)


