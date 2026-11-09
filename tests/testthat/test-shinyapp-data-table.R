library(shinytest2)

# DT draws the table in the browser and, with server-side processing, fetches its rows
# in a second request. Wait until that first draw has arrived, then read the table.
wait_for_drawn_table <- function(app_driver) {
    app_driver$wait_for_js("
        (function() {
            var t = $('#workforce_table table');
            return t.length > 0 && $.fn.dataTable.isDataTable(t) &&
                t.DataTable().page.info().recordsTotal > 0;
        })()
    ")
}

table_headers <- function(app_driver) {
    unlist(app_driver$get_js("
        $('#workforce_table table').DataTable().columns().header().toArray()
            .map(function(h) { return h.textContent; })
    "))
}

table_row_count <- function(app_driver) {
    app_driver$get_js("$('#workforce_table table').DataTable().page.info().recordsTotal")
}

test_that("workforce table shows year, profession and FTE for the filtered years", {
    path <- system.file("app", package = "helloshiny")
    app_driver <- AppDriver$new(app_dir = path)

    wait_for_drawn_table(app_driver)
    expect_equal(table_headers(app_driver), c("year", "profession_label", "total_fte"))

    # default profession Physiotherapie - Fachkraft has one row per year:
    # 2013-2023 -> 11 rows, 2015-2020 -> 6 rows
    expect_equal(table_row_count(app_driver), 11)

    app_driver$set_inputs(year_range = c(2015, 2020))
    wait_for_drawn_table(app_driver)
    expect_equal(table_row_count(app_driver), 6)
    }
)
