#!/usr/bin/env bash
# PreToolUse hook (Bash): block git commands the user reserves for themselves.
#   - git push that targets main: names main (main, HEAD:main, origin/main, +main),
#     runs while main is checked out, or uses --force/--force-with-lease/-f/--mirror/--all
#   - git reset --hard
# Exit 2 blocks the command and shows the reason to Claude.
# Matching is text-based and errs on the side of blocking (e.g. "git push ... main"
# inside a quoted string is blocked too).
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cmd="$(jq -r '.tool_input.command // empty')"
[ -n "$cmd" ] || exit 0

# "git", optional global options (e.g. -C dir, --no-pager), then the subcommand
git_sub() { printf '(^|[^[:alnum:]_.-])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+%s([[:space:]]|$)' "$1"; }
GIT_PUSH="$(git_sub push)"
GIT_RESET="$(git_sub reset)"
NAMES_MAIN='(^|[[:space:]:/+])main([[:space:]]|$)'
FORCE_FLAG='[[:space:]](--force|--force-with-lease|--force-if-includes|-f|--mirror|--all)([[:space:]=]|$)'

block() {
    echo "BLOCKED: '$cmd' $1. The user reserves this for themselves; ask them to do it." >&2
    exit 2
}

# check each part of a chained command (&&, ||, ;, |) on its own
while IFS= read -r part; do
    if grep -qE "$GIT_RESET" <<< "$part" && grep -qE '(^|[[:space:]])--hard([[:space:]]|$)' <<< "$part"; then
        block "runs git reset --hard"
    fi

    if grep -qE "$GIT_PUSH" <<< "$part"; then
        grep -qE "$NAMES_MAIN" <<< "$part" && block "pushes to main"
        grep -qE "$FORCE_FLAG" <<< "$part" && block "is a force/mirror/all push"
        [ "$(git -C "$root" branch --show-current 2> /dev/null)" = "main" ] &&
            block "pushes while main is checked out"
    fi
done < <(printf '%s\n' "$cmd" | awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }')

exit 0
