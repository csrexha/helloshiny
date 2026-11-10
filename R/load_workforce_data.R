#' Loads workforce data
#'
#' @param path A string representing the file path to the workforce data CSV file.
#' @return A data frame
#' @export

load_workforce_data <- function(path) {   
    data <- read_delim(path, 
                       delim=";",
                       locale=locale(encoding="UTF-8")
                       )

    return(data)
}


#' Cleaned workforce data bundled with the package
#'
#' Loads and cleans the CSV named by `data_path` in `inst/config/config.yml`
#' (for the environment in `R_CONFIG_ACTIVE`) on first use, and caches the result
#' for the rest of the R session.
#'
#' @return A data frame, as returned by [clean_workforce_data()]
#' @export

workforce_data <- function() {
    if (is.null(workforce_cache$data)) {
        settings <- config::get(file = system.file("config", "config.yml", package = "helloshiny"))
        workforce_cache$data <- system.file(settings$data_path, package = "helloshiny", mustWork = TRUE) |>
            load_workforce_data() |>
            clean_workforce_data()
    }

    return(workforce_cache$data)
}

workforce_cache <- new.env(parent = emptyenv())
