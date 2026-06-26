library(testthat)

test_that("Aggregate by year and profession", {
  # obtain the cleaned dataset
  cleaned_df <- test_path("testdata", "23621-0008_de_flat.csv") |>
    load_workforce_data() |>
    clean_workforce_data() 

  # aggreate fte across age groups
  aggregated_df <- aggregate_fte(cleaned_df)

  # test the data if it contains all years and profression after aggregation
  expect_setequal(aggregated_df$year, 2012:2024)
  expect_setequal(aggregated_df$profession_code, cleaned_df$profession_code)

  # use profession KB10-8135 in year 2013 as a test example
  expect_contains(aggregated_df$profession_code, "KB10-8135")
  expect_contains(aggregated_df$year, 2013)

  expect_equal(
    aggregated_df |>
      filter(year==2013 & profession_code=="KB10-8135") |>
      pull(total_fte),
    cleaned_df |>
      filter(year==2013 & profession_code=="KB10-8135") |>
      filter(age_group!="Insgesamt") |>
      pull(fte) |>
      sum()
    )
  }
)
