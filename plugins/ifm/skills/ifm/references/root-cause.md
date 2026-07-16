# Workflow: root cause

Find the Jira ticket related to the current work, choose the most appropriate
`Root Cause (migrated)` value, and add one concise root-cause comment. Complete
the workflow without asking the user questions.

## Parameters

Accept either form:

```text
/ifm root cause
/ifm root cause <ticket-key-or-url>
```

Treat all tokens after `root cause` as the optional ticket parameter. Accept a
Jira key such as `IFME-1234` or a Jira issue URL. Reject unrelated extra text.

## Scope And Authorization

- Use the authenticated Jira integration available in the current agent
  environment. Prefer a native Atlassian or Jira connector over browser UI
  automation or direct REST calls.
- Invoking `/ifm root cause` authorizes writes only to the single selected Jira
  ticket: update `Root Cause (migrated)` and add one concise Jira comment.
- Do not transition, assign, link, label, or otherwise modify the ticket. Do not
  modify any other ticket.
- Never request credentials, open a login flow, or ask the user to choose among
  tickets, field values, or comment wording. If authenticated Jira access is
  unavailable or a safe choice cannot be made, output `Failed` with the exact
  reason and stop.

## Step 1 - Resolve The Ticket

If a ticket parameter is present:

1. Extract the ticket key from the key or URL.
2. Fetch that ticket and confirm it exists and is editable.
3. Use it as the only target. Do not search for a replacement ticket if it is
   missing or inaccessible.

If no ticket parameter is present:

1. Read the current repository name, branch name, latest commit subjects and
   bodies, and the current pull request title, body, head branch, and URL when a
   pull request exists.
2. Extract Jira keys matching `[A-Z][A-Z0-9]+-[0-9]+` and verify each candidate
   in Jira.
3. Select one ticket using this evidence order: branch name, pull request title,
   pull request body, then commit messages. Prefer a candidate repeated across
   multiple sources.
4. If multiple valid candidates remain tied at the strongest evidence level,
   or no valid candidate exists, output `Failed` with the candidate keys or the
   missing evidence and stop. Do not ask the user.

## Step 2 - Determine The Root Cause

1. Read the selected ticket's summary, description, existing root-cause value,
   and recent comments.
2. Inspect the related pull request diff and relevant repository files when
   available. Identify the underlying defect or process gap, not merely the
   visible symptom or the implemented fix.
3. Read the Jira edit metadata for the exact field named
   `Root Cause (migrated)` and obtain its current allowed values dynamically.
   Never hardcode option IDs or assume that display names remain stable.
4. Choose the single allowed value best supported by the ticket and code
   evidence. If no value is defensible, output `Failed` with the missing or
   conflicting evidence and stop without writing.
5. Prepare an English comment of one or two short sentences in this form:
   `Root cause: <specific underlying cause>.` Do not include speculation,
   remediation details, progress narration, or agent attribution.

## Step 3 - Update And Verify

1. Check whether the selected root-cause value is already set and whether an
   equivalent root-cause comment already exists. Reuse correct existing data and
   never add a duplicate comment.
2. Update `Root Cause (migrated)` only when its current value differs from the
   selected value.
3. Add the prepared comment only when no equivalent comment exists.
4. Fetch the ticket again and verify the field value and comment. If either
   write or verification fails, output `Failed`, identify any partial update,
   and stop. Do not retry with a different ticket or value.

## Step 4 - Report

On success, report only:

- `Ticket: <key>`
- `Root Cause: <selected value>` followed by `updated` or `already set`
- `Comment: added` or `Comment: already present`

Do not emit progress narration or unnecessary conversational text.
