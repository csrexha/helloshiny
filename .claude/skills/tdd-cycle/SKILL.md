---
name: tdd-cycle
description: Run one build_plan.md cycle of helloshiny end to end, from plan through branch, red test and green code to a PR with green CI, then the build_plan.md update. Use when the user asks to do, start or continue a cycle ("/tdd-cycle 11", "do cycle 11", "next cycle").
---

# One build_plan.md cycle

Cycle: `$ARGUMENTS`. If it's empty, take the first 🚧 cycle in `build_plan.md`.

A cycle is **done** when the full suite is green and CI passes on its PR. Merging is the user's call.

The cycle runs on one of two paths:
- **Test path:** `build_plan.md` names a test for the cycle.
- **Verify path:** the entry says "no new test" (cycles 11–13). It has no red step. Before each commit, the full suite stays green and the check named in the cycle's entry passes (run the app, `docker build`, a CI run).

## Steps

1. **Plan (checkpoint).** Read the cycle's entry in `build_plan.md` and the code it touches. Present:
   - the files that will change;
   - the commits, in `build_plan.md`'s wording;
   - any new dependency (CLAUDE.md: ask first);
   - test path: the seam, with what it catches and what it misses, plus literal expected values read from the data;
   - verify path: the check behind each commit.

   Wait for the user's approval. Done when they approve the plan or a revision of it.

2. **Branch.** Cut it from an up-to-date `main`. Local `main` has no upstream, so name the remote:
   ```bash
   git switch main && git pull --ff-only origin main
   git switch -c feature/cycle-N-short-name   # name from build_plan.md
   ```

3. **Red** (test path only). Write the test at the agreed seam. Its expected values are literals, never recomputed the way the code computes them. Run `scripts/run-suite.sh <filter>`. It's red when the test fails *because the feature is missing*, and you can quote the failing line. A load error or a typo isn't red. Commit `test: ...`.
   - When the seam is the browser, hand the test to the `shinytest2-writer` subagent. Give it the behaviour, the seam, the literal expected values, the ids from the plan and the file name. Before committing, check the failing line it reports yourself.

4. **Green.** Write the minimal code that makes the full suite pass. Run `scripts/run-suite.sh`, which must exit 0. Commit `feat: ...`.
   - Test path: do a **mutation check** after the commit. Break the behaviour each assertion guards (drop a column, shift a bound by one) and see every assertion fail. Then restore with `git checkout -- <file>`.
   - Verify path: run the check before each of the cycle's commits.

5. **Refactor**, if any. Only do it while green, and in its own `refactor:` commit.

6. **Review (checkpoint).** Hand over for `/code-review main`. Fix the findings the user picks, in `fix:` or `refactor:` commits. Done when the user says to open the PR.

7. **PR and CI.**
   - Push with `git push -u origin <branch>`.
   - Write the body (`pr` skill) to a scratchpad file with the Write tool, then run `gh pr create --body-file <file>`. A heredoc body is part of the Bash command, and the git guardrail hook blocks it when the text mentions a push to main or a hard reset.
   - Start `scripts/watch-ci.sh <pr-number>` in the background (CI takes several minutes).
   - Red CI: read the failure it prints, reproduce it locally, and fix it in a new commit. Then watch again.

   Done when CI is green.

8. **build_plan.md.** Once CI is green, mark the cycle ✅ and strike through its bullets. Rewrite the Test and Green lines to say what was actually built. The file is gitignored, so there's no commit. Report the PR URL, the commits and the CI result.

## Scripts

Paths are relative to this skill's folder:
- `scripts/run-suite.sh [filter]` runs the testthat suite, or the files matching `filter`. It prints `RESULT failed=… errored=… warnings=… skipped=… passed=…` and exits 1 when anything failed or errored. A snapshot change counts as a failure plus a warning, and CLAUDE.md says what to do then.
- `scripts/watch-ci.sh <pr-number>` waits for the run on the PR's head commit to appear, watches it, and prints its conclusion. On failure, it also prints the tail of the failed log and exits 1.
