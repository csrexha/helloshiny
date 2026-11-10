library(shinytest2)

# Read what a text output shows in the browser (NULL while the element is missing).
tile_text <- function(app_driver, id) {
    app_driver$get_js(sprintf(
        "(function() { var e = document.getElementById('%s'); return e ? e.textContent.trim() : null; })()",
        id
    ))
}

# Wait until the tile has rendered text that differs from `old` ("" = any text), then
# let expect_equal() report the value, so a wrong value fails with a diff, not a timeout.
wait_for_tile_change <- function(app_driver, id, old = "") {
    app_driver$wait_for_js(sprintf(
        "(function() { var e = document.getElementById('%s'); var t = e ? e.textContent.trim() : '';
                       return t !== '' && t !== '%s'; })()",
        id, old
    ))
}

test_that("summary tiles show latest FTE, change and top age group for the defaults", {
    path <- system.file("app", package = "helloshiny")
    app_driver <- AppDriver$new(app_dir = path)

    # defaults: Physiotherapie - Fachkraft, 2013-2023, age year 2023 (FTE in thousands)
    for (id in c("vb_latest", "vb_change", "vb_age")) wait_for_tile_change(app_driver, id)

    expect_equal(tile_text(app_driver, "vb_latest"), "21 thousand (2023)")
    expect_equal(tile_text(app_driver, "vb_change"), "-22.2 % (2013 to 2023)")
    expect_equal(tile_text(app_driver, "vb_age"), "50 bis unter 60 Jahre (2023)")
})

test_that("summary tiles follow the profession, year range and age year filters", {
    path <- system.file("app", package = "helloshiny")
    app_driver <- AppDriver$new(app_dir = path)

    defaults <- c(
        vb_latest = "21 thousand (2023)",
        vb_change = "-22.2 % (2013 to 2023)",
        vb_age = "50 bis unter 60 Jahre (2023)"
    )
    for (id in names(defaults)) wait_for_tile_change(app_driver, id)

    app_driver$set_inputs(
        profession_select = "Zahnmedizinische Fachangestellte - Fachkraft",
        year_range = c(2015, 2020),
        age_year = "2018"
    )
    # the default values stay on the page until each tile re-renders
    for (id in names(defaults)) wait_for_tile_change(app_driver, id, old = defaults[[id]])

    expect_equal(tile_text(app_driver, "vb_latest"), "132 thousand (2020)")
    expect_equal(tile_text(app_driver, "vb_change"), "+6.5 % (2015 to 2020)")
    expect_equal(tile_text(app_driver, "vb_age"), "unter 30 Jahre (2018)")
})
