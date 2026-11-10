#!/usr/bin/env bash
# Watch the workflow runs (CI, the Claude review, ...) on a PR's current head commit.
#   usage: watch-ci.sh <pr-number>
# Prints one line per workflow for its latest run on that commit, plus the tail of the
# log for each failed one. Exits 1 when a workflow's latest run ends other than success
# or skipped, when no run appears, or when GitHub never reports the pushed commit.
#
# GitHub registers runs late and in any order. Right after a push it can still report
# the previous head commit; runs can appear minutes later; a late-delivered event can
# start a second run of a workflow, which cancels the first. So the script:
#   1. on the PR's branch, waits until GitHub reports the local HEAD as the PR head;
#   2. takes the latest run of each workflow on that commit (superseded runs don't count);
#   3. watches those, then lists again, until every run is finished and the list has
#      stayed the same for 2 polls (about 20s) after that.
# A failed gh call (a transient API error) is retried by these loops instead of
# aborting the script, so there's no `set -e`.
set -uo pipefail

pr="${1:?usage: watch-ci.sh <pr-number>}"

pr_head() {
    gh pr view "$pr" --json headRefName,headRefOid --jq '[.headRefName, .headRefOid] | @tsv' 2> /dev/null
}

# latest run per workflow on the commit, one "<id> TAB <status> TAB <conclusion> TAB <workflow>"
# line each; an unfinished run's empty conclusion becomes "-" (read would collapse an empty
# tab-separated field)
latest_runs() {
    gh run list --commit "$sha" --json databaseId,workflowName,status,conclusion,createdAt \
        --jq 'group_by(.workflowName) | map(max_by(.createdAt)) | .[] |
              [.databaseId, .status, (if (.conclusion // "") == "" then "-" else .conclusion end),
               .workflowName] | @tsv' 2> /dev/null
}

info=""
for _ in $(seq 1 6); do
    info="$(pr_head)" && [ -n "$info" ] && break
    sleep 10
done
[ -n "$info" ] || { echo "Couldn't read PR #$pr from GitHub." >&2; exit 1; }
branch="${info%%$'\t'*}"
sha="${info#*$'\t'}"

if [ "$branch" = "$(git branch --show-current 2> /dev/null)" ]; then
    local_head="$(git rev-parse HEAD)"
    for _ in $(seq 1 12); do
        [ "$sha" = "$local_head" ] && break
        sleep 10
        info="$(pr_head)" && [ -n "$info" ] && sha="${info#*$'\t'}"
    done
    if [ "$sha" != "$local_head" ]; then
        echo "GitHub still reports ${sha:0:7} as the PR's head, not the local HEAD ${local_head:0:7}," \
            "after 2 minutes. Check that it was pushed, and GitHub's status page." >&2
        exit 1
    fi
fi

runs=""
previous=""
unchanged_polls=0
for _ in $(seq 1 90); do
    runs="$(latest_runs)"
    pending="$(awk -F'\t' '$2 != "completed" { print $1 }' <<< "$runs")"
    if [ -n "$pending" ]; then
        for id in $pending; do
            gh run watch "$id" --interval 30 > /dev/null 2>&1
        done
        sleep 10 # keeps the loop paced when gh run watch fails at once
        previous=""
        unchanged_polls=0
        continue
    fi
    if [ -n "$runs" ] && [ "$runs" = "$previous" ]; then
        unchanged_polls=$((unchanged_polls + 1))
        [ "$unchanged_polls" -ge 2 ] && break
    else
        unchanged_polls=0
    fi
    previous="$runs"
    sleep 10
done
[ -n "$runs" ] || { echo "No workflow run for ${sha:0:7} after 15 minutes." >&2; exit 1; }

failed=0
while IFS=$'\t' read -r id status conclusion name; do
    [ "$conclusion" = "-" ] && conclusion="$status"
    echo "$name: $conclusion (run $id on ${sha:0:7})"
    case "$conclusion" in
        success | skipped) ;;
        *)
            failed=1
            # drop the job/step/timestamp columns gh prefixes to every log line
            { gh run view "$id" --log-failed 2> /dev/null || echo "(no failed-step log for run $id)"; } |
                sed -E 's/^[^\t]*\t[^\t]*\t[0-9TZ:.-]+ //' |
                grep -v -E '^(chr|dbl|lgl|int) |^Delimiter|^Rows:' |
                tail -60
            ;;
    esac
done <<< "$runs"
exit "$failed"
