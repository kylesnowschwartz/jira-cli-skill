# jira-cli Command Reference

Quick lookup for common jira-cli commands.

## Issue Commands

| Command | Description | Example |
|---------|-------------|---------|
| `jira issue list` | Search/list issues | `jira issue list -p PROJ -s "In Progress"` |
| `jira issue view KEY` | View issue details | `jira issue view PROJ-123 --comments 5` |
| `jira issue create` | Create new issue | `jira issue create -p PROJ -t Bug -s "Title"` |
| `jira issue edit KEY` | Edit issue fields | `jira issue edit PROJ-123 -s "New title"` |
| `jira issue move KEY STATUS` | Transition status | `jira issue move PROJ-123 "Done"` |
| `jira issue assign KEY USER` | Assign issue | `jira issue assign PROJ-123 user@email` |
| `jira issue clone KEY` | Duplicate issue | `jira issue clone PROJ-123` |
| `jira issue delete KEY` | Delete issue | `jira issue delete PROJ-123` |
| `jira issue link KEY1 KEY2 TYPE` | Link issues | `jira issue link PROJ-1 PROJ-2 "Blocks"` |
| `jira issue unlink KEY1 KEY2` | Remove link | `jira issue unlink PROJ-1 PROJ-2` |
| `jira issue comment add KEY` | Add comment | `jira issue comment add PROJ-123 "text"` |
| `jira issue worklog add KEY TIME` | Log time | `jira issue worklog add PROJ-123 2h` |
| `jira issue worklog list KEY` | List worklogs | `jira issue worklog list PROJ-123` |
| `jira issue watch KEY` | Watch issue | `jira issue watch PROJ-123` |

## Issue List Flags

| Flag | Description | Example |
|------|-------------|---------|
| `-p, --project` | Filter by project | `-p PROJ` |
| `-s, --status` | Filter by status | `-s "In Progress"` |
| `-t, --type` | Filter by type | `-t Bug` |
| `-y, --priority` | Filter by priority | `-yHigh` |
| `-a, --assignee` | Filter by assignee | `-a user@email` |
| `-ax` | Unassigned only | `-ax` |
| `-r, --reporter` | Filter by reporter | `-r user@email` |
| `-l, --label` | Filter by label | `-l backend` |
| `-C, --component` | Filter by component | `-C "API"` |
| `-q, --jql` | Custom JQL query | `-q "sprint = 123"` |
| `--created` | Created date filter | `--created -7d` |
| `--updated` | Updated date filter | `--updated today` |
| `-w, --watching` | Issues I'm watching | `-w` |
| `--history` | Recently accessed | `--history` |

## Output Flags

| Flag | Description |
|------|-------------|
| `--plain` | Plain text table (vs interactive TUI) |
| `--csv` | CSV format |
| `--raw` | Raw JSON |
| `--no-truncate` | Show full field values |
| `--no-headers` | Hide table headers |
| `--columns COL1,COL2` | Select columns to display |
| `--paginate N` | Limit results |

## Issue Create Flags

| Flag | Description |
|------|-------------|
| `-p, --project` | Project key (required if not in config) |
| `-t, --type` | Issue type (Bug, Task, Story, etc.) |
| `-s, --summary` | Issue title |
| `-b, --body` | Description |
| `-y, --priority` | Priority level |
| `-a, --assignee` | Assignee |
| `-r, --reporter` | Reporter |
| `-l, --label` | Labels (repeatable) |
| `-C, --component` | Components (repeatable) |
| `-P, --parent` | Parent issue (for subtasks/epics) |
| `--custom KEY=VALUE` | Custom field |
| `--no-input` | Skip interactive prompts |
| `-T, --template` | Read body from file |

## Sprint Commands

| Command | Description | Example |
|---------|-------------|---------|
| `jira sprint list BOARD_ID` | List sprints | `jira sprint list 123` |
| `jira sprint add SPRINT_ID KEY` | Add issue to sprint | `jira sprint add 456 PROJ-123` |

### Sprint List Flags

| Flag | Description |
|------|-------------|
| `--state STATE` | Filter: active, future, closed |
| `--current` | Show current sprint only |

## Board Commands

| Command | Description | Example |
|---------|-------------|---------|
| `jira board list` | List boards | `jira board list -p PROJ` |

## Other Commands

| Command | Description |
|---------|-------------|
| `jira me` | Show current user |
| `jira serverinfo` | Show server info |
| `jira open KEY` | Open issue in browser |
| `jira init` | Configure jira-cli |

## Date Filters

For `--created` and `--updated` flags:

| Value | Meaning |
|-------|---------|
| `today` | Today |
| `week` | This week |
| `month` | This month |
| `year` | This year |
| `-7d` | Last 7 days |
| `-2w` | Last 2 weeks |
| `-30d` | Last 30 days |
| `2024-01-15` | Specific date |

## Common Link Types

| Type | Description |
|------|-------------|
| `Blocks` | This issue blocks another |
| `is blocked by` | This issue is blocked by another |
| `Relates` | Related issues |
| `Duplicate` | Duplicate issues |
| `Clones` | Issue cloned from another |

## Navigation (Interactive Mode)

| Key | Action |
|-----|--------|
| `j/k` or arrows | Move up/down |
| `h/l` | Move left/right |
| `g/G` | Go to top/bottom |
| `v` | View issue details |
| `m` | Move/transition issue |
| `Enter` | Open in browser |
| `c` | Copy URL |
| `Ctrl+k` | Copy key |
| `q` / `Esc` | Quit |
| `?` | Help |
