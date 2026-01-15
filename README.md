# jira-cli-skill

A Claude Code plugin for Jira integration via [jira-cli](https://github.com/ankitpokhrel/jira-cli).

## Features

- **Issue operations**: Search, create, edit, transition, comment, worklog, sprint, board management
- **Wiki markup**: Syntax reference, validation script, and templates (Jira doesn't use Markdown)
- **Field discovery**: Python script for finding custom field IDs (the one thing jira-cli can't do)

## Installation

### Prerequisites

```bash
# Install jira-cli (macOS)
brew install jira-cli

# Install uv (for field discovery script)
brew install uv
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
/install-plugin /path/to/jira-cli-skill
```

## Quick Start

```bash
# Search issues
jira issue list -p PROJ -s "In Progress"

# View issue
jira issue view PROJ-123

# Create issue (use wiki markup for description!)
jira issue create -p PROJ -t Bug -s "Login fails" -b "h2. Steps
# Navigate to login
# Enter credentials

h2. Expected
Login succeeds"

# Transition
jira issue move PROJ-123 "Done"

# Find custom field IDs
uv run skills/jira/scripts/jira-fields.py search "story points"

# Validate wiki markup
skills/jira/scripts/validate-jira-syntax.sh description.txt
```

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

jira-cli cannot list available fields. The included Python script fills this gap:

```bash
uv run skills/jira/scripts/jira-fields.py search "sprint"
uv run skills/jira/scripts/jira-fields.py list --type custom --json
```

Requires separate auth via `~/.env.jira`:

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
