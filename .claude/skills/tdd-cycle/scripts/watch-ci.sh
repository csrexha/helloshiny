#!/usr/bin/env bash
# Watch CI for a PR's current head commit. Right after a push the run may not be
# registered yet (gh then reports "no checks"), so wait for it to appear first.
#   usage: watch-ci.sh <pr-number>
# Prints the run's conclusion; on failure also the tail of the failed log, exit 1.
set -euo pipefail

pr="${1:?usage: watch-ci.sh <pr-number>}"
sha="$(gh pr view "$pr" --json headRefOid --jq .headRefOid)"

id=""
for _ in $(seq 1 30); do
    id="$(gh run list --commit "$sha" --limit 1 --json databaseId --jq '.[0].databaseId // empty')"
    [ -n "$id" ] && break
    sleep 10
done
[ -n "$id" ] || { echo "No CI run for ${sha:0:7} after 5 minutes." >&2; exit 1; }

gh run watch "$id" --interval 30 > /dev/null 2>&1 || true
conclusion="$(gh run view "$id" --json conclusion --jq .conclusion)"
echo "CI run $id on ${sha:0:7}: $conclusion"

if [ "$conclusion" != "success" ]; then
    # drop the job/step/timestamp columns gh prefixes to every log line
    gh run view "$id" --log-failed |
        sed -E 's/^[^\t]*\t[^\t]*\t[0-9TZ:.-]+ //' |
        grep -v -E '^(chr|dbl|lgl|int) |^Delimiter|^Rows:' |
        tail -60
    exit 1
fi
