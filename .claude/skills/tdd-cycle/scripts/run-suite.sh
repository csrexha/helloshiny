#!/usr/bin/env bash
# Run the testthat suite (or only the files matching a filter) and judge it by
# failures AND errors: testthat lists errored tests in a separate column.
#   usage: run-suite.sh [filter]
# Prints the test output (without readr's column-spec noise), then
#   RESULT failed=N errored=N warnings=N skipped=N passed=N
# Exits 0 only when nothing failed or errored.
set -uo pipefail

filter="${1:-}"
cd "$(git rev-parse --show-toplevel)"

NOT_CRAN=true rv run -e "
    filter <- '$filter'
    res <- as.data.frame(testthat::test_local(
        filter = if (nzchar(filter)) filter else NULL,
        stop_on_failure = FALSE
    ))
    failed <- sum(res\$failed); errored <- sum(res\$error)
    cat(sprintf('RESULT failed=%d errored=%d warnings=%d skipped=%d passed=%d\n',
        failed, errored, sum(res\$warning), sum(res\$skipped), sum(res\$passed)))
    quit(status = as.integer(failed + errored > 0))
" 2>&1 | grep -v -E '^(chr|dbl|lgl|int) |^Delimiter|^Rows:|^i |^ℹ '
