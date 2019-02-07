#!/usr/bin/env ruby

# Simple; uses no extra gems
# Hard-coded to my user for now
# Treat updated gists as 'new'
# TODO: add option for username, trap non-existant user.
# TODO: tests

require 'net/https'
require 'json'

GISTS_FILE = 'gists.json'.freeze
GITHUB_API_STEM = 'https://api.github.com'.freeze

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
  puts 'Read in OLD gists:'
  puts old_gists
rescue Errno::ENOENT
  puts "#{GISTS_FILE} not found. No gists seen before?"
end

json_payload = JSON.parse(fetch(GITHUB_API_STEM + '/users/chrisjomaron/gists'))
# puts current_json_payload

current_gists = []
json_payload.each do |gist|
  current_gists << { 'id' => gist['id'], 'updated_at' => gist['updated_at'] }
end
puts 'Found CURRENT gists:'
puts current_gists

puts 'difference between lists:'
new_gists = []
current_gists.each do |gist|
  if old_gists.include? gist
    puts "discarded seen gist #{gist['id']}"
  else
    puts "found NEW gist #{gist['id']}"
    new_gists << gist
  end
end

File.open(GISTS_FILE, 'w') { |f| f.write(JSON.generate(current_gists)) }
