#!/usr/bin/env ruby
# frozen_string_literal: true

# Get comprehensive Jira context for an issue
# Usage: ruby jira_context.rb ATH-1681
#        ruby jira_context.rb https://envato.atlassian.net/browse/ATH-1681
# Output: JSON with issue details, parent, siblings, comments

require 'json'
require 'open3'

def extract_key(input)
  # Handle URL or direct key
  input.gsub(%r{.*/browse/}, '').strip
end

def jira_view(key)
  stdout, _stderr, status = Open3.capture3('jira', 'issue', 'view', key, '--raw')
  return nil unless status.success?

  JSON.parse(stdout)
rescue JSON::ParserError
  nil
end

def jira_list_children(parent_key, project)
  stdout, _stderr, status = Open3.capture3(
    'jira', 'issue', 'list',
    '-p', project,
    '--jql', "\"Parent Link\" = #{parent_key}",
    '--plain', '--no-headers',
    '--columns', 'KEY,STATUS,SUMMARY'
  )
  return [] unless status.success?

  stdout.lines.filter_map do |line|
    parts = line.strip.split("\t")
    next if parts.length < 3

    { key: parts[0], status: parts[1], summary: parts[2] }
  end
end

def extract_text_from_adf(node)
  return '' unless node.is_a?(Hash)

  case node['type']
  when 'text'
    text = node['text'] || ''
    # Handle marks (bold, italic, code, etc.)
    marks = node['marks'] || []
    marks.each do |mark|
      case mark['type']
      when 'code'
        text = "`#{text}`"
      when 'strong'
        text = "**#{text}**"
      when 'em'
        text = "_#{text}_"
      end
    end
    text
  when 'hardBreak'
    "\n"
  when 'mention'
    "@#{node.dig('attrs', 'text') || 'unknown'}"
  when 'inlineCard'
    node.dig('attrs', 'url') || '[link]'
  else
    content = node['content']
    return '' unless content.is_a?(Array)

    parts = content.map { |child| extract_text_from_adf(child) }

    # Add appropriate separators based on node type
    case node['type']
    when 'paragraph'
      "#{parts.join}\n"
    when 'bulletList', 'orderedList'
      parts.join
    when 'listItem'
      "- #{parts.join.strip}\n"
    when 'codeBlock'
      lang = node.dig('attrs', 'language') || ''
      "```#{lang}\n#{parts.join}\n```\n"
    when 'heading'
      level = node.dig('attrs', 'level') || 1
      "#{'#' * level} #{parts.join.strip}\n"
    when 'blockquote'
      parts.map { |p| "> #{p}" }.join
    else
      parts.join
    end
  end
end

def extract_description(fields)
  desc = fields['description']
  return nil if desc.nil?

  text = extract_text_from_adf(desc)
  text.strip.empty? ? nil : text.strip
end

def extract_comments(fields, limit: 5)
  comments = fields.dig('comment', 'comments') || []
  comments.last(limit).map do |c|
    {
      author: c.dig('author', 'displayName'),
      created: c['created'],
      body: extract_text_from_adf(c['body'] || {}).strip
    }
  end
end

def build_result(issue)
  fields = issue['fields']
  key = issue['key']
  project = key.split('-').first

  result = {
    key: key,
    summary: fields['summary'],
    status: fields.dig('status', 'name'),
    type: fields.dig('issuetype', 'name'),
    assignee: fields.dig('assignee', 'displayName'),
    reporter: fields.dig('reporter', 'displayName'),
    created: fields['created'],
    updated: fields['updated'],
    description: extract_description(fields),
    parent: nil,
    children: [],
    siblings: [],
    comments: extract_comments(fields, limit: 5)
  }

  # Get children of this issue (e.g., stories under an epic)
  result[:children] = jira_list_children(key, project)

  # Get parent if exists
  if fields['parent']
    parent = fields['parent']
    parent_key = parent['key']
    result[:parent] = {
      key: parent_key,
      summary: parent.dig('fields', 'summary'),
      status: parent.dig('fields', 'status', 'name'),
      type: parent.dig('fields', 'issuetype', 'name')
    }

    # Get siblings under same parent
    result[:siblings] = jira_list_children(parent_key, project)
  end

  result
end

# Main
if __FILE__ == $PROGRAM_NAME
  input = ARGV[0]
  if input.nil? || input.empty?
    warn 'Usage: ruby jira_context.rb ISSUE-KEY'
    warn '       ruby jira_context.rb https://envato.atlassian.net/browse/ISSUE-KEY'
    exit 1
  end

  key = extract_key(input)
  issue = jira_view(key)

  if issue.nil?
    warn "Failed to fetch issue: #{key}"
    exit 1
  end

  result = build_result(issue)
  puts JSON.pretty_generate(result)
end
