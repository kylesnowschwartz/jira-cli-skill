# jira-cli-skill

A Claude Code plugin for Jira integration via [jira-cli](https://github.com/ankitpokhrel/jira-cli).

## Features

- **Issue operations**: Search, create, edit, transition, comment, worklog, sprint, board management
- **Rich context**: `/jira-context` command gathers parent, children, siblings, and recent comments
- **Wiki markup**: Syntax reference, validation script, and templates (Jira doesn't use Markdown)
- **Field discovery**: Ruby script for finding custom field IDs (the one thing jira-cli can't do)

## Installation

### Prerequisites

```bash
# Install jira-cli (macOS)
brew install jira-cli

# Ruby (included with macOS, or install via rbenv/asdf)
ruby --version
```

### Configure jira-cli

```bash
# Interactive setup - follow prompts
jira init

# Verify
jira serverinfo
jira me
```

### Install the plugin

```bash
# Via Claude Code
claude plugin marketplace add kylesnowschwartz/jira-cli-skill
claude plugin install jira-cli-skill
```

## Quick Start

```bash
# Search issues
jira issue list -p PROJ -s "In Progress"

# View issue
jira issue view PROJ-123

# Get rich context (parent, children, siblings, comments)
/jira-context PROJ-123
# or
/jira-context https://company.atlassian.net/browse/PROJ-123

# Create issue (use wiki markup for description!)
jira issue create -p PROJ -t Bug -s "Login fails" -b "h2. Steps
# Navigate to login
# Enter credentials

h2. Expected
Login succeeds"

# Transition
jira issue move PROJ-123 "Done"

# Find custom field IDs
ruby skills/jira/scripts/jira_fields.rb search "story points"

# Validate wiki markup
skills/jira/scripts/validate-jira-syntax.sh description.txt
```

## Rich Context with /jira-context

The `/jira-context` command provides comprehensive issue context in one shot:

- **Issue details**: Summary, status, type, assignee, description
- **Parent epic**: If the issue has a parent, shows parent details
- **Child issues**: If the issue is an epic/parent, lists all children
- **Sibling issues**: Other issues under the same parent
- **Recent comments**: Last 5 comments with author and date

This is particularly useful when you need to understand an issue's place in the project hierarchy or when planning work that depends on related issues.

**Usage:**
```bash
/jira-context PROJ-123
/jira-context https://company.atlassian.net/browse/PROJ-123
```

**Behind the scenes:**
Uses `ruby skills/jira/scripts/jira_context.rb` which:
1. Fetches issue details via `jira issue view --raw`
2. Queries children via JQL: `"Parent Link" = PARENT-KEY`
3. Parses Atlassian Document Format (ADF) to readable text
4. Returns JSON that Claude formats as readable markdown

## Wiki Markup (Not Markdown!)

Jira uses wiki markup. Common conversions:

| Markdown | Jira |
|----------|------|
| `## Heading` | `h2. Heading` |
| `**bold**` | `*bold*` |
| `` `code` `` | `{{code}}` |
| `[text](url)` | `[text\|url]` |
| `- item` | `* item` |

See [SKILL.md](skills/jira/SKILL.md) for full reference.

## Field Discovery

jira-cli cannot list available fields. The included Ruby script fills this gap:

```bash
ruby skills/jira/scripts/jira_fields.rb search "sprint"
ruby skills/jira/scripts/jira_fields.rb list --type custom --json
```

Auth via `~/.env.jira` or environment variables (`JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN`):

```bash
# Jira Cloud
JIRA_URL=https://company.atlassian.net
JIRA_USERNAME=your-email@example.com
JIRA_API_TOKEN=your-api-token

# Jira Server/DC
JIRA_URL=https://jira.yourcompany.com
JIRA_PERSONAL_TOKEN=your-personal-access-token
```

## Documentation

- [Jira SKILL.md](skills/jira/SKILL.md) - Full command and syntax reference
- [JQL Quick Reference](skills/jira/references/jql-quick-reference.md)
- [Backlog Quick Wins](skills/jira/references/backlog-quick-wins.md)
- [Syntax Reference](skills/jira/references/syntax-reference.md)

## License

MIT
