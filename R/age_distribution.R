#' Slice profession and year
#'
#' @param data A data frame, as returned by [clean_workforce_data()]
#' @param prof_code A profession code, e.g. `"KB10-81712"`
#' @param time A year, e.g. `2013`
#' @return A data frame with one row per age group, ordered from youngest to oldest
#' @export

age_distribution <- function(data, prof_code, time) {
    age_groups <- c(
        "unter 30 Jahre",
        "30 bis unter 40 Jahre",
        "40 bis unter 50 Jahre",
        "50 bis unter 60 Jahre",
        "60 Jahre und mehr"
    )

    sliced_df <- data |>
        dplyr::filter(profession_code==prof_code & year==time) |>
        dplyr::filter(age_group != "Insgesamt") |>     # remove extra age group
        mutate(age_group = factor(age_group, levels=age_groups)) |> # reorder the age group
        arrange(age_group)
    
    return(sliced_df)
}
