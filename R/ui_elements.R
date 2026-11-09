#' UI element
#'
#' @param ... UI elements for the box
#' @export
#' @rdname uiElements

panelselectinput <- function() {

    cleaned_data <- workforce_data()

    selectInput(
        "profession_select",
        "Profession",
        choices = unique(cleaned_data$profession_label),
        selected = "Physiotherapie - Fachkraft"
        )
}

#' @export
#' @rdname uiElements
panelsliderinput <- function() {
    cleaned_data <- workforce_data()

    year_min <- min(cleaned_data$year)
    year_max <- max(cleaned_data$year)

    sliderInput(
        "year_range",
        "Year",
        min = year_min,
        max = year_max,
        value = c(2013, 2023),
        step = 1,
        sep = ""
        )
}

#' @export
#' @rdname uiElements
panelyearinput <- function() {
    cleaned_data <- workforce_data()

    selectInput(
        "age_year",
        "Year (age distribution)",
        choices = sort(unique(cleaned_data$year), decreasing = TRUE),
        selected = 2023
        )
}
