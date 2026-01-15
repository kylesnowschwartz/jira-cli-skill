# CLAUDE.md

Project guidance for Claude Code when working with this plugin.

## Overview

This plugin provides Jira integration through two skills:

1. **jira-cli**: Wrapper for the [jira-cli](https://github.com/ankitpokhrel/jira-cli) Go tool
2. **jira-syntax**: Wiki markup formatting for Jira content

## Architecture

```
jira-cli-skill/
├── .claude-plugin/plugin.json     # Plugin manifest
├── SKILL.md                       # Root skill (entry point)
├── skills/
│   ├── jira-cli/                  # PRIMARY: jira-cli commands
│   │   ├── SKILL.md               # Command reference
│   │   ├── scripts/
│   │   │   └── jira-fields.py     # ONLY Python script
│   │   └── references/
│   └── jira-syntax/               # Wiki markup skill
```

## Key Principles

1. **jira-cli first**: Use native jira-cli commands for everything except field discovery
2. **Wiki markup required**: All Jira content (descriptions, comments) MUST use Jira wiki markup, NOT Markdown
3. **Single Python script**: `jira-fields.py` is the only Python code - it fills the one gap in jira-cli

## When to Use Which

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
| Format content | Load **jira-syntax** skill |

## Authentication

- **jira-cli**: Configured via `jira init` -> `~/.config/.jira/.config.yml`
- **jira-fields.py**: Uses `~/.env.jira` (separate auth for the Python script)

## Development Notes

- Do not add more Python scripts - use jira-cli for new features
- The jira-fields.py script is standalone (no external lib dependencies)
- Reference files in `skills/jira-cli/references/` for JQL, backlog queries

## Testing

```bash
# Verify jira-cli
jira --version
jira serverinfo

# Verify field discovery
uv run skills/jira-cli/scripts/jira-fields.py --help
```
