#!/usr/bin/env bash
# Usage: ticket-keys.sh <branch> [<log-range>]
#        ticket-keys.sh --text < FILE
# Run from the repository root. Prints Jira keys in first-seen order, uppercase,
# one per line. The first form reads the branch name, then commit subjects in
# <log-range>, oldest first. --text reads arbitrary text from stdin, such as a
# pull request title and body or a diff. Exits 0 with no output when no key is
# found.
set -euo pipefail

# Only these Jira projects count, in any case, so sprint tags (Ferrari-SP-2),
# report numbers (REPORT-44), and names like node-18 are ignored.
# Override with IFM_TICKET_PROJECTS="ABC DEF".
projects="$(printf '%s' "${IFM_TICKET_PROJECTS:-IFME JSD}" | tr -s '[:space:]' ' ' | sed 's/^ //; s/ $//')"
if [[ -z "$projects" ]]; then
  echo "IFM_TICKET_PROJECTS is empty" >&2
  exit 1
fi
export IFM_PROJECT_ALT="${projects// /|}"

# Jira issue numbers never start with 0, which also drops placeholders such
# as IFME-0000.
extract() {
  perl -nle 'my $p = $ENV{IFM_PROJECT_ALT};
    print uc($1) while /(?<![A-Za-z0-9])((?i:$p)-[1-9][0-9]*)(?![0-9])/g'
}

if [[ "${1:-}" == "--text" ]]; then
  extract | awk 'NF && !seen[$0]++'
  exit 0
fi

branch="${1:?branch name required}"
range="${2:-}"

{
  printf '%s\n' "$branch" | extract
  if [[ -n "$range" ]]; then
    git log --reverse --format=%s --end-of-options "$range" | extract
  fi
} | awk 'NF && !seen[$0]++'
