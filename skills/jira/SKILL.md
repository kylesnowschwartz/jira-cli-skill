---
name: jira
description: >
  Jira integration via jira-cli. Use when: searching issues, viewing issue details,
  creating issues, transitioning status, adding comments, logging work, managing sprints,
  managing boards, linking issues, formatting descriptions with wiki markup,
  converting Markdown to Jira format, or using bug/feature templates.
  Keywords: jira issue, jira ticket, jira format, wiki markup, jira syntax.
  Requires jira-cli installed via `brew install jira-cli`.
---

# Jira

Jira operations via [jira-cli](https://github.com/ankitpokhrel/jira-cli) with wiki markup formatting.

## Wiki Markup Syntax

Jira uses wiki markup, **NOT Markdown**. Use this reference when writing descriptions or comments:

| Jira Syntax | Purpose | NOT this (Markdown) |
|-------------|---------|---------------------|
| `h2. Title` | Heading | `## Title` |
| `*bold*` | Bold | `**bold**` |
| `_italic_` | Italic | `*italic*` |
| `{{code}}` | Inline code | `` `code` `` |
| `{code:java}...{code}` | Code block | ` ```java ``` ` |
| `[text\|url]` | Link | `[text](url)` |
| `[PROJ-123]` | Issue link | - |
| `[~username]` | User mention | `@username` |
| `* item` | Bullet list | `- item` |
| `# item` | Numbered list | `1. item` |
| `\|\|Header\|\|` | Table header | `\|Header\|` |

See `references/syntax-reference.md` for complete documentation.

## Prerequisites

```bash
# Install jira-cli
brew install jira-cli

# Configure (interactive)
jira init

# Verify setup
jira serverinfo
jira me
```

## Quick Reference

| Operation | Command |
|-----------|---------|
| Search issues | `jira issue list -q "JQL"` |
| View issue | `jira issue view KEY` |
| Create issue | `jira issue create -t Type -s "Summary"` |
| Edit issue | `jira issue edit KEY` |
| Assign issue | `jira issue assign KEY USER` |
| Transition | `jira issue move KEY "Status"` |
| Add comment | `jira issue comment add KEY "text"` |
| Log work | `jira issue worklog add KEY TIME` |
| Link issues | `jira issue link KEY1 KEY2 TYPE` |
| List sprints | `jira sprint list BOARD_ID` |
| List boards | `jira board list -p PROJECT` |
| Current user | `jira me` |
| Find fields | `uv run scripts/jira-fields.py search TERM` |

## Search & List Issues

```bash
# All issues in project
jira issue list -p PROJ

# With JQL query
jira issue list -q "project = PROJ AND status = 'In Progress'"

# Filter by status, type, priority, assignee
jira issue list -p PROJ -s "To Do" -t Bug -yHigh -a "user@example.com"

# Unassigned issues
jira issue list -p PROJ -ax

# Recently created (last 7 days)
jira issue list -p PROJ --created -7d

# Issues I'm watching
jira issue list -w

# Plain output for scripting
jira issue list -p PROJ --plain --columns KEY,SUMMARY,STATUS --no-truncate

# CSV export
jira issue list -p PROJ --csv > issues.csv

# JSON output
jira issue list -p PROJ --raw
```

## View Issue

```bash
# Basic view
jira issue view PROJ-123

# With comments
jira issue view PROJ-123 --comments 5

# Open in browser
jira open PROJ-123
```

## Create Issue

```bash
# Basic creation
jira issue create -p PROJ -t Task -s "Fix login bug"

# With description and priority
jira issue create -p PROJ -t Bug -s "Login fails" -b "h2. Steps to Reproduce
# Navigate to login
# Enter credentials
# Click submit

h2. Expected
Login succeeds

h2. Actual
500 error" -yHigh

# With labels and components
jira issue create -p PROJ -t Story -s "New feature" -l backend -l "high prio" -C "API"

# Sub-task (requires parent)
jira issue create -p PROJ -t Sub-task -s "Subtask" -P PROJ-100

# With custom fields
jira issue create -p PROJ -t Story -s "Feature" --custom "customfield_10001=value"

# Non-interactive (skip prompts)
jira issue create -p PROJ -t Task -s "Quick task" --no-input
```

## Edit Issue

```bash
# Edit summary
jira issue edit PROJ-123 -s "New summary"

# Edit description
jira issue edit PROJ-123 -b "Updated description"

# Change priority
jira issue edit PROJ-123 -yHigh

# Add labels
jira issue edit PROJ-123 -l newlabel

```

## Assign Issue

```bash
# Assign to user
jira issue assign PROJ-123 "user@example.com"

# Assign to me
jira issue assign PROJ-123 $(jira me)

# Default assignee
jira issue assign PROJ-123 default

# Unassign
jira issue assign PROJ-123 x
```

## Transition (Move) Issue

```bash
# Move to status
jira issue move PROJ-123 "In Progress"
jira issue move PROJ-123 "Done"

# With resolution
jira issue move PROJ-123 "Done" -R"Fixed"

# Assign during transition
jira issue move PROJ-123 "In Progress" -a$(jira me)
```

## Comments

```bash
# Add comment
jira issue comment add PROJ-123 "Fixed in commit abc123"

# Add comment from file
jira issue comment add PROJ-123 -T comment.txt

# List comments (via issue view)
jira issue view PROJ-123 --comments 10
```

## Worklogs (Time Tracking)

```bash
# Log time
jira issue worklog add PROJ-123 2h
jira issue worklog add PROJ-123 "1h 30m"

# With comment
jira issue worklog add PROJ-123 2h --comment "Implemented feature X"
```

## Issue Links

```bash
# Link two issues
jira issue link PROJ-123 PROJ-456 "Blocks"
jira issue link PROJ-123 PROJ-456 "Relates"
jira issue link PROJ-123 PROJ-456 "Duplicate"

# Unlink issues
jira issue unlink PROJ-123 PROJ-456
```

## Sprints

```bash
# List sprints for a board
jira sprint list BOARD_ID

# Active sprints only
jira sprint list BOARD_ID --state active

# Add issue to sprint
jira sprint add SPRINT_ID PROJ-123

# Current sprint issues
jira sprint list BOARD_ID --current
```

## Boards

```bash
# List boards for project
jira board list -p PROJ

# Get board ID, then use for sprint operations
```

## Output Formats

| Flag | Description |
|------|-------------|
| (default) | Interactive TUI mode |
| `--plain` | Plain text table |
| `--csv` | CSV format |
| `--raw` | Raw JSON |
| `--no-truncate` | Show full field values |
| `--columns KEY,SUMMARY,...` | Select columns |
| `--no-headers` | Hide table headers |

## Templates

Use these templates for well-structured issues:

- **Bug Report**: `templates/bug-report-template.md` - Environment, Steps to Reproduce, Expected/Actual, Error Messages
- **Feature Request**: `templates/feature-request-template.md` - Overview, User Stories, Acceptance Criteria, Technical Approach

## Syntax Validation

Validate wiki markup before submitting:

```bash
scripts/validate-jira-syntax.sh path/to/content.txt
```

Checks for common Markdown mistakes and suggests Jira equivalents.

## Field Discovery

jira-cli cannot list available fields. Use the included Python script:

```bash
# Search for fields by name
uv run scripts/jira-fields.py search "story points"
uv run scripts/jira-fields.py search sprint

# List all custom fields
uv run scripts/jira-fields.py list --type custom

# JSON output
uv run scripts/jira-fields.py --json search "epic"
```

Requires auth via `~/.env.jira`:

```
JIRA_URL=https://company.atlassian.net
JIRA_USERNAME=your-email@example.com
JIRA_API_TOKEN=your-api-token
```

## Common Workflows

### Find and work on a backlog item

```bash
# Find high priority backlog items
jira issue list -p PROJ -s Backlog -yHigh --plain

# Pick one and start working
jira issue move PROJ-123 "In Progress" -a$(jira me)

# Log some work
jira issue worklog add PROJ-123 2h --comment "Started implementation"

# Add a comment
jira issue comment add PROJ-123 "WIP: implementing feature X"

# Complete the work
jira issue move PROJ-123 "Done" -R"Fixed"
```

### Sprint planning

```bash
# Find the board
jira board list -p PROJ

# List sprints
jira sprint list BOARD_ID

# Get backlog items ready for sprint
jira issue list -p PROJ -s Backlog --plain --columns KEY,SUMMARY,PRIORITY

# Add issues to sprint
jira sprint add SPRINT_ID PROJ-100 PROJ-101 PROJ-102
```

## References

- [Command Reference](references/command-reference.md) - Quick lookup table
- [JQL Quick Reference](references/jql-quick-reference.md) - Query syntax
- [Backlog Quick Wins](references/backlog-quick-wins.md) - Finding actionable items
- [Syntax Reference](references/syntax-reference.md) - Complete wiki markup documentation
- [jira-cli GitHub](https://github.com/ankitpokhrel/jira-cli) - Full documentation
- [Official Jira Wiki Markup](https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa?section=all)
