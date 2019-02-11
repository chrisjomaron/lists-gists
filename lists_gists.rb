#!/usr/bin/env ruby

# Simple; uses no extra gems
# Treat updated and deleted gists as 'new' for notification purposes.
# TODO: automate some tests

require 'net/https'
require 'json'
require 'optparse'
require 'pp'

GITHUB_API_STEM = 'https://api.github.com'.freeze

# Parse the command line options, using Ruby built-in
options = { username: 'defunkt', verbose: false }
OptionParser.new do |opts|
  opts.banner = 'Usage: lists_gists.rb [options]'

  # display usage banner
  opts.on('-h', '--help', 'Show this help message') do
    puts opts
    exit
  end

  # optional flag to show debug output
  opts.on('-v', '--verbose', 'Run verbosely') do
    options[:verbose] = true
  end

  # override default username, ARG is mandatory if switch is used
  opts.on('-u', '--username=NAME', 'username to poll for public gists') do |u|
    options[:username] = u
  end
end.parse!

# set up variables
@verbose = options[:verbose]
username = options[:username].freeze
previous_gists = []
current_gists = []

pp "Options: #{options}" if @verbose

# Convenience method to return payload from GET request
def fetch_payload(url)
  puts "Connecting to #{url}..." if @verbose
  response = Net::HTTP.get_response(URI(url))
  case response
  when Net::HTTPSuccess then
    puts 'Received JSON payload:', response.body if @verbose
    response.body
  else
    puts "Error code: #{response.value}"
    exit
  end
end

# Receives JSON and returns array of gist hashes (gist urls and timestamps)
def json_to_array(json_payload)
  array = []
  json_payload.each do |line|
    array << { 'url' => line['url'], 'updated_at' => line['updated_at'] }
  end
  array
end

# Attempt to populate array of previous gists, read from the user's state file
GISTS_FILE = "#{username}.json".freeze
begin
  old = JSON.parse(File.read(GISTS_FILE))
  previous_gists = json_to_array(old)
  puts "Read previous gists from '#{GISTS_FILE}':", previous_gists if @verbose
rescue Errno::ENOENT
  puts "File '#{GISTS_FILE}' not found. No gists seen before?"
end

# Now fetch current gists from GitHub API
gists_url = "#{GITHUB_API_STEM}/users/#{username}/gists"
json_payload = JSON.parse(fetch_payload(gists_url))
current_gists = json_to_array(json_payload)
puts 'Parsed CURRENT gists from API:', current_gists if @verbose

puts 'Calculating difference between previous and current:' if @verbose
new_gists = current_gists - previous_gists
deleted_gists = previous_gists - current_gists

if new_gists.empty?
  puts "Sorry, no new gists for #{username}"
else
  puts 'Found new gists:', new_gists
end

puts 'Detected a deleted gist:', deleted_gists unless deleted_gists.empty?

# Write all current gists back to the user's state file
File.open(GISTS_FILE, 'w') { |f| f.write(JSON.generate(current_gists)) }
