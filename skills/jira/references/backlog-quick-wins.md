# Backlog Quick Wins

Commands for finding actionable items in the backlog using `jira-cli`.

## Prerequisites

- `jira-cli` installed (`brew install jira-cli`)
- Configured via `jira init` or `~/.config/.jira/.config.yml`

## Core Command Structure

```bash
jira issue list -p <PROJECT> -s Backlog [filters] --plain --columns KEY,SUMMARY,TYPE,PRIORITY --no-truncate
```

**Output Flags:**
- `--plain` - Table output (vs interactive mode)
- `--no-truncate` - Show full field values
- `--csv` - CSV output for parsing
- `--raw` - Raw JSON
- `--columns KEY,SUMMARY,...` - Select specific columns

## Quick Win Queries

### All Backlog Items

```bash
jira issue list -p PROJ -s Backlog --plain --columns KEY,SUMMARY,TYPE,PRIORITY --no-truncate
```

### High Priority Items

Items that should have been done already:

```bash
jira issue list -p PROJ -s Backlog -yHigh --plain --columns KEY,SUMMARY,TYPE --no-truncate
```

### Tasks Only (Typically Smaller Scope)

Tasks tend to be more concrete than Stories:

```bash
jira issue list -p PROJ -s Backlog -t Task --plain --columns KEY,SUMMARY,PRIORITY --no-truncate
```

### Bugs in Backlog

Often good quick wins - clear problem, clear fix:

```bash
jira issue list -p PROJ -s Backlog -t Bug --plain --columns KEY,SUMMARY,PRIORITY --no-truncate
```

### Unassigned Items (Available to Pick Up)

`-ax` means assignee = unassigned:

```bash
jira issue list -p PROJ -s Backlog -ax --plain --columns KEY,SUMMARY,TYPE,PRIORITY --no-truncate
```

### Recently Created (Fresh Context)

Items from the last 30 days where context is still fresh:

```bash
jira issue list -p PROJ -s Backlog --created -30d --plain --columns KEY,SUMMARY,TYPE,CREATED --no-truncate
```

### Small Story Points (JQL)

Items estimated at 3 points or less:

```bash
jira issue list -p PROJ -q 'status = Backlog AND "Story Points" <= 3' --plain --columns KEY,SUMMARY,TYPE,PRIORITY --no-truncate
```

### Sub-tasks (Usually Well-Defined)

Sub-tasks often have clearer scope than parent issues:

```bash
jira issue list -p PROJ -s Backlog -t Sub-task --plain --columns KEY,SUMMARY,PRIORITY --no-truncate
```

### Unassigned High Priority

The intersection - high value and available:

```bash
jira issue list -p PROJ -s Backlog -yHigh -ax --plain --columns KEY,SUMMARY,TYPE --no-truncate
```

### Items with Specific Label

If your team uses labels like `quick-win` or `ai-suitable`:

```bash
jira issue list -p PROJ -s Backlog -l quick-win --plain --columns KEY,SUMMARY,TYPE --no-truncate
jira issue list -p PROJ -s Backlog -l ai-suitable --plain --columns KEY,SUMMARY,TYPE --no-truncate
```

## Combined Filters (Power Queries)

### Small, Unassigned Tasks

```bash
jira issue list -p PROJ -q 'status = Backlog AND type = Task AND assignee IS EMPTY AND "Story Points" <= 2' --plain --columns KEY,SUMMARY,PRIORITY --no-truncate
```

### Recent High Priority

```bash
jira issue list -p PROJ -s Backlog -yHigh --created -30d --plain --columns KEY,SUMMARY,CREATED --no-truncate
```

### My Backlog Items

Items assigned to you that slipped back to backlog:

```bash
jira issue list -p PROJ -s Backlog -a$(jira me) --plain --columns KEY,SUMMARY,PRIORITY --no-truncate
```

## Output for Scripting

### CSV Export

```bash
jira issue list -p PROJ -s Backlog -t Task --csv > backlog-tasks.csv
```

### JSON for Processing

```bash
jira issue list -p PROJ -s Backlog --raw | jq '.[] | {key, summary, priority: .fields.priority.name}'
```

### Count Only

```bash
jira issue list -p PROJ -s Backlog --plain --no-headers | wc -l
```

## Tips

1. **Start with `-yHigh`** - High priority items in backlog are low-hanging fruit
2. **Check `-t Task`** - Tasks are usually more actionable than Stories
3. **Use `--created -7d`** - Recent items have fresher context
4. **Filter by labels** - Teams often tag items as `quick-win`, `tech-debt`, `ai-suitable`
5. **Combine `-ax` with other filters** - Unassigned + specific type = ready to grab

## Related

- JQL syntax: [jql-quick-reference.md](jql-quick-reference.md)
- Full jira-cli docs: https://github.com/ankitpokhrel/jira-cli
