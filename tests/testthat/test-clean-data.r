library(testthat)

testthat("clean_workforce_data normalizes schema", {
    path <- test_path("testdata", "23621-0008_de_flat.csv")
    df <- load_workforce_data(path)

    cleaned_df <- clean_workforce_data(df)

    # Check that the cleaned data frame has the expected columns
    expected_columns <- c("year", "age_group", "profession_code", "profession_label", "fte",
                          "fte_quality")
    expect_setequal(colnames(cleaned_df), expected_columns)
    expect_true(is.integer(cleaned_df$year))
    expect_true(is.numeric(cleaned_df$fte))
})


