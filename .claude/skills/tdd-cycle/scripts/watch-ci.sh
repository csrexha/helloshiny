#!/usr/bin/env bash
# Watch every workflow run on a PR's current head commit (CI, the Claude review, ...).
# Right after a push the runs may not be registered yet (gh then reports "no checks"),
# and workflows register one by one, so wait until the set of runs stops growing.
#   usage: watch-ci.sh <pr-number>
# Prints one line per run, plus the tail of the failed log for each failed run.
# Exits 1 when any run ends other than success or skipped (a skipped run, e.g. the
# review on a draft PR, isn't a failure).
set -euo pipefail

pr="${1:?usage: watch-ci.sh <pr-number>}"
pr_head() { gh pr view "$pr" --json headRefName,headRefOid --jq '[.headRefName, .headRefOid] | @tsv'; }

# Right after a push GitHub can still report the PR's previous head commit, whose runs
# are long finished. When run on the PR's branch, wait until GitHub has the local HEAD.
info="$(pr_head)"
branch="${info%%$'\t'*}"
sha="${info#*$'\t'}"
if [ "$branch" = "$(git branch --show-current 2> /dev/null)" ]; then
    local_head="$(git rev-parse HEAD)"
    for _ in $(seq 1 12); do
        [ "$sha" = "$local_head" ] && break
        sleep 10
        info="$(pr_head)"
        sha="${info#*$'\t'}"
    done
    [ "$sha" = "$local_head" ] ||
        echo "Warning: GitHub still reports ${sha:0:7} as the PR's head, not local HEAD ${local_head:0:7}." >&2
fi

# a failed gh call (a transient API error) counts as "no runs yet" instead of
# aborting the watch under set -e
run_ids() { { gh run list --commit "$sha" --json databaseId --jq '.[].databaseId' || true; } | sort; }

# Poll every 10s until the set of runs is non-empty and unchanged for 2 polls in a row
# (about 20s without a new run). A workflow that registers later than that is missed.
ids=""
unchanged_polls=0
for _ in $(seq 1 30); do
    now="$(run_ids)"
    if [ -n "$now" ] && [ "$now" = "$ids" ]; then
        unchanged_polls=$((unchanged_polls + 1))
        [ "$unchanged_polls" -ge 2 ] && break
    else
        unchanged_polls=0
    fi
    ids="$now"
    sleep 10
done
[ -n "$ids" ] || { echo "No CI run for ${sha:0:7} after 5 minutes." >&2; exit 1; }

failed=0
for id in $ids; do
    gh run watch "$id" --interval 30 > /dev/null 2>&1 || true
    info="$(gh run view "$id" --json workflowName,conclusion --jq '[.workflowName, .conclusion] | @tsv')"
    name="${info%%$'\t'*}"
    conclusion="${info#*$'\t'}"
    echo "$name: $conclusion (run $id on ${sha:0:7})"

    case "$conclusion" in
        success | skipped) ;;
        *)
            failed=1
            # drop the job/step/timestamp columns gh prefixes to every log line
            gh run view "$id" --log-failed |
                sed -E 's/^[^\t]*\t[^\t]*\t[0-9TZ:.-]+ //' |
                grep -v -E '^(chr|dbl|lgl|int) |^Delimiter|^Rows:' |
                tail -60
            ;;
    esac
done
exit "$failed"
