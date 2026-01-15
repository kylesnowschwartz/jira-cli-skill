#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "atlassian-python-api>=3.41.0",
#     "click>=8.1.0",
# ]
# ///
"""
Jira field discovery - search and list custom fields.

This is the ONE operation jira-cli cannot do: discovering available Jira fields
(especially custom fields) by name or ID. Essential for finding field IDs to use
with jira issue create --custom or jira issue edit --custom.

Usage:
    uv run jira-fields.py search "story"
    uv run jira-fields.py list --type custom
"""

import json
import os
import sys
from pathlib import Path
from typing import Any, Optional

import click
from atlassian import Jira

# ============================================================================
# Inlined configuration (from lib/config.py)
# ============================================================================

DEFAULT_ENV_FILE = Path.home() / ".env.jira"

REQUIRED_URL = 'JIRA_URL'
CLOUD_VARS = ['JIRA_USERNAME', 'JIRA_API_TOKEN']
SERVER_VARS = ['JIRA_PERSONAL_TOKEN']
OPTIONAL_VARS = ['JIRA_CLOUD']
ALL_VARS = [REQUIRED_URL] + CLOUD_VARS + SERVER_VARS + OPTIONAL_VARS


def load_env(env_file: Optional[str] = None) -> dict:
    """Load configuration from file with environment variable fallback."""
    config = {}
    path = Path(env_file) if env_file else DEFAULT_ENV_FILE

    if path.exists():
        with open(path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, _, value = line.partition('=')
                    config[key.strip()] = value.strip().strip('"').strip("'")
    elif env_file:
        raise FileNotFoundError(f"Environment file not found: {path}")

    for var in ALL_VARS:
        if var not in config and var in os.environ:
            config[var] = os.environ[var]

    return config


def validate_config(config: dict) -> list:
    """Validate configuration has required variables."""
    errors = []

    if REQUIRED_URL not in config or not config[REQUIRED_URL]:
        errors.append(f"Missing required variable: {REQUIRED_URL}")

    if REQUIRED_URL in config and config[REQUIRED_URL]:
        url = config[REQUIRED_URL]
        if not url.startswith(('http://', 'https://')):
            errors.append(f"JIRA_URL must start with http:// or https://: {url}")

    has_cloud_auth = all(config.get(var) for var in CLOUD_VARS)
    has_server_auth = config.get('JIRA_PERSONAL_TOKEN')

    if not has_cloud_auth and not has_server_auth:
        errors.append(
            "Missing authentication credentials. Provide either:\n"
            "    - JIRA_USERNAME + JIRA_API_TOKEN (for Cloud)\n"
            "    - JIRA_PERSONAL_TOKEN (for Server/DC)"
        )

    return errors


def get_auth_mode(config: dict) -> str:
    """Determine authentication mode from config."""
    if config.get('JIRA_PERSONAL_TOKEN'):
        return 'pat'
    return 'cloud'


# ============================================================================
# Inlined client (from lib/client.py)
# ============================================================================

def get_jira_client(env_file: Optional[str] = None) -> Jira:
    """Initialize and return a Jira client."""
    config = load_env(env_file)

    errors = validate_config(config)
    if errors:
        raise ValueError("Configuration errors:\n  " + "\n  ".join(errors))

    url = config['JIRA_URL']
    auth_mode = get_auth_mode(config)

    is_cloud = config.get('JIRA_CLOUD', '').lower() == 'true'
    if 'JIRA_CLOUD' not in config:
        is_cloud = '.atlassian.net' in url.lower()

    try:
        if auth_mode == 'pat':
            client = Jira(
                url=url,
                token=config['JIRA_PERSONAL_TOKEN'],
                cloud=is_cloud
            )
        else:
            client = Jira(
                url=url,
                username=config['JIRA_USERNAME'],
                password=config['JIRA_API_TOKEN'],
                cloud=is_cloud
            )
        return client
    except Exception as e:
        raise ConnectionError(f"Failed to connect to Jira at {url}: {e}")


# ============================================================================
# Inlined output (from lib/output.py)
# ============================================================================

def format_json(data: Any, indent: int = 2) -> str:
    """Format data as JSON string."""
    return json.dumps(data, indent=indent, default=str)


def format_table(data: list, columns: Optional[list] = None) -> str:
    """Format list of dicts as ASCII table."""
    if not data:
        return "(no data)"

    if columns is None:
        columns = list(data[0].keys()) if isinstance(data[0], dict) else ['value']

    widths = {col: len(col) for col in columns}
    for row in data:
        if isinstance(row, dict):
            for col in columns:
                val = str(row.get(col, ''))
                widths[col] = max(widths[col], len(val))

    lines = []
    header = " | ".join(col.ljust(widths[col]) for col in columns)
    lines.append(header)
    lines.append("-+-".join("-" * widths[col] for col in columns))

    for row in data:
        if isinstance(row, dict):
            line = " | ".join(str(row.get(col, '')).ljust(widths[col]) for col in columns)
        else:
            line = str(row)
        lines.append(line)

    return "\n".join(lines)


def error(message: str) -> None:
    """Print error message."""
    print(f"Error: {message}", file=sys.stderr)


# ============================================================================
# CLI Definition
# ============================================================================

@click.group()
@click.option('--json', 'output_json', is_flag=True, help='Output as JSON')
@click.option('--quiet', '-q', is_flag=True, help='Minimal output (field IDs only)')
@click.option('--env-file', type=click.Path(), help='Environment file path')
@click.option('--debug', is_flag=True, help='Show debug information on errors')
@click.pass_context
def cli(ctx, output_json: bool, quiet: bool, env_file: str | None, debug: bool):
    """Jira field discovery.

    Search and list Jira fields (including custom fields).
    This is the one thing jira-cli cannot do natively.

    \b
    Examples:
        jira-fields.py search "story points"
        jira-fields.py list --type custom
    """
    ctx.ensure_object(dict)
    ctx.obj['json'] = output_json
    ctx.obj['quiet'] = quiet
    ctx.obj['debug'] = debug
    try:
        ctx.obj['client'] = get_jira_client(env_file)
    except Exception as e:
        if debug:
            raise
        error(str(e))
        sys.exit(1)


@cli.command()
@click.argument('keyword')
@click.option('--limit', '-n', default=20, help='Max results to show')
@click.pass_context
def search(ctx, keyword: str, limit: int):
    """Search fields by keyword.

    KEYWORD: Search term (matches name or ID)

    Useful for finding custom field IDs for --custom options.

    \b
    Examples:
        jira-fields.py search sprint
        jira-fields.py search "story points"
        jira-fields.py search customfield
    """
    client = ctx.obj['client']

    try:
        fields = client.get_all_fields()

        keyword_lower = keyword.lower()
        matching = [
            f for f in fields
            if keyword_lower in f.get('name', '').lower()
            or keyword_lower in f.get('id', '').lower()
        ][:limit]

        if ctx.obj['json']:
            print(format_json(matching))
        elif ctx.obj['quiet']:
            for f in matching:
                print(f.get('id', ''))
        else:
            if not matching:
                print(f"No fields matching '{keyword}'")
            else:
                print(f"Fields matching '{keyword}' ({len(matching)} shown):\n")
                rows = []
                for f in matching:
                    rows.append({
                        'ID': f.get('id', ''),
                        'Name': f.get('name', ''),
                        'Type': f.get('schema', {}).get('type', '-'),
                        'Custom': 'Yes' if f.get('custom', False) else 'No'
                    })
                print(format_table(rows, ['ID', 'Name', 'Type', 'Custom']))

    except Exception as e:
        if ctx.obj['debug']:
            raise
        error(f"Failed to search fields: {e}")
        sys.exit(1)


@cli.command('list')
@click.option('--type', '-t', 'field_type', type=click.Choice(['custom', 'system', 'all']),
              default='all', help='Filter by field type')
@click.option('--limit', '-n', default=50, help='Max results to show')
@click.pass_context
def list_fields(ctx, field_type: str, limit: int):
    """List available fields.

    \b
    Examples:
        jira-fields.py list
        jira-fields.py list --type custom
        jira-fields.py list --type system --limit 100
    """
    client = ctx.obj['client']

    try:
        fields = client.get_all_fields()

        if field_type == 'custom':
            fields = [f for f in fields if f.get('custom', False)]
        elif field_type == 'system':
            fields = [f for f in fields if not f.get('custom', False)]

        fields = fields[:limit]

        if ctx.obj['json']:
            print(format_json(fields))
        elif ctx.obj['quiet']:
            for f in fields:
                print(f.get('id', ''))
        else:
            type_label = field_type if field_type != 'all' else 'all'
            print(f"Jira fields ({type_label}, {len(fields)} shown):\n")
            rows = []
            for f in fields:
                rows.append({
                    'ID': f.get('id', ''),
                    'Name': f.get('name', ''),
                    'Custom': 'Yes' if f.get('custom', False) else 'No'
                })
            print(format_table(rows, ['ID', 'Name', 'Custom']))

    except Exception as e:
        if ctx.obj['debug']:
            raise
        error(f"Failed to list fields: {e}")
        sys.exit(1)


if __name__ == '__main__':
    cli()
