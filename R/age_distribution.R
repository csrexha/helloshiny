#' Slice profession and year
#'
#' @param data A data frame
#' @param profession_code profession_code
#' @param year year
#' @return A sliced data frame 
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
