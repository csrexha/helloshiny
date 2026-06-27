library(testthat)

test_that("age_distribution filters by profession and year", {
    cleaned_df <- test_path("testdata", "23621-0008_de_flat.csv") |>
        load_workforce_data() |>
        clean_workforce_data()

    sliced_df <- age_distribution(
        cleaned_df, 
        prof_code = "KB10-81712", 
        time = 2013
        )

    age_groups <- c(
        "unter 30 Jahre",
        "30 bis unter 40 Jahre",
        "40 bis unter 50 Jahre",
        "50 bis unter 60 Jahre",
        "60 Jahre und mehr"
    )

    expect_shape(sliced_df, nrow=5)
    expect_setequal(sliced_df$age_group, age_groups)
    expect_identical(sliced_df$fte, c(4, 5, 8, 8, 2))
    }
)
