#!/usr/bin/env ruby

# Simple; uses no extra gems
# Treat updated gists as 'new'
# TODO: tests

require 'net/https'
require 'json'
require 'optparse'
require 'pp'

GITHUB_API_STEM = 'https://api.github.com'.freeze

# Parse the command line options, using Ruby built-in
options = {:username => 'defunkt', :verbose => false}
OptionParser.new do |opts|
  opts.banner = "Usage: lists_gists.rb [options]"

  # display usage banner
  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end

  # optional flag to show debug output
  opts.on("-v", "--verbose", "Run verbosely") do 
    options[:verbose] = true
  end

  # override default username, ARG is mandatory if switch is used
  opts.on("-u", "--username=NAME", "specify username to poll for public gists") do |u|
    options[:username] = u
  end

end.parse!

@verbose = options[:verbose]
username = options[:username].freeze

pp "Options: #{options}" if @verbose

# convenience method to return payload from GET request
def fetch_payload(url)
  puts "Connecting to #{url}..." if @verbose
  uri = URI(url)
  response = Net::HTTP.get_response(uri)

  case response
  when Net::HTTPSuccess then
    puts "Response class = #{response.class.name}" if @verbose
    puts "Received JSON payload:\n", response.body if @verbose
    response.body
  else
    puts "Error code: #{response.value}"
    exit
  end
end

# Attempt to populate an array of old gists, read from the user's state file
GISTS_FILE = "#{username}.json".freeze
old_gists = []
begin
  old = JSON.parse(File.read(GISTS_FILE))
  old.each do |gist|
    old_gists << { 'id' => gist['id'], 'updated_at' => gist['updated_at'] }
  end
  puts "Read in previously seen gists from file '#{GISTS_FILE}':\n", old_gists if @verbose
rescue Errno::ENOENT
  puts "File #{GISTS_FILE} not found. No gists seen before?"
end

# Now fetch current gists from GitHub API
gists_url = "#{GITHUB_API_STEM}/users/#{username}/gists"
json_payload = JSON.parse(fetch_payload(gists_url))
current_gists = []
json_payload.each do |gist|
  current_gists << { 'id' => gist['id'], 'updated_at' => gist['updated_at'] }
end
puts "Parsed CURRENT gists from API:\n", current_gists if @verbose

# diff the two, to find original or updated gists
puts 'Calculating difference between old and new:' if @verbose
new_gists = []
current_gists.each do |gist|
  if old_gists.include? gist
    puts "Discarded already known gist #{gist['id']}" if @verbose
  else
    puts "Found NEW gist #{gist['id']}"
    new_gists << gist
  end
end
puts "Sorry, no new gists from #{username}" if new_gists.empty?

# Write all gists back to the user's state file
File.open(GISTS_FILE, 'w') { |f| f.write(JSON.generate(current_gists)) }
