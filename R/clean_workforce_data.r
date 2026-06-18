#' Clean workforce data
#'
#' @param df A data frame
#' @return A cleaned data frame
#' @export
 
clean_workforce_data <- function(data) {
    selected_columns <- c(year="time", 
                          age_group="2_variable_attribute_label", 
                          profession_code="3_variable_attribute_code",
                          profession_label="3_variable_attribute_label",
                          fte="value")

    cleaned_data <- data  |>
        select(all_of(selected_columns)) |>
        mutate(year = as.integer(year), 
               fte = as.numeric(fte))

    return(cleaned_data)
}
