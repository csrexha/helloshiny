#' UI element
#'
#' @param ... UI elements for the box
#' @export
#' @rdname uiElements

panelselectinput <- function() {

    cleaned_data <- load_workforce_data(
        system.file("extdata", "23621-0008_de_flat.csv", package = "helloshiny")
        ) |>
        clean_workforce_data()

    selectInput(
        "profession_select",
        "Profession",
        choices=cleaned_data$profession_label
        )
}
