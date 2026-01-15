# CLAUDE.md

Project guidance for Claude Code when working with this plugin.

## Overview

This plugin provides Jira integration through a single **jira** skill that combines CLI operations with wiki markup formatting.

## Architecture

```
jira-cli-skill/
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/
│   └── jira/                      # Single unified skill
│       ├── SKILL.md               # Commands + wiki markup syntax
│       ├── scripts/
│       │   ├── jira-fields.py     # Field discovery (Python)
│       │   └── validate-jira-syntax.sh
│       ├── references/
│       └── templates/
```

## Key Principles

1. **jira-cli first**: Use native jira-cli commands for everything except field discovery
2. **Wiki markup required**: All Jira content (descriptions, comments) MUST use Jira wiki markup, NOT Markdown
3. **Single Python script**: `jira-fields.py` is the only Python code - it fills the one gap in jira-cli

## Quick Reference

| Need | Use |
|------|-----|
| Search/list issues | `jira issue list` |
| View issue | `jira issue view KEY` |
| Create issue | `jira issue create` |
| Edit issue | `jira issue edit KEY` |
| Transition issue | `jira issue move KEY STATUS` |
| Add comment | `jira issue comment add KEY "text"` |
| Log work | `jira issue worklog add KEY TIME` |
| Find custom fields | `uv run scripts/jira-fields.py search TERM` |
| Validate syntax | `scripts/validate-jira-syntax.sh file.txt` |

## Authentication

- **jira-cli**: Configured via `jira init` -> `~/.config/.jira/.config.yml`
- **jira-fields.py**: Uses `~/.env.jira` (separate auth for the Python script)

## Development Notes

- Do not add more Python scripts - use jira-cli for new features
- The jira-fields.py script is standalone (no external lib dependencies)
- Reference files in `skills/jira/references/` for JQL, backlog queries, syntax

## Testing

```bash
# Verify jira-cli
jira --version
jira serverinfo

# Verify field discovery
uv run skills/jira/scripts/jira-fields.py --help

# Verify syntax validation
skills/jira/scripts/validate-jira-syntax.sh --help
```
