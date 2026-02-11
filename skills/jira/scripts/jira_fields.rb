#!/usr/bin/env ruby
# frozen_string_literal: true

# Jira field discovery - search and list custom fields.
#
# This is the ONE operation jira-cli cannot do: discovering available Jira fields
# (especially custom fields) by name or ID. Essential for finding field IDs to use
# with jira issue create --custom or jira issue edit --custom.
#
# Usage:
#   ruby jira_fields.rb search "story"
#   ruby jira_fields.rb list --type custom
#   ruby jira_fields.rb search sprint --json

require 'json'
require 'net/http'
require 'uri'
require 'optparse'
require 'base64'

DEFAULT_ENV_FILE = File.join(Dir.home, '.env.jira')

# Load auth config from env file with environment variable fallback
def load_config(env_file = nil)
  config = {}
  path = env_file || DEFAULT_ENV_FILE

  if File.exist?(path)
    File.readlines(path).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      next unless line.include?('=')

      key, _, value = line.partition('=')
      config[key.strip] = value.strip.delete_prefix('"').delete_suffix('"').delete_prefix("'").delete_suffix("'")
    end
  elsif env_file
    abort "Error: Environment file not found: #{path}"
  end

  # Environment variable fallback
  %w[JIRA_URL JIRA_USERNAME JIRA_API_TOKEN JIRA_PERSONAL_TOKEN JIRA_CLOUD].each do |var|
    config[var] = ENV.fetch(var, nil) if !config.key?(var) && ENV.key?(var)
  end

  config
end

def validate_config!(config)
  errors = []

  unless config['JIRA_URL']&.match?(%r{\Ahttps?://})
    errors << 'Missing or invalid JIRA_URL (must start with http:// or https://)'
  end

  has_cloud = config['JIRA_USERNAME'] && config['JIRA_API_TOKEN']
  has_pat = config['JIRA_PERSONAL_TOKEN']

  unless has_cloud || has_pat
    errors << <<~MSG.strip
      Missing auth credentials. Provide either:
          JIRA_USERNAME + JIRA_API_TOKEN (for Cloud)
          JIRA_PERSONAL_TOKEN (for Server/DC)
    MSG
  end

  return if errors.empty?

  abort "Configuration errors:\n  #{errors.join("\n  ")}"
end

# Fetch all fields from Jira REST API
def fetch_fields(config)
  url = URI("#{config['JIRA_URL'].chomp('/')}/rest/api/2/field")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = url.scheme == 'https'

  request = Net::HTTP::Get.new(url)
  request['Accept'] = 'application/json'

  if config['JIRA_PERSONAL_TOKEN']
    request['Authorization'] = "Bearer #{config['JIRA_PERSONAL_TOKEN']}"
  else
    encoded = Base64.strict_encode64("#{config['JIRA_USERNAME']}:#{config['JIRA_API_TOKEN']}")
    request['Authorization'] = "Basic #{encoded}"
  end

  response = http.request(request)

  abort "Error: Jira API returned #{response.code}: #{response.body[0..200]}" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)
rescue StandardError => e
  abort "Error: Failed to fetch fields from #{config['JIRA_URL']}: #{e.message}"
end

# Format fields as an ASCII table
def format_table(rows, columns)
  return '(no data)' if rows.empty?

  widths = columns.each_with_object({}) { |col, h| h[col] = col.length }
  rows.each do |row|
    columns.each { |col| widths[col] = [widths[col], row[col].to_s.length].max }
  end

  lines = []
  lines << columns.map { |col| col.ljust(widths[col]) }.join(' | ')
  lines << columns.map { |col| '-' * widths[col] }.join('-+-')
  rows.each do |row|
    lines << columns.map { |col| row[col].to_s.ljust(widths[col]) }.join(' | ')
  end

  lines.join("\n")
end

# --- CLI ---

options = { json: false, quiet: false, env_file: nil, limit: nil, type: 'all' }

parser = OptionParser.new do |opts|
  opts.banner = <<~BANNER
    Jira field discovery - search and list custom fields.

    Usage:
      #{$PROGRAM_NAME} search KEYWORD [options]
      #{$PROGRAM_NAME} list [options]

    Commands:
      search KEYWORD   Search fields by name or ID
      list             List available fields
  BANNER

  opts.on('--json', 'Output as JSON') { options[:json] = true }
  opts.on('-q', '--quiet', 'Minimal output (field IDs only)') { options[:quiet] = true }
  opts.on('--env-file FILE', 'Environment file path') { |f| options[:env_file] = f }
  opts.on('-n', '--limit N', Integer, 'Max results to show') { |n| options[:limit] = n }
  opts.on('-t', '--type TYPE', %w[custom system all], 'Filter by field type (custom/system/all)') do |t|
    options[:type] = t
  end
  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end

parser.parse!(ARGV)
command = ARGV.shift

unless %w[search list].include?(command)
  puts parser
  exit 1
end

config = load_config(options[:env_file])
validate_config!(config)
fields = fetch_fields(config)

case command
when 'search'
  keyword = ARGV.shift
  abort 'Error: search requires a KEYWORD argument' unless keyword

  limit = options[:limit] || 20
  keyword_lower = keyword.downcase
  matching = fields.select do |f|
    (f['name'] || '').downcase.include?(keyword_lower) ||
      (f['id'] || '').downcase.include?(keyword_lower)
  end.first(limit)

  if options[:json]
    puts JSON.pretty_generate(matching)
  elsif options[:quiet]
    matching.each { |f| puts f['id'] }
  elsif matching.empty?
    puts "No fields matching '#{keyword}'"
  else
    puts "Fields matching '#{keyword}' (#{matching.length} shown):\n\n"
    rows = matching.map do |f|
      {
        'ID' => f['id'] || '',
        'Name' => f['name'] || '',
        'Type' => f.dig('schema', 'type') || '-',
        'Custom' => f['custom'] ? 'Yes' : 'No'
      }
    end
    puts format_table(rows, %w[ID Name Type Custom])
  end

when 'list'
  limit = options[:limit] || 50

  filtered = case options[:type]
             when 'custom' then fields.select { |f| f['custom'] }
             when 'system' then fields.reject { |f| f['custom'] }
             else fields
             end.first(limit)

  if options[:json]
    puts JSON.pretty_generate(filtered)
  elsif options[:quiet]
    filtered.each { |f| puts f['id'] }
  else
    puts "Jira fields (#{options[:type]}, #{filtered.length} shown):\n\n"
    rows = filtered.map do |f|
      {
        'ID' => f['id'] || '',
        'Name' => f['name'] || '',
        'Custom' => f['custom'] ? 'Yes' : 'No'
      }
    end
    puts format_table(rows, %w[ID Name Custom])
  end
end
