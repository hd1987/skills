# Workflow: review [<pr-url-or-number>][, <repo>]

Process the latest unresolved code review comments on the target pull request
in one pass. Evaluate every comment, apply reasonable and safe changes, resolve
the threads whose fixes were pushed or were already in place, then request a
Copilot review when the pass completes without risky comments.

## Parameters

```text
review
review <pr-url-or-number>
review, <repo>
review <pr-number>, <repo>
```

- Repository: a pull request URL selects its repository name; otherwise
  choose it per `references/repo.md` (explicit `<repo>`, then conversation
  context, then the current repository). If a URL and a `<repo>` name
  different repositories, report `Failed` and stop. Resolve `REPO_ROOT` per
  `references/repo.md` and run every command from it.
- Pull request: the URL or number when given; otherwise the pull request for
  the checkout's current branch.
- The checkout's current branch must be the pull request's head branch and
  must not be protected per `references/style.md`. Otherwise report `Failed`
  with the reason and stop.

## Scope And Authorization

- Operate only on the target pull request.
- Selecting this workflow authorizes, as one continuous procedure: a standard
  push of only the review-fix commit created during this invocation to the
  target pull request branch, resolving the threads handled in this pass, and
  one Copilot review request on that pull request (Step 5). The Copilot
  request is the final step of this workflow, not a separate action, and needs
  no further confirmation.
- Never force-push or push unrelated or pre-existing commits.
- Do not post replies, comments, reviews, or any other text on GitHub. The only
  permitted GitHub writes are the authorized push, resolving handled review
  threads, and requesting Copilot as a reviewer.
- Run one processing pass only. After requesting Copilot review, do not poll,
  wait for its result, or process the new round automatically. The user will
  select the `review` workflow again.

## Step 1 — Verify The Working State

1. Read the target repository's instructions, as defined in the Repository
   Instructions section of `references/repo.md`, and follow their rules.
2. Resolve `REPO_ROOT`, the current branch, and the target pull request.
3. Fetch the current upstream state.
4. Require no staged or unstaged changes to tracked files, a configured
   upstream branch, and no local commits ahead of or behind upstream.
   Untracked files do not block the pass; they are never staged unless the
   Staging rules in `style.md` allow it. If any requirement fails, stop
   without modifying files and report `Failed` with the specific reason.

Use these commands as the starting point:

```bash
cd "$REPO_ROOT"
git status --short --untracked-files=no
git rev-parse --abbrev-ref HEAD
git fetch origin
git rev-list --left-right --count HEAD...@{upstream}
gh pr view [PR] --json number,url,headRefName
```

## Step 2 — Fetch Open Review Threads

```bash
SKILL_DIR/scripts/review-threads.sh PR
```

It prints one JSON object per unresolved thread with `id`, `isOutdated`,
`path`, `line`, and `comments`. If it prints nothing, skip Steps 3, 4, and 4b
and continue to Step 5. If it fails, report `Failed` with its error and stop.
If it prints a `warning:` line, process the threads it returned, skip Step 5,
and include the warning in the Step 6 report.

## Step 3 — Evaluate Every Comment

Read the current code at each thread's location, then classify every open
thread into exactly one bucket:

- **Already addressed**: the code at the current `HEAD` already does what the
  comment asks, typically on an outdated thread fixed by an earlier commit.
  Confirm this from the current code, not from `isOutdated` alone.
- **Reasonable and safe**: technically correct, within scope, low risk, and
  implementable without crossing a red line other than the narrowly authorized
  standard push.
- **Unreasonable or risky**: technically incorrect, based on a misunderstanding,
  out of scope, ambiguous, or requiring user judgment. Treat schema changes,
  data migrations, file deletion, secrets, tokens, CI/CD changes, destructive
  Git operations, force pushes, and uncertain public behavior changes as risky.

When unsure, classify the thread as risky. Do not guess.

## Step 4 — Apply Safe Comments

Skip this step when no comment is reasonable and safe. Otherwise:

1. Apply the smallest correct fixes locally. Do not modify code for risky
   comments.
2. Run the verification commands chosen per the Repository Instructions
   section of `references/repo.md`. If verification fails,
   do not commit or push; record `Failed` with the failing check and go to
   Step 4b.
3. Stage per the Staging section of `style.md`, review the staged diff, and
   confirm it contains only the safe review fixes.
4. Create one commit whose message follows the Commit Message section of
   `style.md`, with ticket keys resolved per its `review` rule.
5. Push the current branch with a standard push. Do not ask for another
   confirmation; selecting this workflow is the authorization. If the commit
   or push fails, record `Failed` with the reason.

## Step 4b — Resolve Handled Threads

Always run this step when any thread was classified as already addressed or
applied, even if Step 4 was skipped or failed. Resolve in one call every
already-addressed thread, plus every applied thread only when the Step 4 push
succeeded:

```bash
SKILL_DIR/scripts/resolve-threads.sh THREAD_ID...
```

If the script reports a thread that is not `true`, leave it open and record
`Failed` with its location. If any `Failed` was recorded in Step 4 or 4b,
report it and stop. When Step 4 failed before its commit, also list the files
left modified in the working tree; do not revert them.

## Step 5 — Request Copilot Review

Run this step only when no risky comments remain and every required validation,
commit, push, and thread resolution from the current pass succeeded. If any
risky comment or earlier failure remains, skip the Copilot request and continue
to Step 6.

```bash
SKILL_DIR/scripts/copilot-review.sh PR
```

The script reads the Copilot timeline events, skips the request when Copilot
already reviewed the current head or has a pending request (made within the
last 30 minutes and not yet answered by a review), and otherwise
requests one Copilot review and verifies the new request event. Do not check
`reviewRequests` yourself: GitHub omits Copilot from it while its review is in
progress. Do not use `gh pr edit --add-reviewer` or another reviewer
identifier.

- Output `reviewed-head`, `pending`, or `requested <time>`: success.
- Output `failed <reason>` or a non-zero exit: report `Failed` with the
  reason and stop. Do not retry.

Do not wait for Copilot to finish and do not start another processing pass.

## Step 6 — Report Only What Needs Attention

- If Step 2 printed a `warning:` line, output the warning instead of
  `Passed`, followed by any risky comments below.
- If all open comments were already addressed or safe and processed
  successfully, output only `Passed`.
- If no open comments exist, output only `Passed`.
- For each unreasonable or risky comment, leave its code and thread untouched
  and report only:
  - Location: `path:line`.
  - Comment: a concise summary.
  - Rationale: the technical reason it requires confirmation.
- If safe and risky comments are mixed, process the safe comments completely,
  skip the Copilot review request, then report only the risky comments.
- Do not emit progress narration, a triage summary, applied-comment details, a
  push prompt, or any unnecessary conversational text.
