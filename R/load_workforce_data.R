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

