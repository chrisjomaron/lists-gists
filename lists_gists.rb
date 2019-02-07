#!/usr/bin/env ruby

# Simple; uses no extra gems
# Hard-coded to my user for now
# Treat updated gists as 'new'
# TODO: add option for username, trap non-existant user.
# TODO: tests

require 'net/https'
require 'json'
require 'optparse'
require 'pp'

GITHUB_API_STEM = 'https://api.github.com'.freeze

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: lists_gists.rb [options]"

  opts.on("-h", "--help", "Show this help message") do
    puts opts
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  options[:username] = 'chrisjomaron'
  opts.on("-u", "--username", "specify username to pollfor public gists") do |u|
    options[:username] = u
  end

end.parse!

pp options if options[:verbose]
pp ARGV if options[:verbose]
GISTS_FILE = "#{options[:username]}.json".freeze

def fetch(url)
  uri = URI(url)
  response = Net::HTTP.get_response(uri)

  case response
  when Net::HTTPSuccess then
    puts 'Response class = ' + response.class.name 
    response.body
  else
    response.value
  end
end

old_gists = []
begin
  old = JSON.parse(File.read(GISTS_FILE))
  old.each do |gist|
    old_gists << { 'id' => gist['id'], 'updated_at' => gist['updated_at'] }
  end
  puts "Read in OLD gists:\n", old_gists if options[:verbose]
rescue Errno::ENOENT
  puts "#{GISTS_FILE} not found. No gists seen before?"
end

json_payload = JSON.parse(fetch(GITHUB_API_STEM + '/users/chrisjomaron/gists'))
# puts current_json_payload

current_gists = []
json_payload.each do |gist|
  current_gists << { 'id' => gist['id'], 'updated_at' => gist['updated_at'] }
end
puts "Found CURRENT gists:\n", current_gists if options[:verbose]

puts 'calculating difference between lists:' if options[:verbose]
new_gists = []
current_gists.each do |gist|
  if old_gists.include? gist
    puts "discarded known gist #{gist['id']}" if options[:verbose]
  else
    puts "found NEW gist #{gist['id']}"
    new_gists << gist
  end
end

File.open(GISTS_FILE, 'w') { |f| f.write(JSON.generate(current_gists)) }
