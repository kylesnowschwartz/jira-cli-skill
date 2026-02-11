# CLAUDE.md

Project guidance for Claude Code when working with this plugin.

## Overview

This plugin provides Jira integration through a single **jira** skill that combines CLI operations with wiki markup formatting.

## Architecture

```
jira-cli-skill/
├── .claude-plugin/plugin.json     # Plugin manifest
├── commands/
│   └── jira-context.md            # /jira-context command
├── skills/
│   └── jira/                      # Single unified skill
│       ├── SKILL.md               # Commands + wiki markup syntax
│       ├── scripts/
│       │   ├── jira_context.rb    # Context gathering (Ruby)
│       │   ├── jira_fields.rb     # Field discovery (Ruby)
│       │   └── validate-jira-syntax.sh
│       ├── references/
│       └── templates/
```

## Key Principles

1. **jira-cli first**: Use native jira-cli commands for everything except field discovery
2. **Wiki markup required**: All Jira content (descriptions, comments) MUST use Jira wiki markup, NOT Markdown
3. **Ruby and Bash scripts only**: No external language dependencies beyond Ruby stdlib

## Quick Reference

| Need | Use |
|------|-----|
| Search/list issues | `jira issue list` |
| View issue | `jira issue view KEY` |
| Load full context | `/jira-context KEY` (parent, children, siblings, comments) |
| Create issue | `jira issue create` |
| Edit issue | `jira issue edit KEY` |
| Transition issue | `jira issue move KEY STATUS` |
| Add comment | `jira issue comment add KEY "text"` |
| Log work | `jira issue worklog add KEY TIME` |
| Find custom fields | `ruby scripts/jira_fields.rb search TERM` |
| Validate syntax | `scripts/validate-jira-syntax.sh file.txt` |

## Authentication

- **jira-cli**: Configured via `jira init` -> `~/.config/.jira/.config.yml`
- **jira_fields.rb**: Uses `~/.env.jira` or `JIRA_URL`/`JIRA_USERNAME`/`JIRA_API_TOKEN` env vars

## Development Notes

- Use jira-cli for new features when possible
- The jira_fields.rb script fills a gap in jira-cli (field discovery)
- The jira_context.rb script provides rich context (parent, children, siblings, comments)
- Both scripts are standalone with no external lib dependencies
- Reference files in `skills/jira/references/` for JQL, backlog queries, syntax

## Testing

```bash
# Verify jira-cli
jira --version
jira serverinfo

# Verify context gathering
ruby skills/jira/scripts/jira_context.rb PROJ-123

# Verify field discovery
ruby skills/jira/scripts/jira_fields.rb --help

# Verify syntax validation
skills/jira/scripts/validate-jira-syntax.sh --help
```
