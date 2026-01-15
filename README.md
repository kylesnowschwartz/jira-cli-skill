# jira-cli-skill

A Claude Code plugin for Jira integration via [jira-cli](https://github.com/ankitpokhrel/jira-cli).

## Features

- **jira-cli wrapper**: Issue search, creation, editing, transitions, comments, worklogs, sprints, boards
- **jira-syntax**: Wiki markup templates and formatting guidance for Jira content
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

# Create issue
jira issue create -p PROJ -t Task -s "Fix login bug"

# Transition
jira issue move PROJ-123 "Done"

# Find custom field IDs
uv run skills/jira-cli/scripts/jira-fields.py search "story points"
```

## Skills

| Skill | Description |
|-------|-------------|
| **jira-cli** | Command reference for jira-cli operations |
| **jira-syntax** | Wiki markup formatting for descriptions/comments |

## Field Discovery

jira-cli cannot list available fields. The included Python script fills this gap:

```bash
uv run skills/jira-cli/scripts/jira-fields.py search "sprint"
uv run skills/jira-cli/scripts/jira-fields.py list --type custom --json
```

This requires separate auth via `~/.env.jira`:

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

- [jira-cli SKILL.md](skills/jira-cli/SKILL.md) - Full command reference
- [jira-syntax SKILL.md](skills/jira-syntax/SKILL.md) - Wiki markup guide
- [JQL Quick Reference](skills/jira-cli/references/jql-quick-reference.md)
- [Backlog Quick Wins](skills/jira-cli/references/backlog-quick-wins.md)

## License

MIT
