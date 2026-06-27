#' Slice profession and year
#'
#' @param df A data frame
#' @param profession_code profession_code
#' @param year year
#' @return A aggregated data frame 
#' @export

age_distibution <- function(df, profession_code, year) {
    age_groups <- c(
        "unter 30 Jahre",
        "30 bis unter 40 Jahre",
        "40 bis unter 50 Jahre",
        "50 bis unter 60 Jahre",
        "60 Jahre und mehr"
    )

    sliced_df <- df |>
        filter(profession_code==profession_code & year==year)|>
        filter(age_group != "Insgesamt") |>     # remove extra age group
        mutate(age_group = factor(age_group, levels=age_groups, ordered=TRUE))  # reorder the age group
    
    return(sliced_df)
}