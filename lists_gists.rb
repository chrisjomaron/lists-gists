#!/usr/bin/env ruby

# Simple; uses no extra gems
# Hard-coded to my user for now
# Treat updated gists as 'new'
# TODO: add option for username, trap non-existant user.
# TODO: tests

require 'net/https'
require 'json'
require 'getoptlong'
require 'pp'

GITHUB_API_STEM = 'https://api.github.com'.freeze

opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--verbose', '-v', GetoptLong::NO_ARGUMENT],
  ['--username', '-u', GetoptLong::REQUIRED_ARGUMENT]
)
# set a global so this can be accesssed inside the fetch method
@verbose = false
username = 'defunkt'

opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-END_HELP
  lists-gists [OPTIONS]

  -h, --help:
     show help

  --verbose, -v:
     show debug output

  --username [name]:
     username to  poll for public gists
END_HELP
  when '--verbose'
    @verbose = true
  when '--username'
    username = arg
  end
end

puts "Hello #{username}" if username

GISTS_FILE = "#{username}.json".freeze

def fetch(url)
  uri = URI(url)
  response = Net::HTTP.get_response(uri)

  case response
  when Net::HTTPSuccess then
    puts "Response class = #{response.class.name}" if @verbose
    response.body
  else
    "Error code: #{response.value}"
  end
end

old_gists = []
begin
  old = JSON.parse(File.read(GISTS_FILE))
  old.each do |gist|
    old_gists << { 'id' => gist['id'], 'updated_at' => gist['updated_at'] }
  end
  puts "Read in OLD gists:\n", old_gists if @verbose
rescue Errno::ENOENT
  puts "#{GISTS_FILE} not found. No gists seen before?"
end

gists_url = "#{GITHUB_API_STEM}/users/#{username}/gists"
json_payload = JSON.parse(fetch(gists_url))
puts json_payload if @verbose

current_gists = []
json_payload.each do |gist|
  current_gists << { 'id' => gist['id'], 'updated_at' => gist['updated_at'] }
end
puts "Found CURRENT gists:\n", current_gists if @verbose


puts 'calculating difference between lists:' if @verbose
new_gists = []
current_gists.each do |gist|
  if old_gists.include? gist
    puts "discarded known gist #{gist['id']}" if @verbose
  else
    puts "found NEW gist #{gist['id']}"
    new_gists << gist
  end
end
puts "Sorry, no new gists from #{username}" if new_gists.empty?

File.open(GISTS_FILE, 'w') { |f| f.write(JSON.generate(current_gists)) }
