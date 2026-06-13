# This function loads workforce data from a specified path.
# (source: Destatis tabele 23621-0008, downloaded on 2026-06-12, see https://genesis.destatis.de/datenbank/online/table/23621-0008/table-toolbar)

load_workforce_data <- function(path) {   
    data <- read_delim(path, 
                       delim=";",
                       locale=locale(encoding="UTF-8")
                       )

    return(data)
}

