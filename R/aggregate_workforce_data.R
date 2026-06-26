#' Aggregate workforce data across age groups
#'
#' @param df A data frame
#' @return A aggregated data frame 
#' @export

aggregate_fte <- function(data) {
    aggregated_data <- data |>
        filter(age_group != "Insgesamt") |>     # filter pre-calcuated sum
        group_by(year, profession_code) |>
        summarise(fte = sum(fte))

    return(aggregated_data)
}