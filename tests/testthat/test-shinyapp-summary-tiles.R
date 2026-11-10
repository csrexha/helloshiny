library(shinytest2)

tile_ids <- c("vb_latest", "vb_change", "vb_age")

start_app <- function() {
    AppDriver$new(app_dir = system.file("app", package = "helloshiny"))
}

# JS expression for the trimmed text an element shows ('' while it's missing).
# encodeString() quotes R strings safely for JS, so text containing ' can't break it.
shown_text_js <- function(id) {
    sprintf(
        "(function() { var e = document.getElementById(%s); return e ? e.textContent.trim() : ''; })()",
        encodeString(id, quote = "'")
    )
}

# Read what each tile shows in the browser.
tile_text <- function(app_driver, id) {
    app_driver$get_js(shown_text_js(id))
}

# Wait until the tile has rendered text that differs from `old` ("" = any text), then
# let expect_equal() report the value, so a wrong value fails with a diff, not a timeout.
wait_for_tile_change <- function(app_driver, id, old = "") {
    app_driver$wait_for_js(sprintf(
        "(function(t) { return t !== '' && t !== %s; })(%s)",
        encodeString(old, quote = "'"),
        shown_text_js(id)
    ))
}

test_that("summary tiles show latest FTE, change and top age group for the defaults", {
    app_driver <- start_app()

    # defaults: Physiotherapie - Fachkraft, 2013-2023, age year 2023 (FTE in thousands)
    for (id in tile_ids) wait_for_tile_change(app_driver, id)

    expect_equal(tile_text(app_driver, "vb_latest"), "21 thousand (2023)")
    expect_equal(tile_text(app_driver, "vb_change"), "-22.2 % (2013 to 2023)")
    expect_equal(tile_text(app_driver, "vb_age"), "50 bis unter 60 Jahre (2023)")
})

test_that("summary tiles follow the profession, year range and age year filters", {
    app_driver <- start_app()

    for (id in tile_ids) wait_for_tile_change(app_driver, id)
    # what the tiles show before the change (not the expected defaults: with a bug
    # they differ, and waiting for a change from them would read the stale render)
    before <- vapply(tile_ids, function(id) tile_text(app_driver, id), character(1))

    app_driver$set_inputs(
        profession_select = "Zahnmedizinische Fachangestellte - Fachkraft",
        year_range = c(2015, 2020),
        age_year = "2018"
    )
    # the old values stay on the page until each tile re-renders
    for (id in tile_ids) wait_for_tile_change(app_driver, id, old = before[[id]])

    expect_equal(tile_text(app_driver, "vb_latest"), "132 thousand (2020)")
    expect_equal(tile_text(app_driver, "vb_change"), "+6.5 % (2015 to 2020)")
    expect_equal(tile_text(app_driver, "vb_age"), "unter 30 Jahre (2018)")
})

test_that("the change tile shows n/a when the first year of the range has 0 FTE", {
    app_driver <- start_app()

    wait_for_tile_change(app_driver, "vb_change")
    before <- tile_text(app_driver, "vb_change")

    # 0 thousand FTE in 2013, 4 thousand in 2023
    app_driver$set_inputs(profession_select = "Heilerziehungspflege, Sonderpädagogik - Helfer")
    wait_for_tile_change(app_driver, "vb_change", old = before)

    expect_equal(tile_text(app_driver, "vb_change"), "n/a (2013 to 2023)")
})
