#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): after an edit to R/<name>.R, run its testthat file.
#   R/<name>.R      -> tests/testthat/test-<name>.R
#   R/ui_elements.R -> all tests/testthat/test-shinyapp-*.R (browser tests, slower)
#   anything else   -> nothing
# On failure, exits 2 so the test output is fed back to Claude.
set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
file="$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')"
[ -n "$file" ] || exit 0

rel="${file#"$root"/}"
case "$rel" in
    R/*.R | R/*.r) ;;
    *) exit 0 ;;
esac

stem="$(basename "$rel")"
stem="${stem%.*}"

if compgen -G "$root/tests/testthat/test-$stem.[rR]" > /dev/null; then
    filter="^$stem\$"
elif [ "$stem" = "ui_elements" ]; then
    filter="^shinyapp"
else
    exit 0
fi

cd "$root"
if ! out="$(NOT_CRAN=true rv run -e "
    res <- as.data.frame(testthat::test_local(filter = '$filter', reporter = 'summary', stop_on_failure = FALSE))
    quit(status = as.integer(sum(res\$failed) + sum(res\$error) > 0))
" 2>&1)"; then
    {
        echo "Tests for $rel failed (testthat filter '$filter'):"
        echo "$out" | grep -v -E '^(chr|dbl) |^Delimiter|^Rows:|^i |^ℹ ' | tail -40
    } >&2
    exit 2
fi
