---
description: Load Jira context for an issue including parent, children, and siblings
model: sonnet
allowed-tools: Bash(ruby:*), Bash(jira:*)
---

Load comprehensive Jira context for issue: $ARGUMENTS

## Step 1: Run the context script

```bash
ruby ${CLAUDE_PLUGIN_ROOT}/skills/jira/scripts/jira_context.rb $ARGUMENTS
```

## Step 2: Format the JSON output as markdown

Parse the JSON and present as:

### [KEY]: [Summary]

**Status:** [status] | **Type:** [type] | **Assignee:** [assignee or "Unassigned"]

#### Description
[description text, or "No description" if null]

#### Parent Epic (if parent exists)
**[parent.key]:** [parent.summary]
Status: [parent.status] | Type: [parent.type]

#### Child Issues (if children exist)
| Key | Status | Summary |
|-----|--------|---------|
| ... | ... | ... |

#### Sibling Issues (if siblings exist)
| Key | Status | Summary |
|-----|--------|---------|
| ... | ... | ... |

Mark the current issue with an arrow (-->) at the start of its row.

#### Recent Comments (if comments exist)
For each comment show:
**[author]** ([created date formatted as YYYY-MM-DD]):
> [body text]

## Notes

- If no parent exists, skip the "Parent Epic" and "Sibling Issues" sections
- If no children exist, skip the "Child Issues" section
- If no comments exist, skip the "Recent Comments" section
- If description is null, show "No description provided"
- Format dates as YYYY-MM-DD for readability
